from app.models.sustainability_model import SustainabilityRequest, SustainabilityResponse

class SustainabilityCalculator:
    @staticmethod
    def calculate(request: SustainabilityRequest) -> SustainabilityResponse:
        completed = [d for d in request.donations if d.is_completed]
        total_kg = sum(d.quantity_kg for d in completed)
        total_meals = int(total_kg * 2.5)

        # Calculate Score (0-100)
        base_score = min(100, int((total_kg / 50.0) * 100))

        if total_kg >= 200:
            badge = "Platinum Hero"
        elif total_kg >= 100:
            badge = "Gold Rescue Champion"
        elif total_kg >= 50:
            badge = "Silver Saver"
        else:
            badge = "Bronze Contributor"

        summary = f"You have saved {total_kg:.1f} kg of surplus food and provided {total_meals} nutritious meals to communities in need."

        return SustainabilityResponse(
            user_id=request.user_id,
            sustainability_score=base_score,
            badge_level=badge,
            total_meals_rescued=total_meals,
            waste_diverted_kg=round(total_kg, 2),
            impact_summary=summary
        )
