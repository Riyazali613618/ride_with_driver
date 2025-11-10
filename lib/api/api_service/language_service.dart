import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/api_constants.dart';
import '../../constants/token_manager.dart';
import '../api_model/languageModel.dart';
import '../api_model/notification_model.dart';

class LanguageService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<LanguageModel> getLanguages() async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/public/languages'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print("response.statusCode:${response.statusCode}");
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return LanguageModel.fromJson(jsonData);
      } else {
        throw Exception('Failed to load languages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
