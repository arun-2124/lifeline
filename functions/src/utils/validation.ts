import { z } from 'zod';
import { BLOCKED_TEMP_MAIL_DOMAINS } from '../config/constants';

/**
 * Validates email format and blocks disposable/temporary email domains.
 */
export function validateEmail(email: string): { valid: boolean; reason?: string } {
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return { valid: false, reason: 'Invalid email format' };
  }

  const domain = email.split('@')[1]?.toLowerCase();
  if (domain && BLOCKED_TEMP_MAIL_DOMAINS.has(domain)) {
    return { valid: false, reason: 'Disposable / temporary email domain is not permitted' };
  }

  return { valid: true };
}

/**
 * Validates password strength: 8+ chars, uppercase, lowercase, number, special char.
 */
export function validatePasswordStrength(password: string): { valid: boolean; reason?: string } {
  if (password.length < 8) {
    return { valid: false, reason: 'Password must be at least 8 characters long' };
  }
  if (!/[A-Z]/.test(password)) {
    return { valid: false, reason: 'Password must contain at least one uppercase letter' };
  }
  if (!/[a-z]/.test(password)) {
    return { valid: false, reason: 'Password must contain at least one lowercase letter' };
  }
  if (!/[0-9]/.test(password)) {
    return { valid: false, reason: 'Password must contain at least one digit' };
  }
  if (!/[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]/.test(password)) {
    return { valid: false, reason: 'Password must contain at least one special character' };
  }
  return { valid: true };
}

/**
 * Sanitizes input string to prevent XSS / script injection.
 */
export function sanitizeString(input: string): string {
  return input
    .trim()
    .replace(/<[^>]*>?/gm, '') // Strip HTML tags
    .replace(/['"`;]/g, '');   // Neutralize quotes/semicolons
}

// Zod schemas for role-specific validation
export const donorProfileSchema = z.object({
  fssaiLicenseNumber: z.string().optional().transform((val) => val ? sanitizeString(val) : undefined),
  organizationName: z.string().optional().transform((val) => val ? sanitizeString(val) : undefined),
  contactPhone: z.string().min(10, 'Contact phone must be at least 10 digits').transform(sanitizeString),
  address: z.string().min(5, 'Address is required').transform(sanitizeString),
});

export const ngoProfileSchema = z.object({
  registrationNumber: z.string().min(3, 'NGO Registration number is required').transform(sanitizeString),
  darpanId: z.string().optional().transform((val) => val ? sanitizeString(val) : undefined),
  organizationName: z.string().min(2, 'Organization name is required').transform(sanitizeString),
  contactPhone: z.string().min(10, 'Contact phone must be at least 10 digits').transform(sanitizeString),
  address: z.string().min(5, 'Address is required').transform(sanitizeString),
});

export const recipientProfileSchema = z.object({
  fullName: z.string().min(2, 'Full name is required').transform(sanitizeString),
  idProofNumber: z.string().min(4, 'ID proof number is required').transform(sanitizeString),
  contactPhone: z.string().min(10, 'Contact phone must be at least 10 digits').transform(sanitizeString),
  address: z.string().min(5, 'Address is required').transform(sanitizeString),
});
