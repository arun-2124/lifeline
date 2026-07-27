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
exports.onDeliveryStatusChanged = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
const logger_1 = require("../utils/logger");
const fcm_1 = require("../utils/fcm");
exports.onDeliveryStatusChanged = functions.firestore
    .document('delivery_requests/{deliveryId}')
    .onUpdate(async (change, context) => {
    const deliveryId = context.params.deliveryId;
    const beforeData = change.before.data();
    const afterData = change.after.data();
    const oldStatus = beforeData.status;
    const newStatus = afterData.status;
    if (oldStatus === newStatus)
        return;
    logger_1.Logger.info(`[DeliveryStatusTrigger] Delivery ${deliveryId} status changed: ${oldStatus} ──► ${newStatus}`);
    const db = admin.firestore();
    const donationId = afterData.donationId;
    try {
        // Map Delivery Status ──► Donation Status & Stage details
        let donationStatus = newStatus;
        let stageTitle = `Delivery: ${newStatus}`;
        let stageDescription = `Delivery status updated to ${newStatus}.`;
        switch (newStatus) {
            case 'Pickup Started':
                donationStatus = 'Pickup Started';
                stageTitle = 'Pickup Journey Started';
                stageDescription = `${afterData.volunteerName || 'Volunteer'} is traveling to the pickup location.`;
                break;
            case 'Food Picked Up':
                donationStatus = 'Food Picked Up';
                stageTitle = 'Food Picked Up from Donor';
                stageDescription = `Food successfully picked up and verified at donor site by ${afterData.volunteerName || 'Volunteer'}.`;
                break;
            case 'In Transit':
                donationStatus = 'In Transit';
                stageTitle = 'Food In Transit to NGO';
                stageDescription = `Package is currently in transit to ${afterData.ngoName || 'NGO destination'}.`;
                break;
            case 'Delivered':
            case 'Completed':
                donationStatus = 'Completed';
                stageTitle = 'Food Delivered & Handover Verified';
                stageDescription = `Food package delivered and verified at ${afterData.ngoName || 'NGO destination'}.`;
                break;
        }
        // 1. Update Donation Status
        await db.collection('donations').doc(donationId).update({
            status: donationStatus,
            updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        // 2. Add Delivery Log Entry
        await db.collection('delivery_logs').add({
            donationId,
            stage: donationStatus,
            title: stageTitle,
            description: stageDescription,
            timestamp: admin.firestore.FieldValue.serverTimestamp(),
            performedBy: afterData.volunteerId || 'SYSTEM',
        });
        // 3. Send FCM Notifications based on state
        if (newStatus === 'Pickup Started') {
            if (afterData.donorId) {
                await (0, fcm_1.sendUserNotification)(afterData.donorId, {
                    title: 'Driver En Route! 🚚',
                    body: `${afterData.volunteerName || 'Volunteer'} has started the pickup journey to your address.`,
                    type: 'pickup_started',
                    data: { donationId, deliveryId },
                });
            }
        }
        else if (newStatus === 'Delivered' || newStatus === 'Completed') {
            // Notify Donor
            if (afterData.donorId) {
                await (0, fcm_1.sendUserNotification)(afterData.donorId, {
                    title: 'Rescue Complete! 🌟',
                    body: `Your food donation of ${afterData.foodName || 'food'} was successfully delivered to ${afterData.ngoName || 'NGO'}!`,
                    type: 'delivery_completed',
                    data: { donationId, deliveryId },
                });
            }
            // Notify NGO
            if (afterData.ngoId) {
                await (0, fcm_1.sendUserNotification)(afterData.ngoId, {
                    title: 'Delivery Received! ✅',
                    body: `Food package from ${afterData.donorName || 'Donor'} has been marked as completed.`,
                    type: 'delivery_completed',
                    data: { donationId, deliveryId },
                });
            }
            // 4. Record Carbon Savings Audit
            const quantityKg = afterData.quantity || 5;
            const co2SavedKg = quantityKg * 2.5; // IPCC estimation: 2.5 kg CO2e / kg food
            const waterSavedLiters = quantityKg * 250; // FAO estimation: 250L water / kg food
            await db.collection('audit_logs').add({
                event: 'DONATION_RESCUE_COMPLETED',
                donationId,
                deliveryId,
                quantityKg,
                co2SavedKg,
                waterSavedLiters,
                completedAt: admin.firestore.FieldValue.serverTimestamp(),
            });
            logger_1.Logger.info(`[DeliveryStatusTrigger] Rescue completed & carbon savings calculated for donation ${donationId}`);
        }
    }
    catch (error) {
        logger_1.Logger.error(`[DeliveryStatusTrigger] Error updating delivery status for ${deliveryId}`, error);
    }
});
//# sourceMappingURL=onDeliveryStatusChanged.js.map