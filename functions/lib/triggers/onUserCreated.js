"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.handleUserCreated = handleUserCreated;
const admin = __importStar(require("firebase-admin"));
const v2_1 = require("firebase-functions/v2");
const constants_1 = require("../config/constants");
const validation_1 = require("../utils/validation");
/**
 * Auth trigger fired on user creation.
 * Initializes Firestore document, sets default custom claims, and logs audit analytics.
 */
async function handleUserCreated(user) {
    const uid = user.uid;
    const email = user.email || '';
    v2_1.logger.info('Handling onUserCreated trigger for user', { uid, email });
    // 1. Email Domain Security Check
    const emailCheck = (0, validation_1.validateEmail)(email);
    if (!emailCheck.valid) {
        v2_1.logger.warn('User registered with prohibited email format or domain', { uid, email, reason: emailCheck.reason });
        // Disable user account automatically if disposable email detected
        await admin.auth().updateUser(uid, { disabled: true });
        v2_1.logger.info('User account disabled due to invalid email policy', { uid });
        return;
    }
    const db = admin.firestore();
    const userRef = db.collection('users').doc(uid);
    const auditLogRef = db.collection('audit_logs').doc();
    const nowIso = new Date().toISOString();
    const initialProfile = {
        uid,
        email,
        role: constants_1.ROLES.UNASSIGNED,
        accountStatus: constants_1.ACCOUNT_STATUS.PENDING_ONBOARDING,
        termsAccepted: false,
        createdAt: nowIso,
        updatedAt: nowIso,
    };
    const initialClaims = {
        role: constants_1.ROLES.UNASSIGNED,
        accountStatus: constants_1.ACCOUNT_STATUS.PENDING_ONBOARDING,
        termsAccepted: false,
    };
    try {
        // 2. Write to Firestore & Audit Log atomically
        await db.runTransaction(async (transaction) => {
            transaction.set(userRef, initialProfile);
            transaction.set(auditLogRef, {
                event: 'USER_CREATED',
                uid,
                email,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                metadata: { status: constants_1.ACCOUNT_STATUS.PENDING_ONBOARDING },
            });
        });
        // 3. Set Custom Claims via Firebase Admin SDK
        await admin.auth().setCustomUserClaims(uid, initialClaims);
        v2_1.logger.info('User document and custom claims successfully initialized', {
            uid,
            claims: initialClaims,
        });
    }
    catch (error) {
        v2_1.logger.error('Error during onUserCreated execution', { uid, error });
        throw error;
    }
}
//# sourceMappingURL=onUserCreated.js.map