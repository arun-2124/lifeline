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
exports.computeGeohashes = computeGeohashes;
exports.estimateCo2Saved = estimateCo2Saved;
exports.computeTotalCo2 = computeTotalCo2;
exports.normalizeToKg = normalizeToKg;
exports.computeExpiresAt = computeExpiresAt;
exports.extractDistinctCategories = extractDistinctCategories;
exports.extractDietaryTags = extractDietaryTags;
const ngeohash = __importStar(require("ngeohash"));
// CO2 savings factors (kg CO2 per kg of food saved) — based on EPA/FAO published data
const CO2_FACTORS_BY_CATEGORY = {
    cooked_meal: 2.5,
    produce: 1.8,
    bakery: 1.2,
    dairy: 3.2,
    packaged: 2.0,
    beverages: 0.9,
};
/**
 * Compute geohashes at 4, 5, 6, and 9 character precisions from lat/lng.
 */
function computeGeohashes(lat, lng) {
    const geohash = ngeohash.encode(lat, lng, 9);
    return {
        geohash,
        geohash4: geohash.substring(0, 4),
        geohash5: geohash.substring(0, 5),
        geohash6: geohash.substring(0, 6),
    };
}
/**
 * Estimate CO2 saved in kg based on food category and weight.
 * Falls back to a neutral default if category is unrecognized.
 */
function estimateCo2Saved(category, quantityKg) {
    const factor = CO2_FACTORS_BY_CATEGORY[category] ?? 2.0;
    return parseFloat((factor * quantityKg).toFixed(3));
}
/**
 * Compute total estimated CO2 across all food items.
 */
function computeTotalCo2(items) {
    let total = 0;
    for (const item of items) {
        const kg = normalizeToKg(item.quantity, item.unit);
        total += estimateCo2Saved(item.category, kg);
    }
    return parseFloat(total.toFixed(3));
}
/**
 * Normalize a quantity to kg for CO2 + matching calculations.
 */
function normalizeToKg(quantity, unit) {
    switch (unit) {
        case 'kg': return quantity;
        case 'liters': return quantity * 1.0;
        case 'servings': return quantity * 0.35;
        case 'pieces': return quantity * 0.15;
        case 'boxes': return quantity * 2.0;
        default: return quantity;
    }
}
/**
 * Auto-calculate donation expiry: pickupTimeWindow.latest + 2 hours buffer.
 */
function computeExpiresAt(latestPickup) {
    const latest = new Date(latestPickup);
    latest.setHours(latest.getHours() + 2);
    return latest.toISOString();
}
/**
 * Extract unique food categories from a list of items.
 */
function extractDistinctCategories(items) {
    return [...new Set(items.map((i) => i.category))];
}
/**
 * Extract union of all dietary tags from all food items.
 */
function extractDietaryTags(items) {
    const tags = new Set();
    for (const item of items) {
        if (item.dietaryTags) {
            item.dietaryTags.forEach((t) => tags.add(t));
        }
    }
    return [...tags];
}
//# sourceMappingURL=donation_helpers.js.map