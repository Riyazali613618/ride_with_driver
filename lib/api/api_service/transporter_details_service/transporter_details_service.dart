// services/transporter_details_service.dart
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../api_model/transporter_model/transpoter_details_model.dart';
import '../../api_model/vehciles_single_model/DriverDetailsModel.dart';

class TransporterDetailsService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<DriverDetailsModel> getTransporterDetails(
      String transporterId) async {
    print("transporterId:${transporterId}");
    // try {
      final Uri url =
          Uri.parse('$baseUrl/user/single/$transporterId');
      final token = await TokenManager.getToken();
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
          // Add any required headers like authorization
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        print("jsonData:${jsonData}");
        return DriverDetailsModel.fromJson(jsonData);
      } else {
        throw Exception(
            'Failed to load transporter details. Status: ${response.statusCode}');
      }
    // } catch (e) {
    //   throw Exception('Network error: ${e.toString()}');
    // }
  }
}
