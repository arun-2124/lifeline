import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import {
  ROLES,
  ACCOUNT_STATUS,
  ROLE_CHANGE_COOLDOWN_MS,
  RATE_LIMIT_CONFIG,
  UserRole,
  AccountStatus,
} from '../config/constants';
import {
  donorProfileSchema,
  ngoProfileSchema,
  recipientProfileSchema,
} from '../utils/validation';
import { checkRateLimit } from '../utils/rate_limiter';
import { verifyAndLockIdempotencyKey } from '../utils/idempotency';
import { LifelineCustomClaims, ValidateProfilePayload } from '../types/auth.types';

/**
 * Callable Cloud Function: validateProfile
 * Validates role-specific profiles, enforces terms acceptance, 30-day cooldown, rate limits, and updates custom claims atomically.
 */
export const validateProfile = onCall(
  {
    enforceAppCheck: false, // Set to true when Firebase App Check keys are deployed in production
  },
  async (request) => {
    // 1. Auth Enforcement
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'User must be authenticated to validate profile.');
    }

    const uid = request.auth.uid;
    const ip = request.rawRequest.ip || '0.0.0.0';

    // 2. Rate Limiting Check
    await checkRateLimit(
      `validate_profile_${uid}_${ip}`,
      RATE_LIMIT_CONFIG.VALIDATE_PROFILE_MAX_ATTEMPTS,
      RATE_LIMIT_CONFIG.VALIDATE_PROFILE_WINDOW_MS
    );

    const payload = request.data as ValidateProfilePayload;

    // 3. Idempotency Key Lock
    await verifyAndLockIdempotencyKey(payload.idempotencyKey, uid);

    // 4. Terms Acceptance Enforcement
    if (!payload.termsAccepted) {
      throw new HttpsError('failed-precondition', 'You must accept the Terms of Service to proceed.');
    }

    // 5. Target Role Validation
    const requestedRole: UserRole = payload.role;
    const validTargetRoles: UserRole[] = [ROLES.DONOR, ROLES.NGO, ROLES.RECIPIENT];
    if (!validTargetRoles.includes(requestedRole)) {
      throw new HttpsError('invalid-argument', `Invalid role specified: ${requestedRole}`);
    }
    const targetRole = requestedRole as typeof ROLES.DONOR | typeof ROLES.NGO | typeof ROLES.RECIPIENT;

    const db = admin.firestore();
    const userRef = db.collection('users').doc(uid);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      throw new HttpsError('not-found', 'User profile document not found.');
    }

    const userData = userSnap.data()!;

    // 6. 30-Day Role Change Cooldown Check
    if (userData.role && userData.role !== ROLES.UNASSIGNED && userData.lastRoleChangeAt) {
      const lastChange = new Date(userData.lastRoleChangeAt).getTime();
      const now = Date.now();
      if (now - lastChange < ROLE_CHANGE_COOLDOWN_MS) {
        const daysLeft = Math.ceil((ROLE_CHANGE_COOLDOWN_MS - (now - lastChange)) / (1000 * 60 * 60 * 24));
        throw new HttpsError(
          'failed-precondition',
          `Role changes are locked for a 30-day cooldown period. Please wait ${daysLeft} more day(s).`
        );
      }
    }

    // 7. Role-Specific Profile Schema Validation
    let validatedDetails: Record<string, any> = {};
    let newStatus: AccountStatus = ACCOUNT_STATUS.ACTIVE;

    if (targetRole === ROLES.DONOR) {
      if (!payload.donorDetails) {
        throw new HttpsError('invalid-argument', 'Donor profile details are required.');
      }
      const result = donorProfileSchema.safeParse(payload.donorDetails);
      if (!result.success) {
        throw new HttpsError('invalid-argument', `Validation failed: ${result.error.message}`);
      }
      validatedDetails = { donorDetails: result.data };
      newStatus = ACCOUNT_STATUS.ACTIVE;
    } else if (targetRole === ROLES.NGO) {
      if (!payload.ngoDetails) {
        throw new HttpsError('invalid-argument', 'NGO profile details are required.');
      }
      const result = ngoProfileSchema.safeParse(payload.ngoDetails);
      if (!result.success) {
        throw new HttpsError('invalid-argument', `Validation failed: ${result.error.message}`);
      }
      validatedDetails = { ngoDetails: result.data };
      // NGOs require admin verification
      newStatus = ACCOUNT_STATUS.PENDING_VERIFICATION;
    } else if (targetRole === ROLES.RECIPIENT) {
      if (!payload.recipientDetails) {
        throw new HttpsError('invalid-argument', 'Recipient profile details are required.');
      }
      const result = recipientProfileSchema.safeParse(payload.recipientDetails);
      if (!result.success) {
        throw new HttpsError('invalid-argument', `Validation failed: ${result.error.message}`);
      }
      validatedDetails = { recipientDetails: result.data };
      newStatus = ACCOUNT_STATUS.ACTIVE;
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

    const newClaims: LifelineCustomClaims = {
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

      logger.info('Profile validated and role assigned successfully', { uid, role: requestedRole, newStatus });

      return {
        success: true,
        role: requestedRole,
        accountStatus: newStatus,
        requireTokenRefresh: true, // Forces client to refresh ID token
      };
    } catch (error) {
      logger.error('Failed to commit validateProfile transaction', { uid, error });
      throw new HttpsError('internal', 'Internal error while processing profile validation.');
    }
  }
);
