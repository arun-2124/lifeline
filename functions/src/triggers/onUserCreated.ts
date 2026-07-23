import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v2';
import { UserRecord } from 'firebase-admin/auth';
import { ROLES, ACCOUNT_STATUS } from '../config/constants';
import { validateEmail } from '../utils/validation';
import { LifelineCustomClaims, UserProfileDocument } from '../types/auth.types';

/**
 * Auth trigger fired on user creation.
 * Initializes Firestore document, sets default custom claims, and logs audit analytics.
 */
export async function handleUserCreated(user: UserRecord): Promise<void> {
  const uid = user.uid;
  const email = user.email || '';

  logger.info('Handling onUserCreated trigger for user', { uid, email });

  // 1. Email Domain Security Check
  const emailCheck = validateEmail(email);
  if (!emailCheck.valid) {
    logger.warn('User registered with prohibited email format or domain', { uid, email, reason: emailCheck.reason });
    // Disable user account automatically if disposable email detected
    await admin.auth().updateUser(uid, { disabled: true });
    logger.info('User account disabled due to invalid email policy', { uid });
    return;
  }

  const db = admin.firestore();
  const userRef = db.collection('users').doc(uid);
  const auditLogRef = db.collection('audit_logs').doc();

  const nowIso = new Date().toISOString();

  const initialProfile: UserProfileDocument = {
    uid,
    email,
    role: ROLES.UNASSIGNED,
    accountStatus: ACCOUNT_STATUS.PENDING_ONBOARDING,
    termsAccepted: false,
    createdAt: nowIso,
    updatedAt: nowIso,
  };

  const initialClaims: LifelineCustomClaims = {
    role: ROLES.UNASSIGNED,
    accountStatus: ACCOUNT_STATUS.PENDING_ONBOARDING,
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
        metadata: { status: ACCOUNT_STATUS.PENDING_ONBOARDING },
      });
    });

    // 3. Set Custom Claims via Firebase Admin SDK
    await admin.auth().setCustomUserClaims(uid, initialClaims);

    logger.info('User document and custom claims successfully initialized', {
      uid,
      claims: initialClaims,
    });
  } catch (error) {
    logger.error('Error during onUserCreated execution', { uid, error });
    throw error;
  }
}
