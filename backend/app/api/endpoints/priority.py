from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import Optional

router = APIRouter()

class PriorityRequest(BaseModel):
    donation_id: str
    quantity: float
    expiry_hours: float
    is_emergency: bool = False

class PriorityResponse(BaseModel):
    priority_score: float
    urgency_level: str
    dispatch_recommended: bool

@router.post("/priority", response_model=PriorityResponse)
def calculate_priority(request: PriorityRequest):
    try:
        # Priority Algorithm: Score based on expiry risk & quantity
        base_score = 50.0
        if request.expiry_hours <= 2:
            base_score += 40.0
        elif request.expiry_hours <= 4:
            base_score += 25.0

        if request.is_emergency:
            base_score += 10.0

        score = min(100.0, base_score)
        urgency = "CRITICAL" if score >= 80 else ("HIGH" if score >= 60 else "NORMAL")

        return PriorityResponse(
            priority_score=score,
            urgency_level=urgency,
            dispatch_recommended=score >= 60.0
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
