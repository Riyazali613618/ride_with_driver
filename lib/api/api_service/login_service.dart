import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_endpoints.dart';

import '../../constants/api_constants.dart';
import '../api_model/login_model.dart';

class LoginService {
  static final String _baseUrl = ApiConstants.baseUrl;

  static Future<LoginModel> sendOtp(String phoneNumber) async {
    try {
      final uri = Uri.parse(_baseUrl+ ApiEndpoints.sendOtp);
      debugPrint('Sending OTP request to: ${uri.toString()}');

      final response = await http.post(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'number': phoneNumber,
        }),
      );

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');

      final jsonResponse = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return LoginModel.fromJson(jsonResponse);
      } else {
        return LoginModel(
          status: false,
          message: jsonResponse['message'] ?? 'Something went wrong.',
          data: '',
        );
      }
    } catch (e) {
      debugPrint('Exception occurred while sending OTP: $e');
      return LoginModel(
        status: false,
        message: 'Something went wrong. Please check your connection.',
        data: '',
      );
    }
  }
}
