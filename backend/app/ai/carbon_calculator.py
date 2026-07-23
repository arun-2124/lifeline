from app.models.carbon_model import CarbonReductionRequest, CarbonReductionResponse

class CarbonCalculator:
    # FAO/IPCC Emission factors (kg CO2e per kg of food saved from landfill)
    EMISSION_FACTORS = {
        "meat": 14.5,
        "dairy": 4.5,
        "cooked_meal": 3.8,
        "bakery": 1.9,
        "produce": 1.4,
        "beverages": 0.8,
        "packaged": 2.1,
    }

    # Water footprint factors (liters per kg of food)
    WATER_FOOTPRINT_LITERS = {
        "meat": 15400.0,
        "dairy": 3100.0,
        "cooked_meal": 2500.0,
        "bakery": 1600.0,
        "produce": 800.0,
        "beverages": 300.0,
        "packaged": 1200.0,
    }

    @staticmethod
    def calculate(request: CarbonReductionRequest) -> CarbonReductionResponse:
        cat = request.food_category.lower()
        co2_factor = CarbonCalculator.EMISSION_FACTORS.get(cat, 2.5)
        water_factor = CarbonCalculator.WATER_FOOTPRINT_LITERS.get(cat, 1500.0)

        total_co2_saved = round(request.quantity_kg * co2_factor, 2)
        total_water_saved = round(request.quantity_kg * water_factor, 1)

        # 1 kg CO2e saved ~ 2.48 passenger vehicle miles offset
        car_miles = round(total_co2_saved * 2.48, 1)
        # 1 urban tree absorbs ~21.8 kg CO2 per year
        trees = round(total_co2_saved / 21.8, 2)

        return CarbonReductionResponse(
            food_category=request.food_category,
            quantity_kg=request.quantity_kg,
            co2_emissions_saved_kg=total_co2_saved,
            water_saved_liters=total_water_saved,
            equivalent_car_miles_saved=car_miles,
            trees_equivalent_annual=trees
        )
