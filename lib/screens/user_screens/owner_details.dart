import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/components/app_appbar.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/assets_constant.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/screens/user_screens/rating_and_reviews.dart';

import '../../api/api_model/owner/driver_details_model.dart';
import '../../api/api_service/owners/driver_details_service.dart';
import '../../components/app_button.dart';
import '../../components/custom_activity.dart';
import '../../l10n/app_localizations.dart';
import '../common_screens/reviews_screen.dart';

class OwnerDetailsScreen extends StatefulWidget {
  final String driverId;
  final String userId;

  const OwnerDetailsScreen(
      {super.key, required this.driverId, required this.userId});

  @override
  State<OwnerDetailsScreen> createState() => _OwnerDetailsScreenState();
}

class _OwnerDetailsScreenState extends State<OwnerDetailsScreen> {
  late Future<DriverResponse> _driverFuture;
  bool _hasReviewed = false;

  @override
  void initState() {
    super.initState();
    _loadDriverDetails();
  }

  void _loadDriverDetails() {
    setState(() {
      _driverFuture = DriverService.getDriverDetails(widget.userId);
      print("======================${widget.userId}");
      print("======================${widget.driverId}");
    });
  }

  @override
  void didChangeDependencies() {
    _handleReviewSubmitted();
    super.didChangeDependencies();
  }

  void _handleReviewSubmitted() {
    _loadDriverDetails();
    setState(() {
      _hasReviewed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: CustomAppBar(
          title: localizations.driver_profile,
          centerTitle: true,
          elevation: 0,
          leading: CupertinoNavigationBarBackButton(
            color: ColorConstants.white,
          )),
      body: FutureBuilder<DriverResponse>(
        future: _driverFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print("🔫🔫🔫🔫🔫🔫🔫🔫🔫${snapshot.error}");
            return Center(
              child: Text(
                ' ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (snapshot.hasData) {
            final driverData = snapshot.data!.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfileHeader(driverData),
                  const SizedBox(height: 24),
                  _buildDriverInfoForm(driverData),
                  const SizedBox(height: 24),
                  _buildDriverBio(driverData),
                  const SizedBox(height: 24),
                  _buildReviewAndRating(context),
                ],
              ),
            );
          } else {
            return Center(child: Text(localizations.no_driver_details));
          }
        },
      ),
      bottomNavigationBar: FutureBuilder<DriverResponse>(
        future: _driverFuture,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final driverData = snapshot.data!.data;
            return _buildPriceSection(driverData);
          } else {
            return const SizedBox(); // Placeholder
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(DriverData driverData) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Profile Photo
          Container(
            width: 120,
            height: 150,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                driverData.profilePhoto,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Icon(Icons.person, size: 80, color: Colors.grey),
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Basic Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        driverData.fullName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                buildStarRating(
                  double.tryParse(driverData.rating.toString()) ?? 0.0,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.drive_eta, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        localizations.years_experience(driverData.experience),
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        driverData.address.city,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildContactButtons(driverData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStarRating(double rating) {
    double clampedRating = rating.clamp(0.0, 5.0);
    int fullStars = clampedRating.floor();
    bool hasHalfStar = (clampedRating - fullStars) >= 0.5;
    int emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return Row(
      children: [
        ...List.generate(
          fullStars,
          (index) => const Icon(Icons.star, color: Colors.amber, size: 16),
        ),
        if (hasHalfStar)
          const Icon(Icons.star_half, color: Colors.amber, size: 16),
        ...List.generate(
          emptyStars,
          (index) =>
              const Icon(Icons.star_border, color: Colors.amber, size: 16),
        ),
        const SizedBox(width: 4),
        Text(
          clampedRating.toStringAsFixed(1),
          style: const TextStyle(
            color: Colors.amber,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildContactButtons(DriverData driverData) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CustomActivity(
          baseUrl: ApiConstants.baseUrl,
          userId: widget.userId,
          icon: AssetsConstant.whatsApp,
          type: 'WHATSAPP',
          phone: driverData.mobileNumber,
          activityType: ActivityType.WHATSAPP,
          userType: UserType.DRIVER,
        ),
        SizedBox(
          width: 5,
        ),
        CustomActivity(
          baseUrl: ApiConstants.baseUrl,
          userId: widget.userId,
          icon: AssetsConstant.callPhone,
          type: 'PHONE',
          phone: driverData.mobileNumber,
          activityType: ActivityType.PHONE,
          userType: UserType.DRIVER,
        ),
        SizedBox(
          width: 5,
        ),
        CustomActivity(
          baseUrl: ApiConstants.baseUrl,
          userId: widget.userId,
          icon: AssetsConstant.chat,
          type: 'CHAT',
          phone: driverData.mobileNumber,
          activityType: ActivityType.CHAT,
          userType: UserType.DRIVER,
        ),
      ],
    );
  }

  Widget _buildDriverInfoForm(DriverData driverData) {
    final localizations = AppLocalizations.of(context)!;

    final fullAddress = "${driverData.address.addressLine}, "
        "${driverData.address.city}, ${driverData.address.state}, "
        "${driverData.address.country} - ${driverData.address.pincode}";

    // Format languages
    final languages = driverData.languageSpoken.join(", ");

    // Format service cities
    final serviceCities = driverData.servicesCities.join(", ");

    final details = {
      "${localizations.mobile_number}: ": "+91 - ${driverData.mobileNumber}",
      localizations.emailAddress: " ",
      localizations.gender: driverData.gender,
      localizations.language: languages,
      localizations.experience:
          localizations.years_experience(driverData.experience),
      localizations.served_location: serviceCities,
      localizations.address: fullAddress,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConstants.backgroundColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.person_outline,
                  color: ColorConstants.primaryColorLight,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                localizations.more_info,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Form-like layout
          ...details.entries
              .map((entry) => _buildFormRow(entry.key, entry.value))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFormRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  ":   ",
                  style: TextStyle(
                      fontSize: 16, height: 0.1, fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverBio(DriverData driverData) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConstants.backgroundColor.withAlpha(25),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.description_outlined,
                  color: ColorConstants.primaryColorLight,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                localizations.driver_bio,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            driverData.bio,
            style: TextStyle(
              fontSize: 14,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewAndRating(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ReviewsWidget(
            usertype: "DRIVER",
            driverId: widget.userId,
            onReviewStatusChanged: (hasReviewed) {
              setState(() {
                _hasReviewed = hasReviewed;
              });
            },
          ),
          if (!_hasReviewed)
            CustomButton(
              text: localizations.rate_now,
              onPressed: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => RatingsReviewScreen(
                      serviceId: widget.userId,
                      serviceType: 'DRIVER',
                    ),
                  ),
                ).then((_) {
                  setState(() {});
                });
              },
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(DriverData driverData) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.black,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            localizations.minimum_charges,
            style: TextStyle(
              color: Colors.green,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            "₹ ${driverData.minimumCharges} ",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
