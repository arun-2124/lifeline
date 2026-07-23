import {
  computeGeohashes,
  computeTotalCo2,
  computeExpiresAt,
  normalizeToKg,
  extractDistinctCategories,
  extractDietaryTags,
} from '../src/utils/donation_helpers';

describe('Donation Helper: computeGeohashes', () => {
  it('returns a 9-char full geohash and 4/5/6 precision prefixes', () => {
    const result = computeGeohashes(12.9716, 77.5946); // Bangalore
    expect(result.geohash.length).toBe(9);
    expect(result.geohash4.length).toBe(4);
    expect(result.geohash5.length).toBe(5);
    expect(result.geohash6.length).toBe(6);
  });

  it('produces consistent results for the same coordinates', () => {
    const a = computeGeohashes(19.076, 72.8777); // Mumbai
    const b = computeGeohashes(19.076, 72.8777);
    expect(a.geohash).toBe(b.geohash);
  });
});

describe('Donation Helper: normalizeToKg', () => {
  it('returns quantity as-is for kg unit', () => {
    expect(normalizeToKg(10, 'kg')).toBe(10);
  });

  it('converts servings to kg (0.35 per serving)', () => {
    expect(normalizeToKg(4, 'servings')).toBeCloseTo(1.4, 2);
  });

  it('converts pieces to kg (0.15 per piece)', () => {
    expect(normalizeToKg(20, 'pieces')).toBeCloseTo(3.0, 2);
  });

  it('converts boxes to kg (2.0 per box)', () => {
    expect(normalizeToKg(5, 'boxes')).toBe(10.0);
  });
});

describe('Donation Helper: computeTotalCo2', () => {
  it('calculates CO2 savings across multiple food categories', () => {
    const items = [
      { category: 'cooked_meal' as const, quantity: 2, unit: 'kg' },
      { category: 'produce' as const, quantity: 3, unit: 'kg' },
    ];
    const co2 = computeTotalCo2(items);
    // cooked_meal: 2 * 2.5 = 5.0 | produce: 3 * 1.8 = 5.4 → total: 10.4
    expect(co2).toBeCloseTo(10.4, 1);
  });

  it('returns 0 for empty item list', () => {
    expect(computeTotalCo2([])).toBe(0);
  });
});

describe('Donation Helper: computeExpiresAt', () => {
  it('adds exactly 2 hours to the latest pickup time', () => {
    const latest = new Date('2026-08-01T10:00:00.000Z').toISOString();
    const expires = computeExpiresAt(latest);
    expect(new Date(expires).getTime()).toBe(new Date('2026-08-01T12:00:00.000Z').getTime());
  });
});

describe('Donation Helper: extractDistinctCategories', () => {
  it('deduplicates categories from food items', () => {
    const items = [
      { category: 'produce' as const },
      { category: 'produce' as const },
      { category: 'bakery' as const },
    ];
    const cats = extractDistinctCategories(items);
    expect(cats).toHaveLength(2);
    expect(cats).toContain('produce');
    expect(cats).toContain('bakery');
  });
});

describe('Donation Helper: extractDietaryTags', () => {
  it('merges and deduplicates dietary tags across all items', () => {
    const items = [
      { dietaryTags: ['vegan', 'halal'] },
      { dietaryTags: ['halal', 'kosher'] },
    ];
    const tags = extractDietaryTags(items);
    expect(tags).toHaveLength(3);
    expect(tags).toContain('vegan');
    expect(tags).toContain('halal');
    expect(tags).toContain('kosher');
  });

  it('returns empty array when no dietary tags are present', () => {
    expect(extractDietaryTags([{}, {}])).toHaveLength(0);
  });
});
