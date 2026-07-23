from fastapi import APIRouter, HTTPException
from app.models.route_model import RouteOptimizationRequest, RouteOptimizationResponse
from app.ai.route_optimizer import RouteOptimizer
from app.utils.logger import logger

router = APIRouter()

@router.post("/route-optimization", response_model=RouteOptimizationResponse)
def optimize_volunteer_route(request: RouteOptimizationRequest):
    try:
        logger.info(f"Route optimization requested for volunteer: {request.volunteer_id}")
        return RouteOptimizer.optimize(request)
    except Exception as e:
        logger.error(f"Error in route optimization endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
