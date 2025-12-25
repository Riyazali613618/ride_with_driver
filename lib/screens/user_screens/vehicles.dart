import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/api/api_model/vehicle/search_vehicles.dart';
import 'package:r_w_r/components/app_loader.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/main.dart';
import 'package:r_w_r/screens/user_screens/vehicle_details_transporter.dart';

import '../../api/api_model/location_model/location_model.dart';
import '../../api/api_service/filter_service.dart';
import '../../api/api_service/location_service/location_service.dart';
import '../../api/api_service/vehicle/search_vehicle_service.dart';
import '../../components/custom_activity.dart';
import '../../constants/api_constants.dart';
import '../../constants/assets_constant.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';
import 'filter_one.dart';
import '../../api/api_model/favouriteModel.dart' as fm;

class VehicleSearchScreen extends StatefulWidget {
  final String selectedCategory;
  final GooglePlaceDetails? selectedLocation;
  final Map<String, dynamic>? appliedFilters;

  const VehicleSearchScreen({
    Key? key,
    required this.selectedCategory,
    this.selectedLocation,
    this.appliedFilters,
  }) : super(key: key);

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final VehicleService _vehicleService = VehicleService();
  final LocationService _locationService = LocationService();
  List<fm.Data> favouritesData = [];

  List<VehicleOwner> _vehicles = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedVehicleType = ' ';
  bool _showLocationSearch = false;
  bool _isSearchingLocation = false;
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  bool _hasMoreItems = true;
  bool _isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic> _activeFilters = {};
  final FilterService _filterService = FilterService();
  final Map<String, int> _currentVehicleIndex = {};
  bool _hasInitialized = false;
  String? filterType;

  // Location search variables
  List<GooglePlacesSuggestion> _locationSuggestions = [];
  List<LocationData> _recentLocations = [];
  LocationData? _currentLocation;
  final String _apiKey = 'AIzaSyDUkuN7zD7ApTqkkEyzOXnS_LDxEzP-t40';

  String? get currentFilterType {
    return switch (widget.selectedCategory) {
      'ALLVEHICLES' || 'BUS' => 'ALL_VEHICLES',
      'RICKSHAW' => 'RICKSHAW',
      'E_RICKSHAW' => 'E_RICKSHAW',
      'SUV' || 'car' => 'INDEPENDENT_CAR_OWNER',
      'DRIVER' => 'DRIVER',
      _ => null,
    };
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasInitialized) {
      _hasInitialized = true;
      _selectedVehicleType = widget.selectedCategory;
      _searchController.text = widget.selectedLocation?.formattedAddress ?? '';
      _loadRecentLocations();
      _searchVehicles();
      _getCurrentLocation();
    }
  }

  @override
  void initState() {
    super.initState();
    _activeFilters = widget.appliedFilters!;
    _scrollController.addListener(_scrollListener);
    _searchFocusNode.addListener(_handleSearchFocusChange);
    getFavourites();
  }

  Future<void> getFavourites() async {
    favouritesData = await _vehicleService.getFavourites();
  }

  String getLocalizedCategory(String key, AppLocalizations loc) {
    switch (key) {
      case 'allVehicles':
      case 'All Vehicle':
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

  void _handleSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      setState(() {
        _showLocationSearch = true;
        _initializeSearchSuggestions();
      });
    }
  }

  Future<void> _loadRecentLocations() async {
    try {
      await _locationService.loadRecentLocations();
      setState(() {
        _recentLocations = _locationService.getRecentLocations();
      });
    } catch (e) {
      print("Error loading recent locations: $e");
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    try {
      LocationData? location;
      try {
        location = await _locationService.getCurrentLocation();
      } catch (e) {
        print("Main location method failed: $e");
        try {
          location = await _locationService.getCurrentLocationSimple();
        } catch (e2) {
          print("Simple location method also failed: $e2");
          throw Exception("Could not get location: $e2");
        }
      }

      if (mounted) {
        setState(() {
          _currentLocation = location;
        });
      }
    } catch (e) {
      if (mounted) {
        final localizations = AppLocalizations.of(context)!;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.no_locations_found(e)
              // 'Could not access location: $e'
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _initializeSearchSuggestions() {
    final localizations = AppLocalizations.of(context)!;

    List<GooglePlacesSuggestion> initialSuggestions = [];

    if (_currentLocation != null) {
      initialSuggestions.add(GooglePlacesSuggestion(
        placeId: 'current_location',
        mainText: _currentLocation!.displayName,
        secondaryText: localizations.youAreCurrentlyHere,
        fullText: _currentLocation!.displayName,
        isRecentLocation: false,
        isCurrentLocation: true,
      ));
    }

    initialSuggestions.addAll(_convertRecentLocationsToGooglePlaces());
    setState(() => _locationSuggestions = initialSuggestions);
  }

  Future<void> _searchLocationsWithGooglePlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        List<GooglePlacesSuggestion> suggestions = [];

        if (_currentLocation != null) {
          suggestions.add(GooglePlacesSuggestion(
            placeId: 'current_location',
            mainText: _currentLocation!.displayName,
            secondaryText:
            _currentLocation!.addressDetails ?? 'Current Location',
            fullText: _currentLocation!.displayName,
            isRecentLocation: false,
            isCurrentLocation: true,
          ));
        }

        suggestions.addAll(_convertRecentLocationsToGooglePlaces());

        _locationSuggestions = suggestions;
        _isSearchingLocation = false;
      });
      return;
    }

    setState(() {
      _isSearchingLocation = true;
    });

    try {
      final suggestions = await _fetchGooglePlacesSuggestions(query);
      print("API call successful - received ${suggestions.length} suggestions");

      if (mounted) {
        setState(() {
          List<GooglePlacesSuggestion> finalSuggestions = [];

          if (_currentLocation != null) {
            finalSuggestions.add(GooglePlacesSuggestion(
              placeId: 'current_location',
              mainText: _currentLocation!.displayName,
              secondaryText:
              _currentLocation!.addressDetails ?? 'Current Location',
              fullText: _currentLocation!.displayName,
              isRecentLocation: false,
              isCurrentLocation: true,
            ));
          }

          finalSuggestions.addAll(suggestions);

          _locationSuggestions = finalSuggestions;
          _isSearchingLocation = false;
        });
      }
    } catch (e) {
      print("Error searching locations: $e");
      if (mounted) {
        setState(() {
          List<GooglePlacesSuggestion> errorSuggestions = [];
          if (_currentLocation != null) {
            errorSuggestions.add(GooglePlacesSuggestion(
              placeId: 'current_location',
              mainText: _currentLocation!.displayName,
              secondaryText:
              _currentLocation!.addressDetails ?? 'Current Location',
              fullText: _currentLocation!.displayName,
              isRecentLocation: false,
              isCurrentLocation: true,
            ));
          }
          _locationSuggestions = errorSuggestions;
          _isSearchingLocation = false;
        });
        final localizations = AppLocalizations.of(context)!;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.search_error(e))),
        );
      }
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

    final body = jsonEncode({
      "input": input,
      "locationBias": {
        "rectangle": {
          "low": {
            "latitude": 6.0,
            "longitude": 68.0,
          },
          "high": {
            "latitude": 36.0,
            "longitude": 98.0,
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
          isCurrentLocation: false,
        );
      }).toList();
    } else {
      print('Google Places API Error ${response.statusCode}: ${response.body}');
      throw Exception('Failed to fetch suggestions: ${response.statusCode}');
    }
  }

  Future<GooglePlaceDetails> _getGooglePlaceDetails(String placeId) async {
    final localizations = AppLocalizations.of(context)!;

    final url = Uri.parse('https://places.googleapis.com/v1/places/$placeId');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _apiKey,
      'X-Goog-FieldMask': 'location,addressComponents,formattedAddress,types',
    };

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
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
        throw Exception(localizations.locationNotInIndia);
      }

      final location = data['location'];
      final double latitude = location['latitude'];
      final double longitude = location['longitude'];

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

      final formattedAddress =
          data['formattedAddress'] ?? localizations.addressNotAvailable;

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
    return _recentLocations.map((location) {
      return GooglePlacesSuggestion(
        placeId: '',
        mainText: location.displayName,
        secondaryText: location.addressDetails,
        fullText: location.displayName,
        isRecentLocation: true,
        isCurrentLocation: false,
      );
    }).toList();
  }

  void _selectLocation(GooglePlacesSuggestion suggestion) async {
    setState(() {
      _searchController.text = suggestion.fullText;
      _showLocationSearch = false;
      _searchFocusNode.unfocus();
    });

    GooglePlaceDetails? placeDetails;

    if (suggestion.placeId == 'current_location' && _currentLocation != null) {
      placeDetails = GooglePlaceDetails(
        placeId: 'current_location',
        formattedAddress: _currentLocation!.displayName,
        latitude: 0.0,
        longitude: 0.0,
        pinCode: _currentLocation!.pincode ?? 'Not available',
      );
    } else if (suggestion.isRecentLocation) {
      placeDetails = GooglePlaceDetails(
        placeId: '',
        formattedAddress: suggestion.fullText,
        latitude: 0.0,
        longitude: 0.0,
        pinCode: 'Not available',
      );
    } else {
      try {
        placeDetails = await _getGooglePlaceDetails(suggestion.placeId);
        final locationData = LocationData(
          displayName: suggestion.mainText,
          addressDetails: suggestion.secondaryText,
          pincode:
          placeDetails.pinCode != 'Not found' ? placeDetails.pinCode : null,
        );
        _locationService.addToRecentLocations(locationData);
        _loadRecentLocations();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location details: $e')),
        );
        return;
      }
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            VehicleSearchScreen(
              selectedCategory: widget.selectedCategory,
              selectedLocation: placeDetails,
            ),
      ),
    );
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoadingMore && _hasMoreItems) {
        _loadMoreVehicles();
      }
    }
  }

  Future<void> _loadMoreVehicles() async {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoadingMore || !_hasMoreItems) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _vehicleService.searchVehicles(
        pincode: widget.selectedLocation?.pinCode ?? '',
        lat: widget.selectedLocation?.latitude ?? 0.0,
        lng: widget.selectedLocation?.longitude ?? 0.0,
        searchType: _selectedVehicleType,
        page: nextPage,
        limit: _itemsPerPage,
        filters: _activeFilters,
      );

      setState(() {
        if (response.data.results.isNotEmpty) {
          _vehicles.addAll(response.data.results);
          _currentPage = nextPage;
        } else {
          _hasMoreItems = false;
        }
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizations.failed_to_load_more_vehicles(e))),
      );
    }
  }

  bool favAdded = false;
  bool deletFav = false;

  Future<void> addToFav(String partnerId, String vehicleId) async {
    setState(() {
      favAdded = true;
    });
    try {
      final res =
      await _vehicleService.addToFavourites(partnerId, vehicleId).then((_) {
        setState(() {
          favAdded = false;
        });
      });
    } catch (e) {
      setState(() {
        favAdded = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed to add favourites')),
      );
    }
  }

  Future<void> deleteFavourires(String vehicleId) async {
    setState(() {
      deletFav = false;
    });
    try {
      final res = await _vehicleService.deleteFavourites(vehicleId).then((_) {
        setState(() {
          deletFav = true;
        });
      });
    } catch (e) {
      setState(() {
        deletFav = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed to delete from favourites')),
      );
    }
  }

  Future<void> _searchVehicles({bool reset = true}) async {
    final localizations = AppLocalizations.of(context)!;

    developer.log('=== Starting Vehicle Search ===');
    developer
        .log('Selected Location: ${widget.selectedLocation?.formattedAddress}');
    developer.log('Pincode: ${widget.selectedLocation?.pinCode}');
    developer.log('Lat: ${widget.selectedLocation?.latitude}');
    developer.log('Lng: ${widget.selectedLocation?.longitude}');
    developer.log('Vehicle Type: $_selectedVehicleType');
    developer.log('Reset: $reset');

    if (widget.selectedLocation == null) {
      developer.log('ERROR: No location selected');
      setState(() {
        _errorMessage = localizations.selectLocationFirst;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      if (reset) {
        _vehicles.clear();
        _currentPage = 1;
        _hasMoreItems = true;
        _isLoadingMore = false;
        _currentVehicleIndex.clear();
      }
    });

    try {
      developer.log(
          'Making API call... ${convertVehicleType(_selectedVehicleType)}');
      final response = await _vehicleService.searchVehicles(
        pincode: widget.selectedLocation?.pinCode ?? '',
        lat: widget.selectedLocation?.latitude ?? 0.0,
        lng: widget.selectedLocation?.longitude ?? 0.0,
        searchType: convertVehicleType(_selectedVehicleType),
        page: _currentPage,
        limit: _itemsPerPage,
        filters: _activeFilters,
      );

      developer.log('API call completed successfully');
      developer.log('Total vehicles found: ${response.data.results.length}');

      if (mounted) {
        setState(() {
          _vehicles = List.from(response.data.results);
          _isLoading = false;
          _currentVehicleIndex.clear();
          for (var owner in _vehicles) {
            _currentVehicleIndex[owner.id] = 0;
            developer.log(
                'Owner: ${owner.firstName}, ID: ${owner
                    .id}, Vehicle Count: ${owner.vehicles.length}');
          }
          _hasMoreItems = response.data.results.length >= _itemsPerPage;
        });
      }
    } catch (e) {
      developer.log('Error searching vehicles: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshVehicles() async {
    developer.log('=== REFRESH TRIGGERED ===');
    try {
      await _searchVehicles(reset: true);
      developer.log('=== REFRESH COMPLETED ===');
    } catch (e) {
      developer.log('=== REFRESH FAILED: $e ===');
    }
  }

  Future<void> _openFilters() async {
    final filters = await FilterBottomSheet.show(
      context,
      _filterService,
      filterType: currentFilterType,
    );
    if (filters != null && filters.isNotEmpty) {
      setState(() {
        _activeFilters = filters;
      });
      _searchVehicles();
    }
  }

  void _navigateToVehicleDetail(VehicleOwner owner) async {
    print("tappeddddddd");
    bool success = await logUserActivity(
      id: owner.userId,
      activity: ActivityType.CLICK,
      type: getMyType(owner.vehicles.length > 1
          ? "Transporter"
          : owner.vehicles
          .elementAt(0)
          .vehicleType),
      baseUrl: ApiConstants.baseUrl,
    );

    if (success) {
      print("clicked Success 💘💘💘💘💘💘💘💘💘💘");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to log activity")),
      );
    }
    final currentIndex = _currentVehicleIndex[owner.id] ?? 0;
    final vehicle =
    owner.vehicles.isNotEmpty && currentIndex < owner.vehicles.length
        ? owner.vehicles[currentIndex]
        : null;
    final serviceLocation =
    owner.serviceLocation != null ? owner.serviceLocation : null;
    if (vehicle != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              VehicleDetailScreenTransPorter(
                  owner: owner,
                  vehicle: vehicle,
                  type: widget.selectedCategory,
                  serviceLocation: serviceLocation!),
        ),
      );
    }
  }

  bool favTapped = false;

  void _navigateVehicle(String ownerId, int direction) {
    setState(() {
      final currentIndex = _currentVehicleIndex[ownerId] ?? 0;
      final owner = _vehicles.firstWhere((o) => o.id == ownerId);
      final totalVehicles = owner.vehicles.length;

      int newIndex = currentIndex + direction;
      if (newIndex < 0) {
        newIndex = totalVehicles - 1;
      } else if (newIndex >= totalVehicles) {
        newIndex = 0;
      }

      _currentVehicleIndex[ownerId] = newIndex;
    });
  }

  Map<String, bool> favoriteStates = {};

  updateFavState(Vehicle? vehicle) {
    print("favouritesData:${favouritesData}");
    for (var fav in favouritesData) {
      if (fav.vehicle?.sId == vehicle?.id) {
        favoriteStates[vehicle!.id] = true;
      }
    }
    // setState(() {});
  }

// 2. UPDATE _buildVehicleCard METHOD:
  Widget _buildVehicleCard(VehicleOwner owner) {
    final currentIndex = _currentVehicleIndex[owner.id] ?? 0;
    final hasMultipleVehicles = owner.vehicles.length > 1;
    final vehicle =
    owner.vehicles.isNotEmpty && currentIndex < owner.vehicles.length
        ? owner.vehicles[currentIndex]
        : null;
    final localizations = AppLocalizations.of(context)!;
    updateFavState(vehicle);
    return InkWell(
      onTap: () {
        _navigateToVehicleDetail(owner);

      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: gradientFirst.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section with Navigation
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    color: Colors.grey[100],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: _buildVehicleImage(vehicle),
                  ),
                ),
                // Image Counter Badge (Top Right)
                if (hasMultipleVehicles)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${currentIndex + 1}/${owner.vehicles.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Navigation Arrows
                if (hasMultipleVehicles) ...[
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _navigateVehicle(owner.id, -1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_left,
                            color: Colors.black87,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () => _navigateVehicle(owner.id, 1),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.chevron_right,
                            color: Colors.black87,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),

            Expanded(
              child: Column(
                children:[
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 12,right: 12,top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vehicle Name and Rating
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  vehicle?.vehicleName ?? localizations.no_vehicles_found,
                                  style: TextStyle(
                                    fontSize: (vehicle != null &&
                                        vehicle.vehicleName.isNotEmpty)
                                        ? 16
                                        : 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                vehicle?.vehicleType ?? '',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ColorConstants.black2,
                                  fontWeight: FontWeight.w400,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (vehicle != null && vehicle.vehicleName.isNotEmpty)
                                Spacer()
                              else
                                const SizedBox(width: 20),
                              // Rating Badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.amber[50],
                                  border: BoxBorder.all(color: Color(0xFFF9E9AD)),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.star,
                                      size: 14,
                                      color: Colors.amber,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      owner.rating > 0
                                          ? owner.rating.toStringAsFixed(1)
                                          : '4.3',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 12),

                          // Features Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildFeatureTag(
                                icon: "assets/img/seats.png",
                                text: '${vehicle?.seatingCapacity ?? 'N/A'} Seats',
                              ),
                              const SizedBox(width: 8),
                              if (vehicle?.airConditioning != null &&
                                  vehicle!.airConditioning.isNotEmpty)
                                _buildFeatureTag(
                                  icon: "",
                                  text: vehicle.airConditioning,
                                ),
                              Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  if (favoriteStates.containsKey(vehicle!.id)) {
                                    await deleteFavourires(vehicle!.id);
                                    setState(() {
                                      favoriteStates[vehicle.id] = false;
                                    });
                                  } else {
                                    await addToFav(vehicle!.userId, vehicle.id);
                                    setState(() {
                                      favoriteStates[vehicle.id] =
                                      !(favoriteStates[vehicle.id] ?? false);
                                    });
                                  }
                                },
                                child: (favAdded || deletFav)
                                    ? Center(
                                  child: CircularProgressIndicator(),
                                )
                                    : Icon(
                                  (favoriteStates[vehicle?.id] ?? false)
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  color: (favoriteStates[vehicle?.id] ?? false)
                                      ? Colors.red
                                      : Colors.grey[400],
                                  size: 22,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),
                          // Price and Negotiable Badge
                          Row(
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Minimum Charge',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w400),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    '₹ ${vehicle?.minimumChargePerHour ??
                                        owner.minimumCharges}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                ],
                              ),
                              // Negotiable Badge
                              if (vehicle?.isPriceNegotiable == true || owner.negotiable)
                                Flexible(
                                    child: Container(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      /* decoration: BoxDecoration(
                                  color: gradientSecond,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.blue,
                                    width: 0.5,
                                  ),
                                ),*/
                                      child: Text(
                                        (vehicle?.isPriceNegotiable == true ||
                                            owner.negotiable)
                                            ? localizations.negotiable
                                            : localizations.fixedPrice,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: gradientSecond,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )),
                              const SizedBox(width: 10),
                            ],
                          ),
                          // Action Buttons and Favorite Icon Row
                          SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  CustomActivity(
                                    baseUrl: ApiConstants.baseUrl,
                                    userId: owner.userId,
                                    icon: AssetsConstant.chatSVG,
                                    type: 'MESSAGE',
                                    phone: owner.businessMobileNumber,
                                    activityType: ActivityType.WHATSAPP,
                                    userType: getMyType(owner.vehicles.length > 1 &&
                                        owner.vehicles.isNotEmpty
                                        ? "Transporter"
                                        : owner.vehicles.isNotEmpty
                                        ? owner.vehicles.first.vehicleType
                                        : "Unknown"),
                                  ),
                                  const SizedBox(width: 20),
                                  CustomActivity(
                                    baseUrl: ApiConstants.baseUrl,
                                    userId: owner.userId,
                                    icon: AssetsConstant.whatsAppSVG,
                                    type: 'WHATSAPP',
                                    phone: owner.businessMobileNumber,
                                    activityType: ActivityType.WHATSAPP,
                                    userType: getMyType(owner.vehicles.length > 1 &&
                                        owner.vehicles.isNotEmpty
                                        ? "Transporter"
                                        : owner.vehicles.isNotEmpty
                                        ? owner.vehicles.first.vehicleType
                                        : "Unknown"),
                                  ),
                                  const SizedBox(width: 20),
                                  CustomActivity(
                                    baseUrl: ApiConstants.baseUrl,
                                    userId: owner.userId,
                                    icon: AssetsConstant.callPhoneSVG,
                                    type: 'PHONE',
                                    phone: owner.businessMobileNumber,
                                    activityType: ActivityType.PHONE,
                                    userType: getMyType(owner.vehicles.length > 1
                                        ? "Transporter"
                                        : owner.vehicles.isNotEmpty
                                        ? owner.vehicles.first.vehicleType
                                        : "Unknown"),
                                  ),
                                ],
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: InkWell(
                                  onTap: () {
                                    // _navigateToVehicleDetail(owner);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: gradientSecond,
                                      borderRadius: BorderRadius.circular(2),
                                      border: Border.all(
                                        color: AppColors.blue,
                                        width: 0.5,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          "Send Request",
                                          style: const TextStyle(
                                            fontSize: 10,
                                            color: Colors.white,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.send,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ),

                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Owner Info Section (Moved Below View More)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12,vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),bottomRight: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        // Profile Picture
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1)),
                          child: owner.profilePhoto.isNotEmpty
                              ? ClipOval(
                            child: Image.network(
                              owner.profilePhoto,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                              const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          )
                              : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Owner Name and Details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      "${owner.firstName } ${owner.lastName}",
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.black87,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (owner.isVerifiedByAdmin) ...[
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.verified,
                                      size: 12,
                                      color: Colors.green,
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          width: 10,
                        ),
                        // Vehicle Count Badge
                        Row(
                          children: [
                            Text(
                              'Vehicles Owned',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                              decoration: BoxDecoration(
                                color: gradientFirst.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: AppColors.blue,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '${owner.vehicles.length.toString().padLeft(
                                    2, '0')}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                ] ,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 3. ADD THESE NEW HELPER METHODS (add them to your class):
  Widget _buildFeatureTag({required String icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: gradientFirst.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.blue,
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon.isNotEmpty) Image.asset(icon, width: 14, height: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildActionButton(String asset, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: Image.asset(
            asset,
            width: 20,
            height: 20,
            color: color,
          ),
        ),
      ),
    );
  }

// Helper method to build feature chips
  Widget _buildFeatureChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

// Helper method to get fuel type icon
  IconData _getFuelIcon(String fuelType) {
    switch (fuelType.toLowerCase()) {
      case 'petrol':
      case 'gasoline':
        return Icons.local_gas_station_rounded;
      case 'diesel':
        return Icons.local_shipping_rounded;
      case 'electric':
      case 'ev':
        return Icons.electric_car_rounded;
      case 'hybrid':
        return Icons.eco_rounded;
      case 'cng':
        return Icons.gas_meter_rounded;
      default:
        return Icons.local_gas_station_rounded;
    }
  }

// Enhanced action button (you'll need to update this method too)
  Widget _buildEnhancedActionButton(String asset, Color color,
      VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Image.asset(
            asset,
            width: 22,
            height: 22,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActionButton(String icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        padding: EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: ColorConstants.primaryColorNew.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: ColorConstants.primaryColorNew.withOpacity(0.3),
            width: 0.5,
          ),
        ),
        child: Image.asset(
          icon,
          width: 16,
          height: 16,
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.oops_something_wrong,
              // 'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? localizations.pleaseTryAgainLater,
              maxLines: 1,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshVehicles,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(localizations.retry),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.categoryNotFoundMessage,
              // "Oops! We couldn't find this category at your selected location. We're expanding fast—stay tuned!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.try_changing_location,
              // '🔍 Try changing the location or exploring other categories.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshVehicles,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(localizations.refresh),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSearchBar() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      color: ColorConstants.backgroundColor,
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            decoration: InputDecoration(
              hintText: localizations.search_for_location,
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _searchController.clear();
                    _initializeSearchSuggestions();
                  });
                },
              )
                  : null,
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: (value) {
              _searchLocationsWithGooglePlaces(value);
            },
          ),
          const SizedBox(height: 8),
          if (_isSearchingLocation)
            const LinearProgressIndicator(
              minHeight: 2,
              color: ColorConstants.primaryColor,
            ),
        ],
      ),
    );
  }

  Widget _buildLocationSuggestions() {
    final localizations = AppLocalizations.of(context)!;

    return Expanded(
      child: ListView.builder(
        itemCount: _locationSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _locationSuggestions[index];
          bool isCurrentLocation = suggestion.placeId == 'current_location';
          bool isRecentLocation = suggestion.isRecentLocation;

          return ListTile(
            leading: Icon(
              isCurrentLocation ? Icons.my_location : Icons.location_on,
              color: isCurrentLocation ? Colors.blue : Colors.grey,
            ),
            title: Text(
              suggestion.mainText,
              style: TextStyle(
                fontWeight:
                isCurrentLocation ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: isCurrentLocation
                ? Text(localizations.youAreCurrentlyHere)
                : Text(suggestion.secondaryText ?? ''),
            onTap: () {
              _selectLocation(suggestion);
            },
          );
        },
      ),
    );
  }

  Widget _buildVehicleImage(Vehicle? vehicle) {
    if (vehicle == null || vehicle.images.isEmpty) {
      return Icon(
        Icons.directions_car,
        size: 40,
        color: Colors.grey[600],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        vehicle.images.first,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.directions_car,
            size: 40,
            color: Colors.grey[600],
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.purple.shade400,
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    _searchFocusNode.unfocus();
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Remove the header section that was here before
          if (_showLocationSearch) ...[
            _buildLocationSearchBar(),
            _buildLocationSuggestions(),
          ] else
            ...[
              Expanded(
                child: _isLoading
                    ? _buildLoadingWidget()
                    : _errorMessage != null
                    ? _buildErrorWidget()
                    : _vehicles.isEmpty
                    ? _buildEmptyWidget()
                    : _buildVehiclesList(),
              ),
            ],
        ],
      ),
    );
  }

  Widget _buildVehiclesList() {
    return RefreshIndicator(
      onRefresh: _refreshVehicles,
      color: ColorConstants.primaryColor,
      backgroundColor: Colors.white,
      child: GridView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.only(bottom: 10, top: 10, left: 5, right: 5),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 1,
          childAspectRatio: 0.92, // Adjusted for new card height
          crossAxisSpacing: 0.5,
          mainAxisSpacing: 0.5,
        ),
        itemCount: _vehicles.length + (_hasMoreItems ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= _vehicles.length) {
            return Container(
              margin: EdgeInsets.all(12),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: _isLoadingMore
                  ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        ColorConstants.primaryColor,
                      ),
                      strokeWidth: 2,
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Loading more...',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
                  : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.green,
                    size: 28,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All loaded',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }
          return _buildVehicleCard(_vehicles[index]);
        },
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorConstants.primaryColor,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Finding vehicles...',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationSelector() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.25),
            Colors.white.withOpacity(0.15),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _showLocationSearch = true;
              _searchFocusNode.requestFocus();
            });
          },
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColorNew.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.location_on,
                  color: ColorConstants.primaryColorNew,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Current Location',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _searchController.text.isNotEmpty
                          ? _searchController.text
                          : AppLocalizations.of(context)!.tapToChangeLocation,
                      style: TextStyle(
                        color: _searchController.text.isNotEmpty
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
