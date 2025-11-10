import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../constants/api_constants.dart';
import '../../constants/token_manager.dart';
import '../../screens/driver_screens/erikshaw_rikshaw_profile_screen.dart';
import '../api_model/erikshaw_rikshaw_model.dart';

class RickshawService {
  static const String baseUrl = ApiConstants.baseUrl;
  static const Duration timeoutDuration = Duration(seconds: 30);

  static Future<RickshawApiResponse> fetchRickshawProfile(String type) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/register/profile?TYPE=$type'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);
        return RickshawApiResponse.fromJson(jsonData);
      } else {
        throw RickshawException(
          'Failed to load profile. Status code: ${response.statusCode}',
          RickshawErrorType.networkError,
        );
      }
    } on http.ClientException catch (e) {
      throw RickshawException(
        'Network error: ${e.message}',
        RickshawErrorType.networkError,
      );
    } on FormatException catch (e) {
      throw RickshawException(
        'Invalid response format: ${e.message}',
        RickshawErrorType.parseError,
      );
    } catch (e) {
      throw RickshawException(
        'Unexpected error: $e',
        RickshawErrorType.unknown,
      );
    }
  }

  // Mock method for testing with your provided data
  static Future<RickshawApiResponse> getMockRickshawProfile() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay

    const mockResponse = {
      "status": true,
      "message": "Your PROFILE E_RICKSHAW",
      "data": {
        "myId": "454353533",
        "id": "683623f2c8e0d952c2a34ebe",
        "userId": "683621c89bee9576a85598f9",
        "fullName": "archit e rikshaw",
        "phoneNumber": "9936532903",
        "address": {
          "addressLine": "hij hnbhgn",
          "city": "Chandigarh",
          "state": "Chandigarh",
          "pincode": 568569,
          "country": "India"
        },
        "bio": "gghjggfgjf ghvnbh",
        "photo":
            "https://s3.ap-south-1.amazonaws.com/media.ridewithdriver/driver/f6158130-7bc5-4ebd-955c-930d0e964e11.jpg",
        "rating": 0,
        "userType": "E_RICKSHAW",
        "vehicleOwnership": "RENTED",
        "vehicleName": "E Rickshaw",
        "vehicleModelName": "Electric Rickshaw",
        "manufacturing": "2025",
        "fuelType": "Battery",
        "first2Km": 10,
        "airConditioning": "None",
        "vehicleType": "E_RICKSHAW",
        "seatingCapacity": 3,
        "vehicleNumber": "vhh678",
        "vehicleSpecifications": ["Electric"],
        "servedLocation": ["Ghaziabad", "Hyderabad"],
        "minimumChargePerHour": 55,
        "images": [
          "https://s3.ap-south-1.amazonaws.com/media.ridewithdriver/e-rickshaw/f398d182-5469-4471-881d-522c0e4592b8.jpg"
        ],
        "videos": [
          "https://s3.ap-south-1.amazonaws.com/media.ridewithdriver/e-rickshaw/cbbd402a-7b44-405d-88c1-b663e2b68e9d.jpg"
        ],
        "isPriceNegotiable": true,
        "isVerifiedByAdmin": true
      }
    };

    try {
      return RickshawApiResponse.fromJson(mockResponse);
    } catch (e) {
      throw RickshawException(
        'Failed to parse mock data: $e',
        RickshawErrorType.parseError,
      );
    }
  }
}
