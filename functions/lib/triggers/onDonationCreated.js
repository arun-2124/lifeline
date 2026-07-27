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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.onDonationCreated = void 0;
const functions = __importStar(require("firebase-functions/v1"));
const admin = __importStar(require("firebase-admin"));
const logger_1 = require("../utils/logger");
const fcm_1 = require("../utils/fcm");
const crypto_1 = require("crypto");
const http_1 = __importDefault(require("http"));
exports.onDonationCreated = functions.firestore
    .document('donations/{donationId}')
    .onCreate(async (snapshot, context) => {
    const donationId = context.params.donationId;
    const donationData = snapshot.data();
    logger_1.Logger.info(`[DonationTrigger] New donation created: ${donationId}`, { donationId });
    if (!donationData)
        return;
    const db = admin.firestore();
    try {
        // 1. Generate QR Code Reference Document
        const payloadString = `LIFELINE:DONATION:${donationId}:${donationData.donorId}:${Date.now()}`;
        const payloadHash = (0, crypto_1.createHash)('sha256').update(payloadString).digest('hex');
        await db.collection('qr_codes').doc(donationId).set({
            qrId: donationId,
            donationId,
            payloadHash,
            status: 'ACTIVE',
            createdAt: admin.firestore.FieldValue.serverTimestamp(),
        });
        logger_1.Logger.info(`[DonationTrigger] QR Code generated for ${donationId}`);
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
        await (0, fcm_1.sendTopicNotification)('ngo_alerts', {
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
            const req = http_1.default.request({
                hostname: '127.0.0.1',
                port: 8000,
                path: '/v1/ai/matching',
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Content-Length': Buffer.byteLength(postData),
                },
            }, (res) => {
                logger_1.Logger.info(`[AI Trigger] FastAPI AI Matching response status: ${res.statusCode}`);
            });
            req.on('error', (e) => {
                logger_1.Logger.warn(`[AI Trigger] FastAPI AI Engine unreachable (fallback active): ${e.message}`);
            });
            req.write(postData);
            req.end();
        }
        catch (aiErr) {
            logger_1.Logger.warn('[AI Trigger] Gracefully handled AI service call exception', { error: aiErr });
        }
    }
    catch (error) {
        logger_1.Logger.error(`[DonationTrigger] Failed processing donation ${donationId}`, error);
    }
});
//# sourceMappingURL=onDonationCreated.js.map