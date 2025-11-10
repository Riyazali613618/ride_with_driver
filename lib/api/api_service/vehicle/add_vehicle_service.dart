import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../api_model/vehicle/add_vehicle_model.dart';

class VehicleService {
  // Fetch all vehicles for the user
  static Future<List<Vehicle>> fetchVehicles() async {
    String? token = await TokenManager.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/vehicle/vehicle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        final vehiclesData = data['data'] as List;
        return vehiclesData.map((item) => Vehicle.fromJson(item)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load vehicles');
      }
    } else {
      throw Exception('Failed to load vehicles: ${response.statusCode}');
    }
  }

  // Fetch vehicle details by ID
  static Future<Vehicle> fetchVehicleById(String id) async {
    String? token = await TokenManager.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/vehicle/vehicle/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        return Vehicle.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to load vehicle details');
      }
    } else {
      throw Exception('Failed to load vehicle details: ${response.statusCode}');
    }
  }

  // Update vehicle details
  static Future<Vehicle> updateVehicle(
      String id, Map<String, dynamic> vehicleData) async {
    String? token = await TokenManager.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/user/vehicle/edit-vehicle/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(vehicleData),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        return Vehicle.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to update vehicle');
      }
    } else {
      throw Exception('Failed to update vehicle: ${response.statusCode}');
    }
  }

  // Add a new vehicle
  static Future<Vehicle> addVehicle(Map<String, dynamic> vehicleData) async {
    String? token = await TokenManager.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/user/vehicle/vehicle'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(vehicleData),
    );

    if (response.statusCode == 201) {
      final data = json.decode(response.body);

      if (data['success'] == true) {
        return Vehicle.fromJson(data['data']);
      } else {
        throw Exception(data['message'] ?? 'Failed to add vehicle');
      }
    } else {
      throw Exception('Failed to add vehicle: ${response.statusCode}');
    }
  }

  // Delete a vehicle
  static Future<bool> deleteVehicle(String id) async {
    String? token = await TokenManager.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/user/vehicle/vehicle/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['success'] == true;
    } else {
      throw Exception('Failed to delete vehicle: ${response.statusCode}');
    }
  }
}
