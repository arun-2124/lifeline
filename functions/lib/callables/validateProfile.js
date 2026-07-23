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
exports.validateProfile = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const v2_1 = require("firebase-functions/v2");
const constants_1 = require("../config/constants");
const validation_1 = require("../utils/validation");
const rate_limiter_1 = require("../utils/rate_limiter");
const idempotency_1 = require("../utils/idempotency");
/**
 * Callable Cloud Function: validateProfile
 * Validates role-specific profiles, enforces terms acceptance, 30-day cooldown, rate limits, and updates custom claims atomically.
 */
exports.validateProfile = (0, https_1.onCall)({
    enforceAppCheck: false, // Set to true when Firebase App Check keys are deployed in production
}, async (request) => {
    // 1. Auth Enforcement
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'User must be authenticated to validate profile.');
    }
    const uid = request.auth.uid;
    const ip = request.rawRequest.ip || '0.0.0.0';
    // 2. Rate Limiting Check
    await (0, rate_limiter_1.checkRateLimit)(`validate_profile_${uid}_${ip}`, constants_1.RATE_LIMIT_CONFIG.VALIDATE_PROFILE_MAX_ATTEMPTS, constants_1.RATE_LIMIT_CONFIG.VALIDATE_PROFILE_WINDOW_MS);
    const payload = request.data;
    // 3. Idempotency Key Lock
    await (0, idempotency_1.verifyAndLockIdempotencyKey)(payload.idempotencyKey, uid);
    // 4. Terms Acceptance Enforcement
    if (!payload.termsAccepted) {
        throw new https_1.HttpsError('failed-precondition', 'You must accept the Terms of Service to proceed.');
    }
    // 5. Target Role Validation
    const requestedRole = payload.role;
    const validTargetRoles = [constants_1.ROLES.DONOR, constants_1.ROLES.NGO, constants_1.ROLES.RECIPIENT];
    if (!validTargetRoles.includes(requestedRole)) {
        throw new https_1.HttpsError('invalid-argument', `Invalid role specified: ${requestedRole}`);
    }
    const targetRole = requestedRole;
    const db = admin.firestore();
    const userRef = db.collection('users').doc(uid);
    const userSnap = await userRef.get();
    if (!userSnap.exists) {
        throw new https_1.HttpsError('not-found', 'User profile document not found.');
    }
    const userData = userSnap.data();
    // 6. 30-Day Role Change Cooldown Check
    if (userData.role && userData.role !== constants_1.ROLES.UNASSIGNED && userData.lastRoleChangeAt) {
        const lastChange = new Date(userData.lastRoleChangeAt).getTime();
        const now = Date.now();
        if (now - lastChange < constants_1.ROLE_CHANGE_COOLDOWN_MS) {
            const daysLeft = Math.ceil((constants_1.ROLE_CHANGE_COOLDOWN_MS - (now - lastChange)) / (1000 * 60 * 60 * 24));
            throw new https_1.HttpsError('failed-precondition', `Role changes are locked for a 30-day cooldown period. Please wait ${daysLeft} more day(s).`);
        }
    }
    // 7. Role-Specific Profile Schema Validation
    let validatedDetails = {};
    let newStatus = constants_1.ACCOUNT_STATUS.ACTIVE;
    if (targetRole === constants_1.ROLES.DONOR) {
        if (!payload.donorDetails) {
            throw new https_1.HttpsError('invalid-argument', 'Donor profile details are required.');
        }
        const result = validation_1.donorProfileSchema.safeParse(payload.donorDetails);
        if (!result.success) {
            throw new https_1.HttpsError('invalid-argument', `Validation failed: ${result.error.message}`);
        }
        validatedDetails = { donorDetails: result.data };
        newStatus = constants_1.ACCOUNT_STATUS.ACTIVE;
    }
    else if (targetRole === constants_1.ROLES.NGO) {
        if (!payload.ngoDetails) {
            throw new https_1.HttpsError('invalid-argument', 'NGO profile details are required.');
        }
        const result = validation_1.ngoProfileSchema.safeParse(payload.ngoDetails);
        if (!result.success) {
            throw new https_1.HttpsError('invalid-argument', `Validation failed: ${result.error.message}`);
        }
        validatedDetails = { ngoDetails: result.data };
        // NGOs require admin verification
        newStatus = constants_1.ACCOUNT_STATUS.PENDING_VERIFICATION;
    }
    else if (targetRole === constants_1.ROLES.RECIPIENT) {
        if (!payload.recipientDetails) {
            throw new https_1.HttpsError('invalid-argument', 'Recipient profile details are required.');
        }
        const result = validation_1.recipientProfileSchema.safeParse(payload.recipientDetails);
        if (!result.success) {
            throw new https_1.HttpsError('invalid-argument', `Validation failed: ${result.error.message}`);
        }
        validatedDetails = { recipientDetails: result.data };
        newStatus = constants_1.ACCOUNT_STATUS.ACTIVE;
    }
    const nowIso = new Date().toISOString();
    const updatedProfile = {
        role: requestedRole,
        accountStatus: newStatus,
        termsAccepted: true,
        termsAcceptedAt: userData.termsAcceptedAt || nowIso,
        lastRoleChangeAt: nowIso,
        updatedAt: nowIso,
        ...validatedDetails,
    };
    const newClaims = {
        role: requestedRole,
        accountStatus: newStatus,
        termsAccepted: true,
        lastRoleChangeTimestamp: Date.now(),
    };
    // 8. Atomic Transaction & Claims Update
    try {
        await db.runTransaction(async (transaction) => {
            transaction.update(userRef, updatedProfile);
            const auditRef = db.collection('audit_logs').doc();
            transaction.set(auditRef, {
                event: 'PROFILE_VALIDATED_ROLE_ASSIGNED',
                uid,
                role: requestedRole,
                accountStatus: newStatus,
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
            });
        });
        // Update Custom Claims
        await admin.auth().setCustomUserClaims(uid, newClaims);
        v2_1.logger.info('Profile validated and role assigned successfully', { uid, role: requestedRole, newStatus });
        return {
            success: true,
            role: requestedRole,
            accountStatus: newStatus,
            requireTokenRefresh: true, // Forces client to refresh ID token
        };
    }
    catch (error) {
        v2_1.logger.error('Failed to commit validateProfile transaction', { uid, error });
        throw new https_1.HttpsError('internal', 'Internal error while processing profile validation.');
    }
});
//# sourceMappingURL=validateProfile.js.map