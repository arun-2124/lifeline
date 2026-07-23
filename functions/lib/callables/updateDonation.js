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
exports.updateDonation = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const v2_1 = require("firebase-functions/v2");
const donation_schemas_1 = require("../utils/donation_schemas");
const donation_helpers_1 = require("../utils/donation_helpers");
/**
 * HTTP Callable: updateDonation
 * Allows donors to edit draft or published donations.
 * Handles geohash reconciliation when location changes and statusLog appending.
 */
exports.updateDonation = (0, https_1.onCall)({ memory: '256MiB', enforceAppCheck: false }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required.');
    }
    const uid = request.auth.uid;
    const payload = request.data;
    // 1. Validate Input
    const parsed = donation_schemas_1.updateDonationSchema.safeParse(payload);
    if (!parsed.success) {
        throw new https_1.HttpsError('invalid-argument', parsed.error.errors[0]?.message ?? 'Invalid input.');
    }
    const { donationId, updates, isPublishing } = parsed.data;
    const db = admin.firestore();
    const donationRef = db.collection('donations').doc(donationId);
    await db.runTransaction(async (transaction) => {
        const snap = await transaction.get(donationRef);
        if (!snap.exists) {
            throw new https_1.HttpsError('not-found', 'Donation not found.');
        }
        const current = snap.data();
        // 2. Ownership check
        if (current.donorId !== uid) {
            throw new https_1.HttpsError('permission-denied', 'You do not own this donation.');
        }
        // 3. Status constraint — only editable in draft or published
        if (!['draft', 'published'].includes(current.status)) {
            throw new https_1.HttpsError('failed-precondition', `Donation cannot be edited in status: ${current.status}. Only draft or published donations are editable.`);
        }
        const nowIso = new Date().toISOString();
        const updatedFields = { updatedAt: nowIso };
        const loggedChanges = [];
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
        const locationChanged = updates.pickupAddress &&
            (updates.pickupAddress.lat !== current.pickupAddress?.lat ||
                updates.pickupAddress.lng !== current.pickupAddress?.lng);
        if (updates.pickupAddress) {
            const geohashes = (0, donation_helpers_1.computeGeohashes)(updates.pickupAddress.lat, updates.pickupAddress.lng);
            updatedFields['pickupAddress'] = { ...updates.pickupAddress, ...geohashes };
            loggedChanges.push('pickupAddress');
        }
        // 6. Draft → Published transition
        const isTransitioningToPublished = isPublishing && current.status === 'draft';
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
                    .doc(precision)
                    .collection('donations')
                    .doc(donationId);
                transaction.delete(oldIndexRef);
            }
        }
        if (isTransitioningToPublished || (locationChanged && current.status === 'published')) {
            const addressForHash = updates.pickupAddress ?? current.pickupAddress;
            const geohashes = (0, donation_helpers_1.computeGeohashes)(addressForHash.lat, addressForHash.lng);
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
    v2_1.logger.info('updateDonation: Donation updated successfully.', { donationId, uid });
    return { donationId, success: true };
});
//# sourceMappingURL=updateDonation.js.map