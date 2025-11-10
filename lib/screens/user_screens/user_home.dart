import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/assets_constant.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/screens/user_screens/owners.dart';
import 'package:r_w_r/screens/user_screens/vehicles.dart';

import '../../api/api_model/location_model/location_model.dart';
import '../../api/api_service/location_service/location_service.dart';
import '../../l10n/app_localizations.dart';
import '../driver_screens/plans.dart';
import '../driver_screens/widgets/home_banner_widget.dart';
import '../independentCarOwnerRegistration.dart';
import '../notification/notification.dart';
import '../registration_screens/indipendent_car_owner_registration_screen.dart';

class TransportApp extends StatefulWidget {
  final bool showDriverSubscription;

  const TransportApp({super.key, required this.showDriverSubscription});

  @override
  State<TransportApp> createState() => _TransportAppState();
}

class _TransportAppState extends State<TransportApp>
    with WidgetsBindingObserver {
  String selectedDriverOption = "Car";
  int selectedTabIndex = 0;
  bool showSearchSuggestions = false;
  bool showCategoryDropdown = false;
  TextEditingController searchController = TextEditingController();
  FocusNode searchFocusNode = FocusNode();

  List<GooglePlacesSuggestion> filteredLocations = [];
  GooglePlaceDetails? selectedLocationData;
  LocationData? currentLocation;
  bool isSearching = false;

  final String _apiKey = 'AIzaSyDUkuN7zD7ApTqkkEyzOXnS_LDxEzP-t40';

  final LocationService _locationService = LocationService();

  List<LocationData> recentLocations = [];

  String selectedCategory = 'allVehicles';

  final List<String> searchCategoryKeys = [
    'allVehicles',
    'car',
    'suv',
    'auto',
    'minivan',
    'bus',
    'eRickshaw',
    'driver',
  ];

// Step 2: Helper function to get localized label
  String getLocalizedCategory(String key, AppLocalizations loc) {
    switch (key) {
      case 'allVehicles':
        return loc.allVehicles;
      case 'car':
        return loc.car;
      case 'suv':
        return loc.suv;
      case 'auto':
        return loc.auto;
      case 'minivan':
        return loc.minivan;
      case 'bus':
        return loc.bus;
      case 'eRickshaw':
        return loc.eRickshaw;
      case 'driver':
        return loc.driver;
      default:
        return key;
    }
  }

  bool isPressed = false;

  bool _currentSubscriptionVisibility = false;

  @override
  void initState() {
    super.initState();
    searchFocusNode.addListener(() {
      setState(() {}); // Triggers rebuild when focus changes
    });
    print("=== TransportApp Initialized ===");
    WidgetsBinding.instance.addObserver(this);
    _currentSubscriptionVisibility = widget.showDriverSubscription;
    _loadRecentLocations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
    searchFocusNode.addListener(() {
      if (searchFocusNode.hasFocus) {
        print("Search focus gained - showing suggestions");
        setState(() {
          showSearchSuggestions = true;
          showCategoryDropdown = false;
        });
      }
    });

    searchController.addListener(() {
      _searchLocationsWithGooglePlaces(searchController.text);
    });
  }

  @override
  void didUpdateWidget(TransportApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showDriverSubscription != widget.showDriverSubscription) {
      setState(() {
        _currentSubscriptionVisibility = widget.showDriverSubscription;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {
        _currentSubscriptionVisibility = widget.showDriverSubscription;
      });
    }
  }

  Future<void> _loadRecentLocations() async {
    try {
      print("Loading recent locations...");
      await _locationService.loadRecentLocations();
      setState(() {
        recentLocations = _locationService.getRecentLocations();
      });
      print("Recent locations loaded: ${recentLocations.length} items");
    } catch (e) {
      print("Error loading recent locations: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    try {
      print("=== Getting Current Location ===");

      // Try the main method first
      LocationData? location;
      try {
        location = await _locationService.getCurrentLocation();
      } catch (e) {
        print("Main location method failed: $e");
        // Try the simple fallback method
        try {
          location = await _locationService.getCurrentLocationSimple();
        } catch (e2) {
          print("Simple location method also failed: $e2");
          throw Exception("Could not get location: $e2");
        }
      }

      if (mounted) {
        setState(() {
          currentLocation = location;
        });
        print("Current location set: ${location.displayName}");
      }
    } catch (e) {
      print("Error getting current location: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not access location: $e'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _initializeSearchSuggestions() {
    List<GooglePlacesSuggestion> initialSuggestions = [];

    if (currentLocation != null) {
      initialSuggestions.add(GooglePlacesSuggestion(
        placeId: 'current_location',
        mainText: currentLocation!.displayName,
        secondaryText: "You're currently here",
        fullText: currentLocation!.displayName,
        isRecentLocation: false,
        isCurrentLocation: true,
      ));
    }

    initialSuggestions.addAll(_convertRecentLocationsToGooglePlaces());
    setState(() => filteredLocations = initialSuggestions);
  }

  Future<void> _searchLocationsWithGooglePlaces(String query) async {
    print("=== Starting Google Places search ===");
    print("Query: '$query'");

    // Always try to get current location if we don't have it
    if (currentLocation == null) {
      print("No current location available, trying to get it...");
      await _getCurrentLocation();
    }

    if (query.isEmpty) {
      print(
          "Query is empty - showing current location first, then recent locations");
      setState(() {
        List<GooglePlacesSuggestion> suggestions = [];

        // ALWAYS add current location first if available
        if (currentLocation != null) {
          suggestions.add(GooglePlacesSuggestion(
            placeId: 'current_location',
            mainText: currentLocation!.displayName,
            secondaryText: currentLocation!.addressDetails,
            fullText: currentLocation!.displayName,
            isRecentLocation: false,
            isCurrentLocation: true,
          ));
        }

        // Then add recent locations
        suggestions.addAll(_convertRecentLocationsToGooglePlaces());

        filteredLocations = suggestions;
        isSearching = false;
      });
      return;
    }

    setState(() {
      isSearching = true;
    });

    try {
      final suggestions = await _fetchGooglePlacesSuggestions(query);
      print("API call successful - received ${suggestions.length} suggestions");

      if (mounted) {
        setState(() {
          List<GooglePlacesSuggestion> finalSuggestions = [];

          // ALWAYS add current location first if available
          if (currentLocation != null) {
            finalSuggestions.add(GooglePlacesSuggestion(
              placeId: 'current_location',
              mainText: currentLocation!.displayName,
              secondaryText: currentLocation!.addressDetails,
              fullText: currentLocation!.displayName,
              isRecentLocation: false,
              isCurrentLocation: true,
            ));
          }

          // Add other suggestions after current location
          finalSuggestions.addAll(suggestions);

          filteredLocations = finalSuggestions;
          isSearching = false;
        });
      }
    } catch (e) {
      print("Error searching locations: $e");
      if (mounted) {
        setState(() {
          // Even on error, show current location if available
          List<GooglePlacesSuggestion> errorSuggestions = [];
          if (currentLocation != null) {
            errorSuggestions.add(GooglePlacesSuggestion(
              placeId: 'current_location',
              mainText: currentLocation!.displayName,
              secondaryText: currentLocation!.addressDetails,
              fullText: currentLocation!.displayName,
              isRecentLocation: false,
              isCurrentLocation: true,
            ));
          }
          filteredLocations = errorSuggestions;
          isSearching = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Search error: $e')),
        );
      }
    }
  }

// 3. Update the _selectLocation method to handle current location properly
  void _selectLocation(GooglePlacesSuggestion suggestion) async {
    print("=== Location Selected ===");
    print("Selected: ${suggestion.mainText}");

    setState(() {
      searchController.text = suggestion.fullText;
      showSearchSuggestions = false;
      searchFocusNode.unfocus();
    });

    if (suggestion.placeId == 'current_location' && currentLocation != null) {
      print("Selected current location");
      setState(() {
        selectedLocationData = GooglePlaceDetails(
          placeId: 'current_location',
          formattedAddress: currentLocation!.displayName,
          latitude: 0.0,
          // You might want to store these in LocationData
          longitude: 0.0,
          pinCode: currentLocation!.pincode ?? 'Not available',
        );
      });
      return;
    }

    if (suggestion.isRecentLocation) {
      print("Selected from recent locations");
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
      print("Fetching detailed information for place...");
      final placeDetails = await _getGooglePlaceDetails(suggestion.placeId);

      setState(() {
        selectedLocationData = placeDetails;
      });

      // Convert to LocationData format for recent locations compatibility
      final locationData = LocationData(
        displayName: suggestion.mainText,
        addressDetails: suggestion.secondaryText,
        pincode:
            placeDetails.pinCode != 'Not found' ? placeDetails.pinCode : null,
      );

      // Add to recent locations
      _locationService.addToRecentLocations(locationData);
      _loadRecentLocations();

      print("Location selection completed successfully");
    } catch (e) {
      print("Error getting place details: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location details: $e')),
        );
      }
    }
  }

  Future<List<GooglePlacesSuggestion>> _fetchGooglePlacesSuggestions(
      String input) async {
    print("Fetching Google Places suggestions for: '$input'");

    final url =
        Uri.parse('https://places.googleapis.com/v1/places:autocomplete');

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': '*',
    };

    final body = jsonEncode({
      "input": input,
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
      // "locationBias": {
      //   "circle": {
      //     "center": {
      //       "latitude": 20.5937, // Center of India
      //       "longitude": 78.9629
      //     },
      //     "radius": 2000.0 // Radius in kilometers (covers all of India)
      //   }
      // },
      // Or restrict to India by country code:
      // "includedRegionCodes": ["IN"],
    });

    print("Making API request to Google Places...");

    final response = await http.post(url, headers: headers, body: body);

    print("API Response Status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final suggestions = data['suggestions'] as List<dynamic>? ?? [];

      print("Successfully parsed ${suggestions.length} suggestions");

      return suggestions.map((item) {
        final prediction = item['placePrediction'];
        final structuredFormat = prediction['structuredFormat'];

        final mainText = structuredFormat?['mainText']?['text'] ?? '';
        final secondaryText = structuredFormat?['secondaryText']?['text'] ?? '';
        String fullText = '';
        if (prediction?['text'] != null) {
          // Sometimes 'text' could be a string or a map with 'text'
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
      print('Google Places API Error ${response.statusCode}: ${response.body}');
      throw Exception('Failed to fetch suggestions: ${response.statusCode}');
    }
  }

  Future<GooglePlaceDetails> _getGooglePlaceDetails(String placeId) async {
    print("=== Fetching place details ===");
    print("Place ID: $placeId");

    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');

    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': 'location,addressComponents,formattedAddress,types',
    };

    final response = await http.get(url, headers: headers);

    print("Place details API Response Status: ${response.statusCode}");

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
            print("Pin code found: $pinCode");
            break;
          }
        }
      }

      final formattedAddress =
          data['formattedAddress'] ?? 'Address not available';

      print('=== Place Details Retrieved ===');
      print('Formatted Address: $formattedAddress');
      print('Latitude: $latitude');
      print('Longitude: $longitude');
      print('Pin Code: $pinCode');
      print('Country: $country');
      print('=============================');

      return GooglePlaceDetails(
        placeId: placeId,
        formattedAddress: formattedAddress,
        latitude: latitude,
        longitude: longitude,
        pinCode: pinCode,
      );
    } else {
      print(
          'Error fetching place details ${response.statusCode}: ${response.body}');
      throw Exception('Failed to fetch place details: ${response.statusCode}');
    }
  }

  List<GooglePlacesSuggestion> _convertRecentLocationsToGooglePlaces() {
    print("Converting recent locations to Google Places format");
    return recentLocations.map((location) {
      return GooglePlacesSuggestion(
        placeId: '',
        // Recent locations don't have place IDs
        mainText: location.displayName,
        secondaryText: location.addressDetails,
        fullText: location.displayName,
        isRecentLocation: true,
        isCurrentLocation: true,
      );
    }).toList();
  }

  // Handle category selection
  void handleCategorySelection(String category) {
    print("Category selected: $category");
    setState(() {
      selectedCategory = category;
      showCategoryDropdown = false;
      showSearchSuggestions = true;
      searchFocusNode.requestFocus();
    });
  }

  // Toggle category dropdown
  void toggleCategoryDropdown() {
    print("Toggling category dropdown");
    setState(() {
      showCategoryDropdown = !showCategoryDropdown;
      if (showCategoryDropdown) {
        showSearchSuggestions = false;
        searchFocusNode.unfocus();
      }
    });
  }

  void _selectLocations(GooglePlacesSuggestion suggestion) async {
    print("=== Location Selected ===");
    print("Selected: ${suggestion.mainText}");

    setState(() {
      searchController.text = suggestion.fullText;
      showSearchSuggestions = false;
      searchFocusNode.unfocus();
    });

    if (suggestion.placeId == 'current_location' && currentLocation != null) {
      print("Selected current location");
      setState(() {
        selectedLocationData = GooglePlaceDetails(
          placeId: 'current_location',
          formattedAddress: currentLocation!.displayName,
          // Fix: Use default values or get coordinates from location service
          latitude: 0.0,
          // Or get from your location service
          longitude: 0.0,
          // Or get from your location service
          pinCode: currentLocation!.pincode ?? 'Not available',
        );
      });
      return;
    }

    if (suggestion.isRecentLocation) {
      print("Selected from recent locations");
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
      print("Fetching detailed information for place...");
      final placeDetails = await _getGooglePlaceDetails(suggestion.placeId);

      setState(() {
        selectedLocationData = placeDetails;
      });

      // Convert to LocationData format for recent locations compatibility
      final locationData = LocationData(
        displayName: suggestion.mainText,
        addressDetails: suggestion.secondaryText,
        pincode:
            placeDetails.pinCode != 'Not found' ? placeDetails.pinCode : null,
        // Add coordinates if LocationData supports them
        // latitude: placeDetails.latitude,
        // longitude: placeDetails.longitude,
      );

      // Add to recent locations
      _locationService.addToRecentLocations(locationData);
      _loadRecentLocations();

      print("Location selection completed successfully");
    } catch (e) {
      print("Error getting place details: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location details: $e')),
      );
    }
  }

  void navigateBasedOnSelection() {
    print("=== Navigation Request ===");
    print("Selected category: $selectedCategory");
    print("Selected location: ${selectedLocationData?.formattedAddress}");

    if (selectedLocationData == null) {
      print("No location selected - showing error");
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a location first')));
      return;
    }

    print("Navigating based on category: $selectedCategory");
    if (selectedCategory == "driver") {
      print("Navigating to Owners");

      // Navigator.push(
      //     context,
      //     MaterialPageRoute(
      //         builder: (context) => Owners(
      //               selectedLocation: selectedLocationData,
      //             )));
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VehicleSearchScreen(
                    selectedLocation: selectedLocationData,
                    selectedCategory: selectedCategory,
                  )));
    }
  }

  @override
  void dispose() {
    print("TransportApp disposing...");
    searchController.dispose();
    searchFocusNode.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  DateTime? lastPressed;

  @override
  Widget build(BuildContext context) {
    _currentSubscriptionVisibility = widget.showDriverSubscription;
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: ColorConstants.primaryColor,
      appBar: AppBar(
        backgroundColor: ColorConstants.primaryColor,
        automaticallyImplyLeading: false,
        leadingWidth: 10,
        toolbarHeight: 120,
        centerTitle: false,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Text(
            //   localizations.welcome,
            //   textAlign: TextAlign.start,
            //   maxLines: 2,
            //   style: TextStyle(
            //     fontSize: 25,
            //     color: ColorConstants.white,
            //     fontWeight: FontWeight.w900,
            //   ),
            // ),
            // SizedBox(
            //   height: 10,
            // ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: "${localizations.directContact}\n",
                    // "Direct Contact.\n",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      height: 1.2,
                      color: ColorConstants.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: "${localizations.noCommission}\n",
                    // "No Commission.\n",
                    style: GoogleFonts.poppins(
                      fontSize: 28,
                      height: 1.2,
                      color: ColorConstants.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: localizations.poweredByBuntyBhai,
                    // "Powered by Bunty Bhai",
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      height: 1.8,
                      color: ColorConstants.white,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.start,
              maxLines: 5,
            )
          ],
        ),
        titleTextStyle: TextStyle(
            fontSize: 25,
            color: ColorConstants.white,
            fontWeight: FontWeight.w900),
        leading: Icon(
          Icons.circle_rounded,
          color: ColorConstants.primaryColor,
        ),
        actions: [
          CircleAvatar(
            backgroundColor: ColorConstants.white,
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              // LocalizationTestScreen()
                              // BecomeErickshawScreen()
                              NotificationListScreen()
                          //
                          ));
                },
                icon: Icon(
                  Icons.notifications_none,
                  color: ColorConstants.primaryColor,
                )),
          ),
          SizedBox(
            width: 10,
          ),
          CircleAvatar(
            backgroundColor: ColorConstants.white,
            child: IconButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              // LocalizationTestScreen()
                              // BecomeErickshawScreen()
                          IndependentTaxiOwnerFlow()
                          //
                          ));
                },
                icon: Icon(
                  Icons.near_me,
                  color: ColorConstants.primaryColor,
                )),
          ),
          SizedBox(
            width: 10,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: Container(
          decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(60),
                  blurRadius: 8,
                  spreadRadius: 8,
                  offset: const Offset(2, 0),
                ),
              ],
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(35), topLeft: Radius.circular(35))),
          child: Stack(
            children: [
              SafeArea(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      showCategoryDropdown = false;
                      showSearchSuggestions = false;
                      searchFocusNode.unfocus();
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18.0),
                    child: ListView(
                      physics: (showSearchSuggestions || showCategoryDropdown)
                          ? NeverScrollableScrollPhysics()
                          : AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        _buildSearchBar(),
                        if (!showSearchSuggestions &&
                            !showCategoryDropdown) ...[
                          // _buildDriverSubscription(),
                          _buildSuggestions(),
                          SizedBox(
                            height: 15,
                          ),
                          buildHowItWorksRow(context),
                          BannerListScreenWithProvider(
                            showFirstItem: _currentSubscriptionVisibility,
                            onFirstItemTap: () => showOptionsDialog(context),
                          )
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              if (showSearchSuggestions) _buildSearchSuggestions(),
              if (showCategoryDropdown) _buildCategoryDropdown(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
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
          hintText: localizations.searchLocation,
          // hintText: currentLocation?.displayName ?? "Search location...",
          hintStyle: TextStyle(color: ColorConstants.appBlue),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: ColorConstants.greyLight,
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: ColorConstants.primaryColor,
              width: 2.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: ColorConstants.greyLight,
              width: 1.5,
            ),
          ),
          prefixIcon: GestureDetector(
            onTap: toggleCategoryDropdown,
            child: Container(
              height: 55,
              margin: EdgeInsets.only(left: 0, right: 8),
              decoration: BoxDecoration(
                  color: ColorConstants.primaryColorLight.withAlpha(100),
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(color: ColorConstants.primaryColorLight)),
              padding: EdgeInsets.symmetric(
                horizontal: 1,
                vertical: 1,
              ),
              child: GestureDetector(
                onTap: toggleCategoryDropdown,
                child: Container(
                  padding: EdgeInsets.only(left: 5),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        getLocalizedCategory(selectedCategory, localizations),
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorConstants.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        showCategoryDropdown
                            ? Icons.arrow_drop_up
                            : Icons.arrow_drop_down,
                        color: ColorConstants.primaryColor,
                        size: 22,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),

          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (searchFocusNode.hasFocus)
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Colors.grey.withAlpha(30),
                      ),
                      shape: WidgetStatePropertyAll(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      )),
                    ),
                    onPressed: () {
                      searchController.clear();
                      setState(() {
                        selectedLocationData = null;
                        showSearchSuggestions = false;
                        filteredLocations = [];
                      });
                      // Optionally unfocus the text field
                      searchFocusNode.unfocus();
                    },
                    icon: Icon(
                      Icons.cancel_outlined,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                  ),
                IconButton(
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
                      // If location is selected, navigate
                      navigateBasedOnSelection();
                    } else {
                      // Otherwise show search suggestions
                      setState(() {
                        showSearchSuggestions = true;
                        showCategoryDropdown = false; // Close category dropdown
                        searchFocusNode.requestFocus();
                      });
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
              ],
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
        onTap: () async {
          setState(() {
            showSearchSuggestions = true;
            showCategoryDropdown = false;
            filteredLocations = _convertRecentLocationsToGooglePlaces();
          });
          await _getCurrentLocation();
          _initializeSearchSuggestions();
        },
        onChanged: (value) {
          _searchLocationsWithGooglePlaces(value);
          // Trigger rebuild to show/hide cancel icon
          setState(() {});
        },
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    final loc = AppLocalizations.of(context)!;

    return Positioned(
      top: 110, // Position below search bar
      left: 16,
      right: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(75),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: searchCategoryKeys.map((key) {
            final localizedLabel = getLocalizedCategory(key, loc);
            final isSelected = selectedCategory == key;

            return InkWell(
              onTap: () => handleCategorySelection(key),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? ColorConstants.primaryColor.withAlpha(25)
                      : Colors.white,
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      localizedLabel,
                      style: TextStyle(
                        color: isSelected
                            ? ColorConstants.primaryColor
                            : Colors.black87,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check,
                        color: ColorConstants.primaryColor,
                        size: 18,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchSuggestions() {
    final localizations = AppLocalizations.of(context)!;

    return Positioned(
      top: 110,
      left: 0,
      right: 0,
      bottom: 0,
      child: GestureDetector(
        onTap: () {
          setState(() {
            showSearchSuggestions = false;
            searchFocusNode.unfocus();
          });
        },
        child: Container(
          color: Colors.white,
          child: Column(
            mainAxisSize: MainAxisSize.max,
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
                          localizations
                              .no_locations_found(searchController.text),

                          // "No locations found matching '${searchController.text}'",
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[700]),
                        ),
                        // Still show current location even when no results found
                        if (currentLocation != null) ...[
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              _selectLocation(GooglePlacesSuggestion(
                                placeId: 'current_location',
                                mainText: currentLocation!.displayName,
                                secondaryText: currentLocation!.addressDetails,
                                fullText: currentLocation!.displayName,
                                isRecentLocation: false,
                                isCurrentLocation: true,
                              ));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.my_location,
                                      color: Colors.blue.shade600),
                                  SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          localizations.use_current_location,
                                          // "Use Current Location",
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                        Text(
                                          currentLocation!.displayName,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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

                      // Check if this is the current location (should always be first)
                      bool isCurrentLocation =
                          suggestion.placeId == 'current_location';

                      return ListTile(
                        leading: Icon(
                          isCurrentLocation
                              ? Icons.my_location
                              : Icons.location_on,
                          color: isCurrentLocation ? Colors.blue : Colors.grey,
                        ),
                        title: Text(
                          suggestion.mainText,
                          // This will show "New Ashok Nagar, Delhi"
                          style: TextStyle(
                            fontWeight: isCurrentLocation
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        subtitle: isCurrentLocation
                            ? Text(localizations.youAreCurrentlyHere
                                // "You're currently here"
                                )
                            : Text(suggestion.secondaryText),
                        onTap: () => _selectLocation(suggestion),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildHowItWorksRow(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    List<Map<String, dynamic>> items = [
      {
        'icon': Icons.search,
        'text': localizations.stepSearch,
      },
      {
        'icon': Icons.phone_in_talk,
        'text': localizations.stepContact,
      },
      {
        'icon': CupertinoIcons.car_detailed,
        'text': localizations.stepEnjoy,
      },
    ];

    double iconSize = MediaQuery.of(context).size.width * 0.1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Text(
              localizations.howItWorks,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: items.map((item) {
              return Icon(
                item['icon'],
                size: iconSize,
                color: Colors.deepPurple,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.map((item) {
              return SizedBox(
                width: MediaQuery.of(context).size.width *
                    0.28, // responsive width
                child: Text(
                  item['text'],
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    // Implementation unchanged
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, bottom: 10),
          child: Text(
            localizations.suggestions,
            // "Suggestions",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: [
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = "driver";
                      showSearchSuggestions = true;
                      searchFocusNode.requestFocus();
                    });
                  },
                  child: _suggestionItem(
                      getLocalizedCategory('driver', localizations),
                      AssetsConstant.driverBus)),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = "Car";
                    showSearchSuggestions = true;
                    searchFocusNode.requestFocus();
                  });
                },
                child: _suggestionItem(localizations.car, AssetsConstant.car),
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = "Auto";
                    showSearchSuggestions = true;
                    searchFocusNode.requestFocus();
                  });
                },
                child:
                    _suggestionItem(localizations.auto, AssetsConstant.tukTuk),
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = "E_RICKSHAW";
                    showSearchSuggestions = true;
                    searchFocusNode.requestFocus();
                  });
                },
                child: _suggestionItem(
                    localizations.eRickshaw, AssetsConstant.auto,
                    imagePadding: EdgeInsets.all(10)),
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = "SUV";
                    showSearchSuggestions = true;
                    searchFocusNode.requestFocus();
                  });
                },
                child: _suggestionItem(localizations.suv, AssetsConstant.suv,
                    imagePadding: EdgeInsets.all(7)),
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = "MiniVan";
                    showSearchSuggestions = true;
                    searchFocusNode.requestFocus();
                  });
                },
                child: _suggestionItem(
                    localizations.minivan, AssetsConstant.minivan,
                    imagePadding: EdgeInsets.all(7)),
              ),
              SizedBox(
                width: 8,
              ),
              GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = "Bus";
                      showSearchSuggestions = true;
                      searchFocusNode.requestFocus();
                    });
                  },
                  child:
                      _suggestionItem(localizations.bus, AssetsConstant.bus)),
              SizedBox(
                width: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _suggestionItem(String label, String imagePath,
      {EdgeInsets? imagePadding}) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Padding(
              padding: imagePadding ?? EdgeInsets.zero,
              child: Image.asset(imagePath),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  final List<Map<String, String>> options = [
    {'titleKey': 'standAloneDriver', 'icon': '🚖', 'key': "DRIVER"},
    {'titleKey': 'autoRickshaw', 'icon': '🛺', 'key': "RICKSHAW"},
    {'titleKey': 'eRickshaw', 'icon': 'ER', 'key': "E_RICKSHAW"},
    {'titleKey': 'transporter', 'icon': '🚙', 'key': "TRANSPORTER"},
    {
      'titleKey': 'Independent Car Owner ',
      'icon': '🤳',
      'key': "INDIPENDENTCAROWNER"
    },
  ];

  void showOptionsDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withAlpha(150),
      builder: (BuildContext context) {
        final screenSize = MediaQuery.of(context).size;
        final isSmallScreen = screenSize.height < 600 || screenSize.width < 360;

        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
          ),
          elevation: 20,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(isSmallScreen ? 8 : 16),
          // Reduced padding for small screens
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: screenSize.width * (isSmallScreen ? 0.95 : 0.9),
              maxHeight: screenSize.height *
                  (isSmallScreen
                      ? 0.85
                      : 0.7), // Increased max height for small screens
              minHeight: 200, // Minimum height to prevent too small dialogs
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(isSmallScreen ? 16 : 24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: isSmallScreen ? 20 : 30,
                    spreadRadius: 0,
                    offset: Offset(0, isSmallScreen ? 8 : 15),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header Section - Reduced padding for small screens
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      isSmallScreen ? 16 : 24,
                      isSmallScreen ? 16 : 24,
                      isSmallScreen ? 16 : 24,
                      isSmallScreen ? 12 : 16,
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 12 : 20),
                        Text(
                          localizations.choose_vehicle_type,
                          // 'Choose Your Vehicle Type',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: isSmallScreen ? 4 : 8),
                        Text(
                          localizations.select_vehicle_option,
                          // 'Select the option that best describes your vehicle',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 12 : 14,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  // Options Grid - Made scrollable and responsive
                  Flexible(
                    child: SingleChildScrollView(
                      // Added scrolling capability
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 12 : 20,
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: isSmallScreen
                                ? 1
                                : 2, // Single column for very small screens
                            crossAxisSpacing: isSmallScreen ? 8 : 12,
                            mainAxisSpacing: isSmallScreen ? 8 : 12,
                            childAspectRatio: isSmallScreen
                                ? 4.0
                                : 1.1, // Wider aspect ratio for small screens
                          ),
                          itemCount: options.length,
                          itemBuilder: (BuildContext context, int index) {
                            return AnimatedContainer(
                              duration:
                                  Duration(milliseconds: 200 + (index * 100)),
                              curve: Curves.easeOutBack,
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    Navigator.pop(context);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlanSelectionScreen(
                                          planType:'REGISTRATION', planFor: options[index]['key']!, countryId: '68badafaa31eb4f4fe5f6195', stateId:'68badafaa31eb4f4fe5f61a5',
                                        ),
                                      ),
                                    );
                                  },
                                  borderRadius: BorderRadius.circular(
                                      isSmallScreen ? 12 : 20),
                                  splashColor: Colors.blue.withAlpha(25),
                                  highlightColor: Colors.blue.withAlpha(10),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Colors.white,
                                          Colors.grey.shade50,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(
                                          isSmallScreen ? 12 : 20),
                                      border: Border.all(
                                        color: Colors.grey.shade200,
                                        width: 1.5,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withAlpha(200),
                                          blurRadius: isSmallScreen ? 8 : 12,
                                          spreadRadius: 0,
                                          offset:
                                              Offset(0, isSmallScreen ? 2 : 4),
                                        ),
                                      ],
                                    ),
                                    child: isSmallScreen
                                        ? // Horizontal layout for small screens
                                        Padding(
                                            padding: const EdgeInsets.all(12),
                                            child: Row(
                                              children: [
                                                Container(
                                                  width: 48,
                                                  height: 48,
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                      colors: [
                                                        Colors.blue.shade50,
                                                        Colors.indigo.shade50,
                                                      ],
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color:
                                                          Colors.blue.shade100,
                                                      width: 1,
                                                    ),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      options[index]['icon']!,
                                                      style: const TextStyle(
                                                          fontSize: 24),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 16),
                                                Expanded(
                                                  child: Text(
                                                    localizations.getString(
                                                        options[index]
                                                                ['titleKey']
                                                            as String),
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontSize: 14,
                                                      color:
                                                          Colors.grey.shade800,
                                                      letterSpacing: 0.2,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : // Vertical layout for normal screens
                                        Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  gradient: LinearGradient(
                                                    begin: Alignment.topLeft,
                                                    end: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.blue.shade50,
                                                      Colors.indigo.shade50,
                                                    ],
                                                  ),
                                                  borderRadius:
                                                      BorderRadius.circular(18),
                                                  border: Border.all(
                                                    color: Colors.blue.shade100,
                                                    width: 1,
                                                  ),
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    options[index]['icon']!,
                                                    style: const TextStyle(
                                                        fontSize: 28),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 12),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 8),
                                                child: Text(
                                                  localizations.getString(
                                                      options[index]['titleKey']
                                                          as String),
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 13,
                                                    color: Colors.grey.shade800,
                                                    letterSpacing: 0.2,
                                                    height: 1.3,
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  // Bottom Section - Reduced padding for small screens
                  Padding(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                              horizontal: isSmallScreen ? 16 : 24,
                              vertical: isSmallScreen ? 8 : 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(isSmallScreen ? 8 : 12),
                            ),
                          ),
                          child: Text(
                            localizations.cancel,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w600,
                              fontSize: isSmallScreen ? 14 : 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

extension LocalizationHelper on AppLocalizations {
  String getString(String key) {
    switch (key) {
      case 'standAloneDriver':
        return standAloneDriver;
      case 'autoRickshaw':
        return autoRickshaw;
      case 'eRickshaw':
        return eRickshaw;
      case 'transporter':
        return transporter;
      default:
        return key;
    }
  }
}
