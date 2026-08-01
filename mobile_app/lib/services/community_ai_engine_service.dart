import 'package:mobile_app/utils/app_logger.dart';

class CommunityAiEngineService {
  /// Calculate AI Priority Score for matching recipients with surplus food
  static double calculateMatchingPriority({
    required double distanceKm,
    required int urgencyLevel, // 1 (low) to 5 (critical emergency)
    required int hoursUntilExpiry,
    required double donorTrustScore,
  }) {
    final distanceFactor = (10 - distanceKm).clamp(0, 10) * 0.4;
    final urgencyFactor = (urgencyLevel * 2) * 0.3;
    final expiryFactor = (12 - hoursUntilExpiry).clamp(0, 10) * 0.2;
    final trustFactor = (donorTrustScore * 2) * 0.1;

    final totalScore = (distanceFactor + urgencyFactor + expiryFactor + trustFactor).clamp(0.0, 10.0);
    AppLogger.i('AI Smart Matching Score: ${totalScore.toStringAsFixed(1)} / 10');
    return double.parse(totalScore.toStringAsFixed(1));
  }

  /// AI Food Quality Risk Assessment
  static Map<String, dynamic> evaluateFoodSafetyRisk({
    required String storageMethod,
    required int hoursSincePreparation,
    required bool isVeg,
  }) {
    double riskScore = 0.1; // Low risk default

    if (hoursSincePreparation > 6) riskScore += 0.4;
    if (hoursSincePreparation > 10) riskScore += 0.4;
    if (!isVeg) riskScore += 0.2;

    if (storageMethod.toLowerCase().contains('insulated') ||
        storageMethod.toLowerCase().contains('thermal') ||
        storageMethod.toLowerCase().contains('fridge')) {
      riskScore -= 0.3;
    }

    riskScore = riskScore.clamp(0.0, 1.0);
    final riskLevel = riskScore > 0.6 ? 'HIGH' : riskScore > 0.3 ? 'MEDIUM' : 'LOW';

    return {
      'riskScore': riskScore,
      'riskLevel': riskLevel,
      'recommendedShelfLifeHours': isVeg ? 8 : 5,
    };
  }
}
