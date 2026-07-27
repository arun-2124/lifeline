import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { Logger } from '../utils/logger';

/**
 * Scheduled function running every 15 minutes to flag expired donations.
 */
export const scheduledExpireDonations = functions.pubsub
  .schedule('every 15 minutes')
  .onRun(async (context) => {
    Logger.info('[ScheduledTasks] Starting scheduled expiry check');
    const db = admin.firestore();
    const now = admin.firestore.Timestamp.now();

    try {
      const expiredSnapshot = await db
        .collection('donations')
        .where('status', 'in', ['Pending', 'Matched', 'Accepted'])
        .where('expiryTime', '<=', now)
        .get();

      if (expiredSnapshot.empty) {
        Logger.info('[ScheduledTasks] No expired donations found');
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
      Logger.info(`[ScheduledTasks] Successfully expired ${count} donations`);
    } catch (error) {
      Logger.error('[ScheduledTasks] Error running expiry check', error);
    }
  });

/**
 * Scheduled function running daily at 03:00 UTC to clean up old notifications (>30 days).
 */
export const scheduledCleanupNotifications = functions.pubsub
  .schedule('0 3 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    Logger.info('[ScheduledTasks] Starting daily notifications cleanup');
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
        Logger.info('[ScheduledTasks] No old notifications to purge');
        return;
      }

      const batch = db.batch();
      oldNotifications.docs.forEach((doc) => batch.delete(doc.ref));
      await batch.commit();

      Logger.info(`[ScheduledTasks] Purged ${oldNotifications.size} old notifications`);
    } catch (error) {
      Logger.error('[ScheduledTasks] Error purging old notifications', error);
    }
  });

/**
 * Scheduled function running daily at 00:00 UTC to calculate platform analytics summary.
 */
export const scheduledDailyAnalytics = functions.pubsub
  .schedule('0 0 * * *')
  .timeZone('UTC')
  .onRun(async (context) => {
    Logger.info('[ScheduledTasks] Generating daily analytics summary');
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

      Logger.info(`[ScheduledTasks] Daily analytics recorded for ${todayStr}`);
    } catch (error) {
      Logger.error('[ScheduledTasks] Error computing daily analytics', error);
    }
  });
