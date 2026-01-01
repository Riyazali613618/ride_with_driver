import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';

import '../../../../constants/token_manager.dart';

class ProfileRepository {
  Future<Map<String, dynamic>> fetchUserProfile() async {
    final token = await TokenManager.getToken();

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch profile');
    }
  }
}
