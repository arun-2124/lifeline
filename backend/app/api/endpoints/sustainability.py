from fastapi import APIRouter, HTTPException
from app.models.sustainability_model import SustainabilityRequest, SustainabilityResponse
from app.ai.sustainability_calculator import SustainabilityCalculator
from app.utils.logger import logger

router = APIRouter()

@router.post("/sustainability", response_model=SustainabilityResponse)
def calculate_sustainability_score(request: SustainabilityRequest):
    try:
        logger.info(f"Sustainability score requested for user: {request.user_id}")
        return SustainabilityCalculator.calculate(request)
    except Exception as e:
        logger.error(f"Error in sustainability endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
