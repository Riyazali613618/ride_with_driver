import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../../../constants/token_manager.dart';
import '../../api_model/verification_model/document_model.dart';

class DocumentVerificationService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const Duration timeoutDuration = Duration(seconds: 30);

  static Future<DocumentVerificationResult> verifyDocument({
    required String type,
    required String number,
    required String imageBase64,
  }) async {
    try {
      final token = await TokenManager.getToken();

      final response = await http
          .post(
            Uri.parse('$baseUrl/user/register/verify'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              "TYPE": type.toUpperCase(),
              "number": number.trim(),
              "image": imageBase64,
            }),
          )
          .timeout(timeoutDuration);

      final statusCode = response.statusCode;
      final responseBody = jsonDecode(response.body);

      if (statusCode == 200 || statusCode == 201) {
        if (responseBody['status'] == true) {
          return DocumentVerificationResult.success(responseBody);
        } else {
          final errorMessage = responseBody['message']?.toString().trim() ??
              'Verification failed';
          return DocumentVerificationResult.failure(errorMessage);
        }
      } else {
        final errorMessage = responseBody['message']?.toString().trim() ??
            'Verification failed with status code $statusCode';
        return DocumentVerificationResult.failure(errorMessage);
      }
    } catch (e) {
      debugPrint('Document verification error: $e');
      return DocumentVerificationResult.failure(
          'Verification failed. Please try again.');
    }
  }
}
