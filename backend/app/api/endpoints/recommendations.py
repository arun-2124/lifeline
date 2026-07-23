from fastapi import APIRouter, HTTPException
from app.models.recommendation_model import RecommendationRequest, RecommendationResponse
from app.ai.recommender import MealRecommender
from app.utils.logger import logger

router = APIRouter()

@router.post("/recommendations", response_model=RecommendationResponse)
def get_rescue_meal_recommendations(request: RecommendationRequest):
    try:
        logger.info(f"Meal recommendations requested for recipient: {request.recipient_id}")
        return MealRecommender.recommend(request)
    except Exception as e:
        logger.error(f"Error in recommendations endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
