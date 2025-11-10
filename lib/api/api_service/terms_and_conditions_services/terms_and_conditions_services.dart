import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';
import 'package:r_w_r/screens/block/language/language_provider.dart';
import 'package:r_w_r/screens/block/language/language_repo.dart';

import '../../api_model/term_and_conditions_model/terms_and_conditions_model.dart';

class TermsService {
  static const String baseUrl = ApiConstants.baseUrl;
  static final LanguageRepository _languageRepository = LanguageRepository();
  static LanguageProvider _languageProvider=LanguageProvider();

  static Future<TermsResponse> fetchPrivacyPolicy(String type) async {
    try {
      final token = await TokenManager.getToken();

      final currentLanguage = await _languageRepository.getCurrentLanguage();
      final language = (_languageProvider.langCode!.isNotEmpty)?_languageProvider.langCode:'68d4052ce5417ced85c8b0fd';
      final response = await http.get(
        Uri.parse('$baseUrl/public/legal/${type}/${language}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        print("response from privacy policy:${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return TermsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load terms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  static Future<TermsResponse> fetchTermsAndConditions(String type) async {
    try {
      final token = await TokenManager.getToken();

      final currentLanguage = await _languageRepository.getCurrentLanguage();
      final language = (_languageProvider.langCode!.isNotEmpty)?_languageProvider.langCode:'68d4052ce5417ced85c8b0fd';
      final response = await http.get(
        Uri.parse('$baseUrl/public/legal/${type}/${language}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));
      print('$baseUrl/public/legal/${type}/${language}');

      if (response.statusCode == 200) {
        print("response from privacy policy:${response.body}");
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return TermsResponse.fromJson(jsonData);
      } else {
        throw Exception('Failed to load terms: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
