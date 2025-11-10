import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

class FilterService {
  Future<Map<String, dynamic>> fetchFilters(String TYPE) async {
    try {
      final token = await TokenManager.getToken();
      final baseUrl = ApiConstants.baseUrl;

      print("Fetching filters from: $baseUrl/user/filter");

      final response = await http.get(
        Uri.parse('$baseUrl/user/filter?searchType=$TYPE'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);
        print("Decoded response: $decodedResponse");
        return decodedResponse;
      } else {
        print("Error response: ${response.body}");
        throw Exception(
            'Failed to load filters: Status ${response.statusCode}');
      }
    } catch (e) {
      print("Exception caught: $e");
      throw Exception('Failed to fetch filters: $e');
    }
  }
}
