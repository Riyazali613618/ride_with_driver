import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/api_endpoints.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../api_model/verify_otp_model.dart';

class VerifyOtpService {
  static const String baseUrl = ApiConstants.baseUrl;

  Future<OtpVerificationResponse> verifyOtp(
      String phoneNumber, String otp,String language,String country) async {
    final requestUrl = baseUrl + ApiEndpoints.verifyOtp;
    print("OtpVerificationResponse:${phoneNumber} ${otp}");
    String formattedNumber = phoneNumber;
    if (phoneNumber.startsWith('+')) {
      formattedNumber = phoneNumber.substring(1);
      if (formattedNumber.startsWith('91') && formattedNumber.length > 10) {
        formattedNumber = formattedNumber.substring(2);
      }
    }

    final requestBody = {
      'mobileNumber': formattedNumber,
      'otp': otp,
      'language':language,
      'country':country
    };

    if (kDebugMode) {
      print("Making API call to: $requestUrl");
      print("Request body: $requestBody");
    }

    // try {
      final response = await http.post(
        Uri.parse(requestUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

    print("########################################");
    print("Response body: ${response.body}");
    print("########################################");

    if (kDebugMode) {
        print("Response status code: ${response.statusCode}");
        print("Response body: ${response.body}");
      }
      // Parse the response regardless of status code
      final responseJson = jsonDecode(response.body);

      return OtpVerificationResponse.fromJson(responseJson);
    // } catch (e) {
    //   if (kDebugMode) {
    //     print("API error: $e");
    //   }
    //   throw Exception('Network error: $e');
    // }
  }


  Future<String> refershTokenApi(String refershToken) async {
    final requestUrl = '${baseUrl}/auth/refresh-token';
    final requestBody = {
      'refreshToken': refershToken,
    };
    if (kDebugMode) {
      print("Making API call to: $requestUrl");
      print("Request body: $requestBody");
    }
    try {
    final response = await http.post(
      Uri.parse(requestUrl),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (kDebugMode) {
      print("Response status code: ${response.statusCode}");
      print("Response body: ${response.body}");
    }
    // Parse the response regardless of status code
    if(response.statusCode==200 || response.statusCode==201){
      final responseJson = jsonDecode(response.body);
      await TokenManager.saveRefreshToken(responseJson['data']['refreshToken']);
      return responseJson['data']['accessToken'].toString();
    }else{
      return refershToken;
    }
    } catch (e) {
      if (kDebugMode) {
        print("API error: $e");
      }
      throw Exception('Network error: $e');
    }
  }
}
