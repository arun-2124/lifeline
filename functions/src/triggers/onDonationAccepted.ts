import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { Logger } from '../utils/logger';
import { sendUserNotification, sendTopicNotification } from '../utils/fcm';

export const onDonationAccepted = functions.firestore
  .document('ngo_requests/{requestId}')
  .onCreate(async (snapshot, context) => {
    const requestId = context.params.requestId;
    const requestData = snapshot.data();

    Logger.info(`[NgoTrigger] NGO request accepted: ${requestId}`, { requestId });

    if (!requestData) return;

    const db = admin.firestore();
    const donationId = requestData.donationId;

    try {
      // 1. Update Donation Status to 'Accepted'
      await db.collection('donations').doc(donationId).update({
        status: 'Accepted',
        ngoId: requestData.ngoId,
        ngoName: requestData.ngoName,
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 2. Create Delivery Task Document
      const deliveryId = requestId;
      await db.collection('delivery_requests').doc(deliveryId).set({
        deliveryId,
        donationId,
        requestId,
        donorId: requestData.donorId,
        donorName: requestData.donorName || 'Donor',
        donorPhone: requestData.donorPhone || '',
        pickupAddress: requestData.pickupAddress || '',
        pickupLat: requestData.latitude || 12.9716,
        pickupLng: requestData.longitude || 77.5946,
        ngoId: requestData.ngoId,
        ngoName: requestData.ngoName || 'NGO Partner',
        ngoPhone: requestData.ngoPhone || '',
        destinationAddress: requestData.destinationAddress || 'NGO Warehouse',
        destLat: requestData.destLat || 12.9720,
        destLng: requestData.destLng || 77.5950,
        foodName: requestData.foodName || 'Food Surplus',
        quantity: requestData.quantity || 1,
        unit: requestData.unit || 'kg',
        numberOfMeals: requestData.numberOfMeals || 10,
        status: 'Waiting for Volunteer',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      // 3. Log Stage 2: NGO Accepted
      await db.collection('delivery_logs').add({
        donationId,
        stage: 'NGO Accepted',
        title: 'Donation Accepted by NGO',
        description: `${requestData.ngoName || 'NGO'} has accepted the donation and requested volunteer pickup.`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        performedBy: requestData.ngoId,
      });

      // 4. Notify Donor
      await sendUserNotification(requestData.donorId, {
        title: 'Donation Accepted! 🎉',
        body: `${requestData.ngoName || 'An NGO'} has accepted your food donation. A volunteer driver will pick it up soon.`,
        type: 'donation_accepted',
        data: { donationId, requestId },
      });

      // 5. Notify Volunteer Fleet via FCM Topic
      await sendTopicNotification('volunteer_alerts', {
        title: 'New Delivery Task Available 🚚',
        body: `Pickup food from ${requestData.donorName || 'Donor'} and deliver to ${requestData.ngoName || 'NGO'}.`,
        type: 'delivery_available',
        data: { deliveryId, donationId },
      });

      Logger.info(`[NgoTrigger] Delivery request created and notifications sent for ${donationId}`);
    } catch (error) {
      Logger.error(`[NgoTrigger] Failed processing NGO acceptance for ${requestId}`, error);
    }
  });
