import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/api_constants.dart';
import '../../constants/token_manager.dart';
import '../api_model/notification_model.dart';

class NotificationServiceInApp {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<NotificationResponse> getNotifications() async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/notifications'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return NotificationResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load notifications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
