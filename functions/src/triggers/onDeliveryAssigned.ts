import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { Logger } from '../utils/logger';
import { sendUserNotification } from '../utils/fcm';

export const onDeliveryAssigned = functions.firestore
  .document('delivery_requests/{deliveryId}')
  .onUpdate(async (change, context) => {
    const deliveryId = context.params.deliveryId;
    const beforeData = change.before.data();
    const afterData = change.after.data();

    // Trigger only when volunteerId changes from null/empty to assigned
    if (beforeData.volunteerId === afterData.volunteerId || !afterData.volunteerId) {
      return;
    }

    Logger.info(`[VolunteerTrigger] Delivery ${deliveryId} assigned to volunteer ${afterData.volunteerId}`);

    const db = admin.firestore();
    const donationId = afterData.donationId;

    try {
      // 1. Update Donation Status to 'Volunteer Assigned'
      await db.collection('donations').doc(donationId).update({
        status: 'Volunteer Assigned',
        volunteerId: afterData.volunteerId,
        volunteerName: afterData.volunteerName || 'Volunteer Driver',
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. Log Stage 3: Volunteer Assigned
      await db.collection('delivery_logs').add({
        donationId,
        stage: 'Volunteer Assigned',
        title: 'Volunteer Assigned to Task',
        description: `Volunteer ${afterData.volunteerName || 'Driver'} accepted the pickup and delivery assignment.`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        performedBy: afterData.volunteerId,
      });

      // 3. Notify Donor
      if (afterData.donorId) {
        await sendUserNotification(afterData.donorId, {
          title: 'Volunteer Assigned! 🚚',
          body: `${afterData.volunteerName || 'A volunteer'} is on their way to pick up your donation.`,
          type: 'volunteer_assigned',
          data: { donationId, deliveryId },
        });
      }

      // 4. Notify NGO
      if (afterData.ngoId) {
        await sendUserNotification(afterData.ngoId, {
          title: 'Volunteer On The Way! 📦',
          body: `${afterData.volunteerName || 'A volunteer'} has claimed the delivery task for your accepted food donation.`,
          type: 'volunteer_assigned',
          data: { donationId, deliveryId },
        });
      }

      Logger.info(`[VolunteerTrigger] Notifications sent for assignment on delivery ${deliveryId}`);
    } catch (error) {
      Logger.error(`[VolunteerTrigger] Failed handling volunteer assignment for ${deliveryId}`, error);
    }
  });
