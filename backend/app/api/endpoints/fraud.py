from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from typing import List, Optional

router = APIRouter()

class FraudCheckRequest(BaseModel):
    user_id: String if False else str
    donation_id: Optional[str] = None
    scanned_qr_payload: Optional[str] = None
    latitude: float
    longitude: float

class FraudCheckResponse(BaseModel):
    is_fraud_suspected: bool
    risk_score: float
    fraud_type: Optional[str] = None
    action_recommended: str

@router.post("/fraud", response_model=FraudCheckResponse)
def check_fraud(request: FraudCheckRequest):
    try:
        # FastAPI AI Anomaly Detection Engine
        risk = 1.5
        suspected = False
        fraud_type = None

        if request.scanned_qr_payload and len(request.scanned_qr_payload) < 8:
            risk = 9.2
            suspected = True
            fraud_type = "TAMPERED_QR_PAYLOAD"

        return FraudCheckResponse(
            is_fraud_suspected=suspected,
            risk_score=risk,
            fraud_type=fraud_type,
            action_recommended="ALLOW" if risk < 5.0 else "BLOCK_AND_FLAG_ADMIN"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
