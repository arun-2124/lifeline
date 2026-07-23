from pydantic import BaseModel

class CarbonReductionRequest(BaseModel):
    food_category: str  # cooked_meal, produce, bakery, dairy, meat
    quantity_kg: float

class CarbonReductionResponse(BaseModel):
    food_category: str
    quantity_kg: float
    co2_emissions_saved_kg: float
    water_saved_liters: float
    equivalent_car_miles_saved: float
    trees_equivalent_annual: float
