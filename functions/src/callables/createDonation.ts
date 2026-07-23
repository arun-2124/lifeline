import * as admin from 'firebase-admin';
import { onCall, HttpsError } from 'firebase-functions/v2/https';
import { logger } from 'firebase-functions/v2';
import { v4 as uuidv4 } from 'uuid';
import {
  CreateDonationPayload,
  DonationDocument,
  FoodItemDocument,
  PickupAddress,
} from '../types/donation.types';
import { createDonationSchema } from '../utils/donation_schemas';
import {
  computeGeohashes,
  computeTotalCo2,
  computeExpiresAt,
  extractDistinctCategories,
  extractDietaryTags,
  normalizeToKg,
} from '../utils/donation_helpers';
import { checkRateLimit } from '../utils/rate_limiter';
import { verifyAndLockIdempotencyKey } from '../utils/idempotency';

const DONATION_RATE_LIMIT_MAX = 10;
const DONATION_RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000; // 1 hour

/**
 * HTTP Callable: createDonation
 * Validates, rate-limits, and atomically creates a new food donation.
 * Triggers async AI classification and matching pipelines (non-blocking).
 */
export const createDonation = onCall(
  { memory: '256MiB', enforceAppCheck: false },
  async (request) => {
    if (!request.auth) {
      throw new HttpsError('unauthenticated', 'Authentication required.');
    }

    const uid = request.auth.uid;
    const tokenRole = request.auth.token.role;
    const tokenStatus = request.auth.token.accountStatus;

    // 1. Role check — must be an active DONOR
    if (tokenRole !== 'DONOR') {
      throw new HttpsError('permission-denied', 'Only verified donors can create donations.');
    }
    if (tokenStatus !== 'ACTIVE') {
      throw new HttpsError('failed-precondition', 'Your donor account must be ACTIVE to create donations.');
    }

    // 2. Rate Limiting
    await checkRateLimit(
      `create_donation_${uid}`,
      DONATION_RATE_LIMIT_MAX,
      DONATION_RATE_LIMIT_WINDOW_MS
    );

    const payload = request.data as CreateDonationPayload;

    // 3. Schema Validation
    const parsed = createDonationSchema.safeParse(payload);
    if (!parsed.success) {
      throw new HttpsError('invalid-argument', parsed.error.errors[0]?.message ?? 'Invalid input.');
    }

    const data = parsed.data;

    // 4. Idempotency Lock
    await verifyAndLockIdempotencyKey(data.idempotencyKey, uid);

    // 5. Geohash Computation
    const geohashes = computeGeohashes(data.pickupAddress.lat, data.pickupAddress.lng);

    // 6. Aggregates
    const totalQuantityKg = data.foodItems.reduce(
      (sum, item) => sum + normalizeToKg(item.quantity, item.unit), 0
    );
    const foodCategories = extractDistinctCategories(data.foodItems);
    const dietaryTags = extractDietaryTags(data.foodItems);
    const estimatedCo2SavedKg = computeTotalCo2(data.foodItems);
    const expiresAt = computeExpiresAt(data.pickupTimeWindow.latest);

    // 7. Build Firestore Document
    const donationId = uuidv4();
    const nowIso = new Date().toISOString();

    const pickupAddress: PickupAddress = {
      ...data.pickupAddress,
      ...geohashes,
    };

    const foodItems: FoodItemDocument[] = data.foodItems.map((item) => ({
      ...item,
      itemId: uuidv4(),
      photos: item.photos ?? [],
      originalPhotos: item.photos ?? [],
      aiClassification: { status: 'pending' },
    }));

    const status = data.isDraft ? 'draft' : 'published';

    const donation: DonationDocument = {
      donationId,
      donorId: uid,
      donorOrgName: request.auth.token.organizationName ?? '',
      foodItems,
      totalQuantityKg: parseFloat(totalQuantityKg.toFixed(3)),
      totalEstimatedServings: 0, // Backfilled by AI
      foodCategories,
      dietaryTags,
      pickupAddress,
      pickupTimeWindow: data.pickupTimeWindow,
      status,
      visibility: data.visibility,
      estimatedCo2SavedKg,
      actualCo2SavedKg: 0,
      createdAt: nowIso,
      publishedAt: status === 'published' ? nowIso : undefined,
      expiresAt,
      source: 'app',
      version: 2,
      isDeleted: false,
    };

    const db = admin.firestore();
    const donationRef = db.collection('donations').doc(donationId);
    const statusLogRef = donationRef.collection('statusLog').doc();
    const userDonationRef = db.collection('users').doc(uid)
      .collection('donations').doc(donationId);

    // 8. Atomic Transaction Write
    await db.runTransaction(async (transaction) => {
      transaction.set(donationRef, donation);

      // StatusLog entry
      transaction.set(statusLogRef, {
        status,
        previousStatus: null,
        changedBy: uid,
        changedAt: admin.firestore.FieldValue.serverTimestamp(),
        reason: data.isDraft ? 'draft_created' : 'published',
        metadata: { source: 'createDonation_cf' },
      });

      // User reference document
      transaction.set(userDonationRef, {
        donationId,
        status,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // Geohash index documents (only for published donations)
      if (!data.isDraft) {
        const geohashIndexPayload = {
          donationId,
          donorId: uid,
          status: 'published',
          foodCategories,
          dietaryTags,
          totalQuantityKg: donation.totalQuantityKg,
          pickupTimeWindow: {
            earliest: data.pickupTimeWindow.earliest,
            latest: data.pickupTimeWindow.latest,
          },
          lat: data.pickupAddress.lat,
          lng: data.pickupAddress.lng,
          geohash: geohashes.geohash,
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          expiresAt,
          aiMatchScore: 0,
        };

        for (const precision of [geohashes.geohash4, geohashes.geohash5, geohashes.geohash6]) {
          const indexRef = db
            .collection('geohash_indexes')
            .doc(precision)
            .collection('donations')
            .doc(donationId);
          transaction.set(indexRef, geohashIndexPayload);
        }
      }
    });

    // 9. Async AI Classification Trigger (non-blocking PubSub stub)
    logger.info('Donation created. Triggering async AI classification.', { donationId, uid });
    // In production: await pubSubClient.topic('ai-classify-donation').publishMessage({ json: { donationId } });

    logger.info('createDonation: Donation successfully created.', { donationId, status });

    return { donationId, status, expiresAt };
  }
);
