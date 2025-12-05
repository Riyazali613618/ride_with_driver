import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/main.dart';

import '../../../constants/token_manager.dart';

enum PaymentType {
  subscriptionRenewal,
  registrationOnly,
  registrationWithSubscription,
}

class PaymentService {
  // Create order for subscription renewal
  static Future<Map<String, dynamic>> createOrderForSubscriptionRenewal({
    required String planId,
  }) async {
    return _createOrder({
      'paymentType': 'SUBSCRIPTION',
      'subscriptionPlanId': planId,
    });
  }

  // Create order for registration only
  static Future<Map<String, dynamic>> createOrderForRegistrationOnly({
    required String category,
    required String planId,
  }) async {

    return _createOrder({
      'paymentType': 'SUBSCRIPTION',
      'category': category,
      'subscriptionPlanId': planId,
      'paymentGatewayType': 'razorpay',
    });
  }

  // Create order for registration with subscription
  static Future<Map<String, dynamic>>
      createOrderForRegistrationWithSubscription({
    required String category,
    required String planId,
  }) async {
    print("==================================================");
    print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
    print("==================================================");

    return _createOrder({
      'paymentType': 'SUBSCRIPTION',
      'category': category,
      'subscriptionPlanId': planId,
      'paymentGatewayType': 'razorpay',
    });
  }

  // Generic create order method (for backward compatibility)
  static Future<Map<String, dynamic>> createOrder(
    String planId,
  ) async {
    // Default to subscription renewal for backward compatibility
    return createOrderForSubscriptionRenewal(planId: planId);
  }

  // Private method to handle the actual API call
  static Future<Map<String, dynamic>> _createOrder(
    Map<String, dynamic> requestBody,
  ) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      print(token);
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/create-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );
      print("==================================================");
      print(response.body);
      print("==================================================");

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        var data = jsonDecode(response.body);
        print("Errro : ${response.body}");

        WidgetsBinding.instance.addPostFrameCallback((_) {
          rootScaffoldMessengerKey.currentState?.showSnackBar(
            SnackBar(
              content: Text(
                data["error"].toString(),
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        });
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  // Save order for subscription renewal
  static Future<Map<String, dynamic>> saveOrderForSubscriptionRenewal({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String planId,
  }) async {
    return _saveOrder({
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'paymentType': 'SUBSCRIPTION',
      'subscriptionPlanId': planId,
      'paymentGatewayType': "razorpay",
    });
  }

  // Save order for registration only
  static Future<Map<String, dynamic>> saveOrderForRegistrationOnly({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String category,
    required String registrationFeeId,
  }) async {
    return _saveOrder({
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'paymentType': 'SUBSCRIPTION',
      'category': category,
      'subscriptionPlanId': registrationFeeId,
      'paymentGatewayType': "razorpay",
    });
  }

  // Save order for registration with subscription
  static Future<Map<String, dynamic>> saveOrderForRegistrationWithSubscription({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String category,
    required String planId,
    required String registrationFeeId,
  }) async {
    return _saveOrder({
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
      'paymentType': 'SUBSCRIPTION',
      'category': category,
      'subscriptionPlanId': planId,
      'paymentGatewayType': "razorpay",
    });
  }

  // Generic save order method (for backward compatibility)
  static Future<Map<String, dynamic>> saveOrder({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    String? planId,
    String? category,
    String? registrationFeeId,
    PaymentType? paymentType,
  }) async {
    // Determine payment type and call appropriate method
    if (paymentType == PaymentType.subscriptionRenewal && planId != null) {
      return saveOrderForSubscriptionRenewal(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        planId: planId,
      );
    } else if (paymentType == PaymentType.registrationOnly &&
        category != null &&
        registrationFeeId != null) {
      return saveOrderForRegistrationOnly(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        category: category,
        registrationFeeId: registrationFeeId,
      );
    } else if (paymentType == PaymentType.registrationWithSubscription &&
        category != null &&
        planId != null &&
        registrationFeeId != null) {
      return saveOrderForRegistrationWithSubscription(
        razorpayOrderId: razorpayOrderId,
        razorpayPaymentId: razorpayPaymentId,
        razorpaySignature: razorpaySignature,
        category: category,
        planId: planId,
        registrationFeeId: registrationFeeId,
      );
    } else {
      // Default behavior for backward compatibility
      return _saveOrder({
        'razorpay_order_id': razorpayOrderId,
        'razorpay_payment_id': razorpayPaymentId,
        'razorpay_signature': razorpaySignature,
      });
    }
  }

  // Private method to handle the actual save order API call
  static Future<Map<String, dynamic>> _saveOrder(
      Map<String, dynamic> requestBody) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/save-order'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(requestBody),
      );

      print("==================================================");
      print(response);
      print("==================================================");

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Check if subscriptionId exists in the response data
        if (responseData['data'] != null &&
            responseData['data']['subscriptionId'] != null) {
          final subscriptionId = responseData['data']['subscriptionId'];
          print(
              '[PaymentService] Found subscriptionId in response: $subscriptionId');

          // Call regStatusUpdate with the subscriptionId (make it non-blocking)
          try {
            await regStatusUpdate(subscriptionId);
            print('[PaymentService] regStatusUpdate completed successfully');
          } catch (e) {
            // Log the error but don't fail the entire payment process
            print('[PaymentService] regStatusUpdate failed but continuing: $e');
            // Note: We don't rethrow here so the payment can still be marked as successful
          }
        } else {
          print('[PaymentService] No subscriptionId found in response data');
        }

        return responseData;
      } else {
        throw Exception('Failed to save order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to save order: $e');
    }
  }

  static Future<void> regStatusUpdate(String subscriptionId) async {
    try {
      print(
          '[PaymentService] Starting regStatusUpdate for subscriptionId: $subscriptionId');

      final token = await TokenManager.getToken();
      print(
          '[PaymentService] Token retrieved: ${token != null ? "[PRESENT]" : "[NULL]"}');

      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final url = "${ApiConstants.baseUrl}/user/payment/registration-status";
      final requestBody = {"subscriptionId": subscriptionId.toString()};

      print('[PaymentService] Making POST request to: $url');
      print('[PaymentService] Request body: $requestBody');

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestBody),
      );

      print('[PaymentService] Response status code: ${response.statusCode}');
      print('[PaymentService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded['data'];
        print('[PaymentService] regStatusUpdate successful. Data: $data');
      } else {
        print(
            '[PaymentService] regStatusUpdate failed with status ${response.statusCode}');
        print('[PaymentService] Error response: ${response.body}');
        throw Exception(
            "Failed to fetch payment status: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print('[PaymentService] Exception in regStatusUpdate: $e');
      throw Exception("Error fetching payment status: $e");
    }
  }
}
