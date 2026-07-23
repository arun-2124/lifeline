import * as admin from 'firebase-admin';
import { logger } from 'firebase-functions/v2';
import { UserRecord } from 'firebase-admin/auth';
import { ACCOUNT_STATUS } from '../config/constants';

/**
 * Auth trigger fired on user deletion.
 * Implements GDPR-compliant scrubbing, revokes all session tokens, and creates an audit trail.
 */
export async function handleUserDeleted(user: UserRecord): Promise<void> {
  const uid = user.uid;

  logger.info('Handling onUserDeleted trigger for GDPR anonymization', { uid });

  const db = admin.firestore();
  const userRef = db.collection('users').doc(uid);
  const auditLogRef = db.collection('audit_logs').doc();
  const nowIso = new Date().toISOString();

  try {
    // 1. Revoke active refresh tokens / invalidate sessions
    await admin.auth().revokeRefreshTokens(uid);
    logger.info('User refresh tokens successfully revoked', { uid });

    // 2. Perform GDPR document anonymization atomically in Firestore
    await db.runTransaction(async (transaction) => {
      const userSnap = await transaction.get(userRef);
      if (userSnap.exists) {
        transaction.update(userRef, {
          email: `ANONYMIZED_${uid}@deleted.lifeline.internal`,
          accountStatus: ACCOUNT_STATUS.DELETED,
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

    logger.info('GDPR Anonymization completed successfully for user', { uid });
  } catch (error) {
    logger.error('Failed to complete onUserDeleted processing', { uid, error });
    throw error;
  }
}
