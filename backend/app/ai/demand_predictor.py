import datetime
import numpy as np
from sklearn.linear_model import LinearRegression
from app.models.demand_model import DemandPredictionRequest, DemandPredictionResponse, DailyDemandForecast

class DemandPredictor:
    @staticmethod
    def predict(request: DemandPredictionRequest) -> DemandPredictionResponse:
        # Synthetic historical training baseline
        # In production, fetch historical daily request logs from Firestore
        days_hist = 30
        X_hist = np.arange(days_hist).reshape(-1, 1)
        # Base demand trend with weekly cycle fluctuation
        y_hist = 150 + 1.2 * X_hist.flatten() + 20 * np.sin(X_hist.flatten() * 2 * np.pi / 7) + np.random.normal(0, 5, days_hist)

        model = LinearRegression()
        model.fit(X_hist, y_hist)

        forecasts = []
        base_date = datetime.datetime.strptime(request.target_date, "%Y-%m-%d")

        for i in range(request.forecast_days):
            future_day = days_hist + i
            pred_val = int(model.predict([[future_day]])[0])
            pred_val = max(20, pred_val)

            date_str = (base_date + datetime.timedelta(days=i)).strftime("%Y-%m-%d")
            lower = max(10, int(pred_val * 0.85))
            upper = int(pred_val * 1.15)

            forecasts.append(DailyDemandForecast(
                date=date_str,
                predicted_meals_needed=pred_val,
                confidence_lower_bound=lower,
                confidence_upper_bound=upper
            ))

        total_demand = sum(f.predicted_meals_needed for f in forecasts)

        if forecasts[-1].predicted_meals_needed > forecasts[0].predicted_meals_needed * 1.05:
            trend = "INCREASING"
        elif forecasts[-1].predicted_meals_needed < forecasts[0].predicted_meals_needed * 0.95:
            trend = "DECREASING"
        else:
            trend = "STABLE"

        return DemandPredictionResponse(
            region_id=request.region_id,
            food_category=request.food_category,
            forecast=forecasts,
            total_projected_demand=total_demand,
            trend=trend
        )
