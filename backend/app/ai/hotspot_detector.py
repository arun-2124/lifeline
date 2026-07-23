import numpy as np
from sklearn.cluster import KMeans
from app.models.hotspot_model import HotspotDetectionRequest, HotspotDetectionResponse, HotspotCluster

class HotspotDetector:
    @staticmethod
    def detect(request: HotspotDetectionRequest) -> HotspotDetectionResponse:
        if not request.points:
            return HotspotDetectionResponse(
                city_zone=request.city_zone,
                clusters=[],
                highest_severity_cluster_id=-1
            )

        coords = np.array([[p.latitude, p.longitude] for p in request.points])
        weights = np.array([p.deficit_meals for p in request.points])

        n_clusters = min(request.clusters_count, len(request.points))
        kmeans = KMeans(n_clusters=n_clusters, random_state=42, n_init=10)
        labels = kmeans.fit_predict(coords, sample_weight=weights)

        clusters_list = []
        max_deficit = 0
        highest_severity_id = 0

        for cid in range(n_clusters):
            center_lat, center_lng = kmeans.cluster_centers_[cid]
            indices = np.where(labels == cid)[0]
            cluster_deficit = sum(weights[i] for i in indices)
            count = len(indices)

            if cluster_deficit > 300:
                severity = "CRITICAL"
            elif cluster_deficit > 100:
                severity = "HIGH"
            else:
                severity = "MODERATE"

            if cluster_deficit > max_deficit:
                max_deficit = cluster_deficit
                highest_severity_id = cid

            clusters_list.append(HotspotCluster(
                cluster_id=cid,
                center_latitude=round(float(center_lat), 6),
                center_longitude=round(float(center_lng), 6),
                severity_level=severity,
                total_deficit_meals=int(cluster_deficit),
                affected_points_count=count
            ))

        return HotspotDetectionResponse(
            city_zone=request.city_zone,
            clusters=clusters_list,
            highest_severity_cluster_id=highest_severity_id
        )
