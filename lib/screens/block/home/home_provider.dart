import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/api_model/home/home_data_model.dart';
import '../../../api/api_service/home/home_service.dart';

class HomeDataProvider extends ChangeNotifier {
  List<String> _banners = [];
  bool _showDashboard = false;
  bool _isLoading = true;
  String? _error;
  bool _isDriver = false; // Track driver status
  final HomeRepository _homeRepository =
      HomeRepository(baseUrl: ApiConstants.baseUrl);
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  // Getters
  List<String> get banners => _banners;
  bool get showDashboard => _showDashboard;
  bool get isLoading => _isLoading;
  String? get error => _error;

  bool get isDriver => _isDriver; // Getter for driver status

  HomeDataProvider() {
    // Load data from cache immediately on initialization
    _loadFromCache();
  }

  // Set initial driver status (from token data)
  void setInitialDriverStatus(bool isDriverStatus) {
    _isDriver = isDriverStatus;
    notifyListeners();
  }

  Future<void> fetchHomeData({String? fcmToken}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final fcmToken = await _firebaseMessaging.getToken();
      final homeInfo = await _homeRepository.getHomeInfo(fcmToken: fcmToken);

      _banners = homeInfo.data.banners;
      _showDashboard = homeInfo.data.showDashboard;

      // Print the API response for showDashboard
      print('API showDashboard: $_showDashboard');


      // Update driver status based on showDashboard value from API
      _isDriver = homeInfo.data.showDashboard;

      _isLoading = false;

      // Cache the data
      _saveToCache();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Try to load the complete cached response first
      final jsonString = prefs.getString('home_info_response');
      if (jsonString != null) {
        try {
          final jsonResponse = json.decode(jsonString);
          final homeInfo = HomeInfoResponse.fromJson(jsonResponse);

          _banners = homeInfo.data.banners;
          _showDashboard = homeInfo.data.showDashboard;

          // Print the cached value for showDashboard
          print('Cached showDashboard (from JSON): $_showDashboard');


          _isDriver = homeInfo.data
              .showDashboard; // Set driver status from cached showDashboard
        } catch (e) {
          print('Error parsing cached JSON: $e');

          // Fall back to individual cached items
          final cachedBanners = prefs.getStringList('banners');
          if (cachedBanners != null) {
            _banners = cachedBanners;
          }

          _showDashboard = prefs.getBool('showDashboard') ?? false;
          _isDriver =
              prefs.getBool('showDashboard') ?? false; // Set driver status
        }
      } else {
        // Fall back to individual cached items
        final cachedBanners = prefs.getStringList('banners');
        if (cachedBanners != null) {
          _banners = cachedBanners;
        }

        _showDashboard = prefs.getBool('showDashboard') ?? false;
        _isDriver =
            prefs.getBool('showDashboard') ?? false; // Set driver status
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Failed to load from cache: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveToCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save individual items
      await prefs.setStringList('banners', _banners);
      await prefs.setBool('showDashboard', _showDashboard);
      await prefs.setBool('is_driver', _isDriver); // Save driver status

      // Save complete response
      final jsonString = json.encode({
        'status': true,
        'message': 'Cached data',
        'data': {
          'banners': _banners,
          'showDashboard': _showDashboard,
        }
      });
      await prefs.setString('home_info_response', jsonString);

      // Save timestamp
      await prefs.setInt(
          'home_info_timestamp', DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Failed to save to cache: $e');
    }
  }

  // Clear all cached data
  Future<void> clearCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('banners');
      await prefs.remove('showDashboard');
      await prefs.remove('home_info_response');
      await prefs.remove('home_info_timestamp');
    } catch (e) {
      print('Failed to clear cache: $e');
    }
  }
}
