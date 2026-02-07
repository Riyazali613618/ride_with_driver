import 'dart:async';
import 'dart:convert';
import 'dart:math' show Random;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:rwd/components/app_loader.dart';
import 'package:rwd/components/common_parent_container.dart';
import 'package:rwd/screens/Eligibility/bloc/eligibility_event.dart';
import 'package:rwd/screens/driver_screens/plans.dart';
import 'package:rwd/screens/layout.dart';
import 'package:rwd/screens/profileScreens/widget/videoPlayerWidget.dart';
import 'package:rwd/screens/user_screens/JoinPartnerContainer.dart';
import 'package:rwd/screens/user_screens/PartnerRegistrationWidget.dart'
    hide ApplicationStatus;
import 'package:rwd/screens/user_screens/more/more_screen.dart';
import 'package:rwd/screens/user_screens/vehicles.dart';
import 'package:rwd/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import '../../api/api_model/VehicleType.dart';
import '../../api/api_model/location_model/location_model.dart';
import '../../api/api_model/user_model/user_eligibility_model.dart';
import '../../api/api_service/location_service/location_service.dart';
import '../../api/api_service/user_service/user_profile_service.dart';
import '../../constants/GoogleLocationSearchService.dart';
import '../../constants/api_constants.dart';
import '../../constants/assets_constant.dart';
import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../../features/vehicles/presentation/pages/vehicle_type_model.dart';
import '../../plan/data/repositories/plan_repository.dart';
import '../../plan/presentation/bloc/plan_bloc.dart';
import '../Eligibility/bloc/eligibility_bloc.dart';
import '../Eligibility/bloc/eligibility_state.dart';
import '../auth_screens/select_language_screen.dart';
import '../autoRikshawDriverRegistration.dart';
import '../block/home/home_provider.dart';
import '../block/language/language_provider.dart';
import '../block/provider/profile_provider.dart';
import '../driverRegistrationScreen.dart';
import '../eRickshawRegistration.dart';
import '../independentCarOwnerRegistration.dart';
import '../notification/notification.dart';
import 'package:rwd/api/api_model/language/language_model.dart';
import 'package:rwd/l10n/app_localizations.dart';
import '../other/category_view.dart';
import '../transporterRegistration.dart' show TransporterRegistrationFlow;
import 'AutoRickshawProgressCard.dart';
import 'LocationSearchScreen.dart';
import 'owners.dart';

class UserHomeNewScreen extends StatefulWidget {
  final bool? showDriverSubscription;
  final bool? isFirstTime;

  const UserHomeNewScreen(
      {super.key, this.showDriverSubscription, this.isFirstTime});

  @override
  State<UserHomeNewScreen> createState() => _UserHomeNewScreenState();
}

class _UserHomeNewScreenState extends State<UserHomeNewScreen>
    with WidgetsBindingObserver {
  int selectedVehicleIndex = -1;
  bool isRentVehicle = true;
  int currentSlideIndex = 0;
  PageController pageController = PageController();
  ApplicationStatus _status = ApplicationStatus.notStarted;

  Future<ApplicationStatus> _getApplicationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('auto_rickshaw_status');
    if (statusString != null) {
      return ApplicationStatus.values.firstWhere(
        (e) => e.toString() == statusString,
        orElse: () => ApplicationStatus.notStarted,
      );
    }
    return ApplicationStatus.notStarted;
  }

  Future<ApplicationStatus> _loadApplicationStatus(String type) async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString(type);
    if (statusString != null) {
      _status = ApplicationStatus.values.firstWhere(
        (e) => e.toString() == statusString,
        orElse: () => ApplicationStatus.notStarted,
      );
      return _status;
    }
    return ApplicationStatus.notStarted;
  }

  Future<ApplicationStatus> _loadApplicationStatusDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('driver_status');
    if (statusString != null) {
      _status = ApplicationStatus.values.firstWhere(
        (e) => e.toString() == statusString,
        orElse: () => ApplicationStatus.notStarted,
      );
      return _status;
    }
    return ApplicationStatus.notStarted;
  }

  Future<ApplicationStatus> _loadApplicationStatusER() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('er_status');
    if (statusString != null) {
      _status = ApplicationStatus.values.firstWhere(
        (e) => e.toString() == statusString,
        orElse: () => ApplicationStatus.notStarted,
      );
      return _status;
    }
    return ApplicationStatus.notStarted;
  }

  Future<ApplicationStatus> _loadApplicationStatusTrans() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('transporter_status');
    if (statusString != null) {
      _status = ApplicationStatus.values.firstWhere(
        (e) => e.toString() == statusString,
        orElse: () => ApplicationStatus.notStarted,
      );
      return _status;
    }
    return ApplicationStatus.notStarted;
  }

  Future<ApplicationStatus> _loadApplicationStatusIndi() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('indi_status');
    if (statusString != null) {
      _status = ApplicationStatus.values.firstWhere(
        (e) => e.toString() == statusString,
        orElse: () => ApplicationStatus.notStarted,
      );
      return _status;
    }
    return ApplicationStatus.notStarted;
  }

/*  Future<ApplicationStatus> _loadApplicationStatus(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString(key);

    final status = (statusString != null)
        ? ApplicationStatus.values.firstWhere(
            (e) => e.toString() == statusString,
            orElse: () => ApplicationStatus.notStarted,
          )
        : ApplicationStatus.notStarted;

    setState(() {
      _status = status;
    });

    return status; // ✅ return actual status
  }*/

  /// 🔹 Wrapper to decide which status to load based on whoReg
  Future<ApplicationStatus> _loadWhoRegAndStatus(String type) async {
    final prefs = await SharedPreferences.getInstance();

    String userType = type.toUpperCase();
    if (userType.contains("RICKSHAW")) {
      return _loadApplicationStatus('auto_rickshaw_status');
    } else if (userType == "DRIVER") {
      return _loadApplicationStatus('driver_status');
    } else if (userType == "E_RICKSHAW") {
      return _loadApplicationStatus('er_status');
    } else if (userType == "TRANSPORTER") {
      return _loadApplicationStatus('transporter_status');
    } else if (userType == "INDEPENDENT_CAR_OWNER") {
      return _loadApplicationStatus('indi_status');
    }
    return ApplicationStatus.notStarted;
  }

  // Timer? autoScrollTimer;
  GoogleMapController? mapController;
  late ProfileProvider profileProvider;
  String? userName = "Getting name...";
  String currentLocationName = 'Getting location...';
  Language? _selectedLanguage;

  // bool showSearchSuggestions = false;
  bool _languageInitialized = false;
  bool isPressed = false;
  bool _currentSubscriptionVisibility = false;
  List<Map<String, dynamic>> bannerData = [];
  List<Map<String, dynamic>> tutorialData = [];
  bool isLoadingBanners = true;
  bool isLoadingTutorial = true;

  // Default location (Sector-62, Noida)
  LatLng _currentLocation = const LatLng(28.6139, 77.3910);

  // Location search related variables
  final LocationSearchExample _locationSearchService = LocationSearchExample();
  Timer? autoScrollTimer;
  final FocusNode _containerSearchFocusNode = FocusNode();
  final TextEditingController _containerSearchController =
      TextEditingController();
  GooglePlaceDetails? selectedLocationData;
  String selectedCategory = 'allVehicles';
  bool showCategoryDropdown = false;
  LocationData? currentLocation;
  List<LocationData> recentLocations = [];
  List<GooglePlacesSuggestion> filteredLocations = [];
  bool _isLoadingCurrentLocation = false;
  final ScrollController _scrollController = ScrollController();
  String selectedVehicle = "All Services";

  Future<void> _fetchBanners() async {
    try {
      setState(() {
        isLoadingBanners = true;
      });
      // Get user data from ProfileProvider

      final userId = profileProvider.userId;
      final token = await TokenManager.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/banners'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId ?? '',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            bannerData = List<Map<String, dynamic>>.from(responseData['data']);
            bannerData = bannerData
                .where(
                  (element) => element["platform"] == "mobileapp",
                )
                .toList();
            isLoadingBanners = false;
            restartAutoScroll();
          });
        } else {
          // Handle API error response
          setState(() {
            bannerData = [];
            isLoadingBanners = false;
          });
        }
      } else {
        setState(() {
          bannerData = [];
          isLoadingBanners = false;
        });
      }
    } catch (e) {
      setState(() {
        bannerData = [];
        isLoadingBanners = false;
      });
    }
  }

  Future<void> _fetchVideoTutorials() async {
    try {
      setState(() {
        isLoadingTutorial = true;
      });
      // Get user data from ProfileProvider
      Provider.of<ProfileProvider>(context, listen: false);
      final userId = profileProvider.userId;
      final token = await TokenManager.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/tutorials'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId ?? '',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true && responseData['data'] != null) {
          setState(() {
            tutorialData =
                List<Map<String, dynamic>>.from(responseData['data']);
            isLoadingTutorial = false;
          });
        } else {
          // Handle API error response
          setState(() {
            tutorialData = [];
            isLoadingTutorial = false;
          });
        }
      } else {
        setState(() {
          tutorialData = [];
          isLoadingTutorial = false;
        });
      }
    } catch (e) {
      setState(() {
        tutorialData = [];
        isLoadingTutorial = false;
      });
    }
  }

  Future<void> _initializeSelectedLanguage() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    setState(() {
      _selectedLanguage = languageProvider.currentLanguage;
      _languageInitialized = true;
    });
  }

  String mapVehicleToCategory(String vehicleName) {
    switch (vehicleName.toUpperCase()) {
      case 'ALL SERVICES':
        return 'ALLVEHICLES';
      case 'CAR':
        return 'CAR';
      case 'AUTO':
        return 'RICKSHAW';
      case 'E-RICKSHAW':
        return 'E_RICKSHAW';
      case 'SUV':
        return 'SUV';
      case 'MINIVAN':
        return 'MINIVAN';
      case 'BUS':
        return 'BUS';
      case 'DRIVER':
        return 'DRIVER';
      case 'LUXURY':
        return 'LUXURY';
      default:
        return 'ALLVEHICLES';
    }
  }

  String _getSelectedCategory() {
    if (!isRentVehicle) {
      return 'DRIVER';
    }
    if (selectedVehicleIndex == -1) {
      return 'ALLVEHICLES';
    }

    switch (selectedVehicleIndex) {
      case 0:
        return 'CAR';
      case 1:
        return 'RICKSHAW';
      case 2:
        return 'E_RICKSHAW';
      case 3:
        return 'SUV';
      case 4:
        return 'MINIVAN';
      case 5:
        return 'BUS';
      case 6:
        return 'DRIVER';
      case 7:
        return 'LUXURY';
      default:
        return 'ALLVEHICLES';
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingCurrentLocation = true;
    });

    try {
      final locationData =
          await GoogleLocationSearchService.getCurrentLocationWithDetails();
      print("locationData:${locationData}");
      if (locationData != null && mounted) {
        final coordinates = locationData['coordinates'] as LatLng;
        final locationName = locationData['name'] as String;

        setState(() {
          currentLocationName = locationName;
          _currentLocation = coordinates;
          _markers = {
            Marker(
              markerId: const MarkerId('currentLocation'),
              position: _currentLocation,
              infoWindow: InfoWindow(
                  title: 'You are here', snippet: currentLocationName),
            )
          };
          _isLoadingCurrentLocation = false;
        });

        mapController?.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(target: _currentLocation, zoom: 14),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingCurrentLocation = false;
        });
      }
    }
  }

  // Set of markers for drivers and vehicles
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> _loadProfileData() async {
    await context.read<ProfileProvider>().loadProfile(context);
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(UserHomeNewScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showDriverSubscription != widget.showDriverSubscription) {
      setState(() {
        _currentSubscriptionVisibility = widget.showDriverSubscription ?? false;
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (mounted) {
        setState(() {
          _currentSubscriptionVisibility =
              widget.showDriverSubscription ?? false;
        });
      }
    }
  }

  void _createMarkers() {
    _markers.clear();

    // Add user location marker
    _markers.add(
      Marker(
        markerId: const MarkerId('user_location'),
        position: _currentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Your Location',
          snippet: currentLocationName,
        ),
      ),
    );
  }

  void startAutoScroll() {
    autoScrollTimer?.cancel(); // Cancel existing timer if any

    if (bannerData.isNotEmpty) {
      autoScrollTimer =
          Timer.periodic(const Duration(seconds: 3), (Timer timer) {
        if (pageController.hasClients) {
          int nextPage = (currentSlideIndex + 1) % bannerData.length;
          pageController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  void stopAutoScroll() {
    autoScrollTimer?.cancel();
  }

  void restartAutoScroll() {
    stopAutoScroll();
    if (bannerData.isNotEmpty) {
      startAutoScroll();
    }
  }

  @override
  void dispose() {
    autoScrollTimer?.cancel();
    pageController.dispose();
    _locationSearchService.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Map<String, VehicleType> vehicles = {};

  String selectedLanguage = 'En';

  Color getSmoothRandomColor() {
    final Random random = Random();
    final double hue = random.nextDouble() * 360;
    final HSLColor hslColor = HSLColor.fromAHSL(
      1.0,
      hue,
      0.45,
      0.75,
    );

    return hslColor.toColor();
  }

  void navigateBasedOnSelection() {
    // Get current category based on selection
    String currentCategory = _getSelectedCategory();

    if (selectedLocationData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please select a location first')));
      return;
    }

    if (currentCategory == "DRIVER") {
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
                    selectedCategory: currentCategory,
                  )));
    }
  }

  final LocationService _locationService = LocationService();

  Future<void> _loadRecentLocations() async {
    try {
      await _locationService.loadRecentLocations();
      setState(() {
        recentLocations = _locationService.getRecentLocations();
      });
    } catch (e) {}
  }

  Widget _buildContainerSearchBar() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.grey.shade600),
        borderRadius: BorderRadius.circular(30),
      ),
      child: GestureDetector(
        onTap: () async {
          // Navigate to search screen
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LocationSearchScreen(
                selectedCategory: _getSelectedCategory(),
                isRentVehicle: isRentVehicle,
                initialSearchText: _containerSearchController.text,
              ),
            ),
          );

          // Handle result if needed
          if (result != null) {
            // Handle any returned data if needed
          }
        },
        child: Row(
          children: [
            Icon(Icons.search, color: Colors.grey.shade600),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selectedLocationData != null
                    ? selectedLocationData!.formattedAddress
                    : localizations.searchLocation,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            ),
            if (selectedLocationData != null) ...[
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  navigateBasedOnSelection();
                },
                child: Icon(
                  Icons.arrow_forward,
                  color: ColorConstants.primaryColor,
                  size: 20,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildImageSlider() {
    if (isLoadingBanners) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    if (bannerData.isEmpty) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.3),
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text(
            'No banners available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: Stack(
        children: [
          GestureDetector(
            /*  onTapDown: (_) => stopAutoScroll(),
            onTapUp: (_) => restartAutoScroll(),
            onPanStart: (_) => stopAutoScroll(),
            onPanEnd: (_) => restartAutoScroll(),*/
            child: PageView.builder(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentSlideIndex = index;
                });
              },
              itemCount: bannerData.length,
              itemBuilder: (context, index) {
                final banner = bannerData[index];
                return GestureDetector(
                  onTap: () {
                    // Handle banner tap - navigate to link if available
                    if (banner['link'] != null && banner['link'].isNotEmpty) {
                      // You can implement navigation to the link here
                      // Example: launch(banner['link']) if using url_launcher package
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.network(
                        banner['imageurl'] ?? '',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.directions_car,
                              color: Colors.white,
                              size: 40,
                            ),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                value: loadingProgress.expectedTotalBytes !=
                                        null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (bannerData.length > 1)
            Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: bannerData.asMap().entries.map((entry) {
                      return GestureDetector(
                        onTap: () {
                          restartAutoScroll();
                          pageController.animateToPage(
                            entry.key,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: currentSlideIndex == entry.key ? 8 : 6,
                          height: currentSlideIndex == entry.key ? 8 : 6,
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: currentSlideIndex == entry.key
                                ? Colors.white
                                : Colors.white.withOpacity(0.5),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _currentSubscriptionVisibility = widget.showDriverSubscription ?? false;
    final localizations = AppLocalizations.of(context)!;
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CommonParentContainer(
          showLargeGradient: false,
          child: SafeArea(
            child: Column(
              children: [
                _loadHeader(),
                Expanded(
                    child: RefreshIndicator(
                  onRefresh: onRefreshPage,
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        _buildImageSlider(),
                        const SizedBox(height: 22),
                        Container(
                          margin:
                              EdgeInsets.only(left: 12, right: 12, bottom: 16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(12)),
                              boxShadow: [
                                BoxShadow(
                                    offset: Offset(0, 0),
                                    color: Colors.grey.shade300,
                                    blurRadius: 40,
                                    spreadRadius: 0)
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              children: [
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LocationSearchScreen(
                                          selectedCategory:
                                              mapVehicleToCategory(
                                                  selectedVehicle),
                                          isRentVehicle: isRentVehicle,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          gradientFirst,
                                          gradientSecond,
                                          // gradientThird,
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(1.4),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Row(
                                          children: [
                                            PopupMenuButton<String>(
                                              color: Colors.white,
                                              onSelected: (String value) async {
                                                setState(() {
                                                  selectedVehicle = value;
                                                  isRentVehicle = true;
                                                });
                                              },
                                              itemBuilder:
                                                  (BuildContext context) {
                                                return [
                                                  PopupMenuItem<String>(
                                                    value: "All Services",
                                                    child: Text(
                                                      "All Services",
                                                      style: TextStyle(
                                                        fontFamily: AppConstants
                                                            .ptSansFont,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  ..._vehicleTypes.map(
                                                      (Categories vehicle) {
                                                    return PopupMenuItem<
                                                        String>(
                                                      value: vehicle.code,
                                                      child: Text(
                                                        vehicle.code!,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    );
                                                  }).toList(),
                                                ];
                                              },
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 9,
                                                        horizontal: 14),
                                                decoration: const BoxDecoration(
                                                  color: Color(0xffF1F5F9),
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(12),
                                                    bottomLeft:
                                                        Radius.circular(12),
                                                  ),
                                                ),
                                                child: Center(
                                                  child: ShaderMask(
                                                    shaderCallback: (bounds) =>
                                                        LinearGradient(
                                                      colors: [
                                                        gradientFirst,
                                                        gradientSecond,
                                                      ],
                                                      begin: Alignment.topLeft,
                                                      end:
                                                          Alignment.bottomRight,
                                                    ).createShader(
                                                            Rect.fromLTWH(
                                                                0,
                                                                0,
                                                                bounds.width,
                                                                bounds.height)),
                                                    blendMode: BlendMode.srcIn,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Text(
                                                          selectedVehicle ==
                                                                  "All Services"
                                                              ? localizations
                                                                  .all_Services
                                                              : selectedVehicle,
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        const Text(
                                                          "▾",
                                                          style: TextStyle(
                                                              fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),

                                            SizedBox(
                                              width: 16,
                                            ),
                                            Expanded(
                                                child: Text(
                                              "Enter pickup location (e.g., Mumbai)",
                                              style: TextStyle(
                                                fontSize: 10.5,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            )),
                                            SizedBox(
                                              width: 8,
                                            )
                                            // Expanded(
                                            //   child: GestureDetector(
                                            //     onTap: () {
                                            //       Navigator.push(
                                            //         context,
                                            //         MaterialPageRoute(
                                            //           builder: (context) =>
                                            //               LocationSearchScreen(
                                            //             selectedCategory: "driver",
                                            //             isRentVehicle:
                                            //                 isRentVehicle,
                                            //           ),
                                            //         ),
                                            //       );
                                            //     },
                                            //     child: Padding(
                                            //       padding:
                                            //           const EdgeInsets.all(4.0),
                                            //       child: Container(
                                            //         padding:
                                            //             const EdgeInsets.symmetric(
                                            //                 vertical: 10),
                                            //         decoration: BoxDecoration(
                                            //           color: !isRentVehicle
                                            //               ? Colors.white
                                            //               : Colors.transparent,
                                            //           borderRadius:
                                            //               BorderRadius.circular(25),
                                            //           boxShadow: !isRentVehicle
                                            //               ? [
                                            //                   BoxShadow(
                                            //                     color: Colors.grey
                                            //                         .withOpacity(
                                            //                             0.3),
                                            //                     blurRadius: 8,
                                            //                     offset:
                                            //                         const Offset(
                                            //                             0, 2),
                                            //                   ),
                                            //                 ]
                                            //               : null,
                                            //         ),
                                            //         child: Text(
                                            //           localizations.hire_driver,
                                            //           textAlign: TextAlign.center,
                                            //           style: TextStyle(
                                            //             color: !isRentVehicle
                                            //                 ? const Color(
                                            //                     0xFF090040)
                                            //                 : Colors.white,
                                            //             fontWeight: !isRentVehicle
                                            //                 ? FontWeight.bold
                                            //                 : FontWeight.normal,
                                            //           ),
                                            //         ),
                                            //       ),
                                            //     ),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),

                                // const SizedBox(height: 10),
                                // _buildContainerSearchBar(),
                                // const SizedBox(height: 10),

                                // Available vehicles section
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 10, top: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                localizations.suggestions,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              GridViewExample()));
                                },
                                child: Text(
                                  localizations.see_all,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 8, right: 8, bottom: 10),
                            child: Row(
                              children:
                                  _vehicleTypes.asMap().entries.map((entry) {
                                int index = entry.key;
                                Categories vehicle = entry.value;

                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 5.0),
                                  child: GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        selectedVehicleIndex = index;
                                      });

                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              LocationSearchScreen(
                                            selectedCategory:
                                                _getSelectedCategory(),
                                            isRentVehicle: isRentVehicle,
                                          ),
                                        ),
                                      );
                                      setState(() {
                                        selectedVehicleIndex = -1;
                                      });
                                    },
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: 28,
                                          bottom: 22,
                                          left: 4,
                                          right: 8),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            vehicle.color1 ?? Colors.purple,
                                            vehicle.color ?? Colors.white,
                                          ],
                                          stops: const [0.0, 0.7],
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: selectedVehicleIndex == index
                                            ? Border.all(
                                                color:
                                                    ColorConstants.primaryColor,
                                                width: 2,
                                              )
                                            : null,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Image.asset(
                                              vehicle.image ?? "",
                                              width: 90,
                                              height: 55,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Padding(
                                            padding:
                                                const EdgeInsets.only(left: 8),
                                            child: Text(
                                              vehicle.code!,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: Colors.black,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        BlocBuilder<EligibilityBloc, EligibilityState>(
                          builder: (context, state) {
                            if (state is EligibilityLoaded &&
                                (state.userType.isEmpty ||
                                    state.userType.toLowerCase() == "user")) {
                              return Container(
                                height: 50,
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // ✅ works fine
                                      ),
                                      elevation: 0,
                                      backgroundColor: Color(0xff0064E0)),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => BlocProvider(
                                          create: (context) => PlanBloc(
                                            RepositoryProvider.of<
                                                PlanRepository>(context),
                                          ),
                                          child: PartnerRegistrationWidget(),
                                        ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Become Partner',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        BlocBuilder<EligibilityBloc, EligibilityState>(
                          builder: (context, state) {
                            if (state is EligibilityLoaded &&
                                state.paymentPhase == 'PRE_REGISTRATION') {
                              return Container(
                                height: 50,
                                width: double.infinity,
                                margin: EdgeInsets.symmetric(
                                    horizontal: 15, vertical: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            12), // ✅ works fine
                                      ),
                                      elevation: 0,
                                      backgroundColor: Color(0xff0064E0)),
                                  onPressed: () {
                                    _navigateToApplication(state.userType);
                                  },
                                  child: const Text(
                                    'Complete Your Application',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }

                            return const SizedBox.shrink();
                          },
                        ),
                        _buildMediaSection(),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ))
              ],
            ),
          )),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tutorials',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 15),
          SizedBox(
            height: MediaQuery.of(context).size.height * .14,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tutorialData.length,
              itemBuilder: (context, index) {
                final videoUrl = tutorialData[index]['videoUrl'] ?? '';
                final thumbnailUrl = tutorialData[index]['thumbnailUrl'] ?? '';

                return Container(
                  width: MediaQuery.of(context).size.width * .428,
                  margin: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    child: Stack(alignment: Alignment.center, children: [
                      Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.black12,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: CachedNetworkImage(
                            imageUrl: thumbnailUrl,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(12),
                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              FullScreenVideoPlayer(videoUrl: videoUrl),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  bool isRegistrationIncomplete = false;

  Future<UserEligibilityModel> getEligibilityData() async {
    final data = await UserProfileService().getEligibility();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstants.planEligibilityKey, jsonEncode(data.data));
    if (data.data != null &&
        data.data?.paymentPhase.toString() == AppConstants.preRegistration) {
      setState(() {
        isRegistrationIncomplete = true;
      });
    } else {
      setState(() {
        isRegistrationIncomplete = false;
      });
    }
    return data;
  }

  Future<void> _navigateToApplication(String type) async {
    Widget? destination;

    String userType = type;
    if (userType == "RICKSHAW") {
      destination = AutoRickshawDriverFlow();
    } else if (userType == "DRIVER") {
      destination = DriverRegistrationFlow();
    } else if (userType == "E_RICKSHAW") {
      destination = ERickshawDriverFlow();
    } else if (userType == "TRANSPORTER") {
      destination = TransporterRegistrationFlow();
    } else if (userType == "INDEPENDENT_CAR_OWNER") {
      destination = IndependentTaxiOwnerFlow();
    }

    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination!),
      ).then((_) {
        // Load status based on whoReg
        String userType = type.toUpperCase();
        if (userType.contains("RICKSHAW")) {
          _loadWhoRegAndStatus(userType);
        } else if (userType == "DRIVER") {
          _loadApplicationStatusDriver();
        } else if (userType == "E_RICKSHAW") {
          _loadApplicationStatusER();
        } else if (userType == "TRANSPORTER") {
          _loadApplicationStatusTrans();
        } else if (userType == "INDEPENDENT_CAR_OWNER") {
          _loadApplicationStatusIndi();
        }
      });
    }
  }

  List<Categories> _vehicleTypes = [];

  Future<void> getVehicleTypeList() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        final data = await UserProfileService().getVehicleTypeList();
        if (data.data != null) {
          _vehicleTypes = data.data?.categories ?? [];

          _vehicleTypes = mergeServerWithLocalUI(_vehicleTypes);
          setState(() {});
        }
      },
    );
  }

  List<Categories> mergeServerWithLocalUI(
    List<Categories> serverCategories,
  ) {
    return serverCategories.map((category) {
      final local = vehicles[category.code];

      if (local == null) {
        // No local match → return as-is
        return category;
      }

      return category.copyWith(
        color: local.color,
        color1: local.color1,
        image: local.assetImagePath,
      );
    }).toList();
  }

  void addVehicles() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        final localizations = AppLocalizations.of(context)!;
        vehicles = {
          'CAR': VehicleType(
            name: localizations.car,
            assetImagePath: AssetsConstant.car,
            color: const Color(0xFFEF9A9A),
            color1: const Color(0xFFFFEBEE),
          ),
          'AUTO': VehicleType(
            name: localizations.auto,
            assetImagePath: AssetsConstant.tukTuk,
            color: const Color(0xFFFFE082),
            color1: const Color(0xFFFFF8E1),
          ),
          'E_RICKSHAW': VehicleType(
            name: localizations.eRickshaw,
            assetImagePath: AssetsConstant.auto,
            color: const Color(0xFF9575CD),
            color1: const Color(0xFFEDE7F6),
          ),
          'SUV': VehicleType(
            name: localizations.suv,
            assetImagePath: AssetsConstant.suv,
            color: const Color(0xFFFFAB91),
            color1: const Color(0xFFFFEBE9),
          ),
          'MINIVAN': VehicleType(
            name: localizations.minivan,
            assetImagePath: AssetsConstant.minivan,
            color: const Color(0xFFF48FB1),
            color1: const Color(0xFFFCE4EC),
          ),
          'BUS': VehicleType(
            name: localizations.bus,
            assetImagePath: AssetsConstant.bus,
            color: const Color(0xFFA5D6A7),
            color1: const Color(0xFFE8F5E9),
          ),
          'RICKSHAW': VehicleType(
            name: localizations.driver,
            assetImagePath: AssetsConstant.driverBus,
            color: const Color(0xFF81D4FA),
            color1: const Color(0xFFE1F5FE),
          ),
          'LUXURY': VehicleType(
            name: 'Luxury',
            assetImagePath: AssetsConstant.suv,
            color: const Color(0xFFFFAB91),
            color1: const Color(0xFFE1F5FE),
          ),
        };
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  initData() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    addVehicles();
    getVehicleTypeList();
    startAutoScroll();
    _containerSearchController.addListener(() {
      setState(() {});
    });
    _createMarkers();
    _getCurrentLocation();
    _initializeSelectedLanguage();
    _fetchBanners(); // Add this line
    _fetchVideoTutorials(); // Add this line
    WidgetsBinding.instance.addObserver(this);
    _currentSubscriptionVisibility = widget.showDriverSubscription ?? false;
    _loadRecentLocations();

    if (widget.isFirstTime ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
        profileProvider.showDialogBox(context);
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfileData();
      getEligibilityData();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        context.read<EligibilityBloc>().add(FetchEligibilityEvent());
      } catch (e) {}
    });
  }

  Future<void> onRefreshPage() async {
    try {
      addVehicles(); // sync – keep as-is

      await Future.wait([
        getVehicleTypeList(),
        _getCurrentLocation(),
        _initializeSelectedLanguage(),
        _fetchBanners(),
        _fetchVideoTutorials(),
        _loadProfileData(),
        getEligibilityData(),
      ]);

      // Fire-and-forget (no await needed)
      context.read<EligibilityBloc>().add(FetchEligibilityEvent());
    } catch (e, stackTrace) {
      debugPrint('Refresh error: $e');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  _loadHeader() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GestureDetector(
          onTap: () async {
            final profile = await TokenManager.getProfile();
            final showPlan = profile?.subscriptions != null &&
                profile!.subscriptions.isNotEmpty;

            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => MoreScreen(
                  showPlan: showPlan,
                  showDriverSubscription:
                      widget.showDriverSubscription ?? false,
                ),
              ),
            );
          },
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.network(
                    profileProvider.profilePhoto.toString(),
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.account_circle_sharp,
                        color: Colors.grey,
                        size: 35,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hi, ${profileProvider.fullName ?? "Getting Name"}',
                      style: const TextStyle(
                        fontFamily: AppConstants.ptSansFont,
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    Text(
                      currentLocationName,
                      style: GoogleFonts.inter(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Consumer<LanguageProvider>(
                builder: (context, languageProvider, child) {
                  return GestureDetector(
                    onTap: null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/img/flagIcon.png',
                            height: 22,
                            width: 22,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          GestureDetector(
                            onTap: () async {
                              final lang = await Navigator.push<bool>(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const LanguageSelectionScreen()),
                              );
                            },
                            child: Text(
                              languageProvider.currentLanguage?.name ?? 'En',
                              style: GoogleFonts.lexendDeca(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationListScreen(),
                    ),
                  );
                },
                child: const Icon(
                  CupertinoIcons.bell_solid,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ],
          ),
        ));
  }
}

List<Map<String, dynamic>> getLocalizedSuggestions(BuildContext context) {
  final localizations = AppLocalizations.of(context)!;
  return [
    {
      "key": "car",
      "label": localizations.car,
      "asset": AssetsConstant.car,
      "color": const Color(0xFFEF9A9A),
      "color1": const Color(0xFFFFEBEE),
    },
    {
      "key": "auto",
      "label": localizations.auto,
      "asset": AssetsConstant.tukTuk,
      "color": const Color(0xFFFFE082),
      "color1": const Color(0xFFFFF8E1),
    },
    {
      "key": "eRickshaw",
      "label": localizations.eRickshaw,
      "asset": AssetsConstant.auto,
      "color": const Color(0xFF9575CD),
      "color1": const Color(0xFFEDE7F6),
    },
    {
      "key": "suv",
      "label": localizations.suv,
      "asset": AssetsConstant.suv,
      "color": const Color(0xFFFFAB91),
      "color1": const Color(0xFFFFEBE9),
    },
    {
      "key": "miniVan",
      "label": localizations.minivan,
      "asset": AssetsConstant.minivan,
      "color": const Color(0xFFF48FB1),
      "color1": const Color(0xFFFCE4EC),
    },
    {
      "key": "bus",
      "label": localizations.bus,
      "asset": AssetsConstant.bus,
      "color": const Color(0xFFA5D6A7),
      "color1": const Color(0xFFE8F5E9),
    },
    {
      "key": "driver",
      "label": localizations.driver,
      "asset": AssetsConstant.driverBus,
      "color": Color(0xFF81D4FA),
      "color1": Color(0xFFE1F5FE),
    },
  ];
}

class VideoThumbnailView extends StatefulWidget {
  final String videoUrl;
  final VoidCallback onTap;

  const VideoThumbnailView({
    Key? key,
    required this.videoUrl,
    required this.onTap,
  }) : super(key: key);

  @override
  State<VideoThumbnailView> createState() => _VideoThumbnailViewState();
}

class _VideoThumbnailViewState extends State<VideoThumbnailView> {
  Uint8List? thumbnail;

  @override
  void initState() {
    super.initState();
    _loadThumbnail();
  }

  Future<void> _loadThumbnail() async {
    final data = await VideoThumbnail.thumbnailData(
      video: widget.videoUrl,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 400,
      quality: 75,
    );

    if (mounted) {
      setState(() => thumbnail = data);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: Colors.black12,
            ),
            child: thumbnail != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.memory(
                      thumbnail!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  )
                : const Center(child: CircularProgressIndicator()),
          ),

          // ▶ Play icon
          Container(
            decoration: BoxDecoration(
              color: Colors.black54,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(12),
            child: const Icon(
              Icons.play_arrow,
              color: Colors.white,
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const FullScreenVideoPlayer({
    Key? key,
    required this.videoUrl,
  }) : super(key: key);

  @override
  State<FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<FullScreenVideoPlayer> {
  late VideoPlayerController _controller;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(widget.videoUrl),
    )..initialize().then((_) {
        setState(() {});
        _controller.play();
      });

    _controller.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => setState(() => _showControls = !_showControls),
          child: Stack(
            children: [
              /// VIDEO
              Center(
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(color: Colors.white),
              ),

              /// CLOSE BUTTON
              if (_showControls)
                Positioned(
                  top: 16,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

              /// PLAY / PAUSE BUTTON
              if (_showControls)
                Center(
                  child: IconButton(
                    iconSize: 64,
                    icon: Icon(
                      _controller.value.isPlaying
                          ? Icons.pause_circle_filled
                          : Icons.play_circle_filled,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      setState(() {
                        _controller.value.isPlaying
                            ? _controller.pause()
                            : _controller.play();
                      });
                    },
                  ),
                ),

              /// SEEK BAR
              if (_showControls)
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Slider(
                        activeColor: Colors.white,
                        inactiveColor: Colors.white54,
                        min: 0,
                        max: _controller.value.duration.inMilliseconds
                            .toDouble(),
                        value: _controller.value.position.inMilliseconds
                            .clamp(
                              0,
                              _controller.value.duration.inMilliseconds,
                            )
                            .toDouble(),
                        onChanged: (value) {
                          _controller.seekTo(
                            Duration(milliseconds: value.toInt()),
                          );
                        },
                      ),

                      /// TIME TEXT
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _formatDuration(_controller.value.position),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                          Text(
                            _formatDuration(_controller.value.duration),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
