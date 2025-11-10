import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../components/custtom_location_widget.dart';

class PlacesApiService {
  final String apiKey;
  static const String baseUrl = 'https://places.googleapis.com/v1';

  PlacesApiService({required this.apiKey});

  Future<List<dynamic>> searchPlaces(String input) async {
    if (input.isEmpty) {
      return [];
    }

    final url = Uri.parse('$baseUrl/places:autocomplete');

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': '*',
    };

    final body = jsonEncode({
      "input": input,
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['suggestions'] ?? [];
      } else {
        debugPrint('Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('Exception in searchPlaces: $e');
      return [];
    }
  }

  Future<LocationData?> getPlaceDetails(
    String placeId,
    String mainText,
    String secondaryText,
  ) async {
    final url = Uri.parse('$baseUrl/places/$placeId');

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': apiKey,
      'X-Goog-FieldMask': 'location,addressComponents,formattedAddress',
    };

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Extract latitude and longitude
        final location = data['location'];
        final double latitude = location['latitude'];
        final double longitude = location['longitude'];

        // Extract pin code from address components
        String pinCode = 'Not found';
        final addressComponents = data['addressComponents'] as List<dynamic>?;

        if (addressComponents != null) {
          for (var component in addressComponents) {
            final types = component['types'] as List<dynamic>;
            if (types.contains('postal_code')) {
              pinCode = component['longText'];
              break;
            }
          }
        }

        final formattedAddress =
            data['formattedAddress'] ?? 'Address not available';

        return LocationData(
          placeId: placeId,
          mainText: mainText,
          secondaryText: secondaryText,
          latitude: latitude,
          longitude: longitude,
          pinCode: pinCode,
          formattedAddress: formattedAddress,
        );
      } else {
        debugPrint(
            'Error fetching place details ${response.statusCode}: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('Exception fetching place details: $e');
      return null;
    }
  }
}
