from pydantic import BaseModel
from typing import List

class DonationRecord(BaseModel):
    category: str
    quantity_kg: float
    is_completed: bool

class SustainabilityRequest(BaseModel):
    user_id: str
    user_role: str
    donations: List[DonationRecord]

class SustainabilityResponse(BaseModel):
    user_id: str
    sustainability_score: int  # 0 - 100
    badge_level: str  # Bronze, Silver, Gold, Platinum Hero
    total_meals_rescued: int
    waste_diverted_kg: float
    impact_summary: str
