from app.models.recommendation_model import RecommendationRequest, RecommendationResponse, RecommendedItem

class MealRecommender:
    @staticmethod
    def recommend(request: RecommendationRequest) -> RecommendationResponse:
        recommended_list = []
        pref_set = set(c.lower() for c in request.preferred_categories)

        for item in request.available_donations:
            score = 0.5  # Base score

            # Category Preference Match (+0.3)
            if item.category.lower() in pref_set or "all" in pref_set:
                score += 0.3

            # Urgency / Expiry Bonus (+0.15 for short shelf life)
            if item.expiry_hours_left < 3.0:
                score += 0.15
            elif item.expiry_hours_left < 6.0:
                score += 0.08

            # Capacity Fit Bonus (+0.05)
            if item.meals_count <= request.capacity_meals:
                score += 0.05

            score = min(1.0, round(score, 2))

            reason = f"Category Match: {'Yes' if item.category.lower() in pref_set else 'Partial'} | Freshness: {item.expiry_hours_left}h remaining"
            recommended_list.append(RecommendedItem(
                donation_id=item.donation_id,
                food_name=item.food_name,
                recommendation_score=score,
                reason=reason
            ))

        recommended_list.sort(key=lambda x: x.recommendation_score, reverse=True)

        return RecommendationResponse(
            recipient_id=request.recipient_id,
            recommendations=recommended_list
        )
