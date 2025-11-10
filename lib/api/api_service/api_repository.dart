import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/api_endpoints.dart';
import 'package:r_w_r/constants/token_manager.dart';

/// A single centralized repository to manage all API calls.
///
/// This class wraps the existing endpoints and provides a consistent
/// interface for BLoCs. It can be gradually adopted by screens.
class ApiRepository {
  final String baseUrl;
  final http.Client _client;

  ApiRepository({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? ApiConstants.baseUrl,
        _client = client ?? http.Client();

  Future<Map<String, dynamic>> _authedPost(String path, Map<String, dynamic> body) async {
    final token = await TokenManager.getToken();
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
    print("response we got:${response.body} ${body}");
    return _decodeResponse(response);
  }

  Future<Map<String, dynamic>> _authedGet(String path) async {
    final token = await TokenManager.getToken();
    final uri = Uri.parse('$baseUrl$path');
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    return _decodeResponse(response);
  }

  Map<String, dynamic> _decodeResponse(http.Response response) {
    final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonMap;
    }
    throw ApiException(
      statusCode: response.statusCode,
      message: jsonMap['message']?.toString() ?? 'Request failed',
      body: response.body,
    );
  }

  // Authentication
  Future<Map<String, dynamic>> sendOtp({required String number}) async {
    return _authedPost(ApiEndpoints.sendOtp, {'mobileNumber': number});
  }

  Future<Map<String, dynamic>> verifyOtp({required String number, required String otp}) async {
    return _authedPost(ApiEndpoints.verifyOtp, {'number': number, 'otp': otp});
  }

  Future<Map<String, dynamic>> logout() async {
    return _authedPost(ApiEndpoints.logout, {});
  }

  // User
  Future<Map<String, dynamic>> getHome({String? fcmToken}) async {
    return _authedPost(ApiEndpoints.userHome, {'fcmToken': fcmToken ?? ''});
  }

  Future<Map<String, dynamic>> getUserProfile() async {
    return _authedGet(ApiEndpoints.userProfile);
  }

  Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> payload) async {
    return _authedPost(ApiEndpoints.updateProfile, payload);
  }

  Future<Map<String, dynamic>> getPaymentStatus() async {
    return _authedGet(ApiEndpoints.paymentStatus);
  }

  // Vehicles
  Future<Map<String, dynamic>> addVehicle(Map<String, dynamic> payload) async {
    return _authedPost(ApiEndpoints.addVehicle, payload);
  }

  Future<Map<String, dynamic>> searchVehicles(Map<String, dynamic> payload) async {
    return _authedPost(ApiEndpoints.searchVehicles, payload);
  }

  // Chat
  Future<Map<String, dynamic>> startChat(Map<String, dynamic> payload) async {
    return _authedPost(ApiEndpoints.startChat, payload);
  }

  Future<Map<String, dynamic>> fetchChatHistory(Map<String, dynamic> payload) async {
    return _authedPost(ApiEndpoints.chatHistory, payload);
  }

  // Payments
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> payload) async {
    return _authedPost(ApiEndpoints.createPayment, payload);
  }

  Future<Map<String, dynamic>> verifyPayment(Map<String, dynamic> payload) async {
    return _authedPost(ApiEndpoints.verifyPayment, payload);
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String? body;

  ApiException({required this.statusCode, required this.message, this.body});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

