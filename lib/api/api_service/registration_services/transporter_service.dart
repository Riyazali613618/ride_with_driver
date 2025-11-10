import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/api/api_model/language/language_model.dart';
import 'package:r_w_r/screens/layout.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/token_manager.dart';
import '../../api_model/registrations/transporter_model.dart';

class TransporterService {
  static const String logTag = 'TransporterService';

  Future<Map<String, dynamic>> submitTransporterApplication(
    TransporterModel model,
    BuildContext context,
  ) async {
    try {
      print(model);
      if (!context.mounted) {
        return {'success': false, 'message': 'Widget disposed'};
      }
      print(jsonEncode(model));
      final token = await TokenManager.getToken();
      if (token == null) {
        developer.log('No authentication token available', name: logTag);
        return {
          'success': false,
          'message': 'Authentication token not available',
        };
      }

      if (!context.mounted) {
        return {'success': false, 'message': 'Widget disposed'};
      }

      final url = Uri.parse('${ApiConstants.baseUrl}/user/become-transporter');
      developer.log('Submitting transporter application to: $url',
          name: logTag);

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(model.toJson()),
      );

      print('Bearer $token');

      developer.log('Response status code: ${response.statusCode}',
          name: logTag);
      developer.log('Response body: ${response.body}', name: logTag);

      if (!context.mounted) {
        return {'success': true};
      }

      if (response.statusCode >= 200 && response.statusCode < 300) {
        developer.log('Transporter application submitted successfully',
            name: logTag);

        return {'success': true};
      } else {
        final errorResponse = jsonDecode(response.body);
        final errorMessage = errorResponse['message'] ?? 'Submission failed';
        developer.log(
          'Failed to submit transporter application: $errorMessage',
          name: logTag,
        );

        if (context.mounted) {
          showApiErrorSnackBar(context, errorMessage);
        }

        return {'success': false, 'message': errorMessage};
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error submitting transporter application',
        error: e,
        stackTrace: stackTrace,
        name: logTag,
      );
      if (context.mounted) {
        showApiErrorSnackBar(context, 'An unexpected error occurred');
      }

      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  static Future<void> _showSuccessDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          icon: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 64,
          ),
          title: const Text(
            'Application Submitted!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Your transporter application has been submitted successfully. We will review your application and get back to you soon.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          actions: <Widget>[
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  static Future<void> _showAutoSuccessDialog(BuildContext context) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Success!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Application submitted successfully',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            ],
          ),
        );
      },
    );

    await Future.delayed(const Duration(seconds: 2));
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
