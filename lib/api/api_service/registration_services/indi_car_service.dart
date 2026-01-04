import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/token_manager.dart';
import '../../api_model/registrations/become_driver_registration_model.dart'
    show BecomeDriverModel;
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../../api_model/user_model/user_eligibility_model.dart';
import '../user_service/user_profile_service.dart';

class BecomeDriverServiceIndi {
  static const String _logTag = 'BecomeDriverService';

  Future<Map<String, dynamic>> submitDriverApplicationIndi(
      BecomeDriverModel model) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        developer.log('No authentication token available', name: _logTag);
        return {
          'success': false,
          'message': 'No authentication token available'
        };
      }
      String orderId = "";
      String paymentId = "";
      String subscriptionPlanId = "";

      bool isUpgrade = await getUserProfile();
      if (isUpgrade) {
        final data = await getEligibilityData();
        if (data.data != null) {
          subscriptionPlanId = data.data?.subscriptionId ?? "";
          paymentId = data.data?.paymentId ?? "";
          orderId = data.data?.orderId ?? "";
        }
      }
      String method =
          isUpgrade ? "become-upgradable" : "become-independent-car-owner";
      model.copyWith(bio: "DL-202100012345");
      model = model.copyWith(bio: "A");
      final url = Uri.parse('${ApiConstants.baseUrl}/user/$method');
      developer.log('Submitting driver application to: $url', name: _logTag);
      print(jsonEncode(model.toJson()));
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: orderId.isEmpty
            ? jsonEncode(model.toJson())
            : {
                "profilePhoto": model.profilePhoto,
                "firstName": model.firstName,
                "lastName": model.lastName,
                "chosen_category": "INDEPENDENT_CAR_OWNER",
                "orderId": orderId,
                "paymentId": paymentId,
                "subscriptionPlanId": subscriptionPlanId,
                "businessMobileNumber": model.businessMobileNumber,
                "bio": model.bio,
                "address": {
                  "addressLine": model.address?.addressLine ?? "",
                  "pincode": model.address?.pincode ?? "123456",
                  "city": model.address?.city ?? "",
                  "state": model.address?.state ?? ""
                },
                "aadharCardNumber": model.aadharCardNumber,
                "aadharCardPhotoFront": model.aadharCardPhotoFront,
                "aadharCardPhotoBack": model.aadharCardPhotoBack,
                "drivingLicenceNumber": model.drivingLicenceNumber,
                "drivingLicencePhoto": model.drivingLicencePhoto,
                "transportationPermitPhoto": model.transportationPermitPhoto,
                "independentCarOwnerFleetSize": {
                  "cars": model.independentCarOwnerFleetSize?.cars ?? 1,
                  "minivans": model.independentCarOwnerFleetSize?.minivans ?? 1,
                  "buses": model.independentCarOwnerFleetSize?.buses ?? 1,
                  "suvs": model.independentCarOwnerFleetSize?.suvs ?? 1
                }
              },
      );

      developer.log('Response status code: ${response.statusCode}',
          name: _logTag);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        developer.log('Driver application submitted successfully',
            name: _logTag);
        return {'success': true};
      } else {
        final errorResponse = jsonDecode(response.body);
        print("error ${errorResponse}");
        final errorMessage = errorResponse['message'] ?? 'Submission failed';
        developer.log('Failed to submit driver application: $errorMessage',
            name: _logTag);
        return {'success': false, 'message': errorMessage};
      }
    } catch (e, stackTrace) {
      developer.log('Error submitting driver application',
          error: e, stackTrace: stackTrace, name: _logTag);
      return {'success': false, 'message': 'An unexpected error occurred'};
    }
  }

  Future<UserEligibilityModel> getEligibilityData() async {
    final data = await UserProfileService().getEligibility();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstants.planEligibilityKey, jsonEncode(data.data));
    return data;
  }

  Future<bool> getUserProfile() async {
    final data = await UserProfileService().getUserProfile();
    final prefs = await SharedPreferences.getInstance();
    if (data!.subscriptions!.isNotEmpty) {
      for (var sub in data!.subscriptions!) {
        if ((sub.status ?? "").toLowerCase() == "active" &&
            (sub.isUpgrade ?? false)) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  static void showApiErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}
