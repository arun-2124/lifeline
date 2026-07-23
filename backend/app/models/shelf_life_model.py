from pydantic import BaseModel

class ShelfLifeRequest(BaseModel):
    food_category: str
    storage_condition: str  # Ambient, Refrigerated, Frozen
    preparation_timestamp: str  # ISO Format
    ambient_temp_celsius: float = 25.0

class ShelfLifeResponse(BaseModel):
    food_category: str
    freshness_index: float  # 0.0 - 100.0 %
    estimated_shelf_life_hours: float
    remaining_safe_hours: float
    safety_status: str  # FRESH, CONSUME_SOON, CRITICAL, EXPIRED
    recommended_action: str
