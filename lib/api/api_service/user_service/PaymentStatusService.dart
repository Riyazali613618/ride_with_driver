import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../constants/api_constants.dart';
import '../../../constants/token_manager.dart';
import '../../api_model/user_model/PaymentStatus.dart';

class PaymentStatusService {
  static PaymentStatus? globalPaymentStatus;

  static Future<void> fetchPaymentStatus(String category) async {
    try {
      final token = await TokenManager.getToken();
      print("This is token ${token.toString()}");
      if (token == null){
        throw Exception('Authentication token not found');
      }
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/user/status/$category"),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        print("YYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY");
        print("Raw response: ${response.body}");
        // Parse the entire response, not just the 'data' field
        globalPaymentStatus = PaymentStatus.fromJson(decoded);
        // Try different access patterns to debug
        print("Global payment status: $globalPaymentStatus");
        print("Has data: ${globalPaymentStatus?.data}");
        // Alternative: Direct access from decoded JSON for debugging
        final paymentPhase = decoded['data']?['restriction']?['paymentPhase'];
        print("Direct access payment phase: $paymentPhase");
      } else {
        throw Exception("Failed to fetch payment status");
      }
    } catch (e) {
      print("Error details: $e");
      throw Exception("Error fetching payment status: $e");
    }
  }
}