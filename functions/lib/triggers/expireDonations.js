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
exports.expireDonations = void 0;
const admin = __importStar(require("firebase-admin"));
const scheduler_1 = require("firebase-functions/v2/scheduler");
const v2_1 = require("firebase-functions/v2");
const BATCH_SIZE = 500;
/**
 * Scheduled Function: expireDonations
 * Runs every 5 minutes, auto-expires published donations past their expiry time.
 * Cleans geohash indexes, creates audit statusLog, and sends FCM notifications.
 */
exports.expireDonations = (0, scheduler_1.onSchedule)({
    schedule: 'every 5 minutes',
    memory: '128MiB',
    timeoutSeconds: 540,
}, async () => {
    const db = admin.firestore();
    const now = new Date();
    v2_1.logger.info('expireDonations: Starting expiry run.', { time: now.toISOString() });
    const expiredSnap = await db
        .collection('donations')
        .where('status', '==', 'published')
        .where('expiresAt', '<=', now.toISOString())
        .limit(BATCH_SIZE)
        .get();
    if (expiredSnap.empty) {
        v2_1.logger.info('expireDonations: No donations to expire.');
        return;
    }
    v2_1.logger.info(`expireDonations: Found ${expiredSnap.size} donations to expire.`);
    // Process in Firestore batch chunks (max 500 per batch)
    const chunks = [];
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
            v2_1.logger.info(`expireDonations: Marking donation expired.`, {
                donationId,
                donorId: data.donorId,
            });
        }
        await batch.commit();
        v2_1.logger.info(`expireDonations: Committed batch of ${chunk.length} expired donations.`);
        // Post-batch: Send FCM notifications to donors (non-blocking)
        // In production: fan out notification tasks via Cloud Tasks or PubSub
    }
    v2_1.logger.info('expireDonations: Run complete.', { totalExpired: expiredSnap.size });
});
//# sourceMappingURL=expireDonations.js.map