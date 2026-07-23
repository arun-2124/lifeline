from pydantic import BaseModel
from typing import List, Dict

class DemandPredictionRequest(BaseModel):
    region_id: str
    food_category: str
    target_date: str  # YYYY-MM-DD
    forecast_days: int = 7

class DailyDemandForecast(BaseModel):
    date: str
    predicted_meals_needed: int
    confidence_lower_bound: int
    confidence_upper_bound: int

class DemandPredictionResponse(BaseModel):
    region_id: str
    food_category: str
    forecast: List[DailyDemandForecast]
    total_projected_demand: int
    trend: str  # INCREASING, STABLE, DECREASING
