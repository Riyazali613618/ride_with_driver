import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rwd/api/api_model/user_model/my_profile_model.dart';
import 'package:rwd/constants/api_constants.dart';
import 'package:rwd/constants/token_manager.dart';

class CarOwnerProfileApiService {
  Future<MyProfileModel> fetchProfile() async {
    final token=await TokenManager.getToken();
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/profile'),
      headers: {'Content-Type': 'application/json',
        'Authorization':'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return MyProfileModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load profile');
    }
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
   final token=await TokenManager.getToken();
    await http.put(
      Uri.parse('${ApiConstants.baseUrl}/user/profile'),
      headers: {'Content-Type': 'application/json',
      'Authorization':'Bearer $token'},
      body: jsonEncode(body),
    );
  }
}
