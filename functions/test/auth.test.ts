import { validateEmail, validatePasswordStrength, donorProfileSchema, ngoProfileSchema } from '../src/utils/validation';

describe('Lifeline Backend Auth & Profile Validation Utility Tests', () => {

  describe('Email & Disposable Domain Blocker', () => {
    it('should pass valid professional email', () => {
      const result = validateEmail('user@lifeline.org');
      expect(result.valid).toBe(true);
    });

    it('should reject invalid email format', () => {
      const result = validateEmail('invalid-email-format');
      expect(result.valid).toBe(false);
      expect(result.reason).toBe('Invalid email format');
    });

    it('should reject temp-mail domains (e.g. mailinator.com)', () => {
      const result = validateEmail('test@mailinator.com');
      expect(result.valid).toBe(false);
      expect(result.reason).toContain('Disposable / temporary email domain');
    });
  });

  describe('Password Strength Rules', () => {
    it('should pass strong password satisfying all constraints', () => {
      const result = validatePasswordStrength('StrongP@ssw0rd!');
      expect(result.valid).toBe(true);
    });

    it('should reject password under 8 characters', () => {
      const result = validatePasswordStrength('Short1!');
      expect(result.valid).toBe(false);
      expect(result.reason).toContain('at least 8 characters');
    });

    it('should reject password missing special characters', () => {
      const result = validatePasswordStrength('NoSpecialChar123');
      expect(result.valid).toBe(false);
      expect(result.reason).toContain('special character');
    });
  });

  describe('Role Profile Schema Validation', () => {
    it('should validate complete donor profile payload', () => {
      const payload = {
        organizationName: 'Fresh Foods Co',
        contactPhone: '9876543210',
        address: '123 Main Street, Sector 4',
      };
      const parseResult = donorProfileSchema.safeParse(payload);
      expect(parseResult.success).toBe(true);
    });

    it('should reject NGO payload without registration number', () => {
      const payload = {
        organizationName: 'Help Humanity',
        contactPhone: '9876543210',
        address: '456 Hope Avenue',
      };
      const parseResult = ngoProfileSchema.safeParse(payload);
      expect(parseResult.success).toBe(false);
    });
  });
});
