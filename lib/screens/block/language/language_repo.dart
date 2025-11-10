import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/api/api_model/language/language_model.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

class LanguageRepository {
  // All supported languages restored
  static const List<Language> supportedLanguages = [
    Language(code: 'en', name: 'English', nativeName: 'English'),
    Language(code: 'hi', name: 'Hindi', nativeName: 'हिन्दी'),
    Language(code: 'ta', name: 'Tamil', nativeName: 'தமிழ்'),
    Language(code: 'te', name: 'Telugu', nativeName: 'తెలుగు'),
    Language(code: 'kn', name: 'Kannada', nativeName: 'ಕನ್ನಡ'),
    Language(code: 'mr', name: 'Marathi', nativeName: 'मराठी'),
    Language(code: 'gu', name: 'Gujarati', nativeName: 'ગુજરાતી'),
    Language(code: 'bn', name: 'Bengali', nativeName: 'বাংলা'),
    Language(code: 'ml', name: 'Malayalam', nativeName: 'മലയാളം'),
  ];

  Future<Language?> getCurrentLanguage() async {
    try {
      final userData = await TokenManager.getUserData();
      if (userData != null && userData['language'] != null) {
        return supportedLanguages.firstWhere(
              (lang) => lang.code == userData['language'],
          orElse: () => supportedLanguages.first,
        );
      }
      return supportedLanguages.first;
    } catch (e) {
      debugPrint('Error getting current language: $e');
      return supportedLanguages.first;
    }
  }

  Future<bool> updateLanguage(Language language) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        debugPrint('No authentication token found');
        return false;
      }

      debugPrint('Attempting to update language to: ${language.code}');
//here we bneed to pass the language code associated id tht i will add later
      //hardcoding
      final response = await http.put(
        Uri.parse('${ApiConstants.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'language': '68d4052ce5417ced85c8b0fd'}),
      );

      debugPrint('Language update response status: ${response.statusCode}');
      debugPrint('Language update response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        if (responseData['status'] == true || responseData['success'] == true) {
          // Update local storage
          final userData = await TokenManager.getUserData() ?? {};
          userData['language'] = language.code;
          await TokenManager.saveUserData(userData);
          debugPrint('Language successfully updated to: ${language.code}');
          return true;
        } else {
          debugPrint('Server returned false status: ${responseData}');
        }
      } else {
        debugPrint('HTTP error: ${response.statusCode} - ${response.body}');
      }
      return false;
    } catch (e) {
      debugPrint('Error updating language: $e');
      return false;
    }
  }
}