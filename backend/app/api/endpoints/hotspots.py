from fastapi import APIRouter, HTTPException
from app.models.hotspot_model import HotspotDetectionRequest, HotspotDetectionResponse
from app.ai.hotspot_detector import HotspotDetector
from app.utils.logger import logger

router = APIRouter()

@router.post("/hotspots", response_model=HotspotDetectionResponse)
def detect_hunger_hotspots(request: HotspotDetectionRequest):
    try:
        logger.info(f"Hotspot detection requested for zone: {request.city_zone}")
        return HotspotDetector.detect(request)
    except Exception as e:
        logger.error(f"Error in hotspot detection endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
