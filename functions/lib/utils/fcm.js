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
exports.sendUserNotification = sendUserNotification;
exports.sendTopicNotification = sendTopicNotification;
const admin = __importStar(require("firebase-admin"));
/**
 * Sends an FCM push notification to a specific user and records an in-app notification in Firestore.
 */
async function sendUserNotification(userId, payload) {
    const db = admin.firestore();
    // 1. Create in-app notification document
    await db.collection('notifications').add({
        userId,
        title: payload.title,
        body: payload.body,
        type: payload.type,
        isRead: false,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        payload: payload.data || {},
    });
    // 2. Fetch user's FCM token
    const userDoc = await db.collection('users').doc(userId).get();
    if (!userDoc.exists)
        return;
    const fcmToken = userDoc.data()?.fcmToken;
    if (!fcmToken)
        return;
    // 3. Send FCM push notification
    try {
        await admin.messaging().send({
            token: fcmToken,
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: {
                type: payload.type,
                ...payload.data,
            },
            android: {
                priority: 'high',
                notification: {
                    sound: 'default',
                    channelId: 'lifeline_alerts',
                },
            },
            apns: {
                payload: {
                    aps: {
                        sound: 'default',
                        badge: 1,
                    },
                },
            },
        });
    }
    catch (error) {
        console.error(`Failed to send FCM token to user ${userId}:`, error);
    }
}
/**
 * Sends a topic push notification (e.g. to all NGOs or Volunteers).
 */
async function sendTopicNotification(topic, payload) {
    try {
        await admin.messaging().send({
            topic,
            notification: {
                title: payload.title,
                body: payload.body,
            },
            data: {
                type: payload.type,
                ...payload.data,
            },
        });
    }
    catch (error) {
        console.error(`Failed to send topic notification to ${topic}:`, error);
    }
}
//# sourceMappingURL=fcm.js.map