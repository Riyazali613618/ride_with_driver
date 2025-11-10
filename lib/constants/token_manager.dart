import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class TokenManager {
  static const String _tokenKey = 'auth_token';
  static const String _accessToken='access_token';
  static const String _phoneNumberKey = 'phone_number';
  static const String _userDataKey = 'user_data';
  static const String _isFirstTimeKey = 'is_first_time'; // Added missing key

  // Save auth token with error handling
  static Future<bool> saveToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_tokenKey, token);
    } catch (e) {
      print("Error saving token: $e");
      return false;
    }
  }

  static Future<bool> saveRefreshToken(String token) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_accessToken, token);
    } catch (e) {
      print("Error saving token: $e");
      return false;
    }
  }

  // Get auth token with error handling
  static Future<String?> getToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey)??"";
    } catch (e) {
      print("Error getting token: $e");
      return null;
    }
  }
  static Future<String?> getRefreshToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_accessToken);
    } catch (e) {
      print("Error getting token: $e");
      return null;
    }
  }

  // Remove auth token (logout) with error handling
  static Future<bool> removeToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      print("Error removing token: $e");
      return false;
    }
  }

  // IMPROVED: Check if token exists and user data is valid
  static Future<bool> isLoggedIn() async {
    try {
      final token = await getToken();
      final userData = await getUserData();

      // Check if both token and essential user data exist
      return token != null &&
          token.isNotEmpty &&
          userData != null &&
          userData.isNotEmpty;
    } catch (e) {
      print("Error checking login status: $e");
      return false;
    }
  }

  // Save phone number with error handling
  static Future<bool> savePhoneNumber(String phoneNumber) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_phoneNumberKey, phoneNumber);
    } catch (e) {
      print("Error saving phone number: $e");
      return false;
    }
  }

  // Get saved phone number with error handling
  static Future<String?> getPhoneNumber() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(_phoneNumberKey);
    } catch (e) {
      print("Error getting phone number: $e");
      return null;
    }
  }

  // Save user data with error handling
  static Future<bool> saveUserData(Map<String, dynamic> userData) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setString(_userDataKey, jsonEncode(userData));
    } catch (e) {
      print("Error saving user data: $e");
      return false;
    }
  }

  // IMPROVED: Get saved user data with better error handling
  static Future<Map<String, dynamic>?> getUserData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? userDataString = prefs.getString(_userDataKey);

      if (userDataString != null && userDataString.isNotEmpty) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error parsing user data: $e");
      return null;
    }
  }

  // NEW: Save first time user status
  static Future<bool> setFirstTimeStatus(bool isFirstTime) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_isFirstTimeKey, isFirstTime);
    } catch (e) {
      print("Error saving first time status: $e");
      return false;
    }
  }

  // NEW: Check if first time user
  static Future<bool> isFirstTimeUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isFirstTimeKey) ?? true;
    } catch (e) {
      print("Error getting first time status: $e");
      return true;
    }
  }

  // IMPROVED: Clear all stored data with better error handling
  static Future<bool> clearAllData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      // Remove specific keys using Future.wait for better performance
      final List<Future<bool>> removals = [
        prefs.remove(_tokenKey),
        prefs.remove(_phoneNumberKey),
        prefs.remove(_userDataKey),
        // prefs.remove(_isFirstTimeKey),
      ];

      final results = await Future.wait(removals);

      // Return true only if all removals were successful
      return results.every((result) => result);
    } catch (e) {
      print("Error clearing all data: $e");
      return false;
    }
  }

  // NEW: Validate stored data integrity
  static Future<bool> validateStoredData() async {
    try {
      final token = await getToken();
      final userData = await getUserData();

      // Add your validation logic here
      if (token == null || userData == null) {
        return false;
      }

      // Additional validation checks can be added here
      return true;
    } catch (e) {
      print("Error validating stored data: $e");
      return false;
    }
  }

  // NEW: Clear only auth token
  static Future<bool> clearToken() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.clear();
      return await prefs.remove(_tokenKey);
    } catch (e) {
      print("Error clearing token: $e");
      return false;
    }
  }

}
