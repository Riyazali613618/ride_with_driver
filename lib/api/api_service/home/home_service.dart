import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../constants/token_manager.dart';
import '../../api_model/home/home_data_model.dart';

class HomeRepository {
  final String baseUrl;

  HomeRepository({required this.baseUrl});

  Future<HomeInfoResponse> getHomeInfo({String? fcmToken}) async {
    try {
      // Try to fetch from API first
      final response = await _fetchFromApi(fcmToken);
      return response;
    } catch (e) {
      // If API call fails, try to load from cache
      try {
        final cachedResponse = await _loadFromCache();
        if (cachedResponse != null) {
          return cachedResponse;
        }
      } catch (cacheError) {
        print('Cache loading error: $cacheError');
      }

      // If cache also fails, rethrow the original exception
      throw Exception('Failed to load home info: $e');
    }
  }

  Future<HomeInfoResponse> _fetchFromApi(String? fcmToken) async {
    final token = await TokenManager.getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final response = await http.post(
      Uri.parse('$baseUrl/user/home'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({'fcmToken': fcmToken ?? ''}),
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final homeInfo = HomeInfoResponse.fromJson(jsonResponse);

      // Cache the response data
      _saveToCache(homeInfo);

      return homeInfo;
    } else {
      throw Exception('API error: ${response.statusCode}');
    }
  }

  Future<void> _saveToCache(HomeInfoResponse response) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save the banner URLs
      await prefs.setStringList('banners', response.data.banners);

      // Save show dashboard flag
      await prefs.setBool('showDashboard', response.data.showDashboard);

      // Save full JSON response
      final jsonString = json.encode({
        'status': response.status,
        'message': response.message,
        'data': {
          'banners': response.data.banners,
          'showDashboard': response.data.showDashboard,
        }
      });
      await prefs.setString('home_info_response', jsonString);

      // Save timestamp of when this data was cached
      await prefs.setInt(
          'home_info_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Failed to cache home info: $e');
    }
  }

  Future<HomeInfoResponse?> _loadFromCache() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('home_info_response');

    if (jsonString != null) {
      try {
        final jsonResponse = json.decode(jsonString);
        return HomeInfoResponse.fromJson(jsonResponse);
      } catch (e) {
        print('Error parsing cached JSON: $e');

        // Fallback to individual cached elements
        final banners = prefs.getStringList('banners') ?? [];
        final showDashboard = prefs.getBool('showDashboard') ?? false;

        return HomeInfoResponse(
          status: true,
          message: 'Loaded from cache',
          data: HomeData(
            banners: banners,
            showDashboard: showDashboard,
          ),
        );
      }
    }
    return null;
  }
}
