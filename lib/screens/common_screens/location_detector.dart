import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LocationData {
  final String displayName;
  final String addressDetails;
  final double latitude;
  final double longitude;
  final String? pincode;

  LocationData({
    required this.displayName,
    required this.addressDetails,
    required this.latitude,
    required this.longitude,
    this.pincode,
  });

  factory LocationData.fromOpenStreetMap(Map<String, dynamic> json) {
    String display = json['display_name'] ?? 'Unknown Location';

    // Extract address components
    Map<String, dynamic> address = json['address'] ?? {};
    String addressDetail = [
      address['road'],
      address['suburb'],
      address['city'] ?? address['town'] ?? address['village'],
      address['state'],
      address['country'],
    ].where((element) => element != null).join(', ');

    return LocationData(
      displayName: display
          .split(',')
          .take(2)
          .join(','), // First two components for title
      addressDetails: addressDetail,
      latitude: double.parse(json['lat']),
      longitude: double.parse(json['lon']),
      pincode: address['postcode'],
    );
  }

  // For creating a basic location entry from coordinates
  factory LocationData.fromCoordinates(
      double lat, double lon, String name, String details) {
    return LocationData(
      displayName: name,
      addressDetails: details,
      latitude: lat,
      longitude: lon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'displayName': displayName,
      'addressDetails': addressDetails,
      'latitude': latitude,
      'longitude': longitude,
      'pincode': pincode,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      displayName: json['displayName'],
      addressDetails: json['addressDetails'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      pincode: json['pincode'],
    );
  }
}

class LocationService {
  // Singleton pattern
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  // Cache for search results to reduce API calls
  final Map<String, List<LocationData>> _searchCache = {};

  // Recent locations
  List<LocationData> _recentLocations = [];
  static const int _maxRecentLocations = 5;

  // Load recent locations from SharedPreferences
  Future<void> loadRecentLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentLocationsJson = prefs.getStringList('recentLocations') ?? [];

      _recentLocations = recentLocationsJson
          .map((json) => LocationData.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      debugPrint('Error loading recent locations: $e');
      _recentLocations = [];
    }
  }

  // Save recent locations to SharedPreferences
  Future<void> _saveRecentLocations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final recentLocationsJson = _recentLocations
          .map((location) => jsonEncode(location.toJson()))
          .toList();

      await prefs.setStringList('recentLocations', recentLocationsJson);
    } catch (e) {
      debugPrint('Error saving recent locations: $e');
    }
  }

  // Add a location to recent locations
  void addToRecentLocations(LocationData location) {
    // Remove if already exists to avoid duplicates
    _recentLocations.removeWhere((item) =>
        item.latitude == location.latitude &&
        item.longitude == location.longitude);

    // Add to the beginning of the list
    _recentLocations.insert(0, location);

    // Trim list if it exceeds the maximum size
    if (_recentLocations.length > _maxRecentLocations) {
      _recentLocations = _recentLocations.sublist(0, _maxRecentLocations);
    }

    // Save updated list
    _saveRecentLocations();
  }

  // Get recent locations
  List<LocationData> getRecentLocations() {
    return List.from(_recentLocations);
  }

  // Get the user's current location
  Future<LocationData> getCurrentLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // Reverse geocode to get address details
      LocationData locationData =
          await reverseGeocode(position.latitude, position.longitude);

      return locationData;
    } catch (e) {
      debugPrint('Error getting current location: $e');
      rethrow;
    }
  }

  // Search for locations by query (address or PIN)
  Future<List<LocationData>> searchLocation(String query) async {
    // Check cache first
    if (_searchCache.containsKey(query)) {
      return _searchCache[query]!;
    }

    try {
      // Determine if query is a PIN code (only numbers)
      bool isPinCode = RegExp(r'^\d+$').hasMatch(query);

      final Uri uri;
      if (isPinCode) {
        // Search by PIN code using Nominatim
        uri = Uri.parse(
            'https://nominatim.openstreetmap.org/search?postalcode=$query&format=json&addressdetails=1&limit=10');
      } else {
        // Search by address using Nominatim
        uri = Uri.parse(
            'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&limit=10');
      }

      final response = await http.get(
        uri,
        headers: {'User-Agent': 'TransportApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final locations =
            data.map((item) => LocationData.fromOpenStreetMap(item)).toList();

        // Cache the results
        _searchCache[query] = locations;

        return locations;
      } else {
        throw Exception('Failed to search location: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error searching location: $e');
      // Return empty list on error
      return [];
    }
  }

  // Reverse geocode coordinates to get address
  Future<LocationData> reverseGeocode(double latitude, double longitude) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?lat=$latitude&lon=$longitude&format=json&addressdetails=1'),
        headers: {'User-Agent': 'TransportApp/1.0'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return LocationData.fromOpenStreetMap(data);
      } else {
        // Fallback to basic location with coordinates
        return LocationData.fromCoordinates(latitude, longitude,
            'Location at ($latitude, $longitude)', 'Unknown Address');
      }
    } catch (e) {
      debugPrint('Error reverse geocoding: $e');
      // Fallback to basic location with coordinates
      return LocationData.fromCoordinates(latitude, longitude,
          'Location at ($latitude, $longitude)', 'Unknown Address');
    }
  }

  // Clear search cache
  void clearCache() {
    _searchCache.clear();
  }
}
