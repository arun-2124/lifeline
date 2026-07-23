/**
 * Constant definitions for Lifeline Authentication & Profile Management.
 */

export const ROLES = {
  UNASSIGNED: 'UNASSIGNED',
  DONOR: 'DONOR',
  NGO: 'NGO',
  RECIPIENT: 'RECIPIENT',
  ADMIN: 'ADMIN',
} as const;

export type UserRole = (typeof ROLES)[keyof typeof ROLES];

export const ACCOUNT_STATUS = {
  PENDING_ONBOARDING: 'PENDING_ONBOARDING',
  PENDING_VERIFICATION: 'PENDING_VERIFICATION',
  ACTIVE: 'ACTIVE',
  SUSPENDED: 'SUSPENDED',
  DELETED: 'DELETED',
} as const;

export type AccountStatus = (typeof ACCOUNT_STATUS)[keyof typeof ACCOUNT_STATUS];

// Cooldown period for changing user role (30 days in milliseconds)
export const ROLE_CHANGE_COOLDOWN_MS = 30 * 24 * 60 * 60 * 1000;

// List of disposable / temporary email domains blocked during verification
export const BLOCKED_TEMP_MAIL_DOMAINS = new Set([
  'mailinator.com',
  'tempmail.com',
  '10minutemail.com',
  'guerrillamail.com',
  'dispostable.com',
  'trashmail.com',
  'yopmail.com',
  'sharklasers.com',
  'getnada.com',
]);

// Rate limiting thresholds
export const RATE_LIMIT_CONFIG = {
  VALIDATE_PROFILE_MAX_ATTEMPTS: 5,
  VALIDATE_PROFILE_WINDOW_MS: 15 * 60 * 1000, // 15 mins
  CHECK_STATUS_MAX_ATTEMPTS: 30,
  CHECK_STATUS_WINDOW_MS: 5 * 60 * 1000, // 5 mins
};

// Error Codes
export const ERROR_CODES = {
  TEMP_EMAIL_BLOCKED: 'AUTH_TEMP_EMAIL_BLOCKED',
  INVALID_PASSWORD_STRENGTH: 'AUTH_INVALID_PASSWORD_STRENGTH',
  ROLE_COOLDOWN_ACTIVE: 'AUTH_ROLE_COOLDOWN_ACTIVE',
  APP_CHECK_REQUIRED: 'AUTH_APP_CHECK_REQUIRED',
  RATE_LIMIT_EXCEEDED: 'AUTH_RATE_LIMIT_EXCEEDED',
  IDEMPOTENCY_CONFLICT: 'AUTH_IDEMPOTENCY_CONFLICT',
  ACCOUNT_SUSPENDED: 'AUTH_ACCOUNT_SUSPENDED',
} as const;
