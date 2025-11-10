// lib/screens/rickshaw_profile_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../../api/api_model/erikshaw_rikshaw_model.dart';
import '../../api/api_service/erikshaw_rikshaw_service.dart';

enum RickshawErrorType {
  networkError,
  parseError,
  unknown,
}

class RickshawException implements Exception {
  final String message;
  final RickshawErrorType type;

  RickshawException(this.message, this.type);

  @override
  String toString() => 'RickshawException: $message';
}

class RickshawProfileHeader extends StatelessWidget {
  final RickshawProfile profile;

  const RickshawProfileHeader({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConstants.primaryColor,
            ColorConstants.primaryColor,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          CupertinoNavigationBarBackButton(
            color: ColorConstants.white,
          ),
          Row(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 47,
                  backgroundImage: NetworkImage(profile.photo),
                  onBackgroundImageError: (_, __) {},
                  child: profile.photo.isEmpty
                      ? Icon(Icons.person,
                          size: 50, color: Colors.grey.shade600)
                      : null,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            profile.fullName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    if (profile.isVerifiedByAdmin)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified,
                              color: ColorConstants.primaryColor,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: ColorConstants.primaryColor,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      profile.phoneNumber,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        border: Border.all(
                            color: Colors.amber.shade200, width: 0.5),
                        borderRadius: BorderRadius.all(
                          (Radius.circular(8)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star,
                              size: 14.0, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            profile.rating > 0
                                ? profile.rating.toStringAsFixed(1)
                                : '4.9',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.amber.shade800,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RickshawInfoCard extends StatelessWidget {
  final String title;
  final Widget child;
  final IconData icon;

  const RickshawInfoCard({
    Key? key,
    required this.title,
    required this.child,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: ColorConstants.primaryColor.withAlpha(150),
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class RickshawDetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const RickshawDetailRow({
    Key? key,
    required this.label,
    required this.value,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 18,
              color: Colors.grey.shade600,
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RickshawChipList extends StatelessWidget {
  final List<String> items;
  final Color chipColor;

  const RickshawChipList({
    Key? key,
    required this.items,
    required this.chipColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: chipColor.withOpacity(0.3)),
          ),
          child: Text(
            item,
            style: TextStyle(
              color: chipColor,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }).toList(),
    );
  }
}

class RickshawProfileScreen extends StatefulWidget {
  final String userType;

  const RickshawProfileScreen({super.key, required this.userType});

  @override
  State<RickshawProfileScreen> createState() => _RickshawProfileScreenState();
}

class _RickshawProfileScreenState extends State<RickshawProfileScreen> {
  RickshawProfile? _profile;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response =
          await RickshawService.fetchRickshawProfile(widget.userType);

      if (response.status && response.data != null) {
        setState(() {
          _profile = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message.isNotEmpty
              ? response.message
              : 'Failed to load profile';
          _isLoading = false;
        });
      }
    } on RickshawException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unexpected error occurred';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorConstants.primaryColor),
              ),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : _profile != null
                  ? _buildProfileWidget()
                  : const Center(child: Text('No profile data available')),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage!,
              maxLines: 1,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProfile,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileWidget() {
    return SingleChildScrollView(
      child: Column(
        children: [
          RickshawProfileHeader(profile: _profile!),
          const SizedBox(height: 16),

          // Vehicle Information
          RickshawInfoCard(
            title: 'Vehicle Information',
            icon: Icons.directions_car,
            child: Column(
              children: [
                RickshawDetailRow(
                  label: 'Vehicle Name',
                  value: _profile!.vehicleName,
                  icon: Icons.local_taxi,
                ),
                RickshawDetailRow(
                  label: 'Vehicle Type',
                  value: _profile!.vehicleType,
                  icon: Icons.electric_rickshaw_outlined,
                ),
                RickshawDetailRow(
                  label: 'Model',
                  value: _profile!.vehicleModelName,
                  icon: Icons.info_outline,
                ),
                RickshawDetailRow(
                  label: 'Vehicle Number',
                  value: _profile!.vehicleNumber,
                  icon: Icons.confirmation_number,
                ),
                RickshawDetailRow(
                  label: 'Manufacturing Year ',
                  value: _profile!.manufacturing,
                  icon: Icons.calendar_today,
                ),
                RickshawDetailRow(
                  label: 'Fuel Type',
                  value: _profile!.fuelType,
                  icon: Icons.local_gas_station,
                ),
                RickshawDetailRow(
                  label: 'Seating Capacity',
                  value: '${_profile!.seatingCapacity} persons',
                  icon: Icons.airline_seat_recline_normal,
                ),
                RickshawDetailRow(
                  label: 'Air Conditioning',
                  value: _profile!.airConditioning,
                  icon: Icons.ac_unit,
                ),
                RickshawDetailRow(
                  label: 'Ownership',
                  value: _profile!.vehicleOwnership,
                  icon: Icons.key,
                ),
              ],
            ),
          ),

          // Pricing Information
          RickshawInfoCard(
            title: 'Pricing Information',
            icon: Icons.currency_rupee,
            child: Column(
              children: [
                RickshawDetailRow(
                  label: 'First 2 KM Charge',
                  value: '₹${_profile!.first2Km}',
                  icon: Icons.location_on,
                ),
                RickshawDetailRow(
                  label: 'Minimum Charge/Hour',
                  value: '₹${_profile!.minimumChargePerHour}',
                  icon: Icons.access_time,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.handshake,
                      size: 18,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Price Negotiable',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _profile!.isPriceNegotiable
                            ? ColorConstants.primaryColor.withAlpha(80)
                            : Colors.red.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _profile!.isPriceNegotiable ? 'Yes' : 'No',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _profile!.isPriceNegotiable
                              ? ColorConstants.primaryColor
                              : Colors.red.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Address Information
          RickshawInfoCard(
            title: 'Address Information',
            icon: Icons.location_city,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RickshawDetailRow(
                  label: 'Address',
                  value: _profile!.address.addressLine,
                  icon: Icons.home,
                ),
                RickshawDetailRow(
                  label: 'City',
                  value: _profile!.address.city,
                  icon: Icons.location_city,
                ),
                RickshawDetailRow(
                  label: 'State',
                  value: _profile!.address.state,
                  icon: Icons.map,
                ),
                RickshawDetailRow(
                  label: 'Pincode',
                  value: _profile!.address.pincode.toString(),
                  icon: Icons.markunread_mailbox,
                ),
                RickshawDetailRow(
                  label: 'Country',
                  value: _profile!.address.country,
                  icon: Icons.flag,
                ),
              ],
            ),
          ),

          // Service Areas
          if (_profile!.servedLocation.isNotEmpty)
            RickshawInfoCard(
              title: 'Service Areas',
              icon: Icons.map_outlined,
              child: RickshawChipList(
                items: _profile!.servedLocation,
                chipColor: Colors.blue,
              ),
            ),

          // Vehicle Specifications
          if (_profile!.vehicleSpecifications.isNotEmpty)
            RickshawInfoCard(
              title: 'Vehicle Specifications',
              icon: Icons.build,
              child: RickshawChipList(
                items: _profile!.vehicleSpecifications,
                chipColor: Colors.purple,
              ),
            ),

          // Bio
          if (_profile!.bio.isNotEmpty)
            RickshawInfoCard(
              title: 'About Driver',
              icon: Icons.person_outline,
              child: Text(
                _profile!.bio,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.black87,
                ),
              ),
            ),

          // Vehicle Images
          if (_profile!.images.isNotEmpty)
            RickshawInfoCard(
              title: 'Vehicle Images',
              icon: Icons.photo_library,
              child: SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _profile!.images.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          _profile!.images[index],
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey.shade200,
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.grey,
                                  size: 40,
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
            ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
