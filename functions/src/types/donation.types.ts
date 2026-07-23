
export type FoodCategory =
  | 'cooked_meal'
  | 'produce'
  | 'bakery'
  | 'dairy'
  | 'packaged'
  | 'beverages';

export type FoodCondition = 'fresh' | 'good' | 'near_expiry' | 'expired';

export type DonationStatus =
  | 'draft'
  | 'published'
  | 'matched'
  | 'in_transit'
  | 'delivered'
  | 'expired'
  | 'cancelled';

export type DonationVisibility = 'public' | 'ngo_only' | 'invite_only';

export type PickupFlexibility =
  | 'strict'
  | 'flexible_30min'
  | 'flexible_1hr'
  | 'anytime';

export interface AiClassificationResult {
  status: 'pending' | 'completed' | 'failed';
  category?: FoodCategory;
  confidence?: number;
  freshnessScore?: number;
  estimatedServings?: number;
  detectedAllergens?: string[];
  analyzedAt?: string;
  modelVersion?: string;
}

export interface FoodItemInput {
  itemId?: string;
  name: string;
  category: FoodCategory;
  quantity: number;
  unit: 'kg' | 'servings' | 'pieces' | 'liters' | 'boxes';
  allergens?: string[];
  dietaryTags?: string[];
  condition: FoodCondition;
  expiryDate: string; // ISO String
  photos?: string[];
}

export interface FoodItemDocument extends FoodItemInput {
  itemId: string;
  photos: string[];
  originalPhotos: string[];
  aiClassification?: AiClassificationResult;
}

export interface PickupAddress {
  street: string;
  city: string;
  state: string;
  postalCode: string;
  country: string;
  lat: number;
  lng: number;
  geohash: string;  // 9-char
  geohash4: string; // ~20km
  geohash5: string; // ~5km
  geohash6: string; // ~1km
}

export interface PickupTimeWindow {
  earliest: string; // ISO String
  latest: string;   // ISO String
  flexibility: PickupFlexibility;
}

export interface DonationDocument {
  donationId: string;
  donorId: string;
  donorOrgName: string;
  foodItems: FoodItemDocument[];
  totalQuantityKg: number;
  totalEstimatedServings: number;
  foodCategories: FoodCategory[];
  dietaryTags: string[];
  pickupAddress: PickupAddress;
  pickupTimeWindow: PickupTimeWindow;
  status: DonationStatus;
  visibility: DonationVisibility;
  matchedRequestId?: string;
  matchedNgoId?: string;
  matchedNgoName?: string;
  matchConfirmedAt?: string;
  deliveryType?: 'self_pickup' | 'volunteer' | 'delivery_partner';
  assignedVolunteerId?: string;
  assignedDeliveryPartnerId?: string;
  handoffQrCode?: string;
  deliveryQrCode?: string;
  qrGeneratedAt?: string;
  estimatedCo2SavedKg: number;
  actualCo2SavedKg: number;
  createdAt: string;
  publishedAt?: string;
  expiresAt: string;
  completedAt?: string;
  cancelledAt?: string;
  cancelledReason?: string;
  cancelledBy?: string;
  aiMatchScore?: number;
  aiRecommendedNgos?: string[];
  source: 'app' | 'api' | 'bulk_upload' | 'voice';
  version: number;
  isDeleted: boolean;
  deletedAt?: string;
  deletedBy?: string;
}

export interface CreateDonationPayload {
  foodItems: FoodItemInput[];
  pickupAddress: {
    street: string;
    city: string;
    state: string;
    postalCode: string;
    country: string;
    lat: number;
    lng: number;
  };
  pickupTimeWindow: PickupTimeWindow;
  visibility: DonationVisibility;
  photos?: string[];
  isDraft: boolean;
  idempotencyKey: string;
}

export interface UpdateDonationPayload {
  donationId: string;
  updates: Partial<CreateDonationPayload>;
  isPublishing?: boolean;
}

export interface CancelDonationPayload {
  donationId: string;
  reason: string;
}
