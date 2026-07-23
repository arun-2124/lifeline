import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';

export async function verifyAndLockIdempotencyKey(
  key: string,
  uid: string
): Promise<void> {
  if (!key || key.trim().length === 0) {
    throw new HttpsError('invalid-argument', 'Idempotency-Key header or field is required.');
  }

  const db = admin.firestore();
  const idempotencyRef = db.collection('idempotency_keys').doc(`${uid}_${key}`);

  await db.runTransaction(async (transaction) => {
    const doc = await transaction.get(idempotencyRef);
    if (doc.exists) {
      throw new HttpsError(
        'already-exists',
        'Duplicate request detected. This operation has already been processed.'
      );
    }
    transaction.set(idempotencyRef, {
      uid,
      key,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });
  });
}
