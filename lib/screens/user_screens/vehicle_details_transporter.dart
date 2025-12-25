import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_model/vehicle/search_vehicles.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/screens/user_screens/transporter_details_screen.dart';
import 'package:r_w_r/screens/widgets/gradient_button.dart';
import 'package:r_w_r/utils/color.dart';
import 'package:video_player/video_player.dart';
import 'package:http/http.dart' as http;
import '../../components/app_loader.dart';
import '../../components/custom_activity.dart';
import '../../constants/api_constants.dart';
import '../../constants/assets_constant.dart';
import '../../constants/token_manager.dart';
import '../../l10n/app_localizations.dart';
import '../block/provider/profile_provider.dart';

class VehicleDetailScreenTransPorter extends StatefulWidget {
  final String type;
  final VehicleOwner owner;
  final Vehicle vehicle;
  final Location serviceLocation;

  const VehicleDetailScreenTransPorter({
    super.key,
    required this.owner,
    required this.vehicle,
    required this.type,
    required this.serviceLocation,
  });

  @override
  State<VehicleDetailScreenTransPorter> createState() =>
      _VehicleDetailScreenTransPorterState();
}

class _VehicleDetailScreenTransPorterState
    extends State<VehicleDetailScreenTransPorter>
    with TickerProviderStateMixin {
  late PageController _mediaPageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late VideoPlayerController _controller;

  int _currentMediaIndex = 0;
  List<String> _allMedia = [];

  @override
  void initState() {
    super.initState();
    _initializeMedia();

    _mediaPageController = PageController();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _controller = VideoPlayerController.network(
      'https://example.com/your-video.mp4',
    )
      ..initialize().then((_) {
        setState(() {});
      });

    _animationController.forward();
  }

  Future<void> _verifyReview(String reviewDone, bool status) async {
    try {
      final profileProvider =
      Provider.of<ProfileProvider>(context, listen: false);
      final userId = profileProvider.userId;
      final token = await TokenManager.getToken();

      final submitResponse = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/user/communication'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId ?? '',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          "driverId": widget.vehicle.id ?? "",
          "communicationType": reviewDone,
          "status": status
        }),
      );

      if (submitResponse.statusCode == 200) {
        final submitData = json.decode(submitResponse.body);
        if (submitData['status'] == true) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      print('Error verifying communication: $e');
    }
  }

  void _initializeMedia() {
    _allMedia = [
      ...widget.vehicle.images,
      ...widget.vehicle.videos,
    ];

    if (_allMedia.isEmpty) {
      _allMedia = ['placeholder'];
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _mediaPageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _showFullScreenMedia(int index) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            _FullScreenMediaViewer(
              mediaList: _allMedia,
              initialIndex: index,
              isVideo: (url) => widget.vehicle.videos.contains(url),
            ),
      ),
    );
  }

  String getLocalizedVehicleType(String type, AppLocalizations loc) {
    switch (type.toLowerCase()) {
      case 'car':
        return loc.car;
      case 'suv':
        return loc.suv;
      case 'auto':
      case 'auto rickshaw':
        return loc.auto;
      case 'minivan':
        return loc.minivan;
      case 'bus':
        return loc.bus;
      case 'e_rickshaw':
      case 'e-rickshaw':
      case 'erickshaw':
        return loc.eRickshaw;
      case 'driver':
        return loc.driver;
      case 'transporter':
        return loc.transporter;
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          getLocalizedVehicleType(widget.vehicle.vehicleName, localizations),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
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
              Colors.white,
              Colors.white,
              Colors.white,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMediaSection(),
                  _buildVehicleInfoCard(localizations),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      width: MediaQuery
          .of(context)
          .size
          .width,
      height: 180,
      decoration: BoxDecoration(boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ], borderRadius: BorderRadius.circular(8)),
      child: Stack(
        children: [
          PageView.builder(
            controller: _mediaPageController,
            itemCount: _allMedia.length,
            onPageChanged: (index) {
              setState(() {
                _currentMediaIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final mediaUrl = _allMedia[index];
              final isVideo = widget.vehicle.videos.contains(mediaUrl);

              return GestureDetector(
                onTap: () => _showFullScreenMedia(index),
                child: Container(
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ], borderRadius: BorderRadius.circular(8)),
                  child: mediaUrl == 'placeholder'
                      ? _buildPlaceholderImage()
                      : Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(
                          mediaUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholderImage(),
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  ColorConstants.primaryColor,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      if (isVideo)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Navigation arrows
          if (_allMedia.length > 1) ...[
            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (_currentMediaIndex > 0) {
                      _mediaPageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    if (_currentMediaIndex < _allMedia.length - 1) {
                      _mediaPageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],

          // Image counter
          if (_allMedia.length > 1)
            Positioned(
              top: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Color(0x42000000),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_currentMediaIndex + 1}/${_allMedia.length}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVehicleInfoCard(AppLocalizations localizations) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Vehicle Type and Contact Icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  localizations.vehicle_type ?? 'Vehicle Type',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          maxLines: 2,
                          getLocalizedVehicleType(
                              widget.vehicle.vehicleType, localizations),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Spacer(),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          CustomActivity(
                            baseUrl: ApiConstants.baseUrl,
                            userId: widget.owner.userId,
                            icon: AssetsConstant.chatSVG,
                            type: 'CHAT',
                            phone: widget.owner.businessMobileNumber,
                            activityType: ActivityType.CHAT,
                            userType: getMyType(widget.owner.vehicles.length > 1
                                ? "Transporter"
                                : widget.owner.vehicles
                                .elementAt(0)
                                .vehicleType),
                            onBeforeTap: () => _verifyReview('CHAT', true),
                          ),
                          const SizedBox(width: 12),
                          CustomActivity(
                            baseUrl: ApiConstants.baseUrl,
                            userId: widget.owner.userId,
                            icon: AssetsConstant.whatsAppSVG,
                            type: 'WHATSAPP',
                            phone: widget.owner.businessMobileNumber,
                            activityType: ActivityType.WHATSAPP,
                            userType: getMyType(widget.owner.vehicles.length > 1
                                ? "Transporter"
                                : widget.owner.vehicles
                                .elementAt(0)
                                .vehicleType),
                            onBeforeTap: () => _verifyReview('WHATSAPP', true),
                          ),
                          const SizedBox(width: 12),
                          CustomActivity(
                            baseUrl: ApiConstants.baseUrl,
                            userId: widget.owner.userId,
                            icon: AssetsConstant.callPhoneSVG,
                            type: 'PHONE',
                            phone: widget.owner.businessMobileNumber,
                            activityType: ActivityType.PHONE,
                            userType: getMyType(widget.owner.vehicles.length > 1
                                ? "Transporter"
                                : widget.owner.vehicles
                                .elementAt(0)
                                .vehicleType),
                            onBeforeTap: () => _verifyReview('PHONE', true),
                          ),
                        ],
                      )
                    ],
                  ))
            ],
          ),
          SizedBox(
            height: 20,
          ),
          // Vehicle Name
          _buildInfoRow(
            localizations.vehicle_name ?? 'Vehicle Name',
            widget.vehicle.vehicleName,
          ),

          const SizedBox(height: 16),

          // Vehicle Number
          _buildInfoRow(
            localizations.vehicleNumber ?? 'Vehicle Number',
            widget.vehicle.vehicleNumber,
          ),

          const SizedBox(height: 16),

          // Seating and AC
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset("assets/img/seats.png", width: 14, height: 14),
                    const SizedBox(width: 4),
                    Text(
                      "Seats",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: _buildFeatureTag(
                    icon: "",
                    text: widget.vehicle.airConditioning.isNotEmpty
                        ? widget.vehicle.airConditioning
                        : localizations.not_specified ?? 'Not Specified'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Service Locations
          ...[
            Text(
              localizations.service_areas ?? 'Service Locations',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            // Wrap(
            //   spacing: 8,
            //   runSpacing: 8,
            //   children: widget.serviceLocation.map((location) {
            //     return Container(
            //       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            //       decoration: BoxDecoration(
            //         color: ColorConstants.primaryColor.withOpacity(0.1),
            //         borderRadius: BorderRadius.circular(20),
            //         border: Border.all(
            //           color: ColorConstants.primaryColor.withOpacity(0.3),
            //         ),
            //       ),
            //       child: Text(
            //         location,
            //         style: TextStyle(
            //           fontSize: 12,
            //           fontWeight: FontWeight.w500,
            //           color: ColorConstants.primaryColor,
            //         ),
            //       ),
            //     );
            //   }).toList(),
            // ),
            const SizedBox(height: 16),
          ],

          // Minimum Charge and Negotiable
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  localizations.min_charge ?? 'Minimum Charge',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              Expanded(
                  flex: 3,
                  child: Row(
                    children: [
                      Text(
                        '₹ ${widget.vehicle.minimumChargePerHour}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.black,
                        ),
                      ),
                      Spacer(),
                      Container(
                        padding:
                        EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: gradientSecond,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.blue,
                            width: 0.5,
                          ),
                        ),
                        child: Text(
                          (widget.vehicle.isPriceNegotiable == true ||
                              widget.owner.negotiable)
                              ? localizations.negotiable
                              : localizations.fixedPrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 50,
                      )
                    ],
                  ))
            ],
          ),
          SizedBox(
            height: 20,
          ),

          // Vehicle Specifications
          if (widget.vehicle.vehicleSpecifications.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    localizations.vehicle_specifications ??
                        'Vehicle Specification',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.vehicle.vehicleSpecifications.map((spec) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: gradientFirst.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: gradientFirst.withOpacity(0.1)!),
                        ),
                        child: Text(
                          spec,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          const SizedBox(
            height: 20,
          ),
          // Owner Section
          Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: widget.owner.profilePhoto.isNotEmpty
                        ? NetworkImage(widget.owner.profilePhoto)
                        : null,
                    child: widget.owner.profilePhoto.isEmpty
                        ? const Icon(Icons.person, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                "${widget.owner.firstName} ${widget.owner
                                    .lastName},\n${widget.owner.companyName}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (widget.owner.isVerifiedByAdmin) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.green,
                              ),

                            ],
                            const SizedBox(width: 6),
                            Text(
                              'Vehicles Owned',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w400
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 0,
                              ),
                              decoration: BoxDecoration(
                                color: ColorConstants.primaryColor.withOpacity(
                                    0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  width: 0.5,
                                  color: ColorConstants.primaryColor
                                      .withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '${widget.owner.vehicles.length}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: ColorConstants.primaryColor,
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
              const SizedBox(height: 16),
              SizedBox(
                width: 150,
                height: 40,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    // Apply gradient only when enabled
                    gradient: LinearGradient(
                      colors: [gradientFirst, gradientSecond],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    // Fallback to a solid grey color when disabled
                  ),
                  // Use Material/InkWell to handle taps and ripple effect over the gradient
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (context) => TransporterDetailsScreen(
                              transporterId: widget.owner.userId,
                            ),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Center(
                        child: Text(
                          "View Profile",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              localizations.image_not_available,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTag({required String icon, required String text}) {
    return Row(
      children: [
        Container(
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
        ),
        Spacer()
      ],
    );
  }
}

// Full screen media viewer
class _FullScreenMediaViewer extends StatefulWidget {
  final List<String> mediaList;
  final int initialIndex;
  final bool Function(String) isVideo;

  const _FullScreenMediaViewer({
    required this.mediaList,
    required this.initialIndex,
    required this.isVideo,
  });

  @override
  State<_FullScreenMediaViewer> createState() => _FullScreenMediaViewerState();
}

class _FullScreenMediaViewerState extends State<_FullScreenMediaViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          '${_currentIndex + 1} of ${widget.mediaList.length}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.black87,
              Colors.black54,
              Colors.black87,
            ],
          ),
        ),
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.mediaList.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            final mediaUrl = widget.mediaList[index];
            if (mediaUrl == 'placeholder') {
              return Center(
                child: Icon(
                  Icons.broken_image,
                  size: 100,
                  color: Colors.grey[600],
                ),
              );
            }
            return Center(
              child: InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4.0,
                child: Image.network(
                  mediaUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(
                        Icons.broken_image,
                        size: 100,
                        color: Colors.grey[600],
                      ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorConstants.primaryColor,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
