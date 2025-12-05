import '../../../constants/token_manager.dart';
import '../../api_model/registrations/become_driver_registration_model.dart'
    show BecomeDriverModel;
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';

class BecomeDriverServiceIndi {
  static const String _logTag = 'BecomeDriverService';

  Future<Map<String, dynamic>> submitDriverApplicationIndi(
      BecomeDriverModel model) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        developer.log('No authentication token available', name: _logTag);
        return {
          'success': false,
          'message': 'No authentication token available'
        };
      }
      model.copyWith(drivingLicenceNumber: "DL-202100012345");
      final url = Uri.parse(
          '${ApiConstants.baseUrl}/user/become-independent-car-owner');
      developer.log('Submitting driver application to: $url', name: _logTag);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(model.toJson()),
      );

      developer.log('Response status code: ${response.statusCode}',
          name: _logTag);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        developer.log('Driver application submitted successfully',
            name: _logTag);
        return {'success': true};
      } else {
        final errorResponse = jsonDecode(response.body);
        print("error ${errorResponse}");
        final errorMessage = errorResponse['message'] ?? 'Submission failed';
        developer.log('Failed to submit driver application: $errorMessage',
            name: _logTag);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e, stackTrace) {
      developer.log('Error submitting driver application',
          error: e, stackTrace: stackTrace, name: _logTag);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  static void showApiErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
