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
exports.handleUserDeleted = handleUserDeleted;
const admin = __importStar(require("firebase-admin"));
const v2_1 = require("firebase-functions/v2");
const constants_1 = require("../config/constants");
/**
 * Auth trigger fired on user deletion.
 * Implements GDPR-compliant scrubbing, revokes all session tokens, and creates an audit trail.
 */
async function handleUserDeleted(user) {
    const uid = user.uid;
    v2_1.logger.info('Handling onUserDeleted trigger for GDPR anonymization', { uid });
    const db = admin.firestore();
    const userRef = db.collection('users').doc(uid);
    const auditLogRef = db.collection('audit_logs').doc();
    const nowIso = new Date().toISOString();
    try {
        // 1. Revoke active refresh tokens / invalidate sessions
        await admin.auth().revokeRefreshTokens(uid);
        v2_1.logger.info('User refresh tokens successfully revoked', { uid });
        // 2. Perform GDPR document anonymization atomically in Firestore
        await db.runTransaction(async (transaction) => {
            const userSnap = await transaction.get(userRef);
            if (userSnap.exists) {
                transaction.update(userRef, {
                    email: `ANONYMIZED_${uid}@deleted.lifeline.internal`,
                    accountStatus: constants_1.ACCOUNT_STATUS.DELETED,
                    termsAccepted: false,
                    donorDetails: admin.firestore.FieldValue.delete(),
                    ngoDetails: admin.firestore.FieldValue.delete(),
                    recipientDetails: admin.firestore.FieldValue.delete(),
                    isAnonymized: true,
                    deletedAt: nowIso,
                    updatedAt: nowIso,
                });
            }
            transaction.set(auditLogRef, {
                event: 'USER_DELETED_GDPR_ANONYMIZED',
                uid,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });
        });
        v2_1.logger.info('GDPR Anonymization completed successfully for user', { uid });
    }
    catch (error) {
        v2_1.logger.error('Failed to complete onUserDeleted processing', { uid, error });
        throw error;
    }
}
//# sourceMappingURL=onUserDeleted.js.map