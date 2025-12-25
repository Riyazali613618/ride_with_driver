import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_model/driver_transpoter_profile_model.dart';
import 'package:r_w_r/api/api_service/countryStateProviderService.dart';
import 'package:r_w_r/screens/block/language/language_provider.dart';
import 'package:r_w_r/screens/user_screens/PartnerRegistrationWidget.dart';

import '../../../constants/api_constants.dart';
import '../../../constants/token_manager.dart';
import '../../layout.dart';

class ProfileProvider with ChangeNotifier {
  TransporterDriverProfileModel? _profileModel;
  Map<String, dynamic>? _rawProfileData;
  bool _isLoading = false;
  String? _error;

  /// Getters
  TransporterDriverProfileModel? get profileModel => _profileModel;
  UserProfileData? get profileData => _profileModel?.data;
  Map<String, dynamic>? get rawProfileData => _rawProfileData;

  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get userType => profileData?.usertype ?? _rawProfileData?['userType'];
  String? get userId => profileData?.userId ?? _rawProfileData?['userId'];



  String? get fullName {
    return profileData?.firstName ??
        profileData?.firstName ??
        _rawProfileData?['fullName'] ??
        _rawProfileData?['displayName'] ??
        _rawProfileData?['name'] ??
        _getConstructedName();
  }

  String? _getConstructedName() {
    final firstName = _rawProfileData?['firstName']?.toString() ?? '';
    final lastName = _rawProfileData?['lastName']?.toString() ?? '';
    final combined = '$firstName $lastName'.trim();
    return combined.isNotEmpty ? combined : null;
  }

  String? get phoneNumber {
    return profileData?.mobileNumber ??
        profileData?.mobileNumber ??
        _rawProfileData?['phoneNumber'] ??
        _rawProfileData?['mobileNumber'] ??
        _rawProfileData?['number'];
  }

  String? get email {
    return _rawProfileData?['email'] ?? profileData?.toJson()['email'];
  }

  String? get profilePhoto =>
      profileData?.profilePhoto ??
      profileData?.profilePhoto ??
      _rawProfileData?['image'] ??
      _rawProfileData?['profilePhoto'];
  String? get companyName =>
      profileData?.companyName ?? _rawProfileData?['companyName'];
  String? get contactPersonName =>
      profileData?.companyName ?? _rawProfileData?['contactPersonName'];
  Address? get address => profileData?.address;

  String? get firstName => _rawProfileData?['firstName'];
  String? get lastName => _rawProfileData?['lastName'];
  String? get displayName => _rawProfileData?['displayName'];
  Map<String, dynamic> ? get language => _rawProfileData?['language'];
  String? get id => profileData?.id ?? _rawProfileData?['id'];

