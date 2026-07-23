"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.createDonation = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const v2_1 = require("firebase-functions/v2");
const uuid_1 = require("uuid");
const donation_schemas_1 = require("../utils/donation_schemas");
const donation_helpers_1 = require("../utils/donation_helpers");
const rate_limiter_1 = require("../utils/rate_limiter");
const idempotency_1 = require("../utils/idempotency");
const DONATION_RATE_LIMIT_MAX = 10;
const DONATION_RATE_LIMIT_WINDOW_MS = 60 * 60 * 1000; // 1 hour
/**
 * HTTP Callable: createDonation
 * Validates, rate-limits, and atomically creates a new food donation.
 * Triggers async AI classification and matching pipelines (non-blocking).
 */
exports.createDonation = (0, https_1.onCall)({ memory: '256MiB', enforceAppCheck: false }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required.');
    }
    const uid = request.auth.uid;
    const tokenRole = request.auth.token.role;
    const tokenStatus = request.auth.token.accountStatus;
    // 1. Role check — must be an active DONOR
    if (tokenRole !== 'DONOR') {
        throw new https_1.HttpsError('permission-denied', 'Only verified donors can create donations.');
    }
    if (tokenStatus !== 'ACTIVE') {
        throw new https_1.HttpsError('failed-precondition', 'Your donor account must be ACTIVE to create donations.');
    }
    // 2. Rate Limiting
    await (0, rate_limiter_1.checkRateLimit)(`create_donation_${uid}`, DONATION_RATE_LIMIT_MAX, DONATION_RATE_LIMIT_WINDOW_MS);
    const payload = request.data;
    // 3. Schema Validation
    const parsed = donation_schemas_1.createDonationSchema.safeParse(payload);
    if (!parsed.success) {
        throw new https_1.HttpsError('invalid-argument', parsed.error.errors[0]?.message ?? 'Invalid input.');
    }
    const data = parsed.data;
    // 4. Idempotency Lock
    await (0, idempotency_1.verifyAndLockIdempotencyKey)(data.idempotencyKey, uid);
    // 5. Geohash Computation
    const geohashes = (0, donation_helpers_1.computeGeohashes)(data.pickupAddress.lat, data.pickupAddress.lng);
    // 6. Aggregates
    const totalQuantityKg = data.foodItems.reduce((sum, item) => sum + (0, donation_helpers_1.normalizeToKg)(item.quantity, item.unit), 0);
    const foodCategories = (0, donation_helpers_1.extractDistinctCategories)(data.foodItems);
    const dietaryTags = (0, donation_helpers_1.extractDietaryTags)(data.foodItems);
    const estimatedCo2SavedKg = (0, donation_helpers_1.computeTotalCo2)(data.foodItems);
    const expiresAt = (0, donation_helpers_1.computeExpiresAt)(data.pickupTimeWindow.latest);
    // 7. Build Firestore Document
    const donationId = (0, uuid_1.v4)();
    const nowIso = new Date().toISOString();
    const pickupAddress = {
        ...data.pickupAddress,
        ...geohashes,
    };
    const foodItems = data.foodItems.map((item) => ({
        ...item,
        itemId: (0, uuid_1.v4)(),
        photos: item.photos ?? [],
        originalPhotos: item.photos ?? [],
        aiClassification: { status: 'pending' },
    }));
    const status = data.isDraft ? 'draft' : 'published';
    const donation = {
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
    v2_1.logger.info('Donation created. Triggering async AI classification.', { donationId, uid });
    // In production: await pubSubClient.topic('ai-classify-donation').publishMessage({ json: { donationId } });
    v2_1.logger.info('createDonation: Donation successfully created.', { donationId, status });
    return { donationId, status, expiresAt };
});
//# sourceMappingURL=createDonation.js.map