import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/screens/user_screens/rating_and_reviews.dart';
import 'package:video_player/video_player.dart';

import '../../api/api_model/transporter_model/transpoter_details_model.dart';
import '../../api/api_model/vehciles_single_model/DriverDetailsModel.dart';
import '../../api/api_service/transporter_details_service/transporter_details_service.dart';
import '../../components/app_appbar.dart';
import '../../components/app_button.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';
import '../common_screens/reviews_screen.dart';

class TransporterDetailsScreen extends StatefulWidget {
  final String transporterId;

  const TransporterDetailsScreen({
    super.key,
    required this.transporterId,
  });

  @override
  State<TransporterDetailsScreen> createState() =>
      _TransporterDetailsScreenState();
}

class _TransporterDetailsScreenState extends State<TransporterDetailsScreen>
    with TickerProviderStateMixin {
  DriverDetailsModel? _transporterDetails;

  bool _isLoading = true;
  String? _error;
  bool _hasReviewed = false;
  final PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  final PageController _vehiclePageController = PageController(
    viewportFraction: 0.9,
  );
  int _currentVehicleIndex = 0;
  final GlobalKey _reviewsWidgetKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadTransporterDetails();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _vehiclePageController.dispose();
    super.dispose();
  }

  Future<void> _loadTransporterDetails() async {
    // try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final details = await TransporterDetailsService.getTransporterDetails(
        widget.transporterId,
      );
      print("details:${details}");
      if (mounted) {
        setState(() {
          _transporterDetails = details;
          _isLoading = false;
        });
      }
    // } catch (e) {
    //   if (mounted) {
    //     setState(() {
    //       _error = e.toString();
    //       _isLoading = false;
    //     });
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.grey[50],
      appBar: CustomAppBar(
        title: localizations.details,
      ),
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
              stops: [0.0, 0.15, 0.30, .90],
            ),
          ),
          child: SafeArea(child: _buildBody())),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return _buildLoadingWidget();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_transporterDetails == null) {
      return _buildNoDataWidget();
    }

    return RefreshIndicator(
      onRefresh: _loadTransporterDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransporterHeader(),
            _buildContactInfo(),
            _buildFleetInfo(),
            if (_transporterDetails!.provider!.bio!.isNotEmpty) _buildAboutSection(),
            _buildVehiclesSection(),
            _buildReviewsSection(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
                ColorConstants.primaryColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            localizations.loading_transporter_details,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              localizations.oops_something_wrong,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadTransporterDetails,
              icon: const Icon(Icons.refresh),
              label: Text(localizations.retry),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Text(
        localizations.no_data_available,
        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
      ),
    );
  }

  Widget _buildTransporterHeader() {
    final transporter = _transporterDetails!.provider;

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background taxi image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
            ),
            child: Container(
              height: 150,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorConstants.primaryColor.withOpacity(0.8),
                    ColorConstants.primaryColor.withOpacity(0.4),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Image.network(
                'https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=800',
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
                errorBuilder: (context, error, stackTrace) => Container(),
              ),
            ),
          ),

          // Profile content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Profile image
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: transporter!.profilePhoto!.isNotEmpty
                            ? CachedNetworkImage(
                          imageUrl: transporter!.profilePhoto!,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 40),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.person, size: 40),
                          ),
                        )
                            : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.person, size: 40),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Name and ID
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "${transporter.firstName} ${transporter.lastName}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black38,
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (transporter!.isVerifiedByAdmin!) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${transporter.id!.length > 8 ? transporter.id!.substring(transporter.id!.length - 8) : transporter.id}',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ...List.generate(5, (index) {
                                return Icon(
                                  index < transporter.rating!.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 16,
                                );
                              }),
                              const SizedBox(width: 6),
                              Text(
                                transporter.rating!.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    final transporter = _transporterDetails!.provider;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.contact_information,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildContactRow(
            Icons.phone_outlined,
            localizations.phoneNumber,
            transporter!.businessMobileNumber!,
          ),
          const SizedBox(height: 8),
          _buildContactRow(
            Icons.location_on_outlined,
            localizations.address,
            _formatAddress(transporter.address!),
          ),
        ],
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: ColorConstants.primaryColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFleetInfo() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: ColorConstants.primaryColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            localizations.fleet_information,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: ColorConstants.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Text(
              '${8} ${localizations.vehicles}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: ColorConstants.primaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection() {
    final transporter = _transporterDetails!.provider;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.about,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            transporter!.bio!,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehiclesSection() {
    final vehicles = _transporterDetails!.provider!.vehicles;
    final localizations = AppLocalizations.of(context)!;

    if (vehicles!.isEmpty) {
      return _buildEmptyVehiclesWidget();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            localizations.available_vehicles,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 420,
          child: PageView.builder(
            controller: _vehiclePageController,
            onPageChanged: (index) {
              setState(() {
                _currentVehicleIndex = index;
              });
            },
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: _buildVehicleCard(vehicles![index]!),
              );
            },
          ),
        ),
        if (vehicles.length > 1)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: _buildPaginationDots(vehicles.length, _currentVehicleIndex),
            ),
          ),
      ],
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Image
          if (vehicle.images!.isNotEmpty && vehicle.images!.any((img) => img.isNotEmpty))
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
              child: CachedNetworkImage(
                imageUrl: vehicle.images!.first,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  height: 180,
                  child: const Icon(Icons.directions_car, size: 60),
                ),
              ),
            ),

          // Vehicle Info
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle!.vehicleName!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            vehicle.vehicleType!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: ColorConstants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '₹${vehicle.minimumChargePerHour}/hr',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    _buildVehicleSpec(
                      Icons.airline_seat_recline_normal,
                      '${vehicle.seatingCapacity} ${localizations.seats}',
                    ),
                    const SizedBox(width: 12),
                    if (vehicle!.airConditioning==true)
                      _buildVehicleSpec(
                        Icons.ac_unit,
                        vehicle!.airConditioning.toString(),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.confirmation_number, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Text(
                      vehicle.vehicleNumber!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    if (vehicle.isPriceNegotiable!)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Text(
                          localizations.negotiable,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleSpec(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.reviewsAndRatings,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ReviewsWidget(
            key: _reviewsWidgetKey,
            usertype: 'TRANSPORTER',
            driverId: widget.transporterId,
            onReviewStatusChanged: (hasReviewed) {
              if (mounted) {
                setState(() {
                  _hasReviewed = hasReviewed;
                });
              }
            },
          ),
          if (!_hasReviewed) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => RatingsReviewScreen(
                        serviceId: widget.transporterId,
                        serviceType: 'TRANSPORTER',
                      ),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
                icon: const Icon(Icons.rate_review, size: 20),
                label: Text(localizations.enter_your_review),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Widget> _buildPaginationDots(int totalItems, int currentIndex) {
    List<Widget> dots = [];
    if (totalItems <= 8) {
      for (int i = 0; i < totalItems; i++) {
        dots.add(Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: currentIndex == i
                ? ColorConstants.primaryColor
                : Colors.grey[300],
          ),
        ));
      }
    } else {
      dots.add(Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: ColorConstants.primaryColor.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${currentIndex + 1}/$totalItems',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: ColorConstants.primaryColor,
          ),
        ),
      ));
    }
    return dots;
  }

  Widget _buildEmptyVehiclesWidget() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.directions_car_outlined, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              localizations.no_vehicles_available,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  String _formatAddress(Address address) {
    List<String> addressParts = [];

    if (address.addressLine?.isNotEmpty == true) {
      addressParts.add(address.addressLine!);
    }
    if (address.city?.isNotEmpty == true) {
      addressParts.add(address.city!);
    }
    if (address.state?.isNotEmpty == true) {
      addressParts.add(address.state!);
    }
    if (address.pincode != null) {
      addressParts.add(address.pincode.toString());
    }

    return addressParts.join(', ');
  }
}