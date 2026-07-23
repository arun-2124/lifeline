import * as admin from 'firebase-admin';
import * as functions from 'firebase-functions/v1';

// Initialize Firebase Admin SDK (once)
admin.initializeApp();

// ── Sprint 2: Auth Functions ──────────────────────────────────────────────────

import { handleUserCreated } from './triggers/onUserCreated';
import { handleUserDeleted } from './triggers/onUserDeleted';

export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  await handleUserCreated(user);
});

export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  await handleUserDeleted(user);
});

// ── Sprint 2: Auth Callables ──────────────────────────────────────────────────

export { validateProfile } from './callables/validateProfile';
export { checkAccountStatus } from './callables/checkAccountStatus';

// ── Sprint 3: Donation Callables ──────────────────────────────────────────────

export { createDonation } from './callables/createDonation';
export { updateDonation } from './callables/updateDonation';
export { cancelDonation } from './callables/cancelDonation';

// ── Sprint 3: Storage Trigger ─────────────────────────────────────────────────

export { processImages } from './triggers/processImages';

// ── Sprint 3: PubSub Trigger ──────────────────────────────────────────────────

export { aiClassifyFood } from './triggers/aiClassifyFood';

// ── Sprint 3: Scheduled Function ──────────────────────────────────────────────

export { expireDonations } from './triggers/expireDonations';
