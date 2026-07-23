import { z } from 'zod';
import { sanitizeString } from './validation';

const FOOD_CATEGORIES = [
  'cooked_meal', 'produce', 'bakery', 'dairy', 'packaged', 'beverages',
] as const;

const FOOD_CONDITIONS = ['fresh', 'good', 'near_expiry', 'expired'] as const;

const UNITS = ['kg', 'servings', 'pieces', 'liters', 'boxes'] as const;

const VISIBILITIES = ['public', 'ngo_only', 'invite_only'] as const;

const FLEXIBILITIES = ['strict', 'flexible_30min', 'flexible_1hr', 'anytime'] as const;

export const foodItemInputSchema = z.object({
  name: z.string().min(2, 'Item name must be at least 2 characters').max(100).transform(sanitizeString),
  category: z.enum(FOOD_CATEGORIES),
  quantity: z.number().positive('Quantity must be greater than 0').max(10000),
  unit: z.enum(UNITS),
  allergens: z.array(z.string().transform(sanitizeString)).optional().default([]),
  dietaryTags: z.array(z.string().transform(sanitizeString)).optional().default([]),
  condition: z.enum(FOOD_CONDITIONS),
  expiryDate: z.string().refine((val) => {
    const d = new Date(val);
    return !isNaN(d.getTime()) && d > new Date();
  }, 'Expiry date must be a valid future date'),
  photos: z.array(z.string().url('Invalid photo URL')).max(5, 'Maximum 5 photos per item').optional().default([]),
});

export const pickupAddressSchema = z.object({
  street: z.string().min(3).transform(sanitizeString),
  city: z.string().min(2).transform(sanitizeString),
  state: z.string().min(2).transform(sanitizeString),
  postalCode: z.string().min(4).transform(sanitizeString),
  country: z.string().length(2, 'Country must be ISO 3166-1 alpha-2 (e.g., "IN")').transform(sanitizeString),
  lat: z.number().min(-90).max(90),
  lng: z.number().min(-180).max(180),
});

export const pickupTimeWindowSchema = z.object({
  earliest: z.string().refine((val) => {
    const d = new Date(val);
    return !isNaN(d.getTime()) && d > new Date();
  }, 'Earliest pickup time must be in the future'),
  latest: z.string().refine((val) => {
    const d = new Date(val);
    return !isNaN(d.getTime()) && d > new Date();
  }, 'Latest pickup time must be in the future'),
  flexibility: z.enum(FLEXIBILITIES),
}).refine((data) => new Date(data.earliest) < new Date(data.latest), {
  message: 'Earliest pickup time must be before latest pickup time',
});

export const createDonationSchema = z.object({
  foodItems: z.array(foodItemInputSchema).min(1, 'At least one food item is required').max(20, 'Maximum 20 food items allowed'),
  pickupAddress: pickupAddressSchema,
  pickupTimeWindow: pickupTimeWindowSchema,
  visibility: z.enum(VISIBILITIES),
  isDraft: z.boolean(),
  idempotencyKey: z.string().min(1, 'Idempotency key is required'),
});

export const updateDonationSchema = z.object({
  donationId: z.string().min(1, 'Donation ID is required'),
  updates: z.object({
    foodItems: z.array(foodItemInputSchema).min(1).max(20).optional(),
    pickupAddress: pickupAddressSchema.optional(),
    pickupTimeWindow: pickupTimeWindowSchema.optional(),
    visibility: z.enum(VISIBILITIES).optional(),
  }),
  isPublishing: z.boolean().optional().default(false),
});

export const cancelDonationSchema = z.object({
  donationId: z.string().min(1, 'Donation ID is required'),
  reason: z.enum(['donor_withdrawal', 'quality_issue', 'other']),
});
