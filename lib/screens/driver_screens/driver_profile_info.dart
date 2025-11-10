import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/constants/color_constants.dart';

import '../../api/api_model/driver_transpoter_profile_model.dart';
import '../../api/api_service/driver_transpoter_profile_service.dart';
import '../../components/custom_text_field.dart';
import '../../components/custtom_location_widget.dart';
import '../../components/media_uploader_widget.dart';
import '../../constants/api_constants.dart';
import '../common_screens/my_ratings_and_reviews_screen.dart';
import '../registration_screens/r_widgets/select_city_state.dart';

class TransporterDriverProfileScreen extends StatefulWidget {
  final String userType;

  const TransporterDriverProfileScreen({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  State<TransporterDriverProfileScreen> createState() =>
      _TransporterDriverProfileScreenState();
}

class _TransporterDriverProfileScreenState
    extends State<TransporterDriverProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isEditing = false;
  TransporterDriverProfileModel? _profile;
  String? _error;
  Map<String, String?> _errorTexts = {};

  // Controllers
  final _bioController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _contactPersonNameController = TextEditingController();
  final _carCountController = TextEditingController();
  final _busCountController = TextEditingController();
  final _vanCountController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _experienceController = TextEditingController();
  final _minimumChargesController = TextEditingController();
  final _dobController = TextEditingController();

  // Dropdown values
  String? _selectedFleetSize;
  String? _selectedGender;
  List<String> _selectedVehicleTypes = [];
  List<String> _selectedServicesCities = [];
  List<String> _selectedLanguages = [];

  // Options
  final List<String> _fleetSizes = [
    'Small (1-5)',
    'Medium (6-15)',
    'Large (15+)'
  ];
  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _vehicleTypes = [
    'Car',
    'Auto',
    'E-RICKSHAW',
    'SUV',
    'Bus',
    'Minivan',
    'Other'
  ];
  final List<String> _languages = [
    'Hindi',
    'English',
    'Telugu',
    'Tamil',
    'Marathi',
    'Kannad',
    'Gujarati',
    'Bengoli',
    'Malyalam'
  ];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    _bioController.dispose();
    _addressLineController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _pincodeController.dispose();
    _companyNameController.dispose();
    _phoneNumberController.dispose();
    _contactPersonNameController.dispose();
    _carCountController.dispose();
    _busCountController.dispose();
    _vanCountController.dispose();
    _fullNameController.dispose();
    _mobileNumberController.dispose();
    _experienceController.dispose();
    _minimumChargesController.dispose();
    _dobController.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final response =
          await TransporterDriverProfileService.getProfile(widget.userType);

      if (response.status) {
        _populateFields(response);
        setState(() {
          _profile = response;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = response.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _populateFields(TransporterDriverProfileModel profile) {
    final data = profile.data;

    _bioController.text = data.bio ?? '';
    _addressLineController.text = data.address?.addressLine ?? '';
    _cityController.text = data.address?.city ?? '';
    _stateController.text = data.address?.state ?? '';
    _pincodeController.text = data.address?.pincode?.toString() ?? '';

    if (widget.userType == 'TRANSPORTER') {
      _companyNameController.text = data.companyName ?? '';
      _phoneNumberController.text = data.mobileNumber ?? '';
      _contactPersonNameController.text = data.companyName ?? '';

      if (data.fleetSize != null && _fleetSizes.contains(data.fleetSize)) {
        _selectedFleetSize = data.fleetSize;
      }

      if (data.counts != null) {
        _carCountController.text = data.counts!.car?.toString() ?? '';
        _busCountController.text = data.counts!.bus?.toString() ?? '';
        _vanCountController.text = data.counts!.minivan?.toString() ?? '';
      }
    } else {
      _fullNameController.text = data.firstName ?? '';
      _mobileNumberController.text = data.mobileNumber ?? '';
      _experienceController.text = data.experience?.toString() ?? '';
      _minimumChargesController.text = data.minimumCharges?.toString() ?? '';
      _dobController.text = data.dob ?? '';

      if (data.gender != null && _genders.contains(data.gender)) {
        _selectedGender = data.gender;
      }

      // Handle vehicle types - ensure they're valid options
      _selectedVehicleTypes = (data.vehicles ?? [])
          .where((type) => _vehicleTypes.contains(type))
          .cast<String>()
          .toList();

      _selectedLanguages = (data.languageSpoken ?? [])
          .where((lang) => _languages.contains(lang))
          .cast<String>()
          .toList();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() {
        _isSaving = true;
      });

      Map<String, dynamic> updateData = {};

      // Common fields
      updateData['bio'] = _bioController.text;
      updateData['address'] = {
        'addressLine': _addressLineController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'pincode': int.tryParse(_pincodeController.text) ?? 0,
      };

      if (widget.userType == 'TRANSPORTER') {
        updateData['companyName'] = _companyNameController.text;
        updateData['phoneNumber'] = _phoneNumberController.text;
        updateData['contactPersonName'] = _contactPersonNameController.text;
        if (_selectedFleetSize != null)
          updateData['fleetSize'] = _selectedFleetSize;
        updateData['counts'] = {
          'car': int.tryParse(_carCountController.text) ?? 0,
          'bus': int.tryParse(_busCountController.text) ?? 0,
          'van': int.tryParse(_vanCountController.text) ?? 0,
        };
      } else {
        updateData['fullName'] = _fullNameController.text;
        updateData['mobileNumber'] = _mobileNumberController.text;
        updateData['experience'] =
            int.tryParse(_experienceController.text) ?? 0;
        updateData['minimumCharges'] =
            double.tryParse(_minimumChargesController.text) ?? 0.0;
        updateData['dob'] = _dobController.text;
        if (_selectedGender != null) updateData['gender'] = _selectedGender;
        updateData['vehicleType'] = _selectedVehicleTypes;
        updateData['languageSpoken'] = _selectedLanguages;
      }

      final response = await TransporterDriverProfileService.updateProfile(
          widget.userType, updateData);

      if (response.status) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: ColorConstants.primaryColor,
            ),
          );
          setState(() {
            _isEditing = false;
          });
        }
        await _loadProfile();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${response.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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
          : _error != null
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
              _error!,
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
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
          SingleChildScrollView(child: _buildProfileHeader()),
          const SizedBox(height: 16),
          if (_isEditing) _buildEditForm() else _buildViewOnlyProfile(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    final data = _profile!.data;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ColorConstants.primaryColor, ColorConstants.primaryColor],
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
          CupertinoNavigationBarBackButton(color: ColorConstants.white),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 90,
                  height: 90,
                  child: OverflowBox(
                    maxWidth: 100,
                    maxHeight: 170,
                    child: MediaUploader(
                      label: ' ',
                      initialUrl: data.profilePhoto ?? data.profilePhoto ?? '',
                      showDirectImage:
                          (data.profilePhoto ?? data.profilePhoto ?? '').isNotEmpty,
                      allowReupload: true,
                      onMediaUploaded: (url) async {
                        try {
                          Map<String, dynamic> updateData =
                              getCondition(widget.userType, url);

                          final response = await TransporterDriverProfileService
                              .updateProfile(widget.userType, updateData);

                          if (response.status) {
                            await _loadProfile();
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Profile photo updated successfully!'),
                                  backgroundColor: ColorConstants.primaryColor,
                                ),
                              );
                            }
                          } else {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      'Error updating photo: ${response.message}'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Error updating photo: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      allowedExtensions: ['jpg', 'jpeg', 'png'],
                      kind: widget.userType == 'TRANSPORTER'
                          ? 'TRANSPORTER'
                          : 'DRIVER',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: double.infinity,
                          child: Text(
                            widget.userType == 'TRANSPORTER'
                                ? data.companyName ??
                                    data.firstName ??
                                    'Company Name'
                                : data.firstName ?? data.firstName ?? 'Full Name',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),

                        const SizedBox(height: 6),

                        if (data.isVerifiedByAdmin == true)
                          Container(
                            margin: const EdgeInsets.only(bottom: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.verified,
                                    color: ColorConstants.primaryColor,
                                    size: 14),
                                const SizedBox(width: 4),
                                const Text(
                                  'Verified',
                                  style: TextStyle(
                                    color: ColorConstants.primaryColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Show phone number only if it exists
                        if ((widget.userType == 'TRANSPORTER'
                                ? data.mobileNumber
                                : data.mobileNumber) !=
                            null)
                          Container(
                            width: double.infinity,
                            margin: const EdgeInsets.only(bottom: 6),
                            child: Text(
                              widget.userType == 'TRANSPORTER'
                                  ? data.mobileNumber!
                                  : data.mobileNumber!,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => MyRatingsScreen()));
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.amber.shade50,
                              border: Border.all(
                                  color: Colors.amber.shade200, width: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star,
                                    size: 12.0, color: Colors.amber),
                                const SizedBox(width: 2),
                                Text(
                                  data.rating != null && data.rating! > 0
                                      ? data.rating!.toStringAsFixed(1)
                                      : '4.9',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.amber.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewOnlyProfile() {
    final data = _profile!.data;

    return Column(
      children: [
        // Basic Personal Information
        _buildInfoCard(
          title: 'Personal Information',
          icon: Icons.person_outline,
          child: Column(
            children: [
              // Common fields for all user types
              if (data.firstName?.isNotEmpty == true)
                _buildDetailRow('Full Name', '${data.firstName!}${data.lastName}', Icons.person),
              if (data.firstName?.isNotEmpty == true)
                _buildDetailRow('Name', data.firstName!, Icons.person),
              if (data.mobileNumber?.isNotEmpty == true)
                _buildDetailRow(
                    'Mobile Number', data.mobileNumber!, Icons.phone),
              if (data.mobileNumber?.isNotEmpty == true)
                _buildDetailRow('Phone Number', data.mobileNumber!, Icons.phone),
              if (data.dob?.isNotEmpty == true)
                _buildDetailRow('Date of Birth', data.dob!, Icons.cake),
              if (data.gender?.isNotEmpty == true)
                _buildDetailRow('Gender', data.gender!, Icons.wc),
              if (data.bio?.isNotEmpty == true)
                _buildDetailRow('Bio', data.bio!, Icons.description),
              if (data.bio?.isNotEmpty == true)
                _buildDetailRow('About', data.bio!, Icons.info),
              if (data.experience != null)
                _buildDetailRow(
                    'Experience', '${data.experience!} years', Icons.work),
              if (data.minimumCharges != null)
                _buildDetailRow('Minimum Charges', '₹${data.minimumCharges!}',
                    Icons.currency_rupee),
              if (data.negotiable != null)
                _buildDetailRow('Price Negotiable',
                    data.negotiable! ? 'Yes' : 'No', Icons.handshake),
              if (data.rating != null && data.rating! > 0)
                _buildDetailRow('Rating',
                    '${data.rating!.toStringAsFixed(1)} ⭐', Icons.star),
              if (data.totalRating != null && data.totalRating! > 0)
                _buildDetailRow('Total Reviews', data.totalRating!.toString(),
                    Icons.reviews),
            ],
          ),
        ),

        // Company/Business Information (for Transporters)
        if (widget.userType == 'TRANSPORTER' && _hasCompanyInfo(data))
          _buildInfoCard(
            title: 'Company Information',
            icon: Icons.business,
            child: Column(
              children: [
                if (data.companyName?.isNotEmpty == true)
                  _buildDetailRow(
                      'Company Name', data.companyName!, Icons.business),
                if (data.companyName?.isNotEmpty == true)
                  _buildDetailRow(
                      'Contact Person', data.companyName!, Icons.person),
                if (data.gstin?.isNotEmpty == true)
                  _buildDetailRow('GSTIN', data.gstin!, Icons.receipt),
                if (data.fleetSize?.isNotEmpty == true)
                  _buildDetailRow(
                      'Fleet Size', data.fleetSize!, Icons.local_shipping),
                if (data.transportationPermit?.isNotEmpty == true)
                  _buildDetailRow('Transportation Permit',
                      data.transportationPermit!, Icons.description),
              ],
            ),
          ),

        // Address Information
        if (data.address != null && _hasAddressInfo(data.address!))
          _buildInfoCard(
            title: 'Address Information',
            icon: Icons.location_city,
            child: Column(
              children: [
                if (data.address!.addressLine!.isNotEmpty)
                  _buildDetailRow(
                      'Address', data.address!.addressLine!, Icons.home),
                if (data.address!.city?.isNotEmpty == true)
                  _buildDetailRow(
                      'City', data.address!.city!, Icons.location_city),
                if (data.address!.state?.isNotEmpty == true)
                  _buildDetailRow('State', data.address!.state!, Icons.map),
                if (data.address!.pincode != null)
                  _buildDetailRow('Pincode', data.address!.pincode.toString(),
                      Icons.markunread_mailbox),
                if (data.address!.country?.isNotEmpty == true)
                  _buildDetailRow(
                      'Country', data.address!.country!, Icons.public),
              ],
            ),
          ),

        // Service Location (GPS coordinates)
        if (data.serviceLocation != null)
          _buildInfoCard(
            title: 'Service Location',
            icon: Icons.location_on,
            child: Column(
              children: [
                _buildDetailRow('Latitude',
                    data.serviceLocation!.lat.toString(), Icons.gps_fixed),
                _buildDetailRow('Longitude',
                    data.serviceLocation!.lng.toString(), Icons.gps_fixed),
              ],
            ),
          ),

        // Fleet Information (for Transporters)
        if (widget.userType == 'TRANSPORTER' &&
            data.counts != null &&
            _hasFleetCounts(data.counts!))
          _buildInfoCard(
            title: 'Fleet Information',
            icon: Icons.local_shipping,
            child: Column(
              children: [
                if (data.counts!.car != null && data.counts!.car! > 0)
                  _buildDetailRow('Cars', data.counts!.car.toString(),
                      Icons.directions_car),
                if (data.counts!.bus != null && data.counts!.bus! > 0)
                  _buildDetailRow('Buses', data.counts!.bus.toString(),
                      Icons.directions_bus),
                if (data.counts!.minivan != null && data.counts!.minivan! > 0)
                  _buildDetailRow('Vans', data.counts!.minivan.toString(),
                      Icons.local_shipping),
                if (data.counts!.car != null && data.counts!.car! > 0)
                  _buildDetailRow('Total Cars', data.counts!.car.toString(),
                      Icons.directions_car),
                if (data.counts!.minivan != null && data.counts!.minivan! > 0)
                  _buildDetailRow('Minivans', data.counts!.minivan.toString(),
                      Icons.airport_shuttle),
              ],
            ),
          ),

        // Vehicle Information (for Drivers)
        // if (widget.userType != 'TRANSPORTER' && _hasVehicleInfo(data))
        //   _buildInfoCard(
        //     title: 'Vehicle Information',
        //     icon: Icons.directions_car,
        //     child: Column(
        //       children: [
        //         if (data.vehicleNumber?.isNotEmpty == true)
        //           _buildDetailRow(
        //               'Vehicle Number', data.vehicleNumber!, Icons.numbers),
        //         if (data.seatingCapacity != null)
        //           _buildDetailRow('Seating Capacity',
        //               data.seatingCapacity.toString(), Icons.event_seat),
        //         if (data.vehicleImages?.isNotEmpty == true)
        //           _buildChipRow('Vehicle Types', data.vehicles!, Colors.blue),
        //       ],
        //     ),
        //   ),

        // Languages Spoken
        if (data.languageSpoken?.isNotEmpty == true)
          _buildInfoCard(
            title: 'Languages Spoken',
            icon: Icons.language,
            child: _buildChipList(data.languageSpoken!, Colors.purple),
          ),

        // Document Information
        if (_hasDocumentInfo(data))
          _buildInfoCard(
            title: 'Document Information',
            icon: Icons.description,
            child: Column(
              children: [
                // Aadhar Card
                if (data.aadharCardNumber?.isNotEmpty == true)
                  _buildDetailRow('Aadhar Number',
                      _maskAadhar(data.aadharCardNumber!), Icons.credit_card),

                // Driving License
                if (data.drivingLicenceNumber?.isNotEmpty == true)
                  _buildDetailRow('Driving License', data.drivingLicenceNumber!,
                      Icons.drive_eta),
                if (data.drivingLicenceNumber?.isNotEmpty == true)
                  _buildDetailRow('Driving License', data.drivingLicenceNumber!,
                      Icons.drive_eta),

                // PAN Card (from vehicles if available)
                if (data.vehicles?.isNotEmpty == true)
                  for (var vehicle in data.vehicles!)
                    if (vehicle.panCardNumber?.isNotEmpty == true)
                      _buildDetailRow(
                          'PAN Card',
                          _maskPan(vehicle.panCardNumber!),
                          Icons.account_balance_wallet),
              ],
            ),
          ),

        // Document Verification Status
        // if (data.documentVerificationStatus != null)
        //   _buildInfoCard(
        //     title: 'Verification Status',
        //     icon: Icons.verified_user,
        //     child: Column(
        //       children: [
        //         if (data.documentVerificationStatus!.aadharVerified != null)
        //           _buildVerificationRow('Aadhar Card',
        //               data.documentVerificationStatus!.aadharVerified!),
        //         if (data.documentVerificationStatus!.drivingLicenseVerified !=
        //             null)
        //           _buildVerificationRow('Driving License',
        //               data.documentVerificationStatus!.drivingLicenseVerified!),
        //         if (data.documentVerificationStatus!.isVerifiedByAdmin != null)
        //           _buildVerificationRow('Admin Verification',
        //               data.documentVerificationStatus!.isVerifiedByAdmin!),
        //         if (data.isVerifiedByAdmin != null)
        //           _buildVerificationRow(
        //               'Profile Verified', data.isVerifiedByAdmin!),
        //       ],
        //     ),
        //   ),

        if (_hasAccountStatus(data))
          _buildInfoCard(
            title: 'Account Status',
            icon: Icons.account_circle,
            child: Column(
              children: [
                if (data.isVerifiedByAdmin != null)
                  _buildDetailRow(
                      'Account Status',
                      data.isVerifiedByAdmin! ? 'Active' : 'Inactive',
                      data.isVerifiedByAdmin! ? Icons.check_circle : Icons.cancel),
                if (data.isUpgradeAccount != null)
                  _buildDetailRow('Premium Account',
                      data.isUpgradeAccount! ? 'Yes' : 'No', Icons.star),
                if (data.planExpiredDate != null)
                  _buildDetailRow('Plan Expires',
                      _formatDate(data.planExpiredDate!), Icons.schedule),
                if (data.isBlockedByAdmin != null && data.isBlockedByAdmin!)
                  _buildDetailRow(
                      'Account Status', 'Blocked by Admin', Icons.block),
              ],
            ),
          ),

        // Document Images Section
        // if (_hasDocumentImages(data))
        //   _buildInfoCard(
        //     title: 'Document Images',
        //     icon: Icons.image,
        //     child: Column(
        //       children: [
        //         if (data.aadharCardPhoto?.isNotEmpty == true ||
        //             data.aadharCardPhotoFront?.isNotEmpty == true ||
        //             data.aadharCardPhotoBack?.isNotEmpty == true)
        //           _buildDocumentImageRow('Aadhar Card', [
        //             if (data.aadharCardPhoto?.isNotEmpty == true)
        //               data.aadharCardPhoto!,
        //             if (data.aadharCardPhotoFront?.isNotEmpty == true)
        //               data.aadharCardPhotoFront!,
        //             if (data.aadharCardPhotoBack?.isNotEmpty == true)
        //               data.aadharCardPhotoBack!,
        //           ]),
        //         if (data.drivingLicencePhoto?.isNotEmpty == true ||
        //             data.drivingLicensePhoto?.isNotEmpty == true)
        //           _buildDocumentImageRow('Driving License', [
        //             if (data.drivingLicencePhoto?.isNotEmpty == true)
        //               data.drivingLicencePhoto!,
        //             if (data.drivingLicensePhoto?.isNotEmpty == true)
        //               data.drivingLicensePhoto!,
        //           ]),
        //         if (data.transportationPermitPhoto?.isNotEmpty == true)
        //           _buildDocumentImageRow('Transportation Permit',
        //               [data.transportationPermitPhoto!]),
        //       ],
        //     ),
        //   ),

        // Vehicle Details (if exists)
        if (data.vehicles?.isNotEmpty == true) ...[
          for (int i = 0; i < data.vehicles!.length; i++)
            _buildVehicleCard(data.vehicles![i], i + 1),
        ],

        // Account Timeline
        if (data.createdAt != null || data.updatedAt != null)
          _buildInfoCard(
            title: 'Account Timeline',
            icon: Icons.timeline,
            child: Column(
              children: [
                if (data.createdAt != null)
                  _buildDetailRow('Member Since', _formatDate(data.createdAt!),
                      Icons.person_add),
                if (data.updatedAt != null)
                  _buildDetailRow('Last Updated', _formatDate(data.updatedAt!),
                      Icons.update),
              ],
            ),
          ),
      ],
    );
  }

  bool _hasCompanyInfo(UserProfileData data) {
    return data.companyName?.isNotEmpty == true ||
        data.companyName?.isNotEmpty == true ||
        data.gstin?.isNotEmpty == true ||
        data.fleetSize?.isNotEmpty == true ||
        data.transportationPermit?.isNotEmpty == true;
  }

  bool _hasAddressInfo(Address address) {
    return address.addressLine!.isNotEmpty ||
        address.city?.isNotEmpty == true ||
        address.state?.isNotEmpty == true ||
        address.pincode != null ||
        address.country?.isNotEmpty == true;
  }

  bool _hasFleetCounts(FleetCounts counts) {
    return (counts.car != null && counts.car! > 0) ||
        (counts.bus != null && counts.bus! > 0) ||
        (counts.minivan != null && counts.minivan! > 0) ||
        (counts.car != null && counts.car! > 0) ||
        (counts.minivan != null && counts.minivan! > 0);
  }

  bool _hasVehicleInfo(UserProfileData data) {
    return data.vehicles?.isNotEmpty == true ||
        data.vehicleType != null ||
        data.vehicles?.isNotEmpty == true;
  }

  bool _hasDocumentInfo(UserProfileData data) {
    return data.aadharCardNumber?.isNotEmpty == true ||
        data.drivingLicenceNumber?.isNotEmpty == true ||
        data.drivingLicenceNumber?.isNotEmpty == true ||
        (data.vehicles?.any((v) => v.panCardNumber?.isNotEmpty == true) ==
            true);
  }

  bool _hasAccountStatus(UserProfileData data) {
    return data.isUpgradeAccount != null ||
        data.planExpiredDate != null ||
        (data.isBlockedByAdmin != null && data.isBlockedByAdmin!);
  }

  // bool _hasDocumentImages(UserProfileData data) {
  //   return data.aadharCardNumber?.isNotEmpty == true ||
  //       data.aadharCardPhotoFront?.isNotEmpty == true ||
  //       data.aadharCardPhotoBack?.isNotEmpty == true ||
  //       data.drivingLicencePhoto?.isNotEmpty == true ||
  //       data.drivingLicensePhoto?.isNotEmpty == true ||
  //       data.transportationPermitPhoto?.isNotEmpty == true;
  // }

  Widget _buildChipRow(String label, List<dynamic> items, Color chipColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.list, size: 18, color: Colors.grey.shade600),
            const SizedBox(width: 8),
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
          ],
        ),
        const SizedBox(height: 8),
        _buildChipList(items, chipColor),
      ],
    );
  }

  Widget _buildDocumentImageRow(String label, List<String> imageUrls) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imageUrls.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 8),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      imageUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade100,
                          child: Icon(Icons.image_not_supported,
                              color: Colors.grey.shade400),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleImageGrid(List<String> imageUrls) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Text(
          'Vehicle Images',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: Icon(Icons.image_not_supported,
                            color: Colors.grey.shade400),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _maskAadhar(String aadhar) {
    if (aadhar.length >= 8) {
      return 'XXXX-XXXX-${aadhar.substring(aadhar.length - 4)}';
    }
    return aadhar;
  }

  String _maskPan(String pan) {
    if (pan.length >= 6) {
      return '${pan.substring(0, 3)}XXXX${pan.substring(pan.length - 3)}';
    }
    return pan;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
// -----------------------------------------------

  Widget _buildVehicleCard(Vehicle vehicle, int index) {
    return _buildInfoCard(
      title: 'Vehicle $index',
      icon: Icons.directions_car,
      child: Column(
        children: [
          // Basic Vehicle Info
          if (vehicle.vehicleName?.isNotEmpty == true)
            _buildDetailRow(
                'Vehicle Name', vehicle.vehicleName!, Icons.drive_eta),
          if (vehicle.vehicleNumber?.isNotEmpty == true)
            _buildDetailRow(
                'Vehicle Number', vehicle.vehicleNumber!, Icons.numbers),
          if (vehicle.vehicleType?.isNotEmpty == true)
            _buildDetailRow(
                'Vehicle Type', vehicle.vehicleType!, Icons.category),
          if (vehicle.vehicleModelName?.isNotEmpty == true)
            _buildDetailRow(
                'Model', vehicle.vehicleModelName!, Icons.model_training),
          if (vehicle.manufacturing?.isNotEmpty == true)
            _buildDetailRow(
                'Manufacturing Year', vehicle.manufacturing!, Icons.factory),

          // Capacity and Specifications
          if (vehicle.seatingCapacity != null)
            _buildDetailRow('Seating Capacity',
                vehicle.seatingCapacity.toString(), Icons.event_seat),
          if (vehicle.fuelType?.isNotEmpty == true)
            _buildDetailRow(
                'Fuel Type', vehicle.fuelType!, Icons.local_gas_station),
          if (vehicle.milage?.isNotEmpty == true)
            _buildDetailRow('Mileage', vehicle.milage!, Icons.speed),
          if (vehicle.maxPower?.isNotEmpty == true)
            _buildDetailRow('Max Power', vehicle.maxPower!, Icons.power),
          if (vehicle.maxSpeed?.isNotEmpty == true)
            _buildDetailRow('Max Speed', vehicle.maxSpeed!, Icons.speed),
          if (vehicle.airConditioning?.isNotEmpty == true)
            _buildDetailRow('AC', vehicle.airConditioning!, Icons.ac_unit),

          // Pricing
          if (vehicle.minimumChargePerHour != null)
            _buildDetailRow('Rate per Hour',
                '₹${vehicle.minimumChargePerHour!}', Icons.currency_rupee),
          if (vehicle.first2Km != null)
            _buildDetailRow('First 2km Charge', '₹${vehicle.first2Km!}',
                Icons.currency_rupee),
          if (vehicle.currency?.isNotEmpty == true)
            _buildDetailRow('Currency', vehicle.currency!, Icons.money),
          if (vehicle.isPriceNegotiable != null)
            _buildDetailRow('Price Negotiable',
                vehicle.isPriceNegotiable! ? 'Yes' : 'No', Icons.handshake),

          // Registration and Ownership
          if (vehicle.vehicleOwnership?.isNotEmpty == true)
            _buildDetailRow(
                'Ownership', vehicle.vehicleOwnership!, Icons.person),
          if (vehicle.registrationDate?.isNotEmpty == true)
            _buildDetailRow('Registration Date', vehicle.registrationDate!,
                Icons.calendar_today),

          // Specifications and Locations
          if (vehicle.vehicleSpecifications?.isNotEmpty == true)
            _buildChipRow(
                'Specifications', vehicle.vehicleSpecifications!, Colors.green),
          if (vehicle.servedLocation?.isNotEmpty == true)
            _buildChipRow(
                'Service Locations', vehicle.servedLocation!, Colors.orange),

          // Document Information
          if (vehicle.driverLicenseNumber?.isNotEmpty == true)
            _buildDetailRow('Driver License', vehicle.driverLicenseNumber!,
                Icons.drive_eta),
          if (vehicle.aadharCardNumber?.isNotEmpty == true)
            _buildDetailRow('Aadhar Number',
                _maskAadhar(vehicle.aadharCardNumber!), Icons.credit_card),
          if (vehicle.panCardNumber?.isNotEmpty == true)
            _buildDetailRow('PAN Number', _maskPan(vehicle.panCardNumber!),
                Icons.account_balance_wallet),

          // Verification Status
          if (vehicle.isVerifiedByAdmin != null)
            _buildDetailRow(
                'Verified',
                vehicle.isVerifiedByAdmin! ? 'Yes' : 'No',
                vehicle.isVerifiedByAdmin! ? Icons.verified : Icons.cancel),

          // Vehicle Images
          if (vehicle.images?.isNotEmpty == true)
            _buildVehicleImageGrid(vehicle.images!),
        ],
      ),
    );
  }

  Widget _buildVerificationRow(String label, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle : Icons.cancel,
            color: isVerified ? Colors.green : Colors.red,
            size: 18,
          ),
          const SizedBox(width: 8),
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
              isVerified ? 'Verified' : 'Not Verified',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isVerified ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    final data = _profile!.data;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Basic Information Edit
          _buildEditSection(
            title: 'Basic Information',
            icon: Icons.person_outline,
            children: [
              if (widget.userType == 'TRANSPORTER') ...[
                CustomTextField(
                  label: 'Company Name',
                  controller: _companyNameController,
                  validator: (value) => value?.isEmpty == true
                      ? 'Company name is required'
                      : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Contact Person Name',
                  controller: _contactPersonNameController,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Phone Number',
                  controller: _phoneNumberController,
                  keyboardType: TextInputType.phone,
                ),
              ] else ...[
                CustomTextField(
                  label: 'Full Name',
                  controller: _fullNameController,
                  validator: (value) =>
                      value?.isEmpty == true ? 'Full name is required' : null,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Mobile Number',
                  controller: _mobileNumberController,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Date of Birth',
                  controller: _dobController,
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                _buildDropdown(
                  label: 'Gender',
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (value) => setState(() => _selectedGender = value),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Experience (Years)',
                        controller: _experienceController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        label: 'Minimum Charges (₹)',
                        controller: _minimumChargesController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Bio',
                controller: _bioController,
                maxLines: 3,
              ),
            ],
          ),

          // Address Edit Section
          _buildEditSection(
            title: 'Address Information',
            icon: Icons.location_on_outlined,
            children: [
              CustomTextField(
                label: 'Address Line',
                controller: _addressLineController,
                validator: (value) =>
                    value?.isEmpty == true ? 'Address is required' : null,
              ),
              const SizedBox(height: 16),
              StateCityDropdownWidget(
                baseUrl: ApiConstants.baseUrl,
                stateController: _stateController,
                cityController: _cityController,
                stateValidator: (value) => value == null || value.isEmpty
                    ? 'Please select a state'
                    : null,
                cityValidator: (value) => value == null || value.isEmpty
                    ? 'Please select a city'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                label: 'Pincode',
                controller: _pincodeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty == true) return 'Pincode is required';
                  if (value!.length != 6) return 'Enter valid 6-digit pincode';
                  return null;
                },
              ),
            ],
          ),

          // Professional Information Edit
          if (widget.userType == 'TRANSPORTER')
            _buildEditSection(
              title: 'Fleet Information',
              icon: Icons.local_shipping_outlined,
              children: [
                _buildDropdown(
                  label: 'Fleet Size',
                  value: _selectedFleetSize,
                  items: _fleetSizes,
                  onChanged: (value) =>
                      setState(() => _selectedFleetSize = value),
                ),
                const SizedBox(height: 16),
                Text(
                  'Vehicle Counts',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700]),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        label: 'Cars',
                        controller: _carCountController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Buses',
                        controller: _busCountController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomTextField(
                        label: 'Vans',
                        controller: _vanCountController,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else ...[
            _buildEditSection(
              title: 'Professional Information',
              icon: Icons.work_outline,
              children: [
                _buildMultiSelectChips(
                  label: 'Vehicle Types',
                  selectedItems: _selectedVehicleTypes,
                  availableItems: _vehicleTypes,
                  onSelectionChanged: (items) =>
                      setState(() => _selectedVehicleTypes = items),
                ),
                const SizedBox(height: 16),
                Card(
                  color: ColorConstants.white,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LocationSearchScreen(
                      allowMultipleLocations: true,
                      initialLocations: (_selectedServicesCities ?? [])
                          .map((cityName) => LocationData(
                                placeId: cityName,
                                mainText: cityName,
                                secondaryText: '',
                              ))
                          .toList(),
                      onLocationSelected: (location) {
                        setState(() {
                          _selectedServicesCities ??= [];
                          String cityName = location.mainText;
                          if (!_selectedServicesCities!.contains(cityName)) {
                            _selectedServicesCities!.add(cityName);
                          }
                          _errorTexts['servicesCities'] = null;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildMultiSelectChips(
                  label: 'Languages Spoken',
                  selectedItems: _selectedLanguages,
                  availableItems: _languages,
                  onSelectionChanged: (items) =>
                      setState(() => _selectedLanguages = items),
                ),
              ],
            ),
          ],

          // Save and Cancel Buttons
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSaving
                        ? null
                        : () {
                            setState(() {
                              _isEditing = false;
                            });
                            _loadProfile(); // Reset form
                          },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      side:
                          const BorderSide(color: ColorConstants.primaryColor),
                    ),
                    child: const Text('Cancel',
                        style: TextStyle(color: ColorConstants.primaryColor)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isSaving
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text('Saving...'),
                            ],
                          )
                        : const Text('Save Changes'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required Widget child,
    required IconData icon,
  }) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: ColorConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: 8),
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

  Widget _buildChipList(List<dynamic> items, Color chipColor) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: items.map((item) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: chipColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: chipColor.withOpacity(0.3)),
          ),
          child: Text(
            item.toString(),
            style: TextStyle(
              color: chipColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEditSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: ColorConstants.primaryColor,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                  color: ColorConstants.primaryColor, width: 2),
            ),
            fillColor: Colors.grey.shade50,
            filled: true,
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
          hint: Text('Select $label'),
        ),
      ],
    );
  }

  Widget _buildMultiSelectChips({
    required String label,
    required List<String> selectedItems,
    required List<String> availableItems,
    required Function(List<String>) onSelectionChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: availableItems.map((item) {
              final isSelected = selectedItems.contains(item);
              return GestureDetector(
                onTap: () {
                  final updatedList = List<String>.from(selectedItems);
                  if (isSelected) {
                    updatedList.remove(item);
                  } else {
                    updatedList.add(item);
                  }
                  onSelectionChanged(updatedList);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? ColorConstants.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? ColorConstants.primaryColor
                          : Colors.grey.shade400,
                    ),
                  ),
                  child: Text(
                    item,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black87,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dobController.text.isNotEmpty
          ? DateTime.tryParse(_dobController.text) ??
              DateTime.now().subtract(const Duration(days: 365 * 25))
          : DateTime.now().subtract(const Duration(days: 365 * 25)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: ColorConstants.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _dobController.text =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
      });
    }
  }
}

Map<String, dynamic> getCondition(String type, String url) {
  return type == 'TRANSPORTER' ? {"photo": url} : {"profilePhoto": url};
}
