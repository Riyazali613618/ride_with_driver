import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/api/api_model/registrations/auto_rikshaw_registration_model.dart';
import 'package:r_w_r/constants/api_constants.dart';

import '../../../constants/token_manager.dart';
import '../../api_model/registrations/e-rikashaw_registration_model.dart';

class BecomeErickshawService {
  static const String _logTag = 'BecomeErickshawService';
  static const String _baseUrl =
      "${ApiConstants.baseUrl}/user/become-rickshaw";

  Future<Map<String, dynamic>> submitErickshawApplication(
      AutoRickshawModel model) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        developer.log('No authentication token available', name: _logTag);
        return {
          'success': false,
          'message': 'Authentication token not available',
        };
      }

      developer.log('Submitting E_RICKSHAW application request to $_baseUrl',
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

      if (response.statusCode >= 200 && response.statusCode < 300) {
        developer.log('Driver application submitted successfully', name: _logTag);
        
        // Enhanced: Parse response body if available
        Map<String, dynamic>? responseData;
        try {
          if (response.body.isNotEmpty) {
            responseData = jsonDecode(response.body);
          }
        } catch (e) {
          developer.log('Failed to parse success response body', name: _logTag);
        }
        
        return {
          'success': true,
          'message': responseData?['message'] ?? 'Application submitted successfully',
          'data': responseData,
        };
      } else {
        Map<String, dynamic> errorResponse = {};
        try {
          errorResponse = jsonDecode(response.body);
        } catch (e) {
          developer.log('Failed to parse error response body', name: _logTag);
          errorResponse = {'message': 'Server error occurred'};
        }
        
        final errorMessage = errorResponse['message'] ?? 'Submission failed';
        developer.log('Failed to submit driver application: $errorMessage',
            name: _logTag);
        return {
          'success': false, 
          'message': errorMessage,
          'statusCode': response.statusCode,
        };
      }
    } catch (e, stackTrace) {
      developer.log('Error submitting driver application',
          error: e, stackTrace: stackTrace, name: _logTag);
      return {
        'success': false, 
        'message': 'An unexpected error occurred: ${e.toString()}',
      };
    }
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static void showApiErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class ApiResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });
}