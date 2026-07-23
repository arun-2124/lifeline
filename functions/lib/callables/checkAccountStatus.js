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
exports.checkAccountStatus = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const v2_1 = require("firebase-functions/v2");
const constants_1 = require("../config/constants");
const rate_limiter_1 = require("../utils/rate_limiter");
/**
 * Callable Cloud Function: checkAccountStatus
 * Inspects user state, detects token/firestore claims mismatches, syncs claims, and enforces onboarding rules.
 */
exports.checkAccountStatus = (0, https_1.onCall)({
    enforceAppCheck: false,
}, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required to check account status.');
    }
    const uid = request.auth.uid;
    const tokenClaims = request.auth.token;
    const ip = request.rawRequest.ip || '0.0.0.0';
    // Rate Limit Check
    await (0, rate_limiter_1.checkRateLimit)(`check_status_${uid}_${ip}`, constants_1.RATE_LIMIT_CONFIG.CHECK_STATUS_MAX_ATTEMPTS, constants_1.RATE_LIMIT_CONFIG.CHECK_STATUS_WINDOW_MS);
    const db = admin.firestore();
    const userRef = db.collection('users').doc(uid);
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
        throw new https_1.HttpsError('not-found', 'User profile doc does not exist.');
    }
    const userData = userSnap.data();
    const docRole = userData.role || constants_1.ROLES.UNASSIGNED;
    const docStatus = userData.accountStatus || constants_1.ACCOUNT_STATUS.PENDING_ONBOARDING;
    const docTermsAccepted = userData.termsAccepted || false;
    // Check Claims Sync Mismatch
    let claimsSynced = true;
    if (tokenClaims.role !== docRole ||
        tokenClaims.accountStatus !== docStatus ||
        tokenClaims.termsAccepted !== docTermsAccepted) {
        claimsSynced = false;
        v2_1.logger.info('Detected claims mismatch between Firestore doc and Auth Token. Syncing...', { uid });
        const updatedClaims = {
            role: docRole,
            accountStatus: docStatus,
            termsAccepted: docTermsAccepted,
        };
        await admin.auth().setCustomUserClaims(uid, updatedClaims);
    }
    // Onboarding Requirement Check
    const requiresOnboarding = docRole === constants_1.ROLES.UNASSIGNED || docStatus === constants_1.ACCOUNT_STATUS.PENDING_ONBOARDING;
    // Calculate Cooldown Remaining
    let cooldownDaysRemaining = 0;
    if (userData.lastRoleChangeAt && docRole !== constants_1.ROLES.UNASSIGNED) {
        const lastChangeTime = new Date(userData.lastRoleChangeAt).getTime();
        const elapsed = Date.now() - lastChangeTime;
        if (elapsed < constants_1.ROLE_CHANGE_COOLDOWN_MS) {
            cooldownDaysRemaining = Math.ceil((constants_1.ROLE_CHANGE_COOLDOWN_MS - elapsed) / (1000 * 60 * 60 * 24));
        }
    }
    return {
        uid,
        email: userData.email || '',
        role: docRole,
        accountStatus: docStatus,
        claimsSynced,
        requiresOnboarding,
        cooldownDaysRemaining,
    };
});
//# sourceMappingURL=checkAccountStatus.js.map