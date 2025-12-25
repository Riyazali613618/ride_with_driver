import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:r_w_r/api/api_model/upgradeable_plans.dart';
import '../../constants/api_constants.dart';
import '../../constants/token_manager.dart';
import 'dashboard_model.dart';

class DashboardApiService {
  final http.Client client;

  DashboardApiService(this.client);

  Future<DashboardResponse> fetchDashboard(String range) async {
    String? token = await TokenManager.getToken();
    final response = await client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/user/bookings/partner-dashboard?filter_type=card',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return DashboardResponse.fromJson(json);
    } else {
      throw Exception('Failed to load dashboard');
    }
  }

  Future<UpgradeablePlans> fetchUpgradeablePlans(String type) async {
    String? token = await TokenManager.getToken();
    final response = await client.get(
      Uri.parse(
        '${ApiConstants.baseUrl}/user/upgradeable-plans?upgrade_type=$type',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return UpgradeablePlans.fromJson(json);
    } else {
      throw Exception('Failed to load upgradeable plans');
    }
  }
}
