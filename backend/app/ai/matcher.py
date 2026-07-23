import numpy as np
from app.models.matching_model import MatchingRequest, MatchingResponse, MatchResult
from app.services.maps_service import MapsService

class SmartMatcher:
    @staticmethod
    def match(request: MatchingRequest) -> MatchingResponse:
        results = []

        for candidate in request.candidates:
            # 1. Distance Calculation
            dist_km = MapsService.haversine_distance(
                request.latitude, request.longitude,
                candidate.latitude, candidate.longitude
            )

            # Distance Score: Max 30 points (decaying with distance)
            distance_score = max(0.0, 30.0 - (dist_km * 1.5))

            # 2. Capacity Score: Max 30 points (ability to handle donation volume)
            cap_ratio = min(1.0, candidate.capacity_meals / max(1, request.number_of_meals))
            capacity_score = cap_ratio * 30.0

            # 3. Urgency Score: Max 25 points (scaled 1-5 level)
            urgency_score = (candidate.urgency_level / 5.0) * 25.0

            # 4. Reliability Score: Max 15 points
            reliability_score = candidate.historical_fulfillment_rate * 15.0

            # Total Composite Score
            total_score = round(distance_score + capacity_score + urgency_score + reliability_score, 1)
            total_score = min(100.0, max(0.0, total_score))

            travel_mins = int(dist_km * 3.0 + 5)
            reason = f"Proximity: {dist_km}km | Urgency Level {candidate.urgency_level}/5 | Capacity Match: {int(cap_ratio*100)}%"

            results.append(MatchResult(
                candidate_id=candidate.id,
                candidate_name=candidate.name,
                match_score=total_score,
                distance_km=dist_km,
                estimated_delivery_mins=travel_mins,
                recommendation_reason=reason
            ))

        # Sort candidate matches by match_score descending
        results.sort(key=lambda x: x.match_score, reverse=True)

        return MatchingResponse(
            donation_id=request.donation_id,
            matches=results,
            total_candidates_scored=len(results)
        )
