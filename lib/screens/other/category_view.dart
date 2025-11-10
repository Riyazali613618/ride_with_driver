import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/api/api_model/location_model/location_model.dart';
import 'package:r_w_r/api/api_service/location_service/location_service.dart';
import 'package:r_w_r/components/app_appbar.dart';
import 'package:r_w_r/constants/assets_constant.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/screens/user_screens/vehicles.dart';

import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';
import '../user_screens/LocationSearchScreen.dart';

class GridViewExample extends StatefulWidget {
  @override
  _GridViewExampleState createState() => _GridViewExampleState();
}

class _GridViewExampleState extends State<GridViewExample> {
  final LocationService _locationService = LocationService();
  final String _apiKey = 'AIzaSyDUkuN7zD7ApTqkkEyzOXnS_LDxEzP-t40';

  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  bool showSearchSuggestions = false;
  String selectedCategory = "All Vehicles";
  List<GooglePlacesSuggestion> filteredLocations = [];
  GooglePlaceDetails? selectedLocationData;
  bool isSearching = false;
  List<LocationData> recentLocations = [];

  @override
  void initState() {
    super.initState();
    _loadRecentLocations();
    searchFocusNode.addListener(_handleFocusChange);
    searchController.addListener(_handleSearchTextChange);
  }

  void _handleFocusChange() {
    if (searchFocusNode.hasFocus) {
      setState(() {
        showSearchSuggestions = true;
        filteredLocations = _convertRecentLocationsToGooglePlaces();
      });
    }
  }

  void _handleSearchTextChange() {
    _searchLocationsWithGooglePlaces(searchController.text);
  }

  Future<void> _loadRecentLocations() async {
    try {
      await _locationService.loadRecentLocations();
      setState(() {
        recentLocations = _locationService.getRecentLocations();
      });
    } catch (e) {
      print("Error loading recent locations: $e");
    }
  }

  Future<void> _searchLocationsWithGooglePlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredLocations = _convertRecentLocationsToGooglePlaces();
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final suggestions = await _fetchGooglePlacesSuggestions(query);
      setState(() {
        filteredLocations = suggestions;
        isSearching = false;
      });
    } catch (e) {
      setState(() {
        filteredLocations = [];
        isSearching = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search error: $e')),
      );
    }
  }

  Future<List<GooglePlacesSuggestion>> _fetchGooglePlacesSuggestions(
      String input) async {
    final url =
        Uri.parse('https://places.googleapis.com/v1/places:autocomplete');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': '*',
    };
    final body = jsonEncode({"input": input});

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
          } else if (prediction['text'] is Map &&
              prediction['text']['text'] != null) {
            fullText = prediction['text']['text'];
          }
        }
        return GooglePlacesSuggestion(
          placeId: prediction?['placeId'] ?? '',
          mainText: mainText,
          secondaryText: secondaryText,
          fullText: fullText.isNotEmpty ? fullText : mainText,
          isCurrentLocation: true,
        );
      }).toList();
    } else {
      throw Exception('Failed to fetch suggestions: ${response.statusCode}');
    }
  }

  Future<GooglePlaceDetails> _getGooglePlaceDetails(String placeId) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': 'location,addressComponents,formattedAddress',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final location = data['location'];
      final double latitude = location['latitude'];
      final double longitude = location['longitude'];

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

      return GooglePlaceDetails(
        placeId: placeId,
        formattedAddress: formattedAddress,
        latitude: latitude,
        longitude: longitude,
        pinCode: pinCode,
      );
    } else {
      throw Exception('Failed to fetch place details: ${response.statusCode}');
    }
  }

  List<GooglePlacesSuggestion> _convertRecentLocationsToGooglePlaces() {
    return recentLocations.map((location) {
      return GooglePlacesSuggestion(
        placeId: '',
        mainText: location.displayName,
        secondaryText: location.addressDetails,
        fullText: location.displayName,
        isRecentLocation: true,
        isCurrentLocation: true,
      );
    }).toList();
  }

  void _selectLocation(GooglePlacesSuggestion suggestion) async {
    setState(() {
      searchController.text = suggestion.fullText;
      showSearchSuggestions = false;
      searchFocusNode.unfocus();
    });

    if (suggestion.isRecentLocation) {
      setState(() {
        selectedLocationData = GooglePlaceDetails(
          placeId: '',
          formattedAddress: suggestion.fullText,
          latitude: 0.0,
          longitude: 0.0,
          pinCode: 'Not available',
        );
      });
      return;
    }

    try {
      final placeDetails = await _getGooglePlaceDetails(suggestion.placeId);
      setState(() {
        selectedLocationData = placeDetails;
      });

      final locationData = LocationData(
        displayName: suggestion.mainText,
        addressDetails: suggestion.secondaryText,
        pincode:
            placeDetails.pinCode != 'Not found' ? placeDetails.pinCode : null,
      );

      _locationService.addToRecentLocations(locationData);
      _loadRecentLocations();

      // Navigate after selecting location
      _navigateToSelectedScreen();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location details: $e')),
      );
    }
  }

  void _navigateToSelectedScreen() {
    if (selectedLocationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a location first')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VehicleSearchScreen(
          selectedCategory: selectedCategory,
          selectedLocation: selectedLocationData,
          // selectedCategory: selectedCategory,
          // selectedLocation: selectedLocationData!,
        ),
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      // appBar: CustomAppBar(
      //   title: showSearchSuggestions
      //       ? localizations.search_for_location
      //       : localizations.category,
      //   centerTitle: true,
      //   leading: showSearchSuggestions
      //       ? IconButton(
      //           icon: Icon(
      //             Icons.arrow_back_ios_new,
      //             color: Colors.white,
      //           ),
      //           onPressed: () {
      //             setState(() {
      //               showSearchSuggestions = false;
      //               searchFocusNode.unfocus();
      //             });
      //           },
      //         )
      //       : SizedBox.shrink(),
      // ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                gradientFirst,
                gradientSecond,
                gradientThird,
                Colors.white
              ],
              // stops: [
              //   0.0,
              //   0.20,
              //   0.80,
              // ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // ✅ Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.arrow_back_ios,
                          color: ColorConstants.white,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: Text(
                          localizations.category,
                          style: TextStyle(
                            color: ColorConstants.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            
            
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: !showSearchSuggestions
                        ? _buildGridView(screenWidth)
                        : _buildSearchSection(),
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }

  Widget _buildGridView(double screenWidth) {
    final suggestions = getLocalizedSuggestions(context);

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: LayoutBuilder(
        builder: (context, constraints) {
          double maxCrossAxisExtent = screenWidth / 3;

          return GridView.builder(
            itemCount: suggestions.length,
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: maxCrossAxisExtent.clamp(100, 160),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 3 / 3.2,
            ),
            itemBuilder: (BuildContext context, int index) {
              final suggestion = suggestions[index];
              return GestureDetector(
                // onTap: () {
                //   setState(() {
                //     selectedCategory = suggestion['label']!;
                //     showSearchSuggestions = true;
                //     WidgetsBinding.instance.addPostFrameCallback((_) {
                //       searchFocusNode.requestFocus();
                //     });
                //   });
                // },
                onTap: ()async{
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LocationSearchScreen(
                        selectedCategory: suggestion['key']!,
                        isRentVehicle: false,
                      ),
                    ),
                  );
                },
                child:
                    _suggestionItem(suggestion['label']!, suggestion['asset']!),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchSection() {
    return Column(
      children: [
        _buildSearchBar(),
        Expanded(
          child: _buildSearchSuggestions(),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      height: 48,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        focusNode: searchFocusNode,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          hintText: localizations.search_for_location,
          hintStyle: TextStyle(color: ColorConstants.appBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorConstants.greyLight,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorConstants.primaryColor,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: ColorConstants.greyLight,
              width: 1.5,
            ),
          ),
          prefixIcon: Container(
            height: 45,
            margin: EdgeInsets.only(left: 0, right: 8),
            decoration: BoxDecoration(
                color: ColorConstants.primaryColorLight.withAlpha(100),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: ColorConstants.primaryColorLight)),
            padding: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            child: Container(
              padding: EdgeInsets.only(left: 10, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    selectedCategory,
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorConstants.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
          suffixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4),
            child: IconButton(
              padding: EdgeInsets.zero,
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  ColorConstants.primaryColorLight.withAlpha(30),
                ),
                shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                )),
              ),
              onPressed: () {
                if (selectedLocationData != null) {
                  _navigateToSelectedScreen();
                }
              },
              icon: Icon(
                selectedLocationData != null
                    ? Icons.arrow_forward
                    : CupertinoIcons.search,
                color: ColorConstants.primaryColor,
                size: 25,
              ),
            ),
          ),
          labelText: selectedLocationData?.formattedAddress,
          labelStyle: TextStyle(
            color: Colors.black87,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          if (isSearching)
            Container(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: CircularProgressIndicator(
                  color: ColorConstants.primaryColor,
                ),
              ),
            )
          else if (filteredLocations.isEmpty &&
              searchController.text.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.location_off, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      localizations.no_locations_found(searchController.text),
                      // "No locations found matching '${searchController.text}'",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredLocations.length,
                itemBuilder: (context, index) {
                  final suggestion = filteredLocations[index];
                  return GestureDetector(
                    onTap: () {
                      _selectLocation(suggestion);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            height: 40,
                            width: 40,
                            decoration: BoxDecoration(
                              color: suggestion.isRecentLocation
                                  ? ColorConstants.primaryColorLight
                                  : Colors.grey.shade700,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              suggestion.isRecentLocation
                                  ? Icons.history
                                  : Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  suggestion.mainText,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  suggestion.secondaryText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _suggestionItem(String label, String asset) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: Colors.transparent,
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            asset,
            height: 50,
            width: 50,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// List<Map<String, String>> getLocalizedSuggestions(BuildContext context) {
//   final localizations = AppLocalizations.of(context)!;
//   return [
//     {"label": localizations.car, "asset": AssetsConstant.car},
//     {"label": localizations.auto, "asset": AssetsConstant.tukTuk},
//     {"label": localizations.eRickshaw, "asset": AssetsConstant.auto},
//     {"label": localizations.suv, "asset": AssetsConstant.suv},
//     {"label": localizations.minivan, "asset": AssetsConstant.minivan},
//     {"label": localizations.bus, "asset": AssetsConstant.bus},
//     {"label": localizations.driver, "asset": AssetsConstant.driverBus},
//   ];
// }

List<Map<String, String>> getLocalizedSuggestions(BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  return [
    {"key": "car", "label": localizations.car, "asset": AssetsConstant.car},
    {"key": "auto", "label": localizations.auto, "asset": AssetsConstant.tukTuk},
    {"key": "eRickshaw", "label": localizations.eRickshaw, "asset": AssetsConstant.auto},
    {"key": "suv", "label": localizations.suv, "asset": AssetsConstant.suv},
    {"key": "miniVan", "label": localizations.minivan, "asset": AssetsConstant.minivan},
    {"key": "bus", "label": localizations.bus, "asset": AssetsConstant.bus},
    {"key": "driver", "label": localizations.driver, "asset": AssetsConstant.driverBus},
  ];
}