  Future<void> loadProfile(BuildContext context) async {
    _isLoading = true;
    notifyListeners();


    try {
      final _locationProvider=Provider.of<LocationProvider>(context, listen: false);
      final _languageProvider=Provider.of<LanguageProvider>(context, listen: false);
      final token = await TokenManager.getToken();
      print("token:${token}");
      if (token == null) throw Exception('Authentication token not found');

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );





      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {

          // Store both raw data and parsed model
          _rawProfileData =
              data['data'] ?? data; // Handle different response structures

          try {
            _profileModel = TransporterDriverProfileModel.fromJson(data);
          } catch (modelError) {
            // If model parsing fails, we still have raw data as fallback
            print('Model parsing failed: $modelError');
          }
          await TokenManager.saveUserType(_profileModel?.data.usertype??"USER");
          _languageProvider.setLangCode(_profileModel!.data.language!.id!);
          _locationProvider.setSelectedCountry(_profileModel!.data.country!.id!);
          print("load profile: ${_languageProvider.langCode} ${_locationProvider.selectedCountry}");
          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load profile';
        }
      } else if (response.statusCode == 404) {
        _error = 'Profile not found. Please complete your profile.';
        _profileModel = null;
        _rawProfileData = {};
      } else {
        _error = 'HTTP ${response.statusCode}: Failed to load profile';
      }
    } catch (e) {
      _error = 'Error: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile(dynamic updatedData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await TokenManager.getToken();
      if (token == null) throw Exception('Authentication token not found');

      // Handle both UserProfileData objects and Map<String, dynamic>
      Map<String, dynamic> jsonData;
      if (updatedData is UserProfileData) {
        jsonData = updatedData.toJson();
      } else if (updatedData is Map<String, dynamic>) {
        jsonData = updatedData;
      } else {
        throw Exception('Invalid data type for profile update');
      }

      final client = http.Client();
      try {
        final response = await client
            .put(
              Uri.parse('${ApiConstants.baseUrl}/user/profile'),
              headers: {
                'Content-Type': 'application/json',
                'Authorization': 'Bearer $token',
              },
              body: json.encode(jsonData),
            )
            .timeout(
              const Duration(seconds: 30),
              onTimeout: () => _handleTimeoutAndVerify(token),
            );
        if (kDebugMode) {
          print(response.body);
          print("Body $jsonData");
        }
        return _handleResponse(response);
      } finally {
        client.close();
      }
    } catch (e) {
      _error = 'Network error: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Universal method to get any profile field
  String getProfileField(String fieldName) {
    // Try model first
    if (profileData != null) {
      final json = profileData!.toJson();
      if (json[fieldName] != null) {
        return json[fieldName].toString();
      }
    }

    // Fallback to raw data
    return _rawProfileData?[fieldName]?.toString() ?? '';
  }

  // Get any field value dynamically with default
  dynamic getField(String fieldName, {dynamic defaultValue}) {
    if (profileData != null) {
      final json = profileData!.toJson();
      if (json[fieldName] != null) {
        return json[fieldName];
      }
    }
    return _rawProfileData?[fieldName] ?? defaultValue;
  }

  Future<http.Response> _handleTimeoutAndVerify(String token) async {
    await Future.delayed(const Duration(seconds: 2));
    try {
      final verifyResponse = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      if (verifyResponse.statusCode == 200) {
        return http.Response(
          json.encode({
            'status': true,
            'message': 'Profile updated successfully (verified after timeout)',
            'data': json.decode(verifyResponse.body)['data'],
          }),
          200,
        );
      }
    } catch (_) {}
    throw TimeoutException('Request timed out after 30 seconds');
  }

  bool _handleResponse(http.Response response) {
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        // Update both raw data and model
        _rawProfileData = data['data'] ?? data;
        try {
          _profileModel = TransporterDriverProfileModel.fromJson(data);
        } catch (e) {
          // Model parsing failed, but raw data is updated
          print('Model update parsing failed: $e');
        }
        _error = null;
        return true;
      } else {
        _error = data['message'] ?? 'Failed to update profile';
        return false;
      }
    } else {
      _error = 'HTTP ${response.statusCode}: Failed to update profile';
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  bool _isDialogVisible = false;

  bool get isDialogVisible => _isDialogVisible;
  bool _hasDialogBeenShown = false;

  bool get hasDialogBeenShown => _hasDialogBeenShown;
  void showDialogBox(BuildContext context) {
    if(_hasDialogBeenShown)return;
    _isDialogVisible = true;
    _hasDialogBeenShown = true;
    notifyListeners();
    print("calling dialog");
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 16,),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF641BB4),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9), // Less round: 4 px radius
                  ),
                ),
                onPressed: () {
                  _isDialogVisible = false;
                  notifyListeners();
                  Navigator.of(context).pop();
                  // Handle "Continue as User"
                },
                child: Text('Continue as User'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF641BB4),
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9), // Less round: 4 px radius
                  ),
                ),
                onPressed: () {
                  _isDialogVisible = false;
                  Navigator.of(context).pop();
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              PartnerRegistrationWidget()
                      ));
                  notifyListeners();
                  // Handle "Become Partner"
                },
                child: Text('Become Partner'),
              ),
              SizedBox(height: 10,),
            ],
          ),
        );
      },
    ).then((_) {
      _isDialogVisible = false;
      notifyListeners();
    });
  }

}

