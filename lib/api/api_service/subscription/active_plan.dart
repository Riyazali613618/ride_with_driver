import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/token_manager.dart';

import '../../api_model/subscription/active_plan_model.dart';

class SubscriptionService {
  final String baseUrl;

  SubscriptionService({required this.baseUrl});

  Future<SubscriptionResponse> getSubscriptionDetails() async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/register/subscriptions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15)); // Add timeout
      print('Bearer $token');
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Raw data of plans ${response.body}");
        return SubscriptionResponse.fromJson(data);
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        throw ApiException(
          errorData['message'] ?? 'Failed to load subscription details',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is ApiException) {
        throw e;
      } else {
        throw ApiException(
          'Network error: ${e.toString()}',
          0,
        );
      }
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException: $message (Code: $statusCode)';
}
