from fastapi import APIRouter
from app.api.endpoints import (
    matching,
    demand,
    hotspots,
    shelf_life,
    route_optimization,
    sustainability,
    carbon,
    recommendations,
    fraud,
    priority,
)

api_router = APIRouter()

api_router.include_router(matching.router, prefix="/ai", tags=["Smart Matching"])
api_router.include_router(demand.router, prefix="/ai", tags=["Demand Prediction"])
api_router.include_router(hotspots.router, prefix="/ai", tags=["Hunger Hotspots"])
api_router.include_router(shelf_life.router, prefix="/ai", tags=["Shelf Life Prediction"])
api_router.include_router(route_optimization.router, prefix="/ai", tags=["Route Optimization"])
api_router.include_router(sustainability.router, prefix="/ai", tags=["Sustainability Score"])
api_router.include_router(carbon.router, prefix="/ai", tags=["Carbon Reduction"])
api_router.include_router(recommendations.router, prefix="/ai", tags=["Meal Recommendations"])
api_router.include_router(fraud.router, prefix="/ai", tags=["AI Fraud Detection"])
api_router.include_router(priority.router, prefix="/ai", tags=["AI Priority Scoring"])
