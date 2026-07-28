from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional
from app.models.shelf_life_model import ShelfLifeRequest, ShelfLifeResponse
from app.ai.shelf_life_estimator import ShelfLifeEstimator
from app.ai.custom_vision_classifier import LifelineCustomVisionEngine
from app.utils.logger import logger

router = APIRouter()

class VisionInspectRequest(BaseModel):
    image: Optional[str] = None
    image_base64: Optional[str] = None

@router.post("/shelf-life", response_model=ShelfLifeResponse)
def estimate_shelf_life(request: ShelfLifeRequest):
    try:
        logger.info(f"Shelf-life estimation requested for category: {request.food_category}")
        return ShelfLifeEstimator.estimate(request)
    except Exception as e:
        logger.error(f"Error in shelf-life endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/custom-vision-inspect")
def custom_vision_inspect(request: VisionInspectRequest):
    try:
        logger.info("Custom Vision Food Inspection requested")
        image_data = request.image_base64 or request.image or "default_image_payload"
        return LifelineCustomVisionEngine.inspect_food_image(image_data)
    except Exception as e:
        logger.error(f"Error in custom-vision-inspect endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
