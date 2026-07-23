"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.recipientProfileSchema = exports.ngoProfileSchema = exports.donorProfileSchema = void 0;
exports.validateEmail = validateEmail;
exports.validatePasswordStrength = validatePasswordStrength;
exports.sanitizeString = sanitizeString;
const zod_1 = require("zod");
const constants_1 = require("../config/constants");
/**
 * Validates email format and blocks disposable/temporary email domains.
 */
function validateEmail(email) {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
        return { valid: false, reason: 'Invalid email format' };
    }
    const domain = email.split('@')[1]?.toLowerCase();
    if (domain && constants_1.BLOCKED_TEMP_MAIL_DOMAINS.has(domain)) {
        return { valid: false, reason: 'Disposable / temporary email domain is not permitted' };
    }
    return { valid: true };
}
/**
 * Validates password strength: 8+ chars, uppercase, lowercase, number, special char.
 */
function validatePasswordStrength(password) {
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
function sanitizeString(input) {
    return input
        .trim()
        .replace(/<[^>]*>?/gm, '') // Strip HTML tags
        .replace(/['"`;]/g, ''); // Neutralize quotes/semicolons
}
// Zod schemas for role-specific validation
exports.donorProfileSchema = zod_1.z.object({
    fssaiLicenseNumber: zod_1.z.string().optional().transform((val) => val ? sanitizeString(val) : undefined),
    organizationName: zod_1.z.string().optional().transform((val) => val ? sanitizeString(val) : undefined),
    contactPhone: zod_1.z.string().min(10, 'Contact phone must be at least 10 digits').transform(sanitizeString),
    address: zod_1.z.string().min(5, 'Address is required').transform(sanitizeString),
});
exports.ngoProfileSchema = zod_1.z.object({
    registrationNumber: zod_1.z.string().min(3, 'NGO Registration number is required').transform(sanitizeString),
    darpanId: zod_1.z.string().optional().transform((val) => val ? sanitizeString(val) : undefined),
    organizationName: zod_1.z.string().min(2, 'Organization name is required').transform(sanitizeString),
    contactPhone: zod_1.z.string().min(10, 'Contact phone must be at least 10 digits').transform(sanitizeString),
    address: zod_1.z.string().min(5, 'Address is required').transform(sanitizeString),
});
exports.recipientProfileSchema = zod_1.z.object({
    fullName: zod_1.z.string().min(2, 'Full name is required').transform(sanitizeString),
    idProofNumber: zod_1.z.string().min(4, 'ID proof number is required').transform(sanitizeString),
    contactPhone: zod_1.z.string().min(10, 'Contact phone must be at least 10 digits').transform(sanitizeString),
    address: zod_1.z.string().min(5, 'Address is required').transform(sanitizeString),
});
//# sourceMappingURL=validation.js.map