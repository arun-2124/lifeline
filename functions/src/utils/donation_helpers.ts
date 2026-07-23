import * as ngeohash from 'ngeohash';
import { FoodCategory } from '../types/donation.types';

// CO2 savings factors (kg CO2 per kg of food saved) — based on EPA/FAO published data
const CO2_FACTORS_BY_CATEGORY: Record<FoodCategory, number> = {
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
export function computeGeohashes(lat: number, lng: number): {
  geohash: string;
  geohash4: string;
  geohash5: string;
  geohash6: string;
} {
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
export function estimateCo2Saved(
  category: FoodCategory,
  quantityKg: number
): number {
  const factor = CO2_FACTORS_BY_CATEGORY[category] ?? 2.0;
  return parseFloat((factor * quantityKg).toFixed(3));
}

/**
 * Compute total estimated CO2 across all food items.
 */
export function computeTotalCo2(
  items: { category: FoodCategory; quantity: number; unit: string }[]
): number {
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
export function normalizeToKg(quantity: number, unit: string): number {
  switch (unit) {
    case 'kg':       return quantity;
    case 'liters':   return quantity * 1.0;
    case 'servings': return quantity * 0.35;
    case 'pieces':   return quantity * 0.15;
    case 'boxes':    return quantity * 2.0;
    default:         return quantity;
  }
}

/**
 * Auto-calculate donation expiry: pickupTimeWindow.latest + 2 hours buffer.
 */
export function computeExpiresAt(latestPickup: string): string {
  const latest = new Date(latestPickup);
  latest.setHours(latest.getHours() + 2);
  return latest.toISOString();
}

/**
 * Extract unique food categories from a list of items.
 */
export function extractDistinctCategories(
  items: { category: FoodCategory }[]
): FoodCategory[] {
  return [...new Set(items.map((i) => i.category))];
}

/**
 * Extract union of all dietary tags from all food items.
 */
export function extractDietaryTags(
  items: { dietaryTags?: string[] }[]
): string[] {
  const tags = new Set<string>();
  for (const item of items) {
    if (item.dietaryTags) {
      item.dietaryTags.forEach((t) => tags.add(t));
    }
  }
  return [...tags];
}