/// Universal utility for pre-filling user data across all categories
class UserPrefillUtility {
  static Map<String, dynamic>? _cachedUserData;

  static Future<void> prefillUserData({
    TextEditingController? nameController,
    TextEditingController? phoneController,
    TextEditingController? emailController,
    TextEditingController? contactPersonController,
    TextEditingController? companyNameController,
    TextEditingController? firstNameController,
    TextEditingController? lastNameController,
  }) async {
    final userData = await _getUserData();

    if (userData == null || userData.isEmpty) return;

    // Handle name fields with multiple fallbacks
    final name = _getNameFromData(userData);
    if (nameController != null && name.isNotEmpty) {
      nameController.text = name;
    }

    if (contactPersonController != null) {
      final contactName = userData['contactPersonName']?.toString() ?? name;
      if (contactName.isNotEmpty) {
        contactPersonController.text = contactName;
      }
    }

    // Handle first/last names
    if (firstNameController != null) {
      final firstName = userData['firstName']?.toString() ?? '';
      if (firstName.isNotEmpty) {
        firstNameController.text = firstName;
      }
    }

    if (lastNameController != null) {
      final lastName = userData['lastName']?.toString() ?? '';
      if (lastName.isNotEmpty) {
        lastNameController.text = lastName;
      }
    }

    // Handle phone with multiple field names
    if (phoneController != null) {
      final phone = userData['phoneNumber']?.toString() ??
          userData['mobileNumber']?.toString() ??
          userData['number']?.toString() ??
          '';
      if (phone.isNotEmpty) {
        phoneController.text = phone;
      }
    }

    // Handle email
    if (emailController != null) {
      final email = userData['email']?.toString() ?? '';
      if (email.isNotEmpty) {
        emailController.text = email;
      }
    }

    // Handle company name
    if (companyNameController != null) {
      final companyName = userData['companyName']?.toString() ?? '';
      if (companyName.isNotEmpty) {
        companyNameController.text = companyName;
      }
    }
  }

  static Future<Map<String, dynamic>?> _getUserData() async {
    if (_cachedUserData != null) return _cachedUserData;

    try {
      final token = await TokenManager.getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          _cachedUserData = data['data'];
          return _cachedUserData;
        }
      }
    } catch (_) {}

    return null;
  }

  static String _getNameFromData(Map<String, dynamic> data) {
    // Priority order: displayName, fullName, name, firstName+lastName, firstName
    if (data['displayName']?.toString().isNotEmpty == true) {
      return data['displayName'].toString();
    }

    if (data['fullName']?.toString().isNotEmpty == true) {
      return data['fullName'].toString();
    }

    if (data['name']?.toString().isNotEmpty == true) {
      return data['name'].toString();
    }

    final firstName = data['firstName']?.toString() ?? '';
    final lastName = data['lastName']?.toString() ?? '';
    final fullName = '$firstName $lastName'.trim();

    if (fullName.isNotEmpty) {
      return fullName;
    }

    return firstName;
  }

  static void clearCache() {
    _cachedUserData = null;
  }

  static Future<String> getField(String field) async {
    final userData = await _getUserData();
    return userData?[field]?.toString() ?? '';
  }

  static Future<String> getName() async {
    final userData = await _getUserData();
    if (userData == null) return '';
    return _getNameFromData(userData);
  }

  static Future<String> getPhone() async {
    final userData = await _getUserData();
    if (userData == null) return '';
    return userData['phoneNumber']?.toString() ??
        userData['mobileNumber']?.toString() ??
        userData['number']?.toString() ??
        '';
  }

  // Get email
  static Future<String> getEmail() async {
    final userData = await _getUserData();
    if (userData == null) return '';
    return userData['email']?.toString() ?? '';
  }
}
