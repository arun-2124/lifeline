import * as admin from 'firebase-admin';
import { HttpsError } from 'firebase-functions/v2/https';

export async function checkRateLimit(
  key: string,
  maxAttempts: number,
  windowMs: number
): Promise<void> {
  const db = admin.firestore();
  const rateLimitRef = db.collection('rate_limits').doc(key);
  const now = Date.now();

  await db.runTransaction(async (transaction) => {
    const doc = await transaction.get(rateLimitRef);

    if (!doc.exists) {
      transaction.set(rateLimitRef, {
        count: 1,
        resetAt: now + windowMs,
      });
      return;
    }

    const data = doc.data()!;
    if (now > data.resetAt) {
      // Window expired, reset counter
      transaction.set(rateLimitRef, {
        count: 1,
        resetAt: now + windowMs,
      });
    } else {
      if (data.count >= maxAttempts) {
        throw new HttpsError(
          'resource-exhausted',
          `Rate limit exceeded for action (${key}). Please try again later.`
        );
      }
      transaction.update(rateLimitRef, {
        count: admin.firestore.FieldValue.increment(1),
      });
    }
  });
}
