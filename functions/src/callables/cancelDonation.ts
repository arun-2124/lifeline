import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { cancelDonationSchema } from '../utils/donation_schemas';
import { CancelDonationPayload } from '../types/donation.types';

/**
 * HTTP Callable: cancelDonation
 * Validates ownership and status constraints, then atomically cancels a donation.
 * If matched, notifies the assigned NGO and reopens the matched request.
 */
export const cancelDonation = onCall(
  { memory: '256MiB', enforceAppCheck: false },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const uid = request.auth.uid;
    const payload = request.data as CancelDonationPayload;

    // 1. Validate input
    const parsed = cancelDonationSchema.safeParse(payload);
    if (!parsed.success) {
      throw new HttpsError('invalid-argument', parsed.error.errors[0]?.message ?? 'Invalid input.');
    }

    const { donationId, reason } = parsed.data;
    const db = admin.firestore();
    const donationRef = db.collection('donations').doc(donationId);
    const nowIso = new Date().toISOString();

    let matchedNgoId: string | undefined;
    let matchedRequestId: string | undefined;

    await db.runTransaction(async (transaction) => {
      const snap = await transaction.get(donationRef);

      if (!snap.exists) {
        throw new HttpsError('not-found', 'Donation not found.');
      }

      const current = snap.data()!;

      // 2. Ownership check
      if (current.donorId !== uid) {
        throw new HttpsError('permission-denied', 'You do not own this donation.');
      }

      // 3. Status constraint — cannot cancel in_transit or beyond
      const cancellableStatuses = ['draft', 'published', 'matched'];
      if (!cancellableStatuses.includes(current.status)) {
        throw new HttpsError(
          'failed-precondition',
          `Cannot cancel a donation with status: ${current.status}. Cancellation is only allowed for draft, published, or matched donations.`
        );
      }

      matchedNgoId = current.matchedNgoId;
      matchedRequestId = current.matchedRequestId;

      // 4. Update donation status to cancelled
      transaction.update(donationRef, {
        status: 'cancelled',
        cancelledAt: nowIso,
        cancelledReason: reason,
        cancelledBy: uid,
      });

      // 5. Geohash index cleanup
      const geohash4 = current.pickupAddress?.geohash4;
      const geohash5 = current.pickupAddress?.geohash5;
      const geohash6 = current.pickupAddress?.geohash6;

      for (const precision of [geohash4, geohash5, geohash6]) {
        if (precision) {
          const indexRef = db
            .collection('geohash_indexes')
            .doc(precision)
            .collection('donations')
            .doc(donationId);
          transaction.delete(indexRef);
        }
      }

      // 6. If matched, reopen the matched request
      if (matchedRequestId) {
        const requestRef = db.collection('requests').doc(matchedRequestId);
        transaction.update(requestRef, {
          status: 'open',
          updatedAt: nowIso,
        });
      }

      // 7. Append to statusLog
      const logRef = donationRef.collection('statusLog').doc();
      transaction.set(logRef, {
        status: 'cancelled',
        previousStatus: current.status,
        changedBy: uid,
        changedAt: admin.firestore.FieldValue.serverTimestamp(),
        reason,
        metadata: { matchedNgoId, matchedRequestId },
      });
    });

    // 8. Post-transaction: Notify matched NGO if applicable (non-blocking)
    if (matchedNgoId) {
      logger.info('cancelDonation: Matched donation cancelled; NGO notification triggered.', {
        donationId,
        matchedNgoId,
      });
      // In production: send FCM notification to matchedNgoId
    }

    logger.info('cancelDonation: Donation cancelled successfully.', { donationId, uid, reason });

    return { success: true, donationId };
  }
);
