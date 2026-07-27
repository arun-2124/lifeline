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
exports.onDeliveryAssigned = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
const logger_1 = require("../utils/logger");
const fcm_1 = require("../utils/fcm");
exports.onDeliveryAssigned = functions.firestore
    .document('delivery_requests/{deliveryId}')
    .onUpdate(async (change, context) => {
    const deliveryId = context.params.deliveryId;
    const beforeData = change.before.data();
    const afterData = change.after.data();
    // Trigger only when volunteerId changes from null/empty to assigned
    if (beforeData.volunteerId === afterData.volunteerId || !afterData.volunteerId) {
        return;
    }
    logger_1.Logger.info(`[VolunteerTrigger] Delivery ${deliveryId} assigned to volunteer ${afterData.volunteerId}`);
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
            await (0, fcm_1.sendUserNotification)(afterData.donorId, {
                title: 'Volunteer Assigned! 🚚',
                body: `${afterData.volunteerName || 'A volunteer'} is on their way to pick up your donation.`,
                type: 'volunteer_assigned',
                data: { donationId, deliveryId },
            });
        }
        // 4. Notify NGO
        if (afterData.ngoId) {
            await (0, fcm_1.sendUserNotification)(afterData.ngoId, {
                title: 'Volunteer On The Way! 📦',
                body: `${afterData.volunteerName || 'A volunteer'} has claimed the delivery task for your accepted food donation.`,
                type: 'volunteer_assigned',
                data: { donationId, deliveryId },
            });
        }
        logger_1.Logger.info(`[VolunteerTrigger] Notifications sent for assignment on delivery ${deliveryId}`);
    }
    catch (error) {
        logger_1.Logger.error(`[VolunteerTrigger] Failed handling volunteer assignment for ${deliveryId}`, error);
    }
});
//# sourceMappingURL=onDeliveryAssigned.js.map