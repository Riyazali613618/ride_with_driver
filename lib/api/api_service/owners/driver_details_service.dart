import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../api_model/owner/driver_details_model.dart';

class DriverService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<DriverResponse> getDriverDetails(String driverId) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/single/$driverId?type=DRIVER'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>${response.body}");
      print('$baseUrl/user/single/$driverId?type=DRIVER');

      if (response.statusCode == 200) {
        return DriverResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Failed to load driver details: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching driver details: $e');
    }
  }
}
