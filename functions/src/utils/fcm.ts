import * as admin from 'firebase-admin';

export interface NotificationPayload {
  title: string;
  body: string;
  type: string;
  data?: Record<string, string>;

}

/**
 * Sends an FCM push notification to a specific user and records an in-app notification in Firestore.
 */
export async function sendUserNotification(
  userId: string,
  payload: NotificationPayload
): Promise<void> {
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
  if (!userDoc.exists) return;

  const fcmToken = userDoc.data()?.fcmToken;
  if (!fcmToken) return;

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
  } catch (error) {
    console.error(`Failed to send FCM token to user ${userId}:`, error);
  }
}

/**
 * Sends a topic push notification (e.g. to all NGOs or Volunteers).
 */
export async function sendTopicNotification(
  topic: string,
  payload: NotificationPayload
): Promise<void> {
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
  } catch (error) {
    console.error(`Failed to send topic notification to ${topic}:`, error);
  }
}
