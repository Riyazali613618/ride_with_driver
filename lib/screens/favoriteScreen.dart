import 'package:flutter/material.dart';
import 'package:r_w_r/screens/user_screens/vehicle_details_transporter.dart';

import '../api/api_service/vehicle/search_vehicle_service.dart';
import '../components/app_loader.dart';
import '../components/custom_activity.dart';
import '../constants/api_constants.dart';
import '../constants/assets_constant.dart';
import '../constants/color_constants.dart';
import '../l10n/app_localizations.dart';
import '../utils/color.dart';
import '../../api/api_model/favouriteModel.dart' as fm;
import 'layout.dart';
import '../../l10n/app_localizations.dart';

class FavoriteScreen extends StatefulWidget {
  final FavoriteController controller;

  const FavoriteScreen({Key? key, required this.controller}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  // Sample favorites list - replace with your actual data
  List<Map<String, String>> favorites = [];

  // Example with data:
  // List<Map<String, String>> favorites = [
  //   {'name': 'John Doe', 'type': 'Driver', 'rating': '4.5'},
  //   {'name': 'ABC Supplies', 'type': 'Supplier', 'rating': '4.8'},
  // ];
  final VehicleService _vehicleService = VehicleService();
  List<fm.Data> favData = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    widget.controller.refresh = getFavourites;
  }

  void updateData() {
    getFavourites();
  }

  bool getFavs = false;

  Future<void> getFavourites() async {
    setState(() {
      getFavs = true;
    });
    try {
      favData = await _vehicleService.getFavourites();
      setState(() {
        getFavs = false;
      });
    } catch (e) {
      setState(() {
        getFavs = false;
      });
      print("unable to fetch favourites:${e}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            stops: [0.01, 0.25, 0.35, .45],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Row(
                  children: [
                    /*   IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),*/
                    const Expanded(
                      child: Text(
                        'Favorite',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // To balance the back button
                  ],
                ),
              ),

              // Content
              (!getFavs)
                  ? Expanded(
                      child: favData.isEmpty
                          ? const Center(
                              child: Text(
                                'No Driver or Supplier',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 16,
                                ),
                              ),
                            )
                          : _buildVehiclesList(),
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  final ScrollController _scrollController = ScrollController();

  Widget _buildVehiclesList() {
    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 10, top: 10, left: 5, right: 5),
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 0.86, // Adjusted for new card height
        crossAxisSpacing: 0.5,
        mainAxisSpacing: 0.5,
      ),
      itemCount: favData.length,
      itemBuilder: (context, index) {
        return _buildVehicleCard(favData[index]);
      },
    );
  }

  Widget _buildVehicleImage(fm.Vehicle? vehicle) {
    if (vehicle == null || (vehicle.images ?? []).isEmpty) {
      return Icon(
        Icons.directions_car,
        size: 40,
        color: Colors.grey[600],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        vehicle.images?.first ?? "",
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

  final Map<String, int> _currentVehicleIndex = {};

  Widget _buildVehicleCard(fm.Data vehicle) {
    final localizations = AppLocalizations.of(context)!;
    // final currentIndex = _currentVehicleIndex[vehicle.vehicle!.userId] ?? 0;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: gradientFirst.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
          Container(
            height: 190,
            width: double.infinity,
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
              child: _buildVehicleImage(vehicle.vehicle),
            ),
          ),
          // Content Section
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(left: 12, right: 12, top: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Vehicle Name and Rating
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                vehicle.vehicle?.vehicleName ??
                                    localizations.no_vehicles_found,
                                style: TextStyle(
                                  fontSize: (vehicle != null &&
                                          (vehicle.vehicle?.vehicleName ?? "")
                                              .isNotEmpty)
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
                              vehicle.vehicle?.vehicleType ?? '',
                              style: TextStyle(
                                fontSize: 12,
                                color: ColorConstants.black2,
                                fontWeight: FontWeight.w400,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (vehicle != null &&
                                (vehicle.vehicle?.vehicleName ?? "").isNotEmpty)
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
                                    (vehicle.profile?.rating ?? 0) > 0
                                        ? (vehicle.profile?.rating ?? 0)
                                            .toStringAsFixed(1)
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
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset("assets/img/seats.png",
                                    width: 14, height: 14),
                                const SizedBox(width: 4),
                                Text(
                                  '${vehicle.vehicle?.seatingCapacity ?? 'N/A'} Seats',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[700],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            if (vehicle.vehicle?.airConditioning != null &&
                                (vehicle.vehicle?.airConditioning ?? "")
                                    .isNotEmpty)
                              _buildFeatureTag(
                                icon: "",
                                text: vehicle.vehicle?.airConditioning ?? "",
                              ),
                            Spacer(),
                            GestureDetector(
                              onTap: () async {
                                deleteFavourires(vehicle.favoriteId ?? "");
                                favData.remove(vehicle);
                                setState(() {});
                              },
                              child: /*(favAdded || deletFav)
                                  ? Center(
                                child: CircularProgressIndicator(),
                              )
                                  : */
                                  Icon(
                                Icons.favorite,
                                color: Colors.red,
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
                                  '₹ ${vehicle.vehicle?.minimumChargePerHour ?? (vehicle.vehicle?.minimumChargePerHour ?? 0)}',
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
                            Flexible(
                                child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              /* decoration: BoxDecoration(
                                  color: gradientSecond,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: AppColors.blue,
                                    width: 0.5,
                                  ),
                                ),*/
                              child: Text(
                                (vehicle.vehicle?.isPriceNegotiable ?? false)
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
                                  userId: (vehicle.vehicle?.userId ?? ""),
                                  icon: AssetsConstant.chatSVG,
                                  type: 'MESSAGE',
                                  phone:
                                      vehicle.profile?.businessMobileNumber ??
                                          "",
                                  activityType: ActivityType.WHATSAPP,
                                  userType:
                                      getMyType(vehicle.partnerType ?? ""),
                                ),
                                const SizedBox(width: 20),
                                CustomActivity(
                                  baseUrl: ApiConstants.baseUrl,
                                  userId: (vehicle.vehicle?.userId ?? ""),
                                  icon: AssetsConstant.whatsAppSVG,
                                  type: 'WHATSAPP',
                                  phone:
                                      vehicle.profile?.businessMobileNumber ??
                                          "",
                                  activityType: ActivityType.WHATSAPP,
                                  userType:
                                      getMyType(vehicle.partnerType ?? ""),
                                ),
                                const SizedBox(width: 20),
                                CustomActivity(
                                  baseUrl: ApiConstants.baseUrl,
                                  userId: (vehicle.vehicle?.userId ?? ""),
                                  icon: AssetsConstant.callPhoneSVG,
                                  type: 'PHONE',
                                  phone:
                                      vehicle.profile?.businessMobileNumber ??
                                          "",
                                  activityType: ActivityType.PHONE,
                                  userType:
                                      getMyType(vehicle.partnerType ?? ''),
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
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(16),
                        bottomRight: Radius.circular(16)),
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
                        child: (vehicle.profile?.profilePhoto ?? "").isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  vehicle.profile!.profilePhoto!,
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
                                    "${vehicle.profile?.firstName} ${vehicle.profile?.lastName}",
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black87,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
/*
                                if (vehicle.profile?.isVerifiedByAdmin) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.verified,
                                    size: 12,
                                    color: Colors.green,
                                  ),
                                ],
*/
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
/*
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 14, vertical: 2),
                            decoration: BoxDecoration(
                              color: gradientFirst.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: AppColors.blue,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              '${1.padLeft(2, '0')}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
*/
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> deleteFavourires(String vehicleId) async {
    try {
      final res =
          await _vehicleService.deleteFavourites(vehicleId).then((_) {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('failed to delete from favourites')),
      );
    }
  }

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

  void _navigateToVehicleDetail(fm.Data owner) async {
    print("tappeddddddd");
    bool success = await logUserActivity(
      id: owner.vehicle!.userId!,
      activity: ActivityType.CLICK,
      type: getMyType("Transporter"),
      baseUrl: ApiConstants.baseUrl,
    );

    if (success) {
      print("clicked Success 💘💘💘💘💘💘💘💘💘💘");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to log activity")),
      );
    }
    final currentIndex = _currentVehicleIndex[owner.vehicle!.userId] ?? 0;
    final serviceLocation = owner.vehicle!.serviceLocation != null
        ? owner.vehicle!.serviceLocation
        : null;
    if (owner.vehicle != null) {
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => VehicleDetailScreenTransPorter(
      //         owner: owner,
      //         vehicle: owner!.vehicle!,
      //         type: widget.selectedCategory,
      //         serviceLocation:serviceLocation!
      //     ),
      //   ),
      // );
    }
  }
}
