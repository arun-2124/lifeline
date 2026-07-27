import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import { Logger } from '../utils/logger';
import { sendTopicNotification } from '../utils/fcm';
import { createHash } from 'crypto';
import http from 'http';

export const onDonationCreated = functions.firestore
  .document('donations/{donationId}')
  .onCreate(async (snapshot, context) => {
    const donationId = context.params.donationId;
    const donationData = snapshot.data();

    Logger.info(`[DonationTrigger] New donation created: ${donationId}`, { donationId });

    if (!donationData) return;

    const db = admin.firestore();

    try {
      // 1. Generate QR Code Reference Document
      const payloadString = `LIFELINE:DONATION:${donationId}:${donationData.donorId}:${Date.now()}`;
      const payloadHash = createHash('sha256').update(payloadString).digest('hex');

      await db.collection('qr_codes').doc(donationId).set({
        qrId: donationId,
        donationId,
        payloadHash,
        status: 'ACTIVE',
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      Logger.info(`[DonationTrigger] QR Code generated for ${donationId}`);

      // 2. Log Stage 1: Donation Created
      await db.collection('delivery_logs').add({
        donationId,
        stage: 'Donation Created',
        title: 'Food Donation Published',
        description: `${donationData.donorName || 'Donor'} published ${donationData.foodName || 'food surplus'} (${donationData.quantity || 0} ${donationData.unit || 'units'}).`,
        timestamp: admin.firestore.FieldValue.serverTimestamp(),
        performedBy: donationData.donorId,
      });

      // 3. Notify NGOs via FCM Topic
      await sendTopicNotification('ngo_alerts', {
        title: 'Surplus Food Available! 🍲',
        body: `${donationData.foodName || 'Food surplus'} (${donationData.numberOfMeals || 10} meals) available near ${donationData.pickupAddress || 'your area'}.`,
        type: 'donation_created',
        data: { donationId },
      });

      // 4. Trigger FastAPI AI Matching Service (Asynchronous / Non-blocking)
      try {
        const postData = JSON.stringify({
          donation_id: donationId,
          food_name: donationData.foodName || 'Surplus Food',
          food_category: donationData.foodCategory || 'cooked_meal',
          quantity: donationData.quantity || 10,
          number_of_meals: donationData.numberOfMeals || 20,
          latitude: donationData.latitude || 12.9716,
          longitude: donationData.longitude || 77.5946,
          candidates: [],
        });

        const req = http.request({
          hostname: '127.0.0.1',
          port: 8000,
          path: '/v1/ai/matching',
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Content-Length': Buffer.byteLength(postData),
          },
        }, (res) => {
          Logger.info(`[AI Trigger] FastAPI AI Matching response status: ${res.statusCode}`);
        });

        req.on('error', (e) => {
          Logger.warn(`[AI Trigger] FastAPI AI Engine unreachable (fallback active): ${e.message}`);
        });

        req.write(postData);
        req.end();
      } catch (aiErr) {
        Logger.warn('[AI Trigger] Gracefully handled AI service call exception', { error: aiErr });
      }

    } catch (error) {
      Logger.error(`[DonationTrigger] Failed processing donation ${donationId}`, error);
    }
  });
