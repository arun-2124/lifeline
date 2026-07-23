from pydantic import BaseModel, Field
from typing import List, Optional

class RecipientCandidate(BaseModel):
    id: str
    name: str
    role: str  # NGO or Beneficiary
    latitude: float
    longitude: float
    capacity_meals: int
    urgency_level: int = Field(default=1, ge=1, le=5)  # 1 = Low, 5 = Critical
    historical_fulfillment_rate: float = Field(default=0.9, ge=0.0, le=1.0)

class MatchingRequest(BaseModel):
    donation_id: str
    food_name: str
    food_category: str
    quantity: float
    number_of_meals: int
    latitude: float
    longitude: float
    candidates: List[RecipientCandidate]

class MatchResult(BaseModel):
    candidate_id: str
    candidate_name: str
    match_score: float  # 0.0 - 100.0
    distance_km: float
    estimated_delivery_mins: int
    recommendation_reason: str

class MatchingResponse(BaseModel):
    donation_id: str
    matches: List[MatchResult]
    total_candidates_scored: int
