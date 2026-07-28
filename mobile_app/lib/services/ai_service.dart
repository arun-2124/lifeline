import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/config/app_constants.dart';
import 'package:mobile_app/utils/app_logger.dart';

abstract class AiService {
  Future<Map<String, dynamic>> matchDonorRecipients(Map<String, dynamic> requestData);
  Future<Map<String, dynamic>> predictDemand(Map<String, dynamic> requestData);
  Future<Map<String, dynamic>> detectHotspots(Map<String, dynamic> requestData);
  Future<Map<String, dynamic>> estimateShelfLife(Map<String, dynamic> requestData);
  Future<Map<String, dynamic>> classifyFoodImage(String imageBase64);
  Future<Map<String, dynamic>> optimizeRoute(Map<String, dynamic> requestData);
  Future<Map<String, dynamic>> calculateSustainabilityScore(Map<String, dynamic> requestData);
  Future<Map<String, dynamic>> calculateCarbonReduction(Map<String, dynamic> requestData);
  Future<Map<String, dynamic>> getMealRecommendations(Map<String, dynamic> requestData);
}

class AiServiceImpl implements AiService {
  final http.Client _client;
  final String _baseUrl;

  AiServiceImpl({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppConstants.baseUrl;

  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/ai$endpoint');
    AppLogger.d('AI_SERVICE: Calling POST $url');

    try {
      final response = await _client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        AppLogger.e('AI_SERVICE: HTTP ${response.statusCode} - ${response.body}');
        throw Exception('AI Service Error (${response.statusCode}): ${response.body}');
      }
    } catch (e, st) {
      AppLogger.e('AI_SERVICE: Failed call to $endpoint', e, st);
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> matchDonorRecipients(Map<String, dynamic> requestData) {
    return _post('/matching', requestData);
  }

  @override
  Future<Map<String, dynamic>> predictDemand(Map<String, dynamic> requestData) {
    return _post('/demand-prediction', requestData);
  }

  @override
  Future<Map<String, dynamic>> detectHotspots(Map<String, dynamic> requestData) {
    return _post('/hotspots', requestData);
  }

  @override
  Future<Map<String, dynamic>> estimateShelfLife(Map<String, dynamic> requestData) {
    return _post('/shelf-life', requestData);
  }

  @override
  Future<Map<String, dynamic>> classifyFoodImage(String imageBase64) {
    return _post('/custom-vision-inspect', {'image_base64': imageBase64});
  }

  @override
  Future<Map<String, dynamic>> optimizeRoute(Map<String, dynamic> requestData) {
    return _post('/route-optimization', requestData);
  }

  @override
  Future<Map<String, dynamic>> calculateSustainabilityScore(Map<String, dynamic> requestData) {
    return _post('/sustainability', requestData);
  }

  @override
  Future<Map<String, dynamic>> calculateCarbonReduction(Map<String, dynamic> requestData) {
    return _post('/carbon-reduction', requestData);
  }

  @override
  Future<Map<String, dynamic>> getMealRecommendations(Map<String, dynamic> requestData) {
    return _post('/recommendations', requestData);
  }
}
