import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { ROLES, ACCOUNT_STATUS, ROLE_CHANGE_COOLDOWN_MS, RATE_LIMIT_CONFIG } from '../config/constants';
import { checkRateLimit } from '../utils/rate_limiter';
import { CheckAccountStatusResponse, LifelineCustomClaims } from '../types/auth.types';

/**
 * Callable Cloud Function: checkAccountStatus
 * Inspects user state, detects token/firestore claims mismatches, syncs claims, and enforces onboarding rules.
 */
export const checkAccountStatus = onCall(
  {
    enforceAppCheck: false,
  },
  async (request): Promise<CheckAccountStatusResponse> => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required to check account status.');
    }

    const uid = request.auth.uid;
    const tokenClaims = request.auth.token;
    const ip = request.rawRequest.ip || '0.0.0.0';

    // Rate Limit Check
    await checkRateLimit(
      `check_status_${uid}_${ip}`,
      RATE_LIMIT_CONFIG.CHECK_STATUS_MAX_ATTEMPTS,
      RATE_LIMIT_CONFIG.CHECK_STATUS_WINDOW_MS
    );

    const db = admin.firestore();
    const userRef = db.collection('users').doc(uid);
    const userSnap = await userRef.get();

    if (!userSnap.exists) {
      throw new HttpsError('not-found', 'User profile doc does not exist.');
    }

    const userData = userSnap.data()!;
    const docRole = userData.role || ROLES.UNASSIGNED;
    const docStatus = userData.accountStatus || ACCOUNT_STATUS.PENDING_ONBOARDING;
    const docTermsAccepted = userData.termsAccepted || false;

    // Check Claims Sync Mismatch
    let claimsSynced = true;
    if (
      tokenClaims.role !== docRole ||
      tokenClaims.accountStatus !== docStatus ||
      tokenClaims.termsAccepted !== docTermsAccepted
    ) {
      claimsSynced = false;
      logger.info('Detected claims mismatch between Firestore doc and Auth Token. Syncing...', { uid });

      const updatedClaims: LifelineCustomClaims = {
        role: docRole,
        accountStatus: docStatus,
        termsAccepted: docTermsAccepted,
      };

      await admin.auth().setCustomUserClaims(uid, updatedClaims);
    }

    // Onboarding Requirement Check
    const requiresOnboarding =
      docRole === ROLES.UNASSIGNED || docStatus === ACCOUNT_STATUS.PENDING_ONBOARDING;

    // Calculate Cooldown Remaining
    let cooldownDaysRemaining = 0;
    if (userData.lastRoleChangeAt && docRole !== ROLES.UNASSIGNED) {
      const lastChangeTime = new Date(userData.lastRoleChangeAt).getTime();
      const elapsed = Date.now() - lastChangeTime;
      if (elapsed < ROLE_CHANGE_COOLDOWN_MS) {
        cooldownDaysRemaining = Math.ceil((ROLE_CHANGE_COOLDOWN_MS - elapsed) / (1000 * 60 * 60 * 24));
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
  }
);
