"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.cancelDonationSchema = exports.updateDonationSchema = exports.createDonationSchema = exports.pickupTimeWindowSchema = exports.pickupAddressSchema = exports.foodItemInputSchema = void 0;
const zod_1 = require("zod");
const validation_1 = require("./validation");
const FOOD_CATEGORIES = [
    'cooked_meal', 'produce', 'bakery', 'dairy', 'packaged', 'beverages',
];
const FOOD_CONDITIONS = ['fresh', 'good', 'near_expiry', 'expired'];
const UNITS = ['kg', 'servings', 'pieces', 'liters', 'boxes'];
const VISIBILITIES = ['public', 'ngo_only', 'invite_only'];
const FLEXIBILITIES = ['strict', 'flexible_30min', 'flexible_1hr', 'anytime'];
exports.foodItemInputSchema = zod_1.z.object({
    name: zod_1.z.string().min(2, 'Item name must be at least 2 characters').max(100).transform(validation_1.sanitizeString),
    category: zod_1.z.enum(FOOD_CATEGORIES),
    quantity: zod_1.z.number().positive('Quantity must be greater than 0').max(10000),
    unit: zod_1.z.enum(UNITS),
    allergens: zod_1.z.array(zod_1.z.string().transform(validation_1.sanitizeString)).optional().default([]),
    dietaryTags: zod_1.z.array(zod_1.z.string().transform(validation_1.sanitizeString)).optional().default([]),
    condition: zod_1.z.enum(FOOD_CONDITIONS),
    expiryDate: zod_1.z.string().refine((val) => {
        const d = new Date(val);
        return !isNaN(d.getTime()) && d > new Date();
    }, 'Expiry date must be a valid future date'),
    photos: zod_1.z.array(zod_1.z.string().url('Invalid photo URL')).max(5, 'Maximum 5 photos per item').optional().default([]),
});
exports.pickupAddressSchema = zod_1.z.object({
    street: zod_1.z.string().min(3).transform(validation_1.sanitizeString),
    city: zod_1.z.string().min(2).transform(validation_1.sanitizeString),
    state: zod_1.z.string().min(2).transform(validation_1.sanitizeString),
    postalCode: zod_1.z.string().min(4).transform(validation_1.sanitizeString),
    country: zod_1.z.string().length(2, 'Country must be ISO 3166-1 alpha-2 (e.g., "IN")').transform(validation_1.sanitizeString),
    lat: zod_1.z.number().min(-90).max(90),
    lng: zod_1.z.number().min(-180).max(180),
});
exports.pickupTimeWindowSchema = zod_1.z.object({
    earliest: zod_1.z.string().refine((val) => {
        const d = new Date(val);
        return !isNaN(d.getTime()) && d > new Date();
    }, 'Earliest pickup time must be in the future'),
    latest: zod_1.z.string().refine((val) => {
        const d = new Date(val);
        return !isNaN(d.getTime()) && d > new Date();
    }, 'Latest pickup time must be in the future'),
    flexibility: zod_1.z.enum(FLEXIBILITIES),
}).refine((data) => new Date(data.earliest) < new Date(data.latest), {
    message: 'Earliest pickup time must be before latest pickup time',
});
exports.createDonationSchema = zod_1.z.object({
    foodItems: zod_1.z.array(exports.foodItemInputSchema).min(1, 'At least one food item is required').max(20, 'Maximum 20 food items allowed'),
    pickupAddress: exports.pickupAddressSchema,
    pickupTimeWindow: exports.pickupTimeWindowSchema,
    visibility: zod_1.z.enum(VISIBILITIES),
    isDraft: zod_1.z.boolean(),
    idempotencyKey: zod_1.z.string().min(1, 'Idempotency key is required'),
});
exports.updateDonationSchema = zod_1.z.object({
    donationId: zod_1.z.string().min(1, 'Donation ID is required'),
    updates: zod_1.z.object({
        foodItems: zod_1.z.array(exports.foodItemInputSchema).min(1).max(20).optional(),
        pickupAddress: exports.pickupAddressSchema.optional(),
        pickupTimeWindow: exports.pickupTimeWindowSchema.optional(),
        visibility: zod_1.z.enum(VISIBILITIES).optional(),
    }),
    isPublishing: zod_1.z.boolean().optional().default(false),
});
exports.cancelDonationSchema = zod_1.z.object({
    donationId: zod_1.z.string().min(1, 'Donation ID is required'),
    reason: zod_1.z.enum(['donor_withdrawal', 'quality_issue', 'other']),
});
//# sourceMappingURL=donation_schemas.js.map