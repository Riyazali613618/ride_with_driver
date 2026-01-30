import 'package:flutter/material.dart';
import 'package:rwd/api/api_service/vehicle/search_vehicle_service.dart' show VehicleService;
import '../../../api/api_model/location_model/location_model.dart';
import '../../../api/api_model/vehicle/search_vehicles.dart';
import '../../../api/api_service/vehicle/add_vehicle_service.dart' hide VehicleService;
import '../../../components/custom_activity.dart';
import '../../../l10n/app_localizations.dart';
import '../../user_screens/LocationSearchScreen.dart';
import 'vehicle_search_controller.dart';
import 'widgets/vehicle_list.dart';
import 'widgets/loading_state.dart';
import 'widgets/empty_state.dart';
import 'widgets/error_state.dart';
import 'widgets/vehicle_card.dart' hide VehicleOwner;

class VehicleSearchScreen2 extends StatefulWidget {
  final FilterController? filterController;
  final Map<String, String>? filterData;
  final String selectedCategory;
  final GooglePlaceDetails? selectedLocation;
  final Map<String, dynamic>? appliedFilters;

  const VehicleSearchScreen2({
    super.key,
    this.filterData,
    this.filterController,
    required this.selectedCategory,
    this.selectedLocation,
    this.appliedFilters,
  });
  @override
  State<VehicleSearchScreen2> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen2> {
  final controller = VehicleSearchController();

  bool _isLoading = true;
  bool _isLoadingMore = false;
  String? _errorMessage;
  String _selectedVehicleType = ' ';
  int _currentPage = 1;

  List<VehicleOwner> vehicleOwners = [];
  int page = 1;
  final VehicleService _vehicleService = VehicleService();

  @override
  void initState() {
    super.initState();
    controller.attachScrollListener(_loadMore);
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    try {
      setState(() => _isLoading = true);

      final localizations = AppLocalizations.of(context)!;

      if (widget.selectedLocation == null) {
        setState(() {
          _errorMessage = localizations.selectLocationFirst;
          _isLoading = false;
        });
        return;
      }

      setState(() {
        _isLoading = true;
        _errorMessage = null;
     /*   if (reset) {
          vehicleOwners.clear();
          _currentPage = 1;
          _hasMoreItems = true;
          _isLoadingMore = false;
          _currentVehicleIndex.clear();
        }*/
      });

      try {
        final response = await _vehicleService.searchVehicles(
          pincode: widget.selectedLocation?.pinCode ?? '',
          lat: widget.selectedLocation?.latitude ?? 0.0,
          lng: widget.selectedLocation?.longitude ?? 0.0,
          searchType: convertVehicleType(_selectedVehicleType),
          page: _currentPage,
          limit: 20,
          filters: widget.filterData ?? {},
        );

        if (mounted) {
          setState(() {
            vehicleOwners = List.from(response.data.results);
            vehicleOwners = mergeVehicleOwners(vehicleOwners);
            _isLoading = false;
            _isLoadingMore = response.data.pagination.hasNext;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _errorMessage = e.toString().replaceAll('Exception: ', '');
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load vehicles';
    }

    setState(() => _isLoading = false);
  }
  List<VehicleOwner> mergeVehicleOwners(List<VehicleOwner> apiResults) {
    final Map<String, VehicleOwner> ownerMap = {};

    for (final owner in apiResults) {
      final ownerId = owner.id;

      if (!ownerMap.containsKey(ownerId)) {
        // Create fresh owner with empty vehicles
        ownerMap[ownerId] = VehicleOwner(
          id: owner.id,
          userId: owner.userId,
          userType: owner.userType,
          firstName: owner.firstName,
          lastName: owner.lastName,
          profilePhoto: owner.profilePhoto,
          email: owner.email,
          message: owner.message,
          isVerifiedByAdmin: owner.isVerifiedByAdmin,
          rating: owner.rating,
          gstin: owner.gstin,
          companyName: owner.companyName,
          bio: owner.bio,
          fleetSize: owner.fleetSize,
          counts: owner.counts,
          address: owner.address,
          businessMobileNumber: owner.businessMobileNumber,
          coverImage: owner.coverImage,
          vehicleType: owner.vehicleType,
          serviceLocation: owner.serviceLocation,
          languageSpoken: owner.languageSpoken,
          experience: owner.experience,
          minimumCharges: owner.minimumCharges,
          negotiable: owner.negotiable,
          dob: owner.dob,
          gender: owner.gender,
          totalRating: owner.totalRating,
          totalRatingSum: owner.totalRatingSum,
          independentCarOwnerFleetSize: owner.independentCarOwnerFleetSize,
          vehicles: [],
          reviews: owner.reviews,
          reviewsTotal: owner.reviewsTotal,
          language: owner.language,
          country: owner.country,
          state: owner.state,
          city: owner.city,
          fcmToken: owner.fcmToken,
          preferencesWhatsapp: owner.preferencesWhatsapp,
          preferencesPhone: owner.preferencesPhone,
          lat: owner.lat,
          lng: owner.lng,
        );
      }

      // Merge vehicles
      if (owner.vehicles.isNotEmpty) {
        ownerMap[ownerId]!.vehicles.addAll(owner.vehicles);
      }
    }

    return ownerMap.values.toList();
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || !controller.hasMore) return;

    setState(() {
      _isLoadingMore = true;
      controller.isLoadingMore = true;
    });
    try {
      _currentPage= _currentPage++;
      final response = await _vehicleService.searchVehicles(
        pincode: widget.selectedLocation?.pinCode ?? '',
        lat: widget.selectedLocation?.latitude ?? 0.0,
        lng: widget.selectedLocation?.longitude ?? 0.0,
        searchType: convertVehicleType(_selectedVehicleType),
        page: _currentPage,
        limit: 20,
        filters: widget.filterData ?? {},
      );

      if (mounted) {
        setState(() {
          vehicleOwners = List.from(response.data.results);
          vehicleOwners = mergeVehicleOwners(vehicleOwners);
          _isLoading = false;
          _isLoadingMore = response.data.pagination.hasNext;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceAll('Exception: ', '');
          _isLoading = false;
        });
      }
    }

    setState(() {
      _isLoadingMore = false;
      controller.isLoadingMore = false;
      controller.hasMore = vehicleOwners.length < 25;
    });
  }

  Future<void> _refresh() async {
    page = 1;
    controller.hasMore = true;
    await _fetchVehicles();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const LoadingState();
    if (_errorMessage != null) {
      return ErrorState(message: _errorMessage!, onRetry: _refresh);
    }
    if (vehicleOwners.isEmpty) {
      return EmptyState(onRefresh: _refresh);
    }

    return VehicleList(
      controller: controller.scrollController,
      vehicles: vehicleOwners,
      hasMore: controller.hasMore,
      isLoadingMore: _isLoadingMore,
      onRefresh: _refresh,
      itemBuilder: (v) => VehicleCard(owner: v),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
