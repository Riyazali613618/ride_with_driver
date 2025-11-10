import 'package:flutter/material.dart';

import '../api/api_service/location_service/search_location_service.dart';
import '../constants/color_constants.dart';
import '../l10n/app_localizations.dart';

class LocationData {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final double? latitude;
  final double? longitude;
  final String? pinCode;
  final String? formattedAddress;

  LocationData({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
    this.latitude,
    this.longitude,
    this.pinCode,
    this.formattedAddress,
  });

  @override
  String toString() {
    return '$mainText, $secondaryText';
  }

  Map<String, dynamic> toJson() {
    return {
      'placeId': placeId,
      'mainText': mainText,
      'secondaryText': secondaryText,
      'latitude': latitude,
      'longitude': longitude,
      'pinCode': pinCode,
      'formattedAddress': formattedAddress,
    };
  }

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      placeId: json['placeId'] ?? '',
      mainText: json['mainText'] ?? '',
      secondaryText: json['secondaryText'] ?? '',
      latitude: json['latitude'],
      longitude: json['longitude'],
      pinCode: json['pinCode'],
      formattedAddress: json['formattedAddress'],
    );
  }
}

class LocationSearchScreen extends StatefulWidget {
  final void Function(LocationData)? onLocationSelected;
  final List<LocationData>? initialLocations;
  final LocationData? initialLocation;
  final bool allowMultipleLocations;

  const LocationSearchScreen({
    Key? key,
    this.onLocationSelected,
    this.initialLocation,
    this.initialLocations,
    this.allowMultipleLocations = false,
  }) : super(key: key);

  @override
  _LocationSearchScreenState createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  List<dynamic> _suggestions = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Store selected locations
  List<LocationData> _selectedLocations = [];

  // Current focused location for single location mode
  LocationData? _currentLocation;

  // API service
  late PlacesApiService _apiService;

  @override
  void initState() {
    super.initState();
    _apiService =
        PlacesApiService(apiKey: "AIzaSyDUkuN7zD7ApTqkkEyzOXnS_LDxEzP-t40");

    // Initialize with provided locations
    if (widget.allowMultipleLocations) {
      if (widget.initialLocations != null) {
        _selectedLocations = List.from(widget.initialLocations!);
      } else if (widget.initialLocation != null) {
        _selectedLocations = [widget.initialLocation!];
      }
    } else {
      if (widget.initialLocation != null) {
        _currentLocation = widget.initialLocation;
      }
    }

    // Add listener to focus node to clear suggestions when focus is lost
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!_focusNode.hasFocus) {
      // Clear suggestions when focus is lost, after a short delay
      Future.delayed(Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() {
            _suggestions = [];
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchPlace(String input) async {
    setState(() {
      _errorMessage = '';
    });

    if (input.isEmpty) {
      setState(() {
        _suggestions = [];
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      final results = await _apiService.searchPlaces(input);
      if (mounted) {
        setState(() {
          _suggestions = results;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Exception in _searchPlace: $e');
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;

        setState(() {
          _suggestions = [];
          _isLoading = false;
          _errorMessage = localizations.retry;
        });
      }
    }
  }

  Future<void> _selectPlace(dynamic suggestion) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      final placePrediction = suggestion['placePrediction'];
      if (placePrediction == null) {
        setState(() {
          _errorMessage = localizations.pleaseTryAgainLater;
        });
        return;
      }

      final placeId = placePrediction['placeId'];
      final structuredFormat = placePrediction['structuredFormat'];

      if (structuredFormat == null) {
        setState(() {
          _errorMessage = localizations.error_rendering_content;
        });
        return;
      }

      final mainText = structuredFormat['mainText']['text'];
      final secondaryText = structuredFormat['secondaryText']['text'];

      setState(() => _isLoading = true);

      final locationData =
          await _apiService.getPlaceDetails(placeId, mainText, secondaryText);

      if (locationData != null) {
        if (widget.allowMultipleLocations) {
          // Add to list of selected locations if not already present
          if (!_selectedLocations
              .any((loc) => loc.placeId == locationData.placeId)) {
            setState(() {
              _selectedLocations.add(locationData);
            });
          }
        } else {
          // Single location mode
          setState(() {
            _currentLocation = locationData;
          });
        }

        // Clear search field and suggestions
        setState(() {
          _controller.clear();
          _suggestions = [];
        });

        // Notify parent if callback provided
        if (widget.onLocationSelected != null) {
          widget.onLocationSelected!(locationData);
        }
      } else {
        setState(() {
          _errorMessage = localizations.not_specified;
        });
      }
    } catch (e) {
      debugPrint('Error selecting place: $e');
      setState(() {
        _errorMessage = localizations.retry;
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _removeLocation(LocationData location) {
    if (widget.allowMultipleLocations) {
      setState(() {
        _selectedLocations
            .removeWhere((loc) => loc.placeId == location.placeId);
      });
    } else {
      setState(() {
        _currentLocation = null;
      });
    }
  }

  Widget _buildSuggestionItem(dynamic item) {
    try {
      final placePrediction = item['placePrediction'];
      if (placePrediction == null) return SizedBox.shrink();

      final structuredFormat = placePrediction['structuredFormat'];
      if (structuredFormat == null) return SizedBox.shrink();

      final mainText = structuredFormat['mainText']['text'];
      final secondaryText = structuredFormat['secondaryText']['text'];

      return ListTile(
        title: Text(mainText),
        subtitle: Text(secondaryText),
        onTap: () => _selectPlace(item),
      );
    } catch (e) {
      debugPrint('Error building suggestion item: $e');
      return SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search Box
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              // TextField takes remaining space
              Expanded(
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: localizations.search_for_location,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  onChanged: (value) => _searchPlace(value),
                ),
              ),
              // Loading indicator or search icon
              _isLoading
                  ? Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      icon: Icon(Icons.search),
                      onPressed: () => _searchPlace(_controller.text),
                    ),
            ],
          ),
        ),

        // Error message if any
        if (_errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage,
              style: TextStyle(color: Colors.red),
            ),
          ),

        // Selected Location Chips
        if (widget.allowMultipleLocations && _selectedLocations.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Wrap(
              spacing: 2,
              runSpacing: 0,
              children: _selectedLocations
                  .map((location) => LocationChip(
                        location: location,
                        onDelete: () => _removeLocation(location),
                      ))
                  .toList(),
            ),
          )
        else if (!widget.allowMultipleLocations && _currentLocation != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: LocationChip(
              location: _currentLocation!,
              onDelete: () => _removeLocation(_currentLocation!),
            ),
          ),

        // Display suggestions
        if (_suggestions.isNotEmpty)
          Container(
            margin: EdgeInsets.only(top: 8),
            constraints: BoxConstraints(maxHeight: 250),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                return _buildSuggestionItem(_suggestions[index]);
              },
            ),
          ),
      ],
    );
  }
}

class LocationChip extends StatelessWidget {
  final LocationData location;
  final VoidCallback? onDelete;

  const LocationChip({
    Key? key,
    required this.location,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Chip(
      backgroundColor: ColorConstants.primaryColorLight.withAlpha(50),
      labelPadding: EdgeInsets.only(left: 10),
      padding: EdgeInsets.zero,
      side: BorderSide(
        color: ColorConstants.primaryColor.withAlpha(50),
      ),
      label: Text(
        location.mainText,
        style: TextStyle(
          color: ColorConstants.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      deleteIcon: Icon(
        Icons.close,
        size: 14,
        color: ColorConstants.primaryColor,
      ),
      onDeleted: onDelete,
    );
  }
}
