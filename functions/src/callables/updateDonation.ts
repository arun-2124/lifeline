import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { updateDonationSchema } from '../utils/donation_schemas';
import { computeGeohashes } from '../utils/donation_helpers';
import { UpdateDonationPayload } from '../types/donation.types';

/**
 * HTTP Callable: updateDonation
 * Allows donors to edit draft or published donations.
 * Handles geohash reconciliation when location changes and statusLog appending.
 */
export const updateDonation = onCall(
  { memory: '256MiB', enforceAppCheck: false },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const uid = request.auth.uid;
    const payload = request.data as UpdateDonationPayload;

    // 1. Validate Input
    const parsed = updateDonationSchema.safeParse(payload);
    if (!parsed.success) {
      throw new HttpsError('invalid-argument', parsed.error.errors[0]?.message ?? 'Invalid input.');
    }

    const { donationId, updates, isPublishing } = parsed.data;
    const db = admin.firestore();
    const donationRef = db.collection('donations').doc(donationId);

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

      // 3. Status constraint — only editable in draft or published
      if (!['draft', 'published'].includes(current.status)) {
        throw new HttpsError(
          'failed-precondition',
          `Donation cannot be edited in status: ${current.status}. Only draft or published donations are editable.`
        );
      }

      const nowIso = new Date().toISOString();
      const updatedFields: Record<string, unknown> = { updatedAt: nowIso };
      const loggedChanges: string[] = [];

      // 4. Apply allowed field updates
      if (updates.foodItems) {
        updatedFields['foodItems'] = updates.foodItems;
        loggedChanges.push('foodItems');
      }

      if (updates.pickupTimeWindow) {
        updatedFields['pickupTimeWindow'] = updates.pickupTimeWindow;
        loggedChanges.push('pickupTimeWindow');
      }

      if (updates.visibility) {
        updatedFields['visibility'] = updates.visibility;
        loggedChanges.push('visibility');
      }

      // 5. Location change: recompute geohashes + reconcile indexes
      const locationChanged =
        updates.pickupAddress &&
        (updates.pickupAddress.lat !== current.pickupAddress?.lat ||
          updates.pickupAddress.lng !== current.pickupAddress?.lng);

      if (updates.pickupAddress) {
        const geohashes = computeGeohashes(updates.pickupAddress.lat, updates.pickupAddress.lng);
        updatedFields['pickupAddress'] = { ...updates.pickupAddress, ...geohashes };
        loggedChanges.push('pickupAddress');
      }

      // 6. Draft → Published transition
      const isTransitioningToPublished =
        isPublishing && current.status === 'draft';

      if (isTransitioningToPublished) {
        updatedFields['status'] = 'published';
        updatedFields['publishedAt'] = nowIso;
        loggedChanges.push('status: draft → published');
      }

      transaction.update(donationRef, updatedFields);

      // 7. Geohash Index Reconciliation
      if ((locationChanged || isTransitioningToPublished) && current.status !== 'draft') {
        const oldGeohashes = [
          current.pickupAddress?.geohash4,
          current.pickupAddress?.geohash5,
          current.pickupAddress?.geohash6,
        ].filter(Boolean);

        // Delete old indexes
        for (const precision of oldGeohashes) {
          const oldIndexRef = db
            .collection('geohash_indexes')
            .doc(precision as string)
            .collection('donations')
            .doc(donationId);
          transaction.delete(oldIndexRef);
        }
      }

      if (isTransitioningToPublished || (locationChanged && current.status === 'published')) {
        const addressForHash = updates.pickupAddress ?? current.pickupAddress;
        const geohashes = computeGeohashes(addressForHash.lat, addressForHash.lng);

        const indexPayload = {
          donationId,
          donorId: uid,
          status: 'published',
          foodCategories: updates.foodItems
            ? [...new Set(updates.foodItems.map((i) => i.category))]
            : current.foodCategories,
          totalQuantityKg: current.totalQuantityKg,
          pickupTimeWindow: updates.pickupTimeWindow ?? current.pickupTimeWindow,
          lat: addressForHash.lat,
          lng: addressForHash.lng,
          geohash: geohashes.geohash,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          expiresAt: current.expiresAt,
          aiMatchScore: current.aiMatchScore ?? 0,
        };

        for (const precision of [geohashes.geohash4, geohashes.geohash5, geohashes.geohash6]) {
          const newIndexRef = db
            .collection('geohash_indexes')
            .doc(precision)
            .collection('donations')
            .doc(donationId);
          transaction.set(newIndexRef, indexPayload);
        }
      }

      // 8. Append to statusLog
      const logRef = donationRef.collection('statusLog').doc();
      transaction.set(logRef, {
        status: updatedFields['status'] ?? current.status,
        previousStatus: current.status,
        changedBy: uid,
        changedAt: admin.firestore.FieldValue.serverTimestamp(),
        reason: 'donor_update',
        metadata: { updatedFields: loggedChanges },
      });
    });

    logger.info('updateDonation: Donation updated successfully.', { donationId, uid });

    return { donationId, success: true };
  }
);
