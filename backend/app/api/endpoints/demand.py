from fastapi import APIRouter, HTTPException
from app.models.demand_model import DemandPredictionRequest, DemandPredictionResponse
from app.ai.demand_predictor import DemandPredictor
from app.utils.logger import logger

router = APIRouter()

@router.post("/demand-prediction", response_model=DemandPredictionResponse)
def predict_food_demand(request: DemandPredictionRequest):
    try:
        logger.info(f"Demand prediction requested for region: {request.region_id}")
        return DemandPredictor.predict(request)
    except Exception as e:
        logger.error(f"Error in demand prediction endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
