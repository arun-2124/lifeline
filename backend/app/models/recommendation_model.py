from pydantic import BaseModel
from typing import List

class FoodDonationItem(BaseModel):
    donation_id: str
    food_name: str
    category: str
    quantity_kg: float
    meals_count: int
    expiry_hours_left: float

class RecommendationRequest(BaseModel):
    recipient_id: str
    preferred_categories: List[str]
    capacity_meals: int
    available_donations: List[FoodDonationItem]

class RecommendedItem(BaseModel):
    donation_id: str
    food_name: str
    recommendation_score: float  # 0.0 - 1.0
    reason: str

class RecommendationResponse(BaseModel):
    recipient_id: str
    recommendations: List[RecommendedItem]
