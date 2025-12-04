import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../api/api_model/driver_transpoter_profile_model.dart';

class TransporterDriverProfileService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<TransporterDriverProfileModel> getProfile(String type) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/profile?TYPE=$type'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print("=======================================");
      print(response.request);
      print("=======================================");
      print(response);
      print("=======================================");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (kDebugMode) {
          print("Resposne Profile ${jsonData}");
        }
        return TransporterDriverProfileModel.fromJson(
          jsonData,
        );
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<TransporterDriverProfileModel> updateProfile(
      String type, Map<String, dynamic> updateData) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/user/profile?TYPE=$type'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(updateData),
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return TransporterDriverProfileModel.fromJson(
          jsonData,
        );
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
