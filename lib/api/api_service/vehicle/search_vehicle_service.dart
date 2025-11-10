import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:r_w_r/api/api_model/favouriteModel.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../api_model/vehicle/search_vehicles.dart';

class VehicleService {
  Future<VehicleSearchResponse> searchVehicles({
    required String pincode,
    required double lat,
    required double lng,
    required String searchType,
    int page = 1,
    int limit = 10,
    Map<String, dynamic> filters = const {},
  }) async {
    final baseUrl = ApiConstants.baseUrl;
    final token = await TokenManager.getToken();
    final url = Uri.parse('$baseUrl/user/search');

    filters.remove('vehicleType');


    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'pincode': pincode,
          'lat': lat,
          'lng': lng,
          'searchType': searchType,
          'page': page,
          'limit': limit,
          'filters': filters,
        }),
      );
      print("searchVehicles:${jsonEncode({
        'pincode': pincode,
        'lat': lat,
        'lng': lng,
        'searchType': searchType,
        'page': page,
        'limit': limit,
        'filters': filters,
      })}");

      developer.log('Response Status: ${response.statusCode}');
      developer.log('Response Headers: ${response.headers}');
      developer.log('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        developer.log('Parsed JSON: $jsonResponse');

        final vehicleResponse = VehicleSearchResponse.fromJson(jsonResponse);
        developer.log(
            'Vehicle Response Data Length: ${vehicleResponse.data.results.length}');

        for (int i = 0; i < vehicleResponse.data.results.length; i++) {
          final owner = vehicleResponse.data.results[i];
          developer.log(
              'Owner $i: ${owner.firstName}, Vehicles: ${owner.vehicles.length}');
        }

        return vehicleResponse;
      }
      else {
        developer.log('HTTP Error: ${response.statusCode}');
        developer.log('Error Body: ${response.body}');
        throw Exception(
            'Failed to load vehicles: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      developer.log('Exception in searchVehicles: $e');
      throw Exception('Failed to load vehicles: $e');
    }
  }

  Future<void> addToFavourites(String partnerId,String vehicleId) async {
    final baseUrl = ApiConstants.baseUrl;
    final token = await TokenManager.getToken();
    final url = Uri.parse('$baseUrl/user/favorites');

    print("partnerId:${partnerId}:${vehicleId}");
    print("${token}");
try {
  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: jsonEncode({
      'partnerId': partnerId,
      'vehicleId':vehicleId,
    }),
  );
  developer.log('Response Status: ${response.statusCode}');
  developer.log('Response Headers: ${response.headers}');
  developer.log('Response Body: ${response.body}');
  if (response.statusCode == 200 || response.statusCode == 201) {
    developer.log('Added to favourites:${response.body}');
    return;
  }
  else {
    developer.log('HTTP Error: ${response.statusCode}');
    developer.log('Error Body: ${response.body}');
    throw Exception(
        'Failed to add favourites: ${response.statusCode} - ${response.body}');
  }
}catch(e){
  developer.log('Exception in searchVehicles: $e');
  throw Exception('Failed to load vehicles: $e');
}

  }

  Future<List<Data>> getFavourites() async {
    String? token = await TokenManager.getToken();

    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/user/favorites'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true) {
        final favouritesData = data['data'] as List;
        print("favouritesData:${favouritesData}");
        return favouritesData.map((item) => Data.fromJson(item)).toList();
      } else {
        throw Exception(data['message'] ?? 'Failed to load vehicles');
      }
    } else {
      throw Exception('Failed to load vehicles: ${response.statusCode}');
    }
  }

  Future<void> deleteFavourites(String vehicleId) async {
    final baseUrl = ApiConstants.baseUrl;
    final token = await TokenManager.getToken();
    final url = Uri.parse('$baseUrl/user/favorites/${vehicleId}');
    print("partnerId${vehicleId}");
    print("${token}");
    try {
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      developer.log('Response Status: ${response.statusCode}');
      developer.log('Response Headers: ${response.headers}');
      developer.log('Response Body: ${response.body}');
      if (response.statusCode == 200) {
        developer.log('deleted favourites:${response.body}');
        return;
      }
      else {
        developer.log('HTTP Error: ${response.statusCode}');
        developer.log('Error Body: ${response.body}');
        throw Exception(
            'Failed to delete favourites: ${response.statusCode} - ${response.body}');
      }
    }catch(e){
      developer.log('Exception in delete favourites: $e');
      throw Exception('Failed to delete favourites: $e');
    }

  }
}
