from fastapi import APIRouter, HTTPException
from app.models.shelf_life_model import ShelfLifeRequest, ShelfLifeResponse
from app.ai.shelf_life_estimator import ShelfLifeEstimator
from app.utils.logger import logger

router = APIRouter()

@router.post("/shelf-life", response_model=ShelfLifeResponse)
def estimate_shelf_life(request: ShelfLifeRequest):
    try:
        logger.info(f"Shelf-life estimation requested for category: {request.food_category}")
        return ShelfLifeEstimator.estimate(request)
    except Exception as e:
        logger.error(f"Error in shelf-life endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
