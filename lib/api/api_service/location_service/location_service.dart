import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

import '../../api_model/location_model/location_model.dart';

class LocationService {
  List<LocationData> _recentLocations = [];
  final String googleApiKey =
      'AIzaSyDUkuN7zD7ApTqkkEyzOXnS_LDxEzP-t40'; // Your API key

  Future<void> loadRecentLocations() async {
    // TODO: Load from persistent storage if needed
    _recentLocations = [];
  }

  List<LocationData> getRecentLocations() => _recentLocations;

  void addToRecentLocations(LocationData location) {
    _recentLocations
        .removeWhere((loc) => loc.displayName == location.displayName);
    _recentLocations.insert(0, location);
    if (_recentLocations.length > 10) {
      _recentLocations.removeLast();
    }
    // TODO: Save to persistent storage if needed
  }

  Future<LocationData> getCurrentLocation() async {
    try {
      print("=== Getting Current Location ===");

      // 1. Check location permission
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

      // 2. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      print("Permissions OK, getting position...");

      // 3. Get device position with timeout and accuracy settings
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      );

      print("Position obtained: ${position.latitude}, ${position.longitude}");

      // 4. Use Google Geocoding API to reverse geocode
      final url = Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$googleApiKey');

      print("Making reverse geocoding request...");
      final response = await http.get(url);

      print("Reverse geocoding response status: ${response.statusCode}");

      if (response.statusCode != 200) {
        throw Exception(
            "Failed to reverse geocode location: ${response.statusCode}");
      }

      final data = jsonDecode(response.body);
      print("Geocoding API response: ${data['status']}");

      if (data['status'] != 'OK') {
        print("Geocoding error: ${data['error_message'] ?? 'Unknown error'}");
        throw Exception('Geocoding failed: ${data['status']}');
      }

      if (data['results'] == null || data['results'].isEmpty) {
        throw Exception('No address found for current location');
      }

      // Parse address
      final result = data['results'][0];
      final formattedAddress = result['formatted_address'] ?? '';

      print("Formatted address: $formattedAddress");

      String pincode = '';
      String locality = '';
      String administrativeArea = '';
      String street = '';
      String subLocality = '';
      String country = '';

      // Parse address components
      if (result['address_components'] != null) {
        for (var comp in result['address_components']) {
          final types = List<String>.from(comp['types']);

          if (types.contains('postal_code')) {
            pincode = comp['long_name'];
          }
          if (types.contains('locality')) {
            locality = comp['long_name'];
          }
          if (types.contains('administrative_area_level_1')) {
            administrativeArea = comp['long_name'];
          }
          if (types.contains('route')) {
            street = comp['long_name'];
          }
          if (types.contains('sublocality') ||
              types.contains('sublocality_level_1')) {
            subLocality = comp['long_name'];
          }
          if (types.contains('country')) {
            country = comp['long_name'];
          }
        }
      }

      // Create a meaningful display name
      String displayName = '';
      if (subLocality.isNotEmpty && locality.isNotEmpty) {
        displayName = "$subLocality, $locality";
      } else if (locality.isNotEmpty && administrativeArea.isNotEmpty) {
        displayName = "$locality, $administrativeArea";
      } else if (locality.isNotEmpty) {
        displayName = locality;
      } else if (administrativeArea.isNotEmpty) {
        displayName = administrativeArea;
      } else {
        displayName = "Current Location";
      }

      // Create address details
      String addressDetails = '';
      if (street.isNotEmpty && subLocality.isNotEmpty) {
        addressDetails = "$street, $subLocality";
      } else if (street.isNotEmpty) {
        addressDetails = street;
      } else if (subLocality.isNotEmpty) {
        addressDetails = subLocality;
      } else {
        addressDetails = formattedAddress;
      }

      print("=== Location Data Created ===");
      print("Display Name: $displayName");
      print("Address Details: $addressDetails");
      print("Pincode: $pincode");
      print("Country: $country");

      // Verify it's in India
      if (!country.toLowerCase().contains('india')) {
        print("Warning: Location might not be in India: $country");
      }

      return LocationData(
        displayName: displayName,
        addressDetails: addressDetails,
        pincode: pincode.isNotEmpty ? pincode : null,
      );
    } catch (e) {
      print("Error in getCurrentLocation: $e");
      rethrow; // Re-throw the error so it can be handled by the calling code
    }
  }

  // Alternative method using a simpler approach if geocoding fails
  Future<LocationData> getCurrentLocationSimple() async {
    try {
      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions denied');
        }
      }

      // Get position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 15),
      );

      // Return basic location data
      return LocationData(
        displayName: "Current Location",
        addressDetails:
            "Lat: ${position.latitude.toStringAsFixed(6)}, Lng: ${position.longitude.toStringAsFixed(6)}",
        pincode: null,
      );
    } catch (e) {
      print("Error in getCurrentLocationSimple: $e");
      throw Exception('Unable to get current location: $e');
    }
  }
}
