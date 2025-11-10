import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';

import '../../../constants/token_manager.dart';
import '../../api_model/user_model/plan_model.dart';

class PlanService {
  static Future<PlanResponse?> getPlans(String type) async {
    try {
      final token = await TokenManager.getToken();
      print("This is token ${token.toString()}");

      if (token == null) {
        throw Exception('Authentication token not found');
      }
      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/status/$type'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        try {
          // First decode the JSON to check its structure
          final Map<String, dynamic> jsonData = json.decode(response.body);
          print("Decoded JSON: $jsonData");
          // Then try to parse it with your model
          return PlanResponse.fromJson(jsonData);
        } catch (parseError) {
          print("JSON parsing error: $parseError");
          print("Raw response body: ${response.body}");

          // Create a fallback response with empty data
          // return PlanResponse(
          //   success: false,
          //   message: "Failed to parse response data",
          //   data: PaymentStatusData(
          //     category: type,
          //     registrationFee: null,
          //     subscriptionPlans: [],
          //     note: "Error parsing server response",
          //   ),
          // );
        }
      } else {
        print("HTTP Error - Status: ${response.statusCode}, Body: ${response.body}");
        throw Exception('Failed to load plans: ${response.statusCode}');
      }
    } catch (e) {
      print("Service error: $e");
      return null;

      // Return a fallback response instead of throwing
      // return PlanResponse(
      //   status: false,
      //   message: "Service unavailable: $e",
      //   data: PlanData(
      //     category: type,
      //     registrationFee: null,
      //     subscriptionPlans: [],
      //     note: "Service temporarily unavailable",
      //   ),
      // );
    }
  }


}
