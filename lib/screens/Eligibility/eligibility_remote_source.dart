import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import 'model/eligibility_model.dart';

class EligibilityRemoteSource {
  final http.Client client;

  EligibilityRemoteSource(this.client);

  Future<EligibilityModel> fetchEligibility() async {
    final token=await TokenManager.getRefreshToken();
    final response = await client.get(
      Uri.parse('${ApiConstants.baseUrl}/user/eligibility/global'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return EligibilityModel.fromJson(
        json.decode(response.body),
      );
    } else {
      throw Exception('Failed to fetch eligibility');
    }
  }
}
