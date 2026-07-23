from pydantic import BaseModel
from typing import List

class DataPoint(BaseModel):
    latitude: float
    longitude: float
    deficit_meals: int

class HotspotDetectionRequest(BaseModel):
    city_zone: str
    points: List[DataPoint]
    clusters_count: int = 3

class HotspotCluster(BaseModel):
    cluster_id: int
    center_latitude: float
    center_longitude: float
    severity_level: str  # CRITICAL, HIGH, MODERATE
    total_deficit_meals: int
    affected_points_count: int

class HotspotDetectionResponse(BaseModel):
    city_zone: str
    clusters: List[HotspotCluster]
    highest_severity_cluster_id: int
