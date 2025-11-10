import 'package:flutter/material.dart';
import 'package:r_w_r/screens/user_screens/vehicle_details_transporter.dart';

import '../api/api_service/vehicle/search_vehicle_service.dart';
import '../components/custom_activity.dart';
import '../constants/api_constants.dart';
import '../constants/assets_constant.dart';
import '../l10n/app_localizations.dart';
import '../utils/color.dart';
import '../../api/api_model/favouriteModel.dart' as fm;

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

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
  final VehicleService _vehicleService=VehicleService();
  List<fm.Data> favData=[];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getFavourites();

  }
  bool getFavs=false;
  Future<void> getFavourites() async {
    setState(() {
      getFavs=true;
    });
    try {
      favData = await _vehicleService.getFavourites();
      setState(() {
        getFavs = false;
      });
    }catch(e){
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
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
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
              (!getFavs)?
              Expanded(
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
              ):Center(child: CircularProgressIndicator(),),
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
        childAspectRatio: 0.75, // Adjusted for new card height
        crossAxisSpacing: 0.5,
        mainAxisSpacing: 0.5,
      ),
      itemCount: favData.length,
      itemBuilder: (context, index) {
        return _buildVehicleCard(favData[index]!);
      },
    );
  }
  Widget _buildVehicleImage(fm.Vehicle? vehicle) {
    if (vehicle == null || vehicle.images!.isEmpty) {
      return Icon(
        Icons.directions_car,
        size: 40,
        color: Colors.grey[600],
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        vehicle.images!.first,
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
    final currentIndex = _currentVehicleIndex[vehicle.vehicle!.userId] ?? 0;
    return Container(
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
            ],
          ),

          // Content Section
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Name and Rating
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vehicle.vehicle?.vehicleName ?? localizations.no_vehicles_found,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vehicle.vehicle?.vehicleName ?? '',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    // Rating Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.amber[50],
                        borderRadius: BorderRadius.circular(8),
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
                            vehicle.profile!.rating! > 0 ? vehicle.profile!.rating!.toStringAsFixed(1) : '4.3',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
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
                      children: [
                        _buildFeatureTag(
                          icon: Icons.person_outline,
                          text: '${vehicle.vehicle?.seatingCapacity ?? 'N/A'} Seats',
                        ),
                        const SizedBox(width: 8),
                        if (vehicle.vehicle?.airConditioning != null && vehicle.vehicle!.airConditioning!.isNotEmpty)
                          _buildFeatureTag(
                            icon: Icons.ac_unit_outlined,
                            text: vehicle.vehicle!.airConditioning!,
                          ),
                      ],
                    ),
                    // GestureDetector(
                    //   onTap: () async {
                    //     if(favoriteStates.containsKey(vehicle!.id)){
                    //       await deleteFavourires(vehicle!.id);
                    //       setState(() {
                    //         favoriteStates[vehicle.id] = false;
                    //       });
                    //     }else{
                    //       await addToFav(vehicle!.userId,vehicle.id);
                    //       setState(() {
                    //         favoriteStates[vehicle.id] = !(favoriteStates[vehicle.id] ?? false);
                    //       });
                    //     }
                    //   },
                    //   child:(favAdded || deletFav)?Center(child: CircularProgressIndicator(),):Icon(
                    //     (favoriteStates[vehicle!.id] ?? false) ? Icons.favorite : Icons.favorite_border,
                    //     color: (favoriteStates[vehicle.id] ?? false) ? Colors.red : Colors.grey[400],
                    //     size: 22,
                    //   ),
                    // ),
                  ],
                ),

                const SizedBox(height: 12),
                // Price and Negotiable Badge
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Minimum Charge',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹ ${vehicle.vehicle?.minimumChargePerHour ?? vehicle.vehicle!.minimumChargePerHour}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Negotiable Badge
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: (vehicle.vehicle?.isPriceNegotiable == true)
                                ? Colors.green
                                : Colors.orange,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            (vehicle?.vehicle!.isPriceNegotiable == true)
                                ? localizations.negotiable
                                : localizations.fixedPrice,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                      ],
                    ),
                  ],
                ),
                // Action Buttons and Favorite Icon Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        CustomActivity(
                          baseUrl: ApiConstants.baseUrl,
                          userId: vehicle.vehicle!.userId!,
                          icon: AssetsConstant.whatsApp,
                          type: 'WHATSAPP',
                          phone: vehicle!.profile!.businessMobileNumber!,
                          activityType: ActivityType.WHATSAPP,
                          userType: getMyType("Transporter"),
                        ),
                        const SizedBox(width: 3),

                        CustomActivity(
                          baseUrl: ApiConstants.baseUrl,
                          userId:  vehicle.vehicle!.userId!,
                          icon: AssetsConstant.callPhone,
                          type: 'PHONE',
                          phone:vehicle!.profile!.businessMobileNumber!,
                          activityType: ActivityType.PHONE,
                          userType: getMyType("Transporter"),
                        ),


                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: InkWell(
                        onTap: (){
                          _navigateToVehicleDetail(vehicle);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: Color(0xFF8B5CF6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'View More',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Owner Info Section (Moved Below View More)
                Row(
                  children: [
                    // Profile Picture
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: vehicle.profile!.profilePhoto!.isNotEmpty
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
                    const SizedBox(width: 8),

                    // Owner Name and Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  "${vehicle.profile!.firstName} ${vehicle.profile!.lastName}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (vehicle!.vehicle!.isVerifiedByAdmin!) ...[
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.verified,
                                  size: 14,
                                  color: Colors.green,
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Vehicle Count Badge
                    Row(
                      children: [
                        Text(
                          'Vehicles Owned',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black,
                          ),
                        ),
                        SizedBox(width: 10,),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        //   decoration: BoxDecoration(
                        //     color: Colors.grey[100],
                        //     borderRadius: BorderRadius.circular(12),
                        //     border: Border.all(
                        //       color: Colors.grey[300]!,
                        //       width: 1,
                        //     ),
                        //   ),
                        //   child: Text(
                        //     '${vehicle.profile.vehicles.length.toString().padLeft(2, '0')}',
                        //     style: const TextStyle(
                        //       fontSize: 12,
                        //       fontWeight: FontWeight.bold,
                        //       color: Colors.black87,
                        //     ),
                        //   ),
                        // ),
                      ],
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
  Widget _buildFeatureTag({required IconData icon, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color:gradientFirst.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
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
    final serviceLocation=owner.vehicle!.serviceLocation!=null?owner.vehicle!.serviceLocation:null;
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