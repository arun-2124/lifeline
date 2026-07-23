from fastapi import APIRouter, HTTPException
from app.models.matching_model import MatchingRequest, MatchingResponse
from app.ai.matcher import SmartMatcher
from app.utils.logger import logger

router = APIRouter()

@router.post("/matching", response_model=MatchingResponse)
def match_donor_recipients(request: MatchingRequest):
    try:
        logger.info(f"AI Matching requested for donation_id: {request.donation_id}")
        return SmartMatcher.match(request)
    except Exception as e:
        logger.error(f"Error in matching endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
