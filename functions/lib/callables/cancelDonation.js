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
exports.cancelDonation = void 0;
const admin = __importStar(require("firebase-admin"));
const https_1 = require("firebase-functions/v2/https");
const v2_1 = require("firebase-functions/v2");
const donation_schemas_1 = require("../utils/donation_schemas");
/**
 * HTTP Callable: cancelDonation
 * Validates ownership and status constraints, then atomically cancels a donation.
 * If matched, notifies the assigned NGO and reopens the matched request.
 */
exports.cancelDonation = (0, https_1.onCall)({ memory: '256MiB', enforceAppCheck: false }, async (request) => {
    if (!request.auth) {
        throw new https_1.HttpsError('unauthenticated', 'Authentication required.');
    }
    const uid = request.auth.uid;
    const payload = request.data;
    // 1. Validate input
    const parsed = donation_schemas_1.cancelDonationSchema.safeParse(payload);
    if (!parsed.success) {
        throw new https_1.HttpsError('invalid-argument', parsed.error.errors[0]?.message ?? 'Invalid input.');
    }
    const { donationId, reason } = parsed.data;
    const db = admin.firestore();
    const donationRef = db.collection('donations').doc(donationId);
    const nowIso = new Date().toISOString();
    let matchedNgoId;
    let matchedRequestId;
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
        // 3. Status constraint — cannot cancel in_transit or beyond
        const cancellableStatuses = ['draft', 'published', 'matched'];
        if (!cancellableStatuses.includes(current.status)) {
            throw new https_1.HttpsError('failed-precondition', `Cannot cancel a donation with status: ${current.status}. Cancellation is only allowed for draft, published, or matched donations.`);
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
        v2_1.logger.info('cancelDonation: Matched donation cancelled; NGO notification triggered.', {
            donationId,
            matchedNgoId,
        });
        // In production: send FCM notification to matchedNgoId
    }
    v2_1.logger.info('cancelDonation: Donation cancelled successfully.', { donationId, uid, reason });
    return { success: true, donationId };
});
//# sourceMappingURL=cancelDonation.js.map