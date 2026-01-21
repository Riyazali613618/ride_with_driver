import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constants/api_constants.dart';
import '../features/vehicles/presentation/pages/add_new_vehicle_screen.dart';

class GooglePlaceSearchWidgetBooking extends StatefulWidget {
  final TextEditingController controller;
  final String type;
  final Function(PlaceSuggestion) onSelected;

  const GooglePlaceSearchWidgetBooking(
      {required this.controller,
      required this.onSelected,
      required this.type,
      super.key});

  @override
  State<GooglePlaceSearchWidgetBooking> createState() =>
      _GooglePlaceSearchWidgetBookingState();
}

class _GooglePlaceSearchWidgetBookingState
    extends State<GooglePlaceSearchWidgetBooking> {
  @override
  Widget build(BuildContext context) {
    return _googlePlaceSearch(widget.type, context);
  }

  Timer? _searchDebounceTimer;
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  _googlePlaceSearch(String label, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          height: 40,
          padding: const EdgeInsets.only(left: 0),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
              child: CompositedTransformTarget(
                link: _layerLink,
                child: TextField(
                  readOnly: false,
                  controller: widget.controller,
                  style: TextStyle(
                      fontFamily: AppConstants.ptSansFont,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                      hintText: label,
                      suffixIcon: !isLoadingLocation &&
                              widget.controller.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.cancel_outlined,
                                size: 16,
                              ),
                              onPressed: () {
                                widget.controller.clear();
                                setState(() {
                                  _suggestions.clear();
                                  _showDropdown = false;
                                });
                              },
                            )
                          : null,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      labelText: label,
                      labelStyle: TextStyle(
                          fontFamily: AppConstants.ptSansFont,
                          fontSize: 11,
                          fontWeight: FontWeight.w400),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))),
                  onChanged: (value) {
                    _searchDebounceTimer?.cancel();
                    _searchDebounceTimer = Timer(
                      const Duration(milliseconds: 500),
                      () => _searchLocationsWithService(value),
                    );
                  },
                ),
              )
              /*TextField(
                controller: widget.controller,
                decoration: InputDecoration(
                  hintText: label,
                  border: InputBorder.none,
                  suffixIcon: !isLoadingLocation &&
                      widget.controller.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.cancel_outlined,
                      size: 16,
                    ),
                    onPressed: () {
                      widget.controller.clear();
                      setState(() {
                        _suggestions.clear();
                        _showDropdown = false;
                      });
                    },
                  )
                      : null,
                ),
                onChanged: (value) {
                  _searchDebounceTimer?.cancel();
                  _searchDebounceTimer = Timer(
                    const Duration(milliseconds: 500),
                        () => _searchLocationsWithService(value),
                  );
                },
              )*/
              ,
            ),
            if (isLoadingLocation)
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                    strokeWidth: 1,
                  )),
            if (isLoadingLocation)
              SizedBox(
                width: 16,
              )
          ]),
        ),

        /// Dropdown
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  title: Text(item.mainText),
                  subtitle: Text(item.secondaryText),
                  onTap: () {
                    widget.controller.text = "";
                    //  _selectedLocations.add(item.mainText);
                    setState(() {
                      _showDropdown = false;
                    });

                    /// You now have placeId
                    print("Selected placeId: ${item.placeId}");
                  },
                );
              },
            ),
          ),
      ],
    );
  }

  void _showOverlay() {
    _overlayEntry?.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 45),
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(8),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  title: Text(item.mainText),
                  subtitle: Text(item.secondaryText),
                  onTap: () {
                    widget.controller.text = item.mainText;
                    widget.onSelected(item);
                    _removeOverlay();
                    /// placeId available
                    print("Selected placeId: ${item.placeId}");
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  List<PlaceSuggestion> _suggestions = [];
  bool _showDropdown = false;

  void _searchLocationsWithService(String value) async {
    final results = await searchPlaces(value);
    _suggestions = results;
    if (results.isNotEmpty) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
    /* setState(() {
      _showDropdown = results.isNotEmpty;
    });*/
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _removeOverlay();
    super.dispose();
  }

  bool isLoadingLocation = false;

  Future<List<PlaceSuggestion>> searchPlaces(String input) async {
    if (input.isEmpty) return [];
    if (mounted) {
      setState(() {
        isLoadingLocation = true;
      });
    }
    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': ApiConstants.apiKey,
        'X-Goog-FieldMask': 'suggestions.placePrediction',
      },
      body: jsonEncode({
        "input": input,
        "locationBias": {
          "rectangle": {
            "low": {"latitude": 6.0, "longitude": 68.0},
            "high": {"latitude": 36.0, "longitude": 98.0}
          }
        }
      }),
    );
    if (mounted) {
      setState(() {
        isLoadingLocation = false;
      });
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['suggestions'] as List)
          .map((e) => PlaceSuggestion.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to fetch places');
    }
  }


}

Future<Map<String, dynamic>> getLatLngForSelectedLoc(String placeId) async {
  final placeDetailsUrl = Uri.parse(
    'https://places.googleapis.com/v1/places/$placeId',
  );

  final detailsResponse = await http.get(
    placeDetailsUrl,
    headers: {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': ApiConstants.apiKey,
      'X-Goog-FieldMask': 'location',
    },
  );

  Map<String, dynamic>? data = jsonDecode(detailsResponse.body);

  if (data != null) {
    if (data['location'] != null) {
      return data['location'];
    }
  }
  return {};
}
