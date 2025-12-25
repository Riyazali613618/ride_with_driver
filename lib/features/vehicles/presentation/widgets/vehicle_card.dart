import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../components/app_loader.dart';
import '../../../../constants/color_constants.dart';
import '../../../../utils/color.dart';
import '../../domain/entities/vehicle_entity.dart';
import '../pages/add_vehicle_screen.dart';

class VehicleCard extends StatefulWidget {
  final VehicleEntity vehicle;

  const VehicleCard({super.key, required this.vehicle});

  @override
  State<VehicleCard> createState() => _VehicleCardState();
}

class _VehicleCardState extends State<VehicleCard> {
  CarouselSliderController carouselController = CarouselSliderController();
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 140,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                CarouselSlider(
                  carouselController: carouselController,
                  items: widget.vehicle.images.map((img) {
                    return ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: CachedNetworkImage(
                        imageUrl: img,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    );
                  }).toList(),
                  options: CarouselOptions(height: 140, viewportFraction: 1),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    "${currentIndex + 1}/${widget.vehicle.images.length}",
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: Colors.white),
                  ),
                ),
                if (widget.vehicle.images.length > 1) ...[
                  Positioned(
                    left: 8,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () {
                          if (currentIndex != 0) {
                            carouselController.previousPage();
                            currentIndex--;
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
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
                        onTap: () {
                          if (currentIndex < widget.vehicle.images.length - 1) {
                            carouselController.nextPage();
                            currentIndex++;
                            setState(() {});
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
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
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      widget.vehicle.vehicleName ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(width: 10),
                    Container(
                      margin: EdgeInsets.only(top: 3),
                      child: Text(
                        widget.vehicle.vehicleType,
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorConstants.black2,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Spacer(),
                    InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => AddNewVehicleScreen(userType: widget.vehicle.vehicleType??"",vehicle: widget.vehicle,)));
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                              onPressed: () {},
                              child: SvgPicture.asset(
                                  "assets/svg/edit_vehicle.svg")),
                          const SizedBox(width: 2),
                          Container(
                            padding:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [Color(0xFF6A11CB), Color(0xFFFF758C)],
                              ),
                            ),
                            child: Text(
                              "Manage Vehicle",
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFeatureTag(
                      icon: "assets/img/seats.png",
                      text: '${widget.vehicle.seatingCapacity ?? 'N/A'} Seats',
                    ),
                    _buildFeatureTag(
                      icon: "assets/img/seats.png",
                      text: '${widget.vehicle.airConditioning}',
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildFeatureTag(
                      icon: "assets/img/seats.png",
                      text: '${widget.vehicle.airConditioning}',
                    ),
                    if (widget.vehicle.isNegotiable)
                      _buildFeatureTag(
                        icon: "",
                        color: gradientSecond,
                        text: 'Negotiable',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    Text('Minimum Charge',
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 10)),
                    Text('₹ ${widget.vehicle.minimumCharge}/hour',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: [
                    Text('Vehicle No:',
                        style: const TextStyle(
                            fontWeight: FontWeight.w400, fontSize: 11)),
                    Text('${widget.vehicle.vehicleNumber}',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 11)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildVehicleCard(VehicleEntity owner) {
    return Container(
      height: 280,
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
                  child: CarouselSlider(
                    items: widget.vehicle.images.map((img) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20)),
                        child: CachedNetworkImage(
                          imageUrl: img,
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    }).toList(),
                    options: CarouselOptions(height: 180, viewportFraction: 1),
                  ),
                ),
              ),
              // Image Counter Badge (Top Right)
              if (owner.images.length > 1)
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
                      '${1}/${owner.images.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              // Navigation Arrows
              if (owner.images.length > 1) ...[
                Positioned(
                  left: 8,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
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
                      onTap: () {},
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
            child: Padding(
              padding: const EdgeInsets.only(left: 12, right: 12, top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Name and Rating
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          widget.vehicle.vehicleName,
                          style: TextStyle(
                            fontSize: (widget.vehicle.vehicleName.isNotEmpty)
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
                        widget.vehicle.vehicleType ?? '',
                        style: TextStyle(
                          fontSize: 12,
                          color: ColorConstants.black2,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.vehicle.vehicleName.isNotEmpty)
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
                        text:
                            '${widget.vehicle?.seatingCapacity ?? 'N/A'} Seats',
                      ),
                      const SizedBox(width: 8),
                      if (widget.vehicle?.airConditioning != null &&
                          widget.vehicle!.airConditioning.isNotEmpty)
                        _buildFeatureTag(
                          icon: "",
                          text: widget.vehicle.airConditioning,
                        ),
                      Spacer(),
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
                            '₹ ${widget.vehicle.minimumCharge}',
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
                      if (widget.vehicle.isNegotiable)
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
                            "Negotiable",
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureTag(
      {required String icon, Color? color, required String text}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: color ?? gradientFirst.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color ?? AppColors.blue,
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
              color: color != null ? Colors.white : Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }
}
