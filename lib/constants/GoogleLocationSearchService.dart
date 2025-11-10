import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:r_w_r/constants/api_constants.dart';

import '../api/api_model/location_model/location_model.dart';

class GoogleLocationSearchService {
  static const String _apiKey = ApiConstants.apiKey;

  // Get current location
  static Future<LatLng?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.deniedForever) {
          return null;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      print('Error getting current location: $e');
      return null;
    }
  }

  // Get location name from coordinates
  static Future<String> getLocationNameFromCoordinates(LatLng coordinates) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
          coordinates.latitude, coordinates.longitude);

      String locationName = 'Current Location';
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          locationName = place.subLocality!;
        } else if (place.thoroughfare != null && place.thoroughfare!.isNotEmpty) {
          locationName = place.thoroughfare!;
        } else if (place.locality != null && place.locality!.isNotEmpty) {
          locationName = place.locality!;
        }

        if (place.locality != null && place.locality!.isNotEmpty && locationName != place.locality) {
          locationName += ', ${place.locality}';
        }

        if (locationName.isEmpty) locationName = 'Current Location';
      }
      return locationName;
    } catch (e) {
      print('Error getting location name: $e');
      return 'Current Location';
    }
  }

  // Search locations using Google Places API
  static Future<List<GooglePlacesSuggestion>> searchPlaces(String query) async {
    if (query.isEmpty) return [];

    try {
      final url = Uri.parse('https://places.googleapis.com/v1/places:autocomplete');

      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': '*',
      };

      final body = jsonEncode({
        "input": query,
        "locationBias": {
          "rectangle": {
            "low": {
              "latitude": 6.0, // Southernmost point of India
              "longitude": 68.0, // Westernmost point of India
            },
            "high": {
              "latitude": 36.0, // Northernmost point of India
              "longitude": 98.0, // Easternmost point of India
            }
          }
        }
      });

      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final suggestions = data['suggestions'] as List<dynamic>? ?? [];

        return suggestions.map((item) {
          final prediction = item['placePrediction'];
          final structuredFormat = prediction['structuredFormat'];

          final mainText = structuredFormat?['mainText']?['text'] ?? '';
          final secondaryText = structuredFormat?['secondaryText']?['text'] ?? '';
          String fullText = '';

          if (prediction?['text'] != null) {
            if (prediction['text'] is String) {
              fullText = prediction['text'];
            } else if (prediction['text'] is Map && prediction['text']['text'] != null) {
              fullText = prediction['text']['text'];
            }
          }

          return GooglePlacesSuggestion(
            placeId: prediction?['placeId'] ?? '',
            mainText: mainText,
            secondaryText: secondaryText,
            fullText: fullText.isNotEmpty ? fullText : mainText,
            isCurrentLocation: false,
            isRecentLocation: false,
          );
        }).toList();
      } else {
        print('Google Places API Error ${response.statusCode}: ${response.body}');
        throw Exception('Failed to fetch suggestions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error searching places: $e');
      throw e;
    }
  }

  // Get detailed information about a place
  static Future<GooglePlaceDetails> getPlaceDetails(String placeId) async {
    try {
      final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');

      final headers = {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': _apiKey,
        'X-Goog-FieldMask': 'location,addressComponents,formattedAddress,types',
      };

      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Check if the place is in India
        final addressComponents = data['addressComponents'] as List<dynamic>?;
        bool isInIndia = false;
        String country = '';

        if (addressComponents != null) {
          for (var component in addressComponents) {
            final types = component['types'] as List<dynamic>;
            if (types.contains('country')) {
              country = component['longText'];
              isInIndia = country.contains('India');
              break;
            }
          }
        }

        if (!isInIndia) {
          throw Exception('This location is not in India');
        }

        // Extract location
        final location = data['location'];
        final double latitude = location['latitude'];
        final double longitude = location['longitude'];

        // Extract pin code
        String pinCode = 'Not found';
        if (addressComponents != null) {
          for (var component in addressComponents) {
            final types = component['types'] as List<dynamic>;
            if (types.contains('postal_code')) {
              pinCode = component['longText'];
              break;
            }
          }
        }

        final formattedAddress = data['formattedAddress'] ?? 'Address not available';

        return GooglePlaceDetails(
          placeId: placeId,
          formattedAddress: formattedAddress,
          latitude: latitude,
          longitude: longitude,
          pinCode: pinCode,
        );
      } else {
        print('Error fetching place details ${response.statusCode}: ${response.body}');
        throw Exception('Failed to fetch place details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting place details: $e');
      throw e;
    }
  }

  // Get current location with name
  static Future<Map<String, dynamic>?> getCurrentLocationWithDetails() async {
    try {
      final coordinates = await getCurrentLocation();
      if (coordinates == null) return null;

      final locationName = await getLocationNameFromCoordinates(coordinates);

      return {
        'coordinates': coordinates,
        'name': locationName,
        'suggestion': GooglePlacesSuggestion(
          placeId: 'current_location',
          mainText: locationName,
          secondaryText: "Your current location",
          fullText: locationName,
          isRecentLocation: false,
          isCurrentLocation: true,
        )
      };
    } catch (e) {
      print('Error getting current location with details: $e');
      return null;
    }
  }
}

// Example usage class
class LocationSearchExample {
  Timer? _searchDebounceTimer;
  List<GooglePlacesSuggestion> suggestions = [];

  // Search with debouncing
  void searchLocations(String query, Function(List<GooglePlacesSuggestion>) onResults) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(Duration(milliseconds: 500), () async {
      try {
        if (query.isEmpty) {
          // Show current location when query is empty
          final currentLocationData = await GoogleLocationSearchService.getCurrentLocationWithDetails();
          if (currentLocationData != null) {
            onResults([currentLocationData['suggestion']]);
          } else {
            onResults([]);
          }
          return;
        }

        final results = await GoogleLocationSearchService.searchPlaces(query);

        // Always add current location as first option
        List<GooglePlacesSuggestion> finalResults = [];
        final currentLocationData = await GoogleLocationSearchService.getCurrentLocationWithDetails();
        if (currentLocationData != null) {
          finalResults.add(currentLocationData['suggestion']);
        }

        finalResults.addAll(results);
        onResults(finalResults);
      } catch (e) {
        print('Search error: $e');
        onResults([]);
      }
    });
  }

  // Handle location selection
  Future<GooglePlaceDetails?> selectLocation(GooglePlacesSuggestion suggestion) async {
    try {
      if (suggestion.isRecentLocation) {
        final currentLocationData = await GoogleLocationSearchService.getCurrentLocationWithDetails();
        if (currentLocationData != null) {
          final coordinates = currentLocationData['coordinates'] as LatLng;
          return GooglePlaceDetails(
            placeId: 'current_location',
            formattedAddress: currentLocationData['name'],
            latitude: coordinates.latitude,
            longitude: coordinates.longitude,
            pinCode: 'Not available',
          );
        }
        return null;
      }

      return await GoogleLocationSearchService.getPlaceDetails(suggestion.placeId);
    } catch (e) {
      print('Error selecting location: $e');
      return null;
    }
  }

  void dispose() {
    _searchDebounceTimer?.cancel();
  }
}
