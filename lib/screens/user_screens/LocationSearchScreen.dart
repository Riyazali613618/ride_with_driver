import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:r_w_r/api/api_model/VehicleType.dart';
import 'package:r_w_r/components/app_loader.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/constants/assets_constant.dart';
import 'package:r_w_r/l10n/app_localizations.dart';
import 'package:r_w_r/screens/user_screens/owner_details.dart';
import 'package:r_w_r/utils/color.dart';
import '../../api/api_model/location_model/location_model.dart';
import '../../api/api_service/location_service/location_service.dart';
import '../../constants/GoogleLocationSearchService.dart';
import '../../constants/color_constants.dart';
import 'more/filterScreen.dart';
import 'vehicles.dart';
import 'owners.dart';

class LocationSearchScreen extends StatefulWidget {
  final String selectedCategory;
  final bool isRentVehicle;
  final String? initialSearchText;

  const LocationSearchScreen({
    super.key,
    required this.selectedCategory,
    required this.isRentVehicle,
    this.initialSearchText,
  });

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final LocationSearchExample _locationSearchService = LocationSearchExample();
  final LocationService _locationService = LocationService();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _selectedCategory = '';
  final List<String> _availableCategories = [
    'ALL',
    'CAR',
    'RICKSHAW', // Changed from 'auto' to match homescreen
    'E_RICKSHAW', // Changed from 'erickshaw' to match homescreen
    'SUV',
    'MINIVAN', // Changed from 'miniVan' to match homescreen
    'BUS',
    'DRIVER' // Changed from 'driver' to match homescreen
  ];

  final List<VehicleType> vehicles = [
    VehicleType(
      name: 'Car',
      assetImagePath: AssetsConstant.car,
      color: const Color(0xFFEF9A9A),
      color1: const Color(0xFFFFEBEE),
    ),
    VehicleType(
      name: 'Auto',
      assetImagePath: AssetsConstant.tukTuk,
      color: const Color(0xFFFFE082),
      color1: const Color(0xFFFFF8E1),
    ),
    VehicleType(
      name: 'E-Rickshaw',
      assetImagePath: AssetsConstant.auto,
      color: const Color(0xFF9575CD),
      color1: const Color(0xFFEDE7F6),
    ),
    VehicleType(
      name: 'SUV',
      assetImagePath: AssetsConstant.suv,
      color: const Color(0xFFFFAB91),
      color1: const Color(0xFFFFEBE9),
    ),
    VehicleType(
      name: 'MiniVan',
      assetImagePath: AssetsConstant.minivan,
      color: const Color(0xFFF48FB1),
      color1: const Color(0xFFFCE4EC),
    ),
    VehicleType(
      name: 'Bus',
      assetImagePath: AssetsConstant.bus,
      color: const Color(0xFFA5D6A7),
      color1: const Color(0xFFE8F5E9),
    ),
    VehicleType(
      name: 'Driver',
      assetImagePath: AssetsConstant.driverBus,
      color: const Color(0xFF81D4FA),
      color1: const Color(0xFFE1F5FE),
    ),
  ];

  Timer? _searchDebounceTimer;
  List<GooglePlacesSuggestion> filteredLocations = [];
  List<LocationData> recentLocations = [];
  LocationData? currentLocation;
  GooglePlaceDetails? selectedLocationData;
  bool _isLoadingCurrentLocation = false;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.selectedCategory.toUpperCase();
    _searchController.text = widget.initialSearchText ?? '';
    // Load recent locations and current location first
    _loadRecentLocations().then((_) {
      _getCurrentLocation().then((_) {
        // Initialize suggestions after everything is loaded
        if (mounted) {
          _initializeSearchSuggestions();
        }
      });
    });
    // Auto-focus search bar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
      if (widget.initialSearchText?.isNotEmpty == true) {
        _searchLocationsWithService(widget.initialSearchText!);
      }
    });
  }

  @override
  void dispose() {
    _searchDebounceTimer?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _locationSearchService.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    print("🔍 Starting to get current location...");
    setState(() => _isLoadingCurrentLocation = true);
    try {
      final locationData =
          await GoogleLocationSearchService.getCurrentLocationWithDetails();
      print("🔍 Location data received: $locationData");

      if (locationData != null && mounted) {
        final coordinates = locationData['coordinates'] as LatLng;
        final locationName = locationData['name'] as String;

        print("🔍 Setting current location: $locationName");

        setState(() {
          currentLocationCoordinates = coordinates;
          currentLocation = LocationData(
            displayName: locationName,
            addressDetails: "Your current location",
            pincode: null,
          );
          _isLoadingCurrentLocation = false;
        });

        // Update suggestions after state is set
        if (mounted) {
          print("🔍 Updating suggestions with current location");
          _initializeSearchSuggestions();
        }
      }
    } catch (e) {
      print('🔍 Error getting location: $e');
      if (mounted) {
        setState(() => _isLoadingCurrentLocation = false);
      }
    }
  }

  Future<void> _loadRecentLocations() async {
    try {
      await _locationService.loadRecentLocations();
      if (mounted) {
        setState(() {
          recentLocations = _locationService.getRecentLocations();
        });
      }
    } catch (e) {
      print("Error loading recent locations: $e");
    }
  }

  bool searchedSelected = false;

  Future<void> _searchLocationsWithService(String query) async {
    print("_searchLocationsWithService:${query}");
    if (!_availableCategories.contains(query.toUpperCase())) {
      selectedLocationData = null;
    }
    if (query.isEmpty) {
      _initializeSearchSuggestions();
      return;
    }
    setState(() {
      _isSearching = true;
      searchedSelected = true;
    });
    if (selectedLocationData != null) {
      Future.delayed(Duration(seconds: 2)).then((_) {
        setState(() {
          _isSearching = false;
          searchedSelected = false;
        });
      });
    } else {
      _locationSearchService.searchLocations(query, (results) {
        if (mounted) {
          setState(() {
            filteredLocations = results;
            _isSearching = false;
          });
        }
      });
    }
    print("queryy:${query} ${filteredLocations}");
  }

  void _initializeSearchSuggestions() {
    List<GooglePlacesSuggestion> initialSuggestions = [];
    // Add current location first (only if available)
    if (currentLocation != null) {
      initialSuggestions.add(GooglePlacesSuggestion(
        placeId: 'current_location',
        mainText: currentLocation!.displayName,
        secondaryText: "Your current location",
        fullText: currentLocation!.displayName,
        isRecentLocation: false,
        isCurrentLocation: true,
      ));
    }
    // Add recent locations
    initialSuggestions.addAll(recentLocations.map((location) {
      return GooglePlacesSuggestion(
        placeId: '',
        mainText: location.displayName,
        secondaryText: location.addressDetails,
        fullText: location.displayName,
        isRecentLocation: true,
        isCurrentLocation: false,
      );
    }).toList());

    if (mounted) {
      setState(() => filteredLocations = initialSuggestions);
    }
  }

  LatLng? currentLocationCoordinates;

  void _selectLocation(GooglePlacesSuggestion suggestion) async {
    try {
      GooglePlaceDetails? details;
      if (suggestion.isCurrentLocation) {
        // Handle current location selection
        if (currentLocation != null) {
          // Create GooglePlaceDetails from current location data
          details = GooglePlaceDetails(
            placeId: 'current_location',
            name: currentLocation!.displayName,
            formattedAddress: currentLocation!.addressDetails,
            latitude: currentLocationCoordinates?.latitude ?? 0.0,
            longitude: currentLocationCoordinates?.longitude ?? 0.0,
            pinCode: currentLocation!.pincode ?? 'Not found',
            // city: currentLocation!.displayName.split(',').first,
            // state: currentLocation!.displayName.contains(',')
            //     ? currentLocation!.displayName.split(',').last.trim()
            //     : '',
          );
        }
      } else {
        // Handle other location selections
        details = await _locationSearchService.selectLocation(suggestion);
      }
      if (details != null && mounted) {
        selectedLocationData = details;
        // Add to recent locations if not current location
        if (!suggestion.isCurrentLocation) {
          final locationData = LocationData(
            displayName: suggestion.mainText,
            addressDetails: suggestion.secondaryText,
            pincode: details.pinCode != 'Not found' ? details.pinCode : null,
          );
          _locationService.addToRecentLocations(locationData);
        }
        _navigateBasedOnSelection();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting location: $e')),
      );
    }
  }

  void _navigateBasedOnSelection() {
    if (selectedLocationData == null) return;
    print("selectedLocationData:${selectedLocationData} ${_selectedCategory}");
    setState(() {
      searchedSelected = false;
    });
    // if (_selectedCategory.toUpperCase() == "DRIVER") {
    //   // Updated comparison
    //   // Navigator.pushReplacement(
    //   //   context,
    //   //   MaterialPageRoute(
    //        Owners(
    //         selectedLocation: selectedLocationData,
    //       );
    //     // ),
    //   // );
    // } else {
    //   // Navigator.pushReplacement(
    //   //   context,
    //   //   MaterialPageRoute(
    //        VehicleSearchScreen(
    //         selectedLocation: selectedLocationData,
    //         selectedCategory: _selectedCategory, // Already in correct format
    //       );
    //     // ),
    //   // );
    // }
  }

  Widget _buildSearchSuggestion(GooglePlacesSuggestion suggestion, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: suggestion.isCurrentLocation
                  ? ColorConstants.primaryColor.withOpacity(0.1)
                  : suggestion.isRecentLocation
                      ? Colors.orange.withOpacity(0.1)
                      : Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              suggestion.isCurrentLocation
                  ? Icons.my_location
                  : suggestion.isRecentLocation
                      ? Icons.history
                      : Icons.location_on,
              color: suggestion.isCurrentLocation
                  ? ColorConstants.primaryColor
                  : suggestion.isRecentLocation
                      ? Colors.orange
                      : Colors.black,
              size: 20,
            ),
          ),
          title: Text(
            suggestion.isCurrentLocation
                ? "Use current location"
                : suggestion.mainText,
            style: TextStyle(
              fontSize: 16,
              fontWeight: suggestion.isCurrentLocation
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: suggestion.isCurrentLocation
                  ? ColorConstants.primaryColor
                  : Colors.black87,
            ),
          ),
          subtitle: Text(
            suggestion.isCurrentLocation
                ? (currentLocation?.displayName ?? "Your current location")
                : (suggestion.secondaryText ?? ""),
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          trailing: suggestion.isRecentLocation
              ? Icon(Icons.north_west, color: Colors.grey.shade400, size: 16)
              : null,
          onTap: () {
            setState(() {});
            _selectLocation(suggestion);
          }),
    );
  }

  String _getCategoryDisplayNameByKey(String key) {
    final localizations = AppLocalizations.of(context)!;
    switch (key.toUpperCase()) {
      case 'ALL':
        return 'All';
      case 'CAR':
        return 'Car';
      case 'RICKSHAW': // Updated
        return 'Auto';
      case 'E_RICKSHAW': // Updated
        return 'E-Rickshaw';
      case 'SUV':
        return 'SUV';
      case 'MINIVAN': // Updated
        return 'Mini Van';
      case 'BUS':
        return 'Bus';
      case 'DRIVER': // Updated
        return localizations.hire_driver;
      default:
        return 'All Vehicles';
    }
  }

  String mapCategoryForApi(String category) {
    // Categories are already in the correct format for API
    return category.toUpperCase();
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 30,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableCategories.length,
        itemBuilder: (context, index) {
          String category = _availableCategories[index];
          if (_selectedCategory == "ALLVEHICLES") {
            _selectedCategory = 'ALL';
          }
          bool isSelected =
              _selectedCategory.toUpperCase() == category.toUpperCase();
          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  if (selectedLocationData != null) {
                    setState(() {
                      _selectedCategory = category;
                      searchedSelected = false;
                      if (_selectedCategory == 'ALL') {
                        category = 'ALLVEHICLES';
                      }
                    });
                    print("category:${category}");
                    _searchLocationsWithService(category);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please select location'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.blue
                          : Color(0x73FFFFFF),
                      width: 1.5,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      _getCategoryDisplayNameByKey(category),
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Map<String, dynamic> filters = {};

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      body: CommonParentContainer(
        showLargeGradient: false,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Row(
                  children: [
                    // Back Button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Search Field
                    Expanded(
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _searchController.text = "";
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: Icon(
                                  Icons.cancel_outlined,
                                  color: gradientSecond,
                                  size: 20,
                                ),
                              ),
                            ),
                            hintText: localizations.searchLocation,
                            hintStyle: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: gradientSecond,
                              size: 20,
                            ),
                            suffixIconConstraints: const BoxConstraints(
                                minWidth: 32, minHeight: 32),
                            border: InputBorder.none,
                          ),
                          onChanged: (value) {
                            _searchDebounceTimer?.cancel();
                            _searchDebounceTimer = Timer(
                              const Duration(milliseconds: 500),
                              () => _searchLocationsWithService(value),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Filter Button
                    GestureDetector(
                      onTap: () async {
                        final result =
                            await showModalBottomSheet<Map<String, dynamic>>(
                          context: context,
                          isScrollControlled: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.vertical(top: Radius.circular(25)),
                          ),
                          builder: (context) => FilterBottomSheet(),
                        );
                        if (result != null) {
                          setState(() {
                            searchedSelected = true;
                            filters = result;
                          });
                          _searchLocationsWithService(
                              result['vehicleType'].toString().toUpperCase());
                          Future.delayed(Duration(milliseconds: 500)).then((_) {
                            setState(() {
                              searchedSelected = false;
                              _selectedCategory = result['vehicleType']
                                  .toString()
                                  .toUpperCase();
                              ;
                            });
                          });
                          print('Applied Filters: $result');
                          // Use the filters in your API call or filtering logic
                        }
                        // Navigator.push(context, MaterialPageRoute<void>(
                        //   builder: (BuildContext context) => (),
                        // ),)
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Category Chips
              _buildCategoryChips(),
              const SizedBox(height: 12),
              // Results Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      if (selectedLocationData == null || searchedSelected) ...[
                        Expanded(
                          child: _isSearching || _isLoadingCurrentLocation
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const CircularProgressIndicator(),
                                      const SizedBox(height: 16),
                                      Text(
                                        _isLoadingCurrentLocation
                                            ? 'Getting your location...'
                                            : 'Searching...',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : filteredLocations.isEmpty &&
                                      _searchController.text.isNotEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.location_off,
                                            size: 64,
                                            color: Colors.grey.shade400,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            'No locations found',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          Text(
                                            'Try searching with different keywords',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey.shade500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.builder(
                                      padding: const EdgeInsets.only(
                                          top: 8, bottom: 16),
                                      itemCount: filteredLocations.length,
                                      itemBuilder: (context, index) {
                                        return _buildSearchSuggestion(
                                          filteredLocations[index],
                                          index,
                                        );
                                      },
                                    ),
                        ),
                      ] else ...[
                        Expanded(
                          child: (_selectedCategory.toUpperCase() != "DRIVER")
                              ? _buildVehicleSearchContent()
                              : Container(),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleSearchContent() {
    return VehicleSearchScreen(
      // Make this a widget, not a screen
      selectedLocation: selectedLocationData,
      selectedCategory:
          (_selectedCategory == 'ALL') ? 'ALLVEHICLES' : _selectedCategory,
      appliedFilters: filters,
    );
  }
// Widget _buildOwnerSearchContent(){
//   return Owners(selectedLocation: selectedLocationData,);
// }
}
