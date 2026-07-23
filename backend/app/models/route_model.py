from pydantic import BaseModel
from typing import List

class Waypoint(BaseModel):
    id: str
    name: str
    latitude: float
    longitude: float
    type: str  # START, PICKUP, DROPOFF

class RouteOptimizationRequest(BaseModel):
    volunteer_id: str
    start_location: Waypoint
    waypoints: List[Waypoint]

class OptimizedStep(BaseModel):
    step_number: int
    waypoint_id: str
    name: str
    type: str
    distance_from_prev_km: float
    estimated_travel_mins: int

class RouteOptimizationResponse(BaseModel):
    volunteer_id: str
    optimized_sequence: List[OptimizedStep]
    total_distance_km: float
    total_estimated_mins: int
