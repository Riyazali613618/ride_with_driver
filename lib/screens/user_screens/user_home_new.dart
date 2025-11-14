import 'dart:async';
import 'dart:convert';
import 'dart:math' show Random;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/screens/driver_screens/plans.dart';
import 'package:r_w_r/screens/layout.dart';
import 'package:r_w_r/screens/profileScreens/widget/videoPlayerWidget.dart';
import 'package:r_w_r/screens/user_screens/JoinPartnerContainer.dart';
import 'package:r_w_r/screens/user_screens/PartnerRegistrationWidget.dart'
    hide ApplicationStatus;
import 'package:r_w_r/screens/user_screens/vehicles.dart';
import 'package:r_w_r/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_model/VehicleType.dart';
import '../../api/api_model/location_model/location_model.dart';
import '../../api/api_service/location_service/location_service.dart';
import '../../constants/GoogleLocationSearchService.dart';
import '../../constants/api_constants.dart';
import '../../constants/assets_constant.dart';
import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../../plan/data/repositories/plan_repository.dart';
import '../../plan/presentation/bloc/plan_bloc.dart';
import '../block/home/home_provider.dart';
import '../block/language/language_provider.dart';
import '../block/provider/profile_provider.dart';
import '../notification/notification.dart';
import 'package:r_w_r/api/api_model/language/language_model.dart';
import 'package:r_w_r/l10n/app_localizations.dart';
import '../other/category_view.dart';
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
  String? whoReg;

  // Future<ApplicationStatus> _getApplicationStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final statusString = prefs.getString('auto_rickshaw_status');
  //   if (statusString != null) {
  //     return ApplicationStatus.values.firstWhere(
  //           (e) => e.toString() == statusString,
  //       orElse: () => ApplicationStatus.notStarted,
  //     );
  //   }
  //   return ApplicationStatus.notStarted;
  // }

  // Future<ApplicationStatus> _loadApplicationStatus() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final statusString = prefs.getString('auto_rickshaw_status');
  //   if (statusString != null) {
  //     setState(() {
  //       _status = ApplicationStatus.values.firstWhere(
  //             (e) => e.toString() == statusString,
  //         orElse: () => ApplicationStatus.notStarted,
  //       );
  //     });
  //   }
  //   return ApplicationStatus.notStarted;
  // }
  //
  // Future<ApplicationStatus> _loadApplicationStatusDriver() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final statusString = prefs.getString('driver_status');
  //   if (statusString != null) {
  //     setState(() {
  //       _status = ApplicationStatus.values.firstWhere(
  //             (e) => e.toString() == statusString,
  //         orElse: () => ApplicationStatus.notStarted,
  //       );
  //     });
  //   }
  //   return ApplicationStatus.notStarted;
  // }
  // Future<ApplicationStatus> _loadApplicationStatusER() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final statusString = prefs.getString('er_status');
  //   if (statusString != null) {
  //     setState(() {
  //       _status = ApplicationStatus.values.firstWhere(
  //             (e) => e.toString() == statusString,
  //         orElse: () => ApplicationStatus.notStarted,
  //       );
  //     });
  //   }
  //   return ApplicationStatus.notStarted;
  // }
  // Future<ApplicationStatus> _loadApplicationStatusTrans() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final statusString = prefs.getString('transporter_status');
  //   if (statusString != null) {
  //     setState(() {
  //       _status = ApplicationStatus.values.firstWhere(
  //             (e) => e.toString() == statusString,
  //         orElse: () => ApplicationStatus.notStarted,
  //       );
  //     });
  //   }
  //   return ApplicationStatus.notStarted;
  // }
  // Future<ApplicationStatus> _loadApplicationStatusIndi() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final statusString = prefs.getString('indi_status');
  //   if (statusString != null) {
  //     setState(() {
  //       _status = ApplicationStatus.values.firstWhere(
  //             (e) => e.toString() == statusString,
  //         orElse: () => ApplicationStatus.notStarted,
  //       );
  //     });
  //   }
  //   return ApplicationStatus.notStarted;
  // }
  //
  // Future<void> _loadWhoReg() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   whoReg = prefs.getString('who_reg');
  //
  //   if (whoReg == "Auto") {
  //     _loadApplicationStatus();
  //   }else if(whoReg == "Driver"){
  //     _loadApplicationStatusDriver();
  //   }else if(whoReg == "ER"){
  //     _loadApplicationStatusER();
  //   }else if(whoReg == "Transporter"){
  //     _loadApplicationStatusTrans();
  //   }else if(whoReg == "Indi"){
  //     _loadApplicationStatusIndi();
  //   }
  // }
  Future<ApplicationStatus> _loadApplicationStatus(String key) async {
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
  }

  /// 🔹 Wrapper to decide which status to load based on whoReg
  Future<ApplicationStatus> _loadWhoRegAndStatus() async {
    final prefs = await SharedPreferences.getInstance();
    whoReg = prefs.getString('who_reg');

    if (whoReg == "Auto") {
      return _loadApplicationStatus('auto_rickshaw_status');
    } else if (whoReg == "Driver") {
      return _loadApplicationStatus('driver_status');
    } else if (whoReg == "ER") {
      return _loadApplicationStatus('er_status');
    } else if (whoReg == "Transporter") {
      return _loadApplicationStatus('transporter_status');
    } else if (whoReg == "Indi") {
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
  bool isLoadingBanners = true;

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
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final userId = profileProvider.userId;
      final token = await TokenManager.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/banners/mobile'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId ?? '',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == true && responseData['data'] != null) {
          setState(() {
            bannerData = List<Map<String, dynamic>>.from(responseData['data']);
            isLoadingBanners = false;
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
        return 'DRIVE';
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
    startAutoScroll();
    _containerSearchController.addListener(() {
      setState(() {});
    });
    _createMarkers();
    _getCurrentLocation();
    _initializeSelectedLanguage();
    _fetchBanners(); // Add this line
    WidgetsBinding.instance.addObserver(this);
    _currentSubscriptionVisibility = widget.showDriverSubscription ?? false;
    _loadRecentLocations();
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    if (widget.isFirstTime ?? false) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _getCurrentLocation();
        profileProvider.showDialogBox(context);
      });
    }
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
      setState(() {
        _currentSubscriptionVisibility = widget.showDriverSubscription ?? false;
      });
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

  void _showLanguageSelectionDialog() {
    if (!_languageInitialized) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Consumer<LanguageProvider>(
          builder: (context, languageProvider, child) {
            final localizations = AppLocalizations.of(context)!;

            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF471396),
                      Color(0xFFE74C3C),
                    ],
                    stops: [0.0, 1.0],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF471396),
                              Color(0xFFE74C3C),
                            ],
                          ),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(17),
                            topRight: Radius.circular(17),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.language,
                              color: Colors.white,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              localizations.language,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Loading indicator
                      if (languageProvider.isLoading)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 20,
                                height: 20,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text(localizations.change_language("")),
                            ],
                          ),
                        ),

                      // Language List
                      if (!languageProvider.isLoading)
                        Container(
                          constraints: const BoxConstraints(maxHeight: 400),
                          child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children:
                                    languageProvider.languages.map((language) {
                                  return _buildLanguageItem(
                                      language, languageProvider);
                                }).toList(),
                              ),
                            ),
                          ),
                        ),

                      // Footer
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          localizations.language_spoken,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLanguageItem(
      Language language, LanguageProvider languageProvider) {
    bool isSelected = _selectedLanguage?.code == language.code;

    return GestureDetector(
      onTap: languageProvider.isLoading
          ? null
          : () async {
              setState(() {
                _selectedLanguage = language;
              });

              if (language.code != languageProvider.currentLanguage?.code) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        ),
                        const SizedBox(width: 12),
                        Text('Changing language to ${language.name}...'),
                      ],
                    ),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF471396),
                  ),
                );

                await languageProvider.changeLanguage(language);

                if (languageProvider.error == null && mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Language changed to ${language.name}'),
                      duration: const Duration(seconds: 2),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (languageProvider.error != null && mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${languageProvider.error}'),
                      duration: const Duration(seconds: 3),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } else {
                Navigator.pop(context);
              }
            },
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF471396),
                    Color(0xFFE74C3C),
                  ],
                )
              : null,
          color: isSelected ? null : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF471396).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFF471396).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.translate,
                color: isSelected ? Colors.white : const Color(0xFF471396),
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language.name,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    language.nativeName,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white.withOpacity(0.8)
                          : Colors.grey.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                language.code,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check,
                  color: Color(0xFF471396),
                  size: 16,
                ),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400, width: 2),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
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

  final List<Map<String, String>> options = [
    {'titleKey': ' As Transporter', 'icon': '🚛', 'key': "TRANSPORTER"},
    {
      'titleKey': ' As Independent Car Owner ',
      'icon': '🚗',
      'key': "INDIPENDENTCAROWNER"
    },
    {'titleKey': 'As AutoRickshaw Owner', 'icon': '🛺', 'key': "RICKSHAW"},
    {'titleKey': 'As eRickshaw Owner', 'icon': '🔋', 'key': "E_RICKSHAW"},
    {'titleKey': 'As StandAloneDriver', 'icon': '👨‍✈️', 'key': "DRIVER"},
  ];

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
            onTapDown: (_) => stopAutoScroll(),
            onTapUp: (_) => restartAutoScroll(),
            onPanStart: (_) => stopAutoScroll(),
            onPanEnd: (_) => restartAutoScroll(),
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
                        banner['image'] ?? '',
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
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: height * .4,
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
                ),
                SafeArea(
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.all(16.0),
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
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    Text(
                                      currentLocationName,
                                      style: const TextStyle(
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
                                          Text(
                                            languageProvider
                                                    .currentLanguage?.name ??
                                                'En',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w500,
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
                                      builder: (context) =>
                                          NotificationListScreen(),
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
                          )),

                      _buildImageSlider(),

                      const SizedBox(height: 22),

                      Container(
                        margin:
                            EdgeInsets.only(left: 12, right: 12, bottom: 16),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
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
                                        selectedCategory: mapVehicleToCategory(
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
                                        borderRadius: BorderRadius.circular(12),
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
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  ),
                                                ),
                                                ...vehicles
                                                    .map((VehicleType vehicle) {
                                                  return PopupMenuItem<String>(
                                                    value: vehicle.name,
                                                    child: Text(
                                                      vehicle.name,
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
                                                borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(12),
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
                                                    end: Alignment.bottomRight,
                                                  ).createShader(Rect.fromLTWH(
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
                                                      const SizedBox(width: 4),
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
                            children: vehicles.asMap().entries.map((entry) {
                              int index = entry.key;
                              VehicleType vehicle = entry.value;

                              return Container(
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
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
                                        top: 28, bottom: 22, left: 4, right: 8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          vehicle.color1,
                                          vehicle.color,
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
                                            vehicle.assetImagePath ?? "",
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
                                            vehicle.name,
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
                      Consumer<HomeDataProvider>(
                        builder: (context, provider, child) {
                          return provider.showDashboard == false
                              ? Column(
                                  children: [
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: SizedBox(
                                        height: 54,
                                        child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12), // ✅ works fine
                                                ),
                                                elevation: 0,
                                                backgroundColor:
                                                    Color(0xff0064E0)),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => BlocProvider(
                                                    create: (context) =>
                                                        PlanBloc(
                                                      RepositoryProvider.of<
                                                              PlanRepository>(
                                                          context),
                                                    ),
                                                    child:
                                                        PartnerRegistrationWidget(),
                                                  ),
                                                ),
                                              );
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) => BlocProvider(
                                                    create: (_) => PlanBloc(
                                                      RepositoryProvider.of<PlanRepository>(context),
                                                    ),
                                                    child: PartnerRegistrationWidget(),
                                                  ),
                                                ),
                                              );


                                            },
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  AssetsConstant.partnerIcon,
                                                  height: 40,
                                                  width: 40,
                                                ),
                                                SizedBox(
                                                  width: 10,
                                                ),
                                                Text(
                                                  localizations.become_partner,
                                                  style: TextStyle(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: Colors.white),
                                                )
                                              ],
                                            )),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox.shrink();
                        },
                      ),
                      // Consumer<HomeDataProvider>(
                      //   builder: (context, provider, child) {
                      //     return provider.showDashboard == false
                      //         ? JoinPartnerContainer()
                      //         : SizedBox.shrink();
                      //   },
                      // ),

                      FutureBuilder<ApplicationStatus>(
                        future: _loadWhoRegAndStatus(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final status = snapshot.data!;
                            if (status != ApplicationStatus.notStarted &&
                                status != ApplicationStatus.submitted &&
                                status != ApplicationStatus.approved &&
                                status != ApplicationStatus.rejected) {
                              return AutoRickshawProgressCard();
                            }
                            return const SizedBox.shrink();
                          }

                          return const Center(
                              child: CircularProgressIndicator());
                        },
                      ),
                      _buildMediaSection(),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       color: Colors.white,
                      //       borderRadius: BorderRadius.circular(10),
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.grey.withOpacity(0.3),
                      //           blurRadius: 10,
                      //           offset: const Offset(0, 5),
                      //         ),
                      //       ],
                      //     ),
                      //     child: Column(
                      //       children: [
                      //         // Around You Header
                      //         Padding(
                      //           padding: const EdgeInsets.all(16.0),
                      //           child: Align(
                      //             alignment: Alignment.centerLeft,
                      //             child: Text(
                      //               localizations.around_you,
                      //               style: TextStyle(
                      //                 fontSize: 16,
                      //                 fontWeight: FontWeight.w600,
                      //               ),
                      //             ),
                      //           ),
                      //         ),

                      //         // Map Section
                      //         Padding(
                      //           padding: const EdgeInsets.only(
                      //               left: 8.0, right: 8.0, bottom: 10.0),
                      //           child: Container(
                      //             height: 300,
                      //             decoration: BoxDecoration(
                      //               borderRadius: BorderRadius.circular(15),
                      //               boxShadow: [
                      //                 BoxShadow(
                      //                   color: Colors.grey.withOpacity(0.2),
                      //                   blurRadius: 8,
                      //                   offset: const Offset(0, 3),
                      //                 ),
                      //               ],
                      //             ),
                      //             child: ClipRRect(
                      //               borderRadius: BorderRadius.circular(15),
                      //               child: GoogleMap(
                      //                 onMapCreated: (GoogleMapController controller) {
                      //                   mapController = controller;
                      //                 },
                      //                 initialCameraPosition: CameraPosition(
                      //                   target: _currentLocation,
                      //                   zoom: 14.0,
                      //                 ),
                      //                 markers: _markers,
                      //                 myLocationEnabled: true,
                      //                 myLocationButtonEnabled: true,
                      //                 zoomControlsEnabled: false,
                      //                 mapToolbarEnabled: false,
                      //                 compassEnabled: true,
                      //                 rotateGesturesEnabled: true,
                      //                 scrollGesturesEnabled: true,
                      //                 tiltGesturesEnabled: true,
                      //                 zoomGesturesEnabled: true,
                      //                 mapType: MapType.normal,
                      //                 onCameraMove: (CameraPosition position) {},
                      //                 onTap: (LatLng position) {},
                      //               ),
                      //             ),
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      // _buildMediaSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
              itemCount: 5,
              itemBuilder: (context, index) {
                List<String> videos = [
                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
                  'http://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
                ];

                return Container(
                    width: MediaQuery.of(context).size.width * .428,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Container());
              },
            ),
          ),
        ],
      ),
    );
  }
}
