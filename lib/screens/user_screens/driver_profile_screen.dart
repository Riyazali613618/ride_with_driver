import 'dart:math' as math;

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:r_w_r/api/api_model/rating_reviews_model.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/screens/user_screens/rating_and_reviews.dart';
import 'package:video_player/video_player.dart';

import '../../api/api_model/transporter_model/transpoter_details_model.dart';
import '../../api/api_model/vehciles_single_model/DriverDetailsModel.dart';
import '../../api/api_service/transporter_details_service/transporter_details_service.dart';
import '../../components/app_appbar.dart';
import '../../components/app_button.dart';
import '../../components/app_loader.dart';
import '../../components/custom_activity.dart';
import '../../constants/api_constants.dart';
import '../../constants/assets_constant.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';
import '../../utils/common_utils.dart';
import '../common_screens/reviews_screen.dart';

class DriverProfileScreen extends StatefulWidget {
  final String transporterId;

  const DriverProfileScreen({
    super.key,
    required this.transporterId,
  });

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen>
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
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: localizations.details,
      ),
      body: CommonParentContainer(
        showLargeGradient: false,
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
    final localizations = AppLocalizations.of(context)!;
    final transporter = _transporterDetails!.provider;

    return RefreshIndicator(
      onRefresh: _loadTransporterDetails,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTransporterHeader(),
            _buildContactInfo(),
            if (_transporterDetails!.provider!.bio!.isNotEmpty)
              _buildAboutSection(),
            Row(
              children: [
                Padding(
                  padding:
                      EdgeInsets.only(left: 16, right: 5, top: 10, bottom: 10),
                  child: Text(
                      "Reviews (${transporter?.reviewsTotal ?? 0})",
                    style: TextStyle(
                      fontFamily: AppConstants.ptSansFont,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: List.generate(
                    4,
                    (_) =>
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                  ),
                ),
                Spacer(),
                if (!_hasReviewed)
                  GestureDetector(
                    onTap: () {
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
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: BoxBorder.all(color: AppColors.blue),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          SvgPicture.asset("assets/svg/write_review.svg"),
                          const SizedBox(
                            width: 5,
                          ),
                          Text(
                            "Write a Review",
                            style: TextStyle(
                              fontFamily: AppConstants.ptSansFont,
                              fontSize: 11,
                              color: AppColors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                  )
              ],
            ),
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
            valueColor:
                AlwaysStoppedAnimation<Color>(ColorConstants.primaryColor),
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

    return SizedBox(
      height: 200, // cover(140) + avatar overflow
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Image.network(
            "https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=800",
            height: 120,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            left: 20,
            bottom: 25, // ✅ no negative offset
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage(
                        transporter?.profilePhoto ??
                            "https://images.unsplash.com/photo-1449965408869-eaa3f722e40d?w=800",
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.bottomRight,
            margin: EdgeInsets.only(left: 110, bottom: 0, right: 10),
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Row(
                children: [
                  Text(
                    "${transporter?.firstName} ${transporter?.lastName}",
                    style: CommonUtils.commonTitleStyle(
                        fontSize: 16, color: Colors.black),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  if (transporter?.isVerifiedByAdmin ?? false)
                    const Icon(
                      Icons.verified,
                      size: 12,
                      color: Colors.green,
                    ),
                  Spacer(),
                  Container(
                    alignment: Alignment.centerRight,
                    height: 25,
                    padding: const EdgeInsets.symmetric(horizontal: 6),
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
                          color: Color(0xFFFFC633),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          transporter != null &&
                                  transporter.rating != null &&
                                  (transporter.rating ?? 0) > 0
                              ? transporter.rating!.toStringAsFixed(1)
                              : '4.3',
                          style: CommonUtils.commonTitleStyle(
                              fontSize: 12,
                              color: Color(0xFFF38B0F),
                              weight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                color: Colors.transparent,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomActivity(
                          baseUrl: ApiConstants.baseUrl,
                          userId: transporter?.userId ?? "",
                          icon: AssetsConstant.chatSVG,
                          type: 'CHAT',
                          userName: transporter?.firstName ?? "",
                          userImage: transporter?.profilePhoto ?? "",
                          phone: transporter?.businessMobileNumber ?? "",
                          activityType: ActivityType.WHATSAPP,
                          userType: getMyType(
                              (transporter?.vehicles?.length ?? 0) > 1
                                  ? "Transporter"
                                  : transporter!.vehicles!.isNotEmpty
                                      ? transporter
                                              .vehicles!.first.vehicleType ??
                                          ""
                                      : "Unknown"),
                        ),
                        CustomActivity(
                          baseUrl: ApiConstants.baseUrl,
                          userId: transporter?.userId ?? "",
                          icon: AssetsConstant.whatsAppSVG,
                          type: 'WHATSAPP',
                          phone: transporter?.businessMobileNumber ?? "",
                          activityType: ActivityType.WHATSAPP,
                          userType: getMyType(
                              (transporter?.vehicles?.length ?? 0) > 1 &&
                                      transporter!.vehicles!.isNotEmpty
                                  ? "Transporter"
                                  : transporter!.vehicles!.isNotEmpty
                                      ? transporter!
                                              .vehicles!.first.vehicleType ??
                                          ""
                                      : "Unknown"),
                        ),
                        CustomActivity(
                          baseUrl: ApiConstants.baseUrl,
                          userId: transporter.userId ?? "",
                          icon: AssetsConstant.callPhoneSVG,
                          type: 'PHONE',
                          phone: transporter?.businessMobileNumber ?? "",
                          activityType: ActivityType.PHONE,
                          userType: getMyType(
                              (transporter.vehicles!.length ?? 0) > 1
                                  ? "Transporter"
                                  : transporter.vehicles!.isNotEmpty
                                      ? transporter
                                              .vehicles!.first!.vehicleType ??
                                          ""
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
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: gradientSecond,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            "👉 Send Request",
                            style: CommonUtils.commonTitleStyle(
                                fontSize: 10,
                                weight: FontWeight.w400,
                                color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          )
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
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
              topLeft: Radius.circular(0),
              topRight: Radius.circular(0),
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

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.phone_outlined,
                      size: 20,
                    ),
                  )),
              Expanded(
                  flex: 4,
                  child: Text(
                    transporter?.businessMobileNumber ?? "",
                    style: CommonUtils.commonTitleStyle(fontSize: 12),
                  )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 20,
                    ),
                  )),
              Expanded(
                  flex: 4,
                  child: Text(
                    transporter?.address?.addressLine ?? "",
                    style: CommonUtils.commonTitleStyle(fontSize: 12),
                  )),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Minimum Charge',
                      style: CommonUtils.commonTextLabelsStyle(fontSize: 12),
                    ),
                  )),
              Expanded(
                flex: 4,
                child: Text(
                  '₹ ${transporter?.minimumCharges ?? 0}/hour',
                  style: CommonUtils.commonTitleStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Experience',
                      style: CommonUtils.commonTextLabelsStyle(fontSize: 12),
                    ),
                  )),
              Expanded(
                flex: 4,
                child: Text(
                  '₹ ${transporter?.experience ?? 0}',
                  style: CommonUtils.commonTitleStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(top: 4),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Spoken Languages',
                      style: CommonUtils.commonTextLabelsStyle(fontSize: 12),
                    ),
                  )),
              Expanded(
                flex: 4,
                child: Wrap(
                  spacing: 4,
                  runSpacing: 0,
                  alignment: WrapAlignment.start,
                  children: (transporter?.languageSpoken ?? []).map((item) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 2, horizontal: 2),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0x1F641BB4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF641BB4).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item,
                            style: const TextStyle(
                              color: Color(0xFF9C27B0),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 4),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.only(top: 4),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Service Location',
                      style: CommonUtils.commonTextLabelsStyle(fontSize: 12),
                    ),
                  )),
              Expanded(
                flex: 4,
                child: Container(
                  width: 50,
                  margin:
                      const EdgeInsets.symmetric(vertical: 2, horizontal: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  /* decoration: BoxDecoration(
                      color: const Color(0x1F641BB4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF641BB4).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "",
                          style: const TextStyle(
                            color: Color(0xFF9C27B0),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                      ],
                    ),*/
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );

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
        border: Border.all(color: AppColors.blue),
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
            style: TextStyle(
              fontSize: 14,
              fontFamily: AppConstants.ptSansFont,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            transporter!.bio!,
            style: TextStyle(
              fontSize: 12,
              fontFamily: AppConstants.ptSansFont,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  int currentSlideIndex = 0;

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
          if (vehicle.images!.isNotEmpty &&
              vehicle.images!.any((img) => img.isNotEmpty))
            Stack(alignment: Alignment.center, children: [
              ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  child: SizedBox(
                    height: 140, // 👈 REQUIRED
                    child: PageView.builder(
                      scrollDirection: Axis.horizontal,
                      onPageChanged: (index) {
                        setState(() {
                          currentSlideIndex = index;
                        });
                      },
                      itemCount: vehicle.images?.length ?? 0,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {},
                          child: CachedNetworkImage(
                            imageUrl: vehicle.images![index],
                            height: 140,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.grey[300],
                              height: 180,
                              child: const Icon(Icons.directions_car, size: 60),
                            ),
                          ),
                        );
                      },
                    ),
                  )),
              if ((vehicle.images ?? []).length > 1)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentSlideIndex != 0) {
                          currentSlideIndex--;
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 4),
                        margin: EdgeInsets.only(left: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (currentSlideIndex < vehicle.images!.length - 1) {
                          currentSlideIndex++;
                          setState(() {});
                        }
                      },
                      child: Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(left: 4),
                        margin: EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.all(Radius.circular(30))),
                        child: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              Positioned(
                  top: 0,
                  right: 10,
                  child: Text(
                    "${currentSlideIndex + 1}/${vehicle.images!.length}",
                    style: CommonUtils.commonTitleStyle(
                        color: Colors.white,
                        fontSize: 12,
                        weight: FontWeight.w400),
                  ))
            ]),

          // Vehicle Info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      vehicle!.vehicleName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      vehicle.vehicleType!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Row(
                      children: [
                        Text(
                          'Minimum Charge',
                          style:
                              CommonUtils.commonTextLabelsStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          '₹ ${vehicle.minimumChargePerHour ?? "0.0"}',
                          style: CommonUtils.commonTitleStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                    // Negotiable Badge
                    if (vehicle.isPriceNegotiable == true)
                      Flexible(
                          child: Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        child: Text(
                          (vehicle.isPriceNegotiable == true)
                              ? localizations.negotiable
                              : localizations.fixedPrice,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CommonUtils.commonTitleStyle(
                              fontSize: 12,
                              color: Color(0xFF1FAF38),
                              weight: FontWeight.w400),
                        ),
                      )),
                    const SizedBox(width: 10),
                  ],
                ),
                const SizedBox(height: 12),
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
                          '${vehicle?.seatingCapacity ?? 'N/A'} Seats',
                          style:
                              CommonUtils.commonTextLabelsStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    if (vehicle?.airConditioning != null &&
                        vehicle!.airConditioning!.isNotEmpty)
                      _buildFeatureTag(
                        icon: "",
                        text: vehicle.airConditioning ?? "",
                      ),
                    Spacer(),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
/*
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    width: 100,
                    height: 24,
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
                          onTap: () {},
                          borderRadius: BorderRadius.circular(30),
                          child: Center(
                            child: Text(
                              "View More",
                              style: TextStyle(
                                fontFamily: AppConstants.ptSansFont,
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
*/
              ],
            ),
          ),
        ],
      ),
    );
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
            style: CommonUtils.commonTextLabelsStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        /* if (!_hasReviewed) ...[
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
        ],*/
      ],
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
            Icon(Icons.directions_car_outlined,
                size: 60, color: Colors.grey[400]),
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

class ReviewCard extends StatelessWidget {
  final Review review;

  const ReviewCard({required this.review, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 1,
          color: AppColors.blue,
        ),
        color: Colors.white.withOpacity(0.95),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// STARS
          Row(
            children: List.generate(
              4,
              (_) => const Icon(Icons.star, color: Colors.amber, size: 18),
            ),
          ),

          const SizedBox(height: 12),

          /// NAME
          Text(
            review.userName,
            style: TextStyle(
              fontFamily: AppConstants.ptSansFont,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),

          const SizedBox(height: 8),

          /// REVIEW TEXT
          Text(
            review.review,
            style: TextStyle(
              fontFamily: AppConstants.ptSansFont,
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: Color(0x99000000),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          /// DATE
          const Text(
            "Posted on August 15, 2023",
            style: TextStyle(
              fontFamily: AppConstants.ptSansFont,
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0x99000000),
            ),
          ),
        ],
      ),
    );
  }
}
