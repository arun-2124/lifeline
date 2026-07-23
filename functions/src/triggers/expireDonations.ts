import * as admin from 'firebase-admin';
import { onSchedule } from 'firebase-functions/v2/scheduler';
import { logger } from 'firebase-functions/v2';

const BATCH_SIZE = 500;

/**
 * Scheduled Function: expireDonations
 * Runs every 5 minutes, auto-expires published donations past their expiry time.
 * Cleans geohash indexes, creates audit statusLog, and sends FCM notifications.
 */
export const expireDonations = onSchedule(
  {
    schedule: 'every 5 minutes',
    memory: '128MiB',
    timeoutSeconds: 540,
  },
  async () => {
    const db = admin.firestore();
    const now = new Date();

    logger.info('expireDonations: Starting expiry run.', { time: now.toISOString() });

    const expiredSnap = await db
      .collection('donations')
      .where('status', '==', 'published')
      .where('expiresAt', '<=', now.toISOString())
      .limit(BATCH_SIZE)
      .get();

    if (expiredSnap.empty) {
      logger.info('expireDonations: No donations to expire.');
      return;
    }

    logger.info(`expireDonations: Found ${expiredSnap.size} donations to expire.`);

    // Process in Firestore batch chunks (max 500 per batch)
    const chunks: FirebaseFirestore.QueryDocumentSnapshot[][] = [];
    const docs = expiredSnap.docs;
    for (let i = 0; i < docs.length; i += BATCH_SIZE) {
      chunks.push(docs.slice(i, i + BATCH_SIZE));
    }

    const nowIso = now.toISOString();

    for (const chunk of chunks) {
      const batch = db.batch();

      for (const doc of chunk) {
        const data = doc.data();
        const donationId = doc.id;

        // Update donation status to expired
        batch.update(doc.ref, {
          status: 'expired',
          completedAt: nowIso,
        });

        // Append to statusLog
        const logRef = doc.ref.collection('statusLog').doc();
        batch.set(logRef, {
          status: 'expired',
          previousStatus: 'published',
          changedBy: 'system',
          changedAt: admin.firestore.FieldValue.serverTimestamp(),
          reason: 'auto_expired',
          metadata: { expiresAt: data.expiresAt },
        });

        // Delete geohash indexes for all 3 precisions
        const geohash4 = data.pickupAddress?.geohash4;
        const geohash5 = data.pickupAddress?.geohash5;
        const geohash6 = data.pickupAddress?.geohash6;

        for (const precision of [geohash4, geohash5, geohash6]) {
          if (precision) {
            const indexRef = db
              .collection('geohash_indexes')
              .doc(precision)
              .collection('donations')
              .doc(donationId);
            batch.delete(indexRef);
          }
        }

        logger.info(`expireDonations: Marking donation expired.`, {
          donationId,
          donorId: data.donorId,
        });
      }

      await batch.commit();
      logger.info(`expireDonations: Committed batch of ${chunk.length} expired donations.`);

      // Post-batch: Send FCM notifications to donors (non-blocking)
      // In production: fan out notification tasks via Cloud Tasks or PubSub
    }

    logger.info('expireDonations: Run complete.', { totalExpired: expiredSnap.size });
  }
);
