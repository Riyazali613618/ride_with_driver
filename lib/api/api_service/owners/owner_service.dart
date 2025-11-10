import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';

import '../../../constants/token_manager.dart';
import '../../api_model/owner/owners_model.dart';

class DriverService {
  static const String baseUrl = ApiConstants.baseUrl;

  Future<DriverResponse> searchDrivers({
    required String pincode,
    required double lat,
    required double lng,
  }) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      final response = await http.post(
        Uri.parse('$baseUrl/user/search'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pincode': pincode,
          'lat': lat,
          'lng': lng,
          'searchType': 'DRIVER',
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return DriverResponse.fromJson(responseData);
      } else {
        if (kDebugMode) {
          print('API Error: ${response.statusCode} - ${response.body}');
        }
        throw Exception(
            'Failed to search drivers. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Exception in searchDrivers: $e');
      }
      throw Exception('Network error while searching drivers: $e');
    }
  }
}
