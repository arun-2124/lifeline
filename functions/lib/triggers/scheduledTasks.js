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
exports.scheduledDailyAnalytics = exports.scheduledCleanupNotifications = exports.scheduledExpireDonations = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
const logger_1 = require("../utils/logger");
/**
 * Scheduled function running every 15 minutes to flag expired donations.
 */
exports.scheduledExpireDonations = functions.pubsub
    .schedule('every 15 minutes')
    .onRun(async (context) => {
    logger_1.Logger.info('[ScheduledTasks] Starting scheduled expiry check');
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();
    try {
        const expiredSnapshot = await db
            .collection('donations')
            .where('status', 'in', ['Pending', 'Matched', 'Accepted'])
            .where('expiryTime', '<=', now)
            .get();
        if (expiredSnapshot.empty) {
            logger_1.Logger.info('[ScheduledTasks] No expired donations found');
            return;
        }
        const batch = db.batch();
        let count = 0;
        for (const doc of expiredSnapshot.docs) {
            batch.update(doc.ref, {
                status: 'Expired',
                updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            // Write delivery log entry
            const logRef = db.collection('delivery_logs').doc();
            batch.set(logRef, {
                donationId: doc.id,
                stage: 'Expired',
                title: 'Donation Expired',
                description: 'Food donation reached expiry deadline before completion.',
                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                performedBy: 'SYSTEM_CRON',
            });
            count++;
        }
        await batch.commit();
        logger_1.Logger.info(`[ScheduledTasks] Successfully expired ${count} donations`);
    }
    catch (error) {
        logger_1.Logger.error('[ScheduledTasks] Error running expiry check', error);
    }
});
/**
 * Scheduled function running daily at 03:00 UTC to clean up old notifications (>30 days).
 */
exports.scheduledCleanupNotifications = functions.pubsub
    .schedule('0 3 * * *')
    .timeZone('UTC')
    .onRun(async (context) => {
    logger_1.Logger.info('[ScheduledTasks] Starting daily notifications cleanup');
    const db = admin.firestore();
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    try {
        const oldNotifications = await db
            .collection('notifications')
            .where('isRead', '==', true)
            .where('createdAt', '<=', admin.firestore.Timestamp.fromDate(thirtyDaysAgo))
            .limit(500)
            .get();
        if (oldNotifications.empty) {
            logger_1.Logger.info('[ScheduledTasks] No old notifications to purge');
            return;
        }
        const batch = db.batch();
        oldNotifications.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        logger_1.Logger.info(`[ScheduledTasks] Purged ${oldNotifications.size} old notifications`);
    }
    catch (error) {
        logger_1.Logger.error('[ScheduledTasks] Error purging old notifications', error);
    }
});
/**
 * Scheduled function running daily at 00:00 UTC to calculate platform analytics summary.
 */
exports.scheduledDailyAnalytics = functions.pubsub
    .schedule('0 0 * * *')
    .timeZone('UTC')
    .onRun(async (context) => {
    logger_1.Logger.info('[ScheduledTasks] Generating daily analytics summary');
    const db = admin.firestore();
    try {
        const todayStr = new Date().toISOString().split('T')[0];
        const completedSnapshot = await db
            .collection('donations')
            .where('status', '==', 'Completed')
            .get();
        let totalMeals = 0;
        let totalKg = 0;
        completedSnapshot.docs.forEach((doc) => {
            const d = doc.data();
            totalMeals += d.numberOfMeals || 0;
            totalKg += d.quantity || 0;
        });
        const co2SavedKg = totalKg * 2.5;
        await db.collection('analytics_daily').doc(todayStr).set({
            date: todayStr,
            totalCompletedDonations: completedSnapshot.size,
            totalMealsRescued: totalMeals,
            totalWasteDivertedKg: totalKg,
            co2SavedKg,
            generatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        logger_1.Logger.info(`[ScheduledTasks] Daily analytics recorded for ${todayStr}`);
    }
    catch (error) {
        logger_1.Logger.error('[ScheduledTasks] Error computing daily analytics', error);
    }
});
//# sourceMappingURL=scheduledTasks.js.map