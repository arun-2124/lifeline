from fastapi import APIRouter, HTTPException
from app.models.carbon_model import CarbonReductionRequest, CarbonReductionResponse
from app.ai.carbon_calculator import CarbonCalculator
from app.utils.logger import logger

router = APIRouter()

@router.post("/carbon-reduction", response_model=CarbonReductionResponse)
def calculate_carbon_reduction(request: CarbonReductionRequest):
    try:
        logger.info(f"Carbon reduction calculation requested for category: {request.food_category}")
        return CarbonCalculator.calculate(request)
    except Exception as e:
        logger.error(f"Error in carbon reduction endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
