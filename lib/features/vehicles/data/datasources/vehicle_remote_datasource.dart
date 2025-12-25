import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import '../../../../constants/api_constants.dart';
import '../../../../constants/token_manager.dart';
import '../models/vehicle_model.dart';

abstract class VehicleRemoteDatasource {
  Future<List<VehicleModel>> getVehicles();
}

class VehicleRemoteDatasourceImpl implements VehicleRemoteDatasource {
  VehicleRemoteDatasourceImpl();

  @override
  Future<List<VehicleModel>> getVehicles() async {
    final response = await fetchVehicles(ApiConstants.vehicles);
    final data = response as List;
    return data.map((e) => VehicleModel.fromJson(e)).toList();
  }

  static Future<dynamic> fetchVehicles(String url) async {
    String? token = await TokenManager.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}$url'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        final vehiclesData = data['data'] as List;
        return vehiclesData;
      } else {
        throw Exception(data['message'] ?? 'Failed to load vehicles');
      }
    } else {
      throw Exception('Failed to load vehicles: ${response.statusCode}');
    }
  }
}
