import datetime
import math
from app.models.shelf_life_model import ShelfLifeRequest, ShelfLifeResponse

class ShelfLifeEstimator:
    # Base shelf life in hours under baseline conditions (20°C ambient, 4°C refrigerated)
    BASE_SHELF_LIFE_HOURS = {
        "cooked_meal": 6.0,
        "produce": 72.0,
        "bakery": 48.0,
        "dairy": 12.0,
        "packaged": 168.0,
        "beverages": 24.0,
    }

    @staticmethod
    def estimate(request: ShelfLifeRequest) -> ShelfLifeResponse:
        cat = request.food_category.lower()
        base_hours = ShelfLifeEstimator.BASE_SHELF_LIFE_HOURS.get(cat, 12.0)

        # Storage Multiplier
        storage = request.storage_condition.lower()
        if storage == "refrigerated":
            storage_mult = 2.5
        elif storage == "frozen":
            storage_mult = 10.0
        else:
            storage_mult = 1.0

        # Temperature Q10 Temperature Coefficient (decay accelerates with temperature)
        temp_delta = max(0.0, request.ambient_temp_celsius - 20.0)
        temp_decay_factor = math.pow(1.1, temp_delta)

        adjusted_total_hours = (base_hours * storage_mult) / temp_decay_factor

        # Calculate Elapsed Hours
        try:
            prep_time = datetime.datetime.fromisoformat(request.preparation_timestamp.replace('Z', '+00:00'))
            now = datetime.datetime.now(datetime.timezone.utc)
            elapsed_hours = max(0.0, (now - prep_time).total_seconds() / 3600.0)
        except Exception:
            elapsed_hours = 1.0

        remaining_hours = max(0.0, adjusted_total_hours - elapsed_hours)
        freshness_pct = max(0.0, min(100.0, (remaining_hours / adjusted_total_hours) * 100.0))

        if freshness_pct > 70.0:
            status = "FRESH"
            recommendation = "Safe for redistribution. High quality surplus food."
        elif freshness_pct > 30.0:
            status = "CONSUME_SOON"
            recommendation = "Priority dispatch recommended. Distribute within 2 hours."
        elif freshness_pct > 0.0:
            status = "CRITICAL"
            recommendation = "Urgent consumption required. Immediate pickup needed."
        else:
            status = "EXPIRED"
            recommendation = "Unsafe for human consumption. Route to composting / biowaste facility."

        return ShelfLifeResponse(
            food_category=request.food_category,
            freshness_index=round(freshness_pct, 1),
            estimated_shelf_life_hours=round(adjusted_total_hours, 1),
            remaining_safe_hours=round(remaining_hours, 1),
            safety_status=status,
            recommended_action=recommendation
        )
