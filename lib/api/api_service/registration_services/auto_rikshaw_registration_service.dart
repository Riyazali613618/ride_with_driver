import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';

import '../../../constants/token_manager.dart';
import '../../api_model/registrations/auto_rikshaw_registration_model.dart';

class AutoRickshawService {
  static const String _logTag = 'AutoRickshawService';
  static const String _baseUrl =
      "${ApiConstants.baseUrl}/user/register/become-transporter-rickshaw";

  Future<Map<String, dynamic>> submitAutoRickshawApplication(
      AutoRickshawModel model) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        developer.log('No authentication token available', name: _logTag);
        return {
          'success': false,
          'message': 'No authentication token available'
        };
      }

      developer.log('Submitting auto rickshaw application request to $_baseUrl',
          name: _logTag);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(model.toJson()),
      );

      developer.log('Response status: ${response.statusCode}', name: _logTag);
      developer.log('Response body: ${response.body}', name: _logTag);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successful response
        return {'success': true};
      } else {
        // Error response
        developer.log('Response status code: ${response.statusCode}',
            name: _logTag);

        if (response.statusCode >= 200 && response.statusCode < 300) {
          developer.log('Driver application submitted successfully',
              name: _logTag);
          return {'success': true};
        } else {
          final errorResponse = jsonDecode(response.body);
          final errorMessage = errorResponse['message'] ?? 'Submission failed';
          developer.log('Failed to submit driver application: $errorMessage',
              name: _logTag);
          return {'success': false, 'message': errorMessage};
        }
      }
    } catch (e, stackTrace) {
      developer.log('Error submitting driver application',
          error: e, stackTrace: stackTrace, name: _logTag);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  // Helper method to show success message
  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Helper method to show error message
  static void showApiErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
