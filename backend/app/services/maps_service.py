import math
import requests
from app.config.settings import settings
from app.utils.logger import logger

class MapsService:
    @staticmethod
    def haversine_distance(lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """
        Calculate the great-circle distance between two points in km.
        """
        R = 6371.0  # Earth radius in kilometers

        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = (math.sin(dlat / 2) ** 2 +
             math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
             math.sin(dlon / 2) ** 2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return round(R * c, 2)

    @staticmethod
    def get_distance_matrix(origins: list, destinations: list) -> dict:
        """
        Queries Google Maps Distance Matrix API or falls back to Haversine calculations.
        """
        if not settings.GOOGLE_MAPS_API_KEY or settings.GOOGLE_MAPS_API_KEY == "YOUR_GOOGLE_MAPS_API_KEY":
            logger.info("Using Haversine distance fallback for distance matrix.")
            matrix = []
            for orig in origins:
                row = []
                for dest in destinations:
                    dist = MapsService.haversine_distance(orig[0], orig[1], dest[0], dest[1])
                    row.append({"distance_km": dist, "duration_mins": int(dist * 3.0 + 5)})
                matrix.append(row)
            return {"status": "OK", "rows": matrix}

        try:
            url = "https://maps.googleapis.com/maps/api/distancematrix/json"
            orig_str = "|".join([f"{o[0]},{o[1]}" for o in origins])
            dest_str = "|".join([f"{d[0]},{d[1]}" for d in destinations])
            
            params = {
                "origins": orig_str,
                "destinations": dest_str,
                "key": settings.GOOGLE_MAPS_API_KEY,
            }
            res = requests.get(url, params=params, timeout=5)
            return res.json()
        except Exception as e:
            logger.error(f"Google Maps API call failed: {e}. Falling back to Haversine.")
            return MapsService.get_distance_matrix(origins, destinations)
