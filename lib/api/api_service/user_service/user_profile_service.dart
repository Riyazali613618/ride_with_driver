// services/user_profile_service.dart

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../../../constants/api_constants.dart';
import '../../../constants/token_manager.dart';
import '../../api_model/user_model/user_profile_model.dart';

class UserProfileService {
  // Get user profile from API
  Future<UserProfileModel> getUserProfile() async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return UserProfileModel.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to load profile: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('No internet connection. Please check your network.');
    }
  }

  // Update user profile
  Future<UpdateProfileResponse> updateUserProfile(UserData userData) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final Map<String, dynamic> requestBody = {
        'firstName': userData.firstName,
        'lastName': userData.lastName,
        'email': userData.email,
        'language': userData.language,
      };

      final response = await http
          .put(
            Uri.parse('${ApiConstants.baseUrl}/user/profile'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

        // Cache the updated user data
        if (data['status'] == true) {
          final currentData = await TokenManager.getUserData();
          if (currentData != null) {
            final updatedData = {...currentData, ...requestBody};
            await TokenManager.saveUserData(updatedData);
          }
        }

        return UpdateProfileResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else {
        throw Exception('Failed to update profile: ${response.statusCode}');
      }
    } on SocketException catch (_) {
      throw Exception('No internet connection. Please check your network.');
    }
  }

  Future<String> uploadProfilePhoto(String filePath) async {
     try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      print("filepath:${filePath}");
      var headers = {
        'Authorization': 'Bearer ${token}'
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConstants.baseUrl}/user/upload?type=profilePhoto')
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath,contentType: MediaType('image', 'jpeg'),));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        print('Upload successful: $responseBody');
        return data['data']['url'];
      } else {
        print('Upload failed: ${response.statusCode} - ${await response.stream.bytesToString()} ${filePath}');
       throw Exception('Failed to upload profile photo: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading profile photo: $e');
      rethrow;
    }
  }

  Future<String> uploadCoverPhoto(String filePath) async {
    try {
      final token = await TokenManager.getToken();
      if (token == null) {
        throw Exception('Authentication token not found');
      }
      print("filepath:${filePath}");
      var headers = {
        'Authorization': 'Bearer ${token}'
      };
      var request = http.MultipartRequest(
          'POST',
          Uri.parse('${ApiConstants.baseUrl}/user/upload?type=coverImage')
      );
      request.files.add(await http.MultipartFile.fromPath('file', filePath,contentType: MediaType('image', 'jpeg'),));
      request.headers.addAll(headers);
      http.StreamedResponse response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        final Map<String, dynamic> data = jsonDecode(responseBody);
        print('Upload successful: $responseBody');
        return data['data']['url'];
      } else {
        print('Upload failed: ${response.statusCode} - ${await response.stream.bytesToString()} ${filePath}');
        throw Exception('Failed to upload profile photo: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error uploading profile photo: $e');
      rethrow;
    }
  }


}
