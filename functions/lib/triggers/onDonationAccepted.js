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
exports.onDonationAccepted = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
const logger_1 = require("../utils/logger");
const fcm_1 = require("../utils/fcm");
exports.onDonationAccepted = functions.firestore
    .document('ngo_requests/{requestId}')
    .onCreate(async (snapshot, context) => {
    const requestId = context.params.requestId;
    const requestData = snapshot.data();
    logger_1.Logger.info(`[NgoTrigger] NGO request accepted: ${requestId}`, { requestId });
    if (!requestData)
        return;
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
        await (0, fcm_1.sendUserNotification)(requestData.donorId, {
            title: 'Donation Accepted! 🎉',
            body: `${requestData.ngoName || 'An NGO'} has accepted your food donation. A volunteer driver will pick it up soon.`,
            type: 'donation_accepted',
            data: { donationId, requestId },
        });
        // 5. Notify Volunteer Fleet via FCM Topic
        await (0, fcm_1.sendTopicNotification)('volunteer_alerts', {
            title: 'New Delivery Task Available 🚚',
            body: `Pickup food from ${requestData.donorName || 'Donor'} and deliver to ${requestData.ngoName || 'NGO'}.`,
            type: 'delivery_available',
            data: { deliveryId, donationId },
        });
        logger_1.Logger.info(`[NgoTrigger] Delivery request created and notifications sent for ${donationId}`);
    }
    catch (error) {
        logger_1.Logger.error(`[NgoTrigger] Failed processing NGO acceptance for ${requestId}`, error);
    }
});
//# sourceMappingURL=onDonationAccepted.js.map