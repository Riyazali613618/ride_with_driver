import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

import '../../../constants/api_constants.dart';
import '../../../constants/token_manager.dart';

class PlanService {
 // static const String baseUrl = "https://api.ridewithdriverr.com";

  static Future<Map<String, dynamic>?> getUserStatus(String type) async {
    try {
      final token = await TokenManager.getToken();
      final baseUrl = ApiConstants.baseUrl;

      final uri = Uri.parse("$baseUrl/user/status/$type");
      final response = await http.get(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },);

      debugPrint("User status response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error in getUserStatus: $e");
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getPlans({
    required String planFor,
    required String countryId,
    required String stateId,
  }) async {
    try {
      final token = await TokenManager.getToken();
      final baseUrl = ApiConstants.baseUrl;
      final uri = Uri.parse(
          "$baseUrl/user/plans/location?planFor=$planFor&countryId=$countryId&stateId=$stateId");
      print("Riyaz Ali getPlans:$uri");
      print("Riyaz Ali getPlans Token:$token");
      final response = await http.get(uri,  headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },);

      debugPrint("Plans response: ${response.body}");
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint("Error in getPlans: $e");
    }
    return null;
  }
}
