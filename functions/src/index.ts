import * as admin from 'firebase-admin';

// Initialize Firebase Admin SDK singleton
if (!admin.apps.length) {
  admin.initializeApp();
}

// ── Auth Triggers ─────────────────────────────────────────────────────────────
export { handleUserCreated } from './triggers/onUserCreated';
export { handleUserDeleted } from './triggers/onUserDeleted';

// ── Auth Callables ────────────────────────────────────────────────────────────
export { validateProfile } from './callables/validateProfile';
export { checkAccountStatus } from './callables/checkAccountStatus';

// ── Donation Callables ────────────────────────────────────────────────────────
export { createDonation } from './callables/createDonation';
export { updateDonation } from './callables/updateDonation';
export { cancelDonation } from './callables/cancelDonation';

// ── Event Triggers (Donation, NGO, Volunteer, Delivery) ──────────────────────
export { onDonationCreated } from './triggers/onDonationCreated';
export { onDonationAccepted } from './triggers/onDonationAccepted';
export { onDeliveryAssigned } from './triggers/onDeliveryAssigned';
export { onDeliveryStatusChanged } from './triggers/onDeliveryStatusChanged';

// ── Storage & AI Triggers ─────────────────────────────────────────────────────
export { processImages } from './triggers/processImages';
export { aiClassifyFood } from './triggers/aiClassifyFood';

// ── Scheduled Cron Functions ──────────────────────────────────────────────────
export {
  scheduledExpireDonations,
  scheduledCleanupNotifications,
  scheduledDailyAnalytics,
} from './triggers/scheduledTasks';
