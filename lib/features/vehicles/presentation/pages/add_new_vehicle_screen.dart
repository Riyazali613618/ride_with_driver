// vehicle_registration_provider.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_service/media_service.dart';
import 'package:r_w_r/api/api_service/user_service/user_profile_service.dart';
import 'package:r_w_r/components/app_loader.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_repository.dart';
import 'package:r_w_r/features/vehicles/presentation/pages/vehicle_added_successfully_screen.dart';
import 'package:r_w_r/features/vehicles/presentation/pages/vehicle_type_model.dart';
import 'package:r_w_r/utils/common_utils.dart';

import '../../../../constants/GoogleLocationSearchService.dart';
import '../../../../constants/token_manager.dart';
import '../../../../screens/layout.dart';
import '../../../../screens/widgets/common_submit_button.dart';
import '../../../../utils/color.dart';
import '../bloc/profile_bloc.dart';

class AddVehicleProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;

  String? get error => _error;

  static const String baseUrl = '${ApiConstants.baseUrl}';
  static String authToken = 'YOUR_AUTH_TOKEN';

  Future<void> getToken() async {
    final token = await TokenManager.getToken();
    authToken = token.toString();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
  }

  Future<bool> submitVehicleRegistration({
    required String userType,
    String? vehicleType,
    String? vehicleName,
    required String vehicleNumber,
    required int seatingCapacity,
    required String airConditioning,
    required List<String> vehicleSpecifications,
    required Map<String, double> serviceLocation,
    required double minimumChargePerHour,
    required bool isPriceNegotiable,
    required List<String> images,
    required List<String> videos,
    String? rcBookFrontPhoto,
    String? rcBookBackPhoto,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      };
      print(authToken.substring(0, 100));
      print(authToken.substring(100));

      var request = http.Request('POST', Uri.parse('$baseUrl/user/vehicles'));

      // Build request body based on user type
      Map<String, dynamic> requestBody = {
        "vehicleNumber": vehicleNumber,
        "seatingCapacity": seatingCapacity,
        "airConditioning": airConditioning,
        "vehicleSpecifications": vehicleSpecifications,
        "serviceLocation": serviceLocation,
        "minimumChargePerHour": minimumChargePerHour,
        "isPriceNegotiable": isPriceNegotiable,
        "images": images,
        "videos": videos,
      };

      // Add vehicleType and vehicleName only if not auto-rickshaw or e-rickshaw
      /* if (userType != 'Auto-Rickshaw' && userType != 'E-Rickshaw Driver') {
        if (vehicleType != null) requestBody["vehicleType"] = vehicleType;
        if (vehicleName != null) requestBody["vehicleName"] = vehicleName;
      }*/
      if (vehicleType != null) requestBody["vehicleType"] = vehicleType;
      if (vehicleName != null) requestBody["vehicleName"] = vehicleName;

      // Add RC photos only if not auto-rickshaw or e-rickshaw
      /* if (userType != 'Auto-Rickshaw' && userType != 'E-Rickshaw Driver') {
        if (rcBookFrontPhoto != null)
          requestBody["rcBookFrontPhoto"] = rcBookFrontPhoto;
        if (rcBookBackPhoto != null)
          requestBody["rcBookBackPhoto"] = rcBookBackPhoto;
      }*/
      if (rcBookFrontPhoto != null) {
        requestBody["rcBookFrontPhoto"] = rcBookFrontPhoto;
      }
      if (rcBookBackPhoto != null) {
        requestBody["rcBookBackPhoto"] = rcBookBackPhoto;
      }
      print(requestBody);
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print('Success: ${response.statusCode}');

      if (response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        print('Success: $responseBody');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> map = json.decode(responseBody);
        print('failed: ${responseBody}');

        try {
          _error = 'Failed to submit: ${map["errors"]["errors"].toList()[0]}';
        } catch (e, s) {
          _error = 'Failed to submit';
          print(s);
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// vehicle_registration_form.dart

class AddNewVehicleScreen extends StatefulWidget {
  final bool isFromRegistration;
  final VehicleEntity? vehicle;
  final String
      userType; // 'Transporter', 'Taxi Owner', 'Auto-Rickshaw', 'E-Rickshaw Driver'

  const AddNewVehicleScreen({
    super.key,
    this.isFromRegistration = false,
    required this.userType,
    this.vehicle,
  });

  @override
  State<AddNewVehicleScreen> createState() => _VehicleRegistrationFormState();
}

class _VehicleRegistrationFormState extends State<AddNewVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final _vehicleNameController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _minimumChargeController = TextEditingController();

  // Form Data
  Categories? _selectedVehicleType;
  String? _selectedSeatingCapacity;
  String _selectedAirConditioning = 'Non-AC';
  bool _isNegotiable = false;
  List<String> _selectedLocations = [];
  List<String> _selectedSpecifications = [];
  List<File> _vehicleImages = [];
  List<String> _vehicleImagesServer = [];
  List<File> _vehicleVideos = [];
  List<String> _vehicleVideosServer = [];
  List<File> _rcImages = [];
  List<String> _rcImagesServer = [];

  final Map<String, double> _currentLocation = {'lat': 28.6139, 'lng': 77.209};

  final List<String> _serviceLocations = [
    'New Delhi',
    'Faridabad',
    'Noida',
    'Gurgaon',
    'Mumbai',
    'Bangalore'
  ];

  final List<String> _specifications = [
    'Navigation System',
    'Airbags',
    'ABS',
    'Leather Seats',
    'Rear Camera',
    'Bluetooth',
    'Sunroof',
    'Petrol',
    'CNG fuel',
    'Good condition',
    'Regular maintenance',
    'Clean interior'
  ];

  // Check if field should be shown based on user type
  bool get _shouldShowVehicleType => true
      /*  widget.userType != 'Auto-Rickshaw' &&
      widget.userType != 'E-Rickshaw Driver'*/
      ;

  bool get _shouldShowVehicleName => true
      /*widget.userType != 'Auto-Rickshaw' &&
      widget.userType != 'E-Rickshaw Driver'*/
      ;

  bool get _shouldShowRCPhotos => true
      /*widget.userType != 'Auto-Rickshaw' &&
      widget.userType != 'E-Rickshaw Driver'*/
      ;

  @override
  void initState() {
    if (widget.vehicle != null) {
      // _selectedVehicleType = widget.vehicle?.vehicleType;
      _vehicleNameController.text = widget.vehicle?.vehicleName ?? "";
      _vehicleNumberController.text = widget.vehicle?.vehicleNumber ?? "";
      _selectedSeatingCapacity = widget.vehicle?.seatingCapacity.toString();
      _selectedAirConditioning = widget.vehicle?.airConditioning ?? "Non-AC";
      _minimumChargeController.text =
          widget.vehicle?.minimumCharge.toString() ?? "";
      _isNegotiable = widget.vehicle?.isNegotiable ?? false;
      _selectedSpecifications = widget.vehicle?.vehicleSpecifications ?? [];
      _vehicleImagesServer = widget.vehicle?.images ?? [];
      _vehicleVideosServer = widget.vehicle?.videos ?? [];
      _rcImagesServer = [
        if (widget.vehicle?.rcBookFrontPhoto != null)
          widget.vehicle!.rcBookFrontPhoto,
        if (widget.vehicle?.rcBookBackPhoto != null)
          widget.vehicle!.rcBookBackPhoto,
      ];
    }

    super.initState();
    getVehicleTypeList();
  }

  @override
  void dispose() {
    _vehicleNameController.dispose();
    _vehicleNumberController.dispose();
    _minimumChargeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        switch (type) {
          case 'vehicle':
            _vehicleImages.add(File(image.path));

            break;
          case 'rc':
            _rcImages.add(File(image.path));
            break;
        }
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _vehicleVideos.add(File(video.path));
      });
    }
  }

  void _removeFile(String type, int index) {
    setState(() {
      switch (type) {
        case 'vehicle':
          _vehicleImages.removeAt(index);
          break;
        case 'video':
          _vehicleVideos.removeAt(index);
          break;
        case 'rc':
          _rcImages.removeAt(index);
          break;
      }
    });
  }

  Future<List<String>> _uploadFiles(List<File> files, String type) async {
    List<String> urls = [];
    int i = 0;
    for (File file in files) {
      var type = "";
      if (i == 0) {
        type = "rcBookFront";
      } else {
        type = "rcBookBack";
      }
      final String? url = await MediaService().uploadFileAndGetUrl(
        file,
        kind: type,
      );
      urls.add(url ?? "");
    }
    return urls;
  }

  bool isLoading = false;

  Future<void> _submitForm(AddVehicleProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation based on user type
    if (_shouldShowVehicleType && _selectedVehicleType == null) {
      _showErrorSnackBar('Please select vehicle type');
      return;
    }

    if (_shouldShowVehicleName && _vehicleNameController.text.isEmpty) {
      _showErrorSnackBar('Please enter vehicle name');
      return;
    }

    if (_vehicleNumberController.text.isEmpty) {
      _showErrorSnackBar('Please enter vehicle number');
      return;
    }

    if (_selectedSeatingCapacity == null) {
      _showErrorSnackBar('Please select seating capacity');
      return;
    }

    if (_minimumChargeController.text.isEmpty) {
      _showErrorSnackBar('Please enter minimum charge');
      return;
    }

    if (_shouldShowRCPhotos && _rcImages.length < 2) {
      _showErrorSnackBar('Please upload both front and back RC images');
      return;
    }

    try {
      isLoading = true;
      setState(() {});
      List<String> imageUrls = [];
      for (var images in _vehicleImages) {
        final String? url = await MediaService().uploadFileAndGetUrl(
          images,
          kind: "vehicleImage",
        );
        imageUrls.add(url ?? "");
      }
      List<String> videoUrls = [];
      for (var videos in _vehicleVideos) {
        final String? url = await MediaService().uploadFileAndGetUrl(
          videos,
          kind: "vehicleVideo",
        );
        videoUrls.add(url ?? "");
      }
      print(videoUrls);
      List<String> rcUrls =
          _shouldShowRCPhotos ? await _uploadFiles(_rcImages, 'rc') : [];

      String? rcFrontUrl =
          _shouldShowRCPhotos && rcUrls.isNotEmpty ? rcUrls[0] : null;
      String? rcBackUrl =
          _shouldShowRCPhotos && rcUrls.length > 1 ? rcUrls[1] : null;

      /* final provider =
          Provider.of<AddVehicleProvider>(context, listen: false);*/
      await provider.getToken();

      bool success = await provider.submitVehicleRegistration(
        userType: widget.userType,
        vehicleType: _shouldShowVehicleType
            ? _selectedVehicleType != null
                ? _selectedVehicleType!.code!
                : ""
            : null,
        vehicleName:
            _shouldShowVehicleName ? _vehicleNameController.text.trim() : null,
        vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
        seatingCapacity: int.parse(_selectedSeatingCapacity!),
        airConditioning: _selectedAirConditioning,
        vehicleSpecifications: _selectedSpecifications,
        serviceLocation: _currentLocation,
        minimumChargePerHour: double.parse(_minimumChargeController.text),
        isPriceNegotiable: _isNegotiable,
        images: imageUrls,
        videos: videoUrls,
        rcBookFrontPhoto: rcFrontUrl,
        rcBookBackPhoto: rcBackUrl,
      );
      isLoading = false;

      if (success) {
        _showSuccessSnackBar('Vehicle registration submitted successfully!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => BlocProvider(
                    create: (_) => ProfileBloc(ProfileRepository()),
                    child: VehicleAddedSuccessfullyScreen(
                        userType: widget.userType),
                  )),
        );
      } else if (provider.error != null) {
        _showErrorSnackBar(provider.error!);
      }
    } catch (e) {
      isLoading = false;
      _showErrorSnackBar('An error occurred: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _handleBackPress,
      child: Scaffold(
        body: CommonParentContainer(
          showLargeGradient: true,
          child: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding:
                      const EdgeInsets.only(top: 16.0, left: 16, right: 16),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final shouldPop = await _handleBackPress();
                          if (shouldPop) {
                            Navigator.pop(context);
                          }
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        widget.vehicle == null
                            ? 'Add Vehicle'
                            : "Manage Vehicle",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Form Content
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Vehicle Type - Only for Transporter and Taxi Owner
                            if (_shouldShowVehicleType)
                              _buildDropdownVehicleTypeField(
                                label: 'Vehicle Type',
                                value: _selectedVehicleType,
                                items: _vehicleTypes,
                                onChanged: (value) {
                                  setState(() {
                                    _selectedVehicleType = value;
                                    final min = _selectedVehicleType
                                            ?.seatingLimits?.min ??
                                        1;
                                    final max = _selectedVehicleType
                                            ?.seatingLimits?.max ??
                                        2;
                                    _seatingCapacities = List.generate(
                                        max - min + 1,
                                        (index) => (min + index).toString());
                                  });
                                },
                                isRequired: true,
                              ),

                            // Vehicle Name - Only for Transporter and Taxi Owner
                            if (_shouldShowVehicleName)
                              _buildTextField(
                                label: 'Vehicle Name',
                                controller: _vehicleNameController,
                                isHighlighted: true,
                              ),

                            _buildTextField(
                              label: 'Vehicle Number',
                              controller: _vehicleNumberController,
                              isHighlighted: true,
                            ),

                            _buildDropdownField(
                              label: 'Seating Capacity',
                              value: _selectedSeatingCapacity,
                              items: _seatingCapacities,
                              onChanged: (value) {
                                setState(() {
                                  _selectedSeatingCapacity = value;
                                });
                              },
                            ),

                            _buildMinimumChargeField(),

                            _googlePlaceSearch(),
                            const SizedBox(height: 16),
                            _buildAirConditioningField(),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(
                                    child: _buildMultiSelectField(
                                  label: 'Specifications',
                                  selectedItems: _selectedSpecifications,
                                  allItems: _specifications,
                                  addButton: true,
                                  onSelectionChanged: (specs) {
                                    setState(() {
                                      _selectedSpecifications = specs;
                                    });
                                  },
                                )),
                              ],
                            ),
                            _buildFileUploadSection(
                              title: 'Upload Vehicle Image',
                              files: _vehicleImages,
                              filesServer: _vehicleImagesServer,
                              onAddFile: () => _pickImage('vehicle'),
                              onRemoveFile: (index) =>
                                  _removeFile('vehicle', index),
                              fileType: 'image',
                            ),

                            _buildFileUploadSection(
                              title: 'Upload Vehicle Video',
                              files: _vehicleVideos,
                              filesServer: _vehicleVideosServer,
                              onAddFile: () => _pickVideo(),
                              onRemoveFile: (index) =>
                                  _removeFile('video', index),
                              fileType: 'video',
                            ),

                            // RC Upload - Only for Transporter and Taxi Owner
                            if (_shouldShowRCPhotos) _buildRCUploadSection(),

                            const SizedBox(height: 40),

                            // Submit Button
                            Consumer<AddVehicleProvider>(
                              builder: (context, provider, child) {
                                return Container(
                                  alignment: Alignment.bottomRight,
                                  child: CommonSubmitButton(
                                    gradientColors: [
                                      gradientFirst,
                                      gradientSecond
                                    ],
                                    onPressed: () {
                                      if (provider.isLoading || isLoading) {
                                        return;
                                      }
                                      _submitForm(provider);
                                    },
                                    text: "Submit",
                                    borderRadius: 12,
                                    isLoading: isLoading,
                                  ),
                                );
                                return SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      (provider.isLoading || isLoading)
                                          ? null
                                          : _submitForm(provider);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: gradientFirst,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: (provider.isLoading || isLoading)
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Submit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _handleBackPress() async {
    // If NOT from registration → normal back
    if (!widget.isFromRegistration) {
      return true;
    }

    // Show confirmation dialog
    final shouldLeave = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Leave Registration?'),
        content: const Text(
          'Are you sure you want to leave the vehicle registration?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLeave == true) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => const Layout(isFirstTime: false)),
        (route) => false,
      );
      return false; // we handled navigation ourselves
    }

    return false; // close dialog only
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            style: CommonUtils.commonInputTextStyle(),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.commonBorderColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.commonBorderColor,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: 'Select Type',
              hintStyle: CommonUtils.commonTextLabelsStyle(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.commonBorderColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.commonBorderColor,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: CommonUtils.commonTextLabelsStyle(),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownVehicleTypeField({
    required String label,
    required Categories? value,
    required List<Categories> items,
    required Function(Categories?) onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<Categories>(
            value: value,
            decoration: InputDecoration(
              hintText: 'Select Type',
              hintStyle: CommonUtils.commonHintTextStyle(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.commonBorderColor,
                  width: 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: AppColors.commonBorderColor,
                  width: 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: items.map((Categories item) {
              return DropdownMenuItem<Categories>(
                value: item,
                child: Text(item.code ?? ""),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMinimumChargeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Minimum Charge Per Hour',
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _minimumChargeController,
                  keyboardType: TextInputType.number,
                  style: CommonUtils.commonInputTextStyle(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.commonBorderColor,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _isNegotiable,
                      onChanged: (value) {
                        setState(() {
                          _isNegotiable = value!;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    Text(
                      'Negotiable',
                      style: CommonUtils.commonTextLabelsStyle(),
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

  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedItems,
    required List<String> allItems,
    bool addButton = false,
    required Function(List<String>) onSelectionChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: Text('Search $label'),
                        isExpanded: true,
                        items: allItems.map((String item) {
                          return DropdownMenuItem<String>(
                            value: item,
                            child: Text(item),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null && !selectedItems.contains(value)) {
                            final newList = List<String>.from(selectedItems)
                              ..add(value);
                            onSelectionChanged(newList);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                if (addButton)
                  GestureDetector(
                    onTap: () {
                      showAddCustomSpecificationPopup();
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Icon(
                        Icons.add_circle,
                        color: ColorConstants.primaryColor,
                        size: 24,
                      ),
                    ),
                  )
              ]),
          if (selectedItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedItems.map((item) {
                return Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 2),
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
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          final newList = List<String>.from(selectedItems)
                            ..remove(item);
                          onSelectionChanged(newList);
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.only(left: 10, right: 0, bottom: 5),
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(30)),
                                border:
                                    Border.all(color: Colors.black, width: 1)),
                            child: const Icon(
                              Icons.close,
                              size: 10,
                              color: Color(0xFF9C27B0),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAirConditioningField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Air Conditioning',
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    'AC',
                    style: CommonUtils.commonTextLabelsStyle(),
                  ),
                  value: 'AC',
                  groupValue: _selectedAirConditioning,
                  onChanged: (value) {
                    setState(() {
                      _selectedAirConditioning = value!;
                    });
                  },
                  activeColor: Colors.green,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: Text(
                    'Non AC',
                    style: CommonUtils.commonTextLabelsStyle(),
                  ),
                  value: 'Non-AC',
                  groupValue: _selectedAirConditioning,
                  onChanged: (value) {
                    setState(() {
                      _selectedAirConditioning = value!;
                    });
                  },
                  activeColor: Colors.green,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection({
    required String title,
    required List<File> files,
    required List<String> filesServer,
    required VoidCallback onAddFile,
    required Function(int) onRemoveFile,
    required String fileType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          const SizedBox(height: 8),
          Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: onAddFile,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Color(0x80000000),
                  strokeWidth: 1,
                  dashPattern: [5, 2],
                  radius: Radius.circular(6),
                ),
                child: SizedBox(
                  width: 75,
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.black, size: 16),
                      Text(
                        'Add',
                        style: CommonUtils.commonTextLabelsStyle(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (files.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: files.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: fileType == 'video'
                                  ? const Icon(Icons.video_file, size: 40)
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        files[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => onRemoveFile(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            const SizedBox(width: 8),
            if (filesServer.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filesServer.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Colors.grey.shade200,
                              ),
                              child: fileType == 'video'
                                  ? const Icon(Icons.video_file, size: 40)
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: CachedNetworkImage(
                                        imageUrl: filesServer[index],
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => onRemoveFile(index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
          ]),
        ],
      ),
    );
  }

  Widget _buildRCUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "RC (Front & Back)",
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: ColorConstants.inputFieldBorderColor),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 32,
                color: Color(0xFF8B5CF6),
              ),
              SizedBox(height: 8),
              Text(
                'select your file or drag and drop',
                style: CommonUtils.commonTextLabelsStyle(),
              ),
              SizedBox(height: 4),
              Text(
                'png, pdf, jpg, docx accepted',
                style: TextStyle(
                  fontSize: 10,
                  fontFamily: AppConstants.ptSansFont,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 12),
              CommonUtils.commonGradientBorderButton(
                text: "browse",
                onTap: () {
                  _pickImage("rc");
                },
              ),
              if (_rcImages.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _rcImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _rcImages[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => _removeFile('rc', index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
              if (_rcImagesServer.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _rcImagesServer.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: Stack(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: CachedNetworkImage(
                                  imageUrl: _rcImagesServer[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: -4,
                              right: -4,
                              child: GestureDetector(
                                onTap: () => _removeFile('rc', index),
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRCUploadSectionOld() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RC (Front & Back)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                const Text(
                  'select your file or drag and drop',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'png, pdf, jpg, docx accepted',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pickImage('rc'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientFirst,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Browse',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_rcImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _rcImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _rcImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () => _removeFile('rc', index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
          if (_rcImagesServer.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _rcImagesServer.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: _rcImagesServer[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () => _removeFile('rc', index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  List<Categories> _vehicleTypes = [];
  List<String> _seatingCapacities = [];

  Future<void> getVehicleTypeList() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        final data = await UserProfileService().getVehicleTypeList();
        if (data.data != null) {
          _vehicleTypes = data.data?.categories ?? [];

          setState(() {});
        }
      },
    );
  }

  TextEditingController specController = TextEditingController();

  void showAddCustomSpecificationPopup() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                'Add New Specification',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 12),

              // Subtitle
              const Text(
                'Drivers who do not own a vehicle.',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 24),

              // Section title
              TextFormField(
                controller: specController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Colors.grey,
                      width: 1,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Optional action button
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _selectedSpecifications
                            .add(specController.text.toString());
                        setState(() {});
                        specController.text = "";
                      },
                      child: const Text(
                        'OK',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Future<Map<String, dynamic>?> getCurrentLocationWithDetails() async {
    try {
      final locationData =
          await GoogleLocationSearchService.getCurrentLocationWithDetails();
    } catch (e) {
      print('Error getting current location with details: $e');
      return null;
    }
  }

  final searchLocationController = TextEditingController();
  Timer? _searchDebounceTimer;

  _googlePlaceSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Service Locations",
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        const SizedBox(height: 8),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 16),
          decoration: CommonUtils.commonInputBoxDecoration(),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
              child: TextField(
                controller: searchLocationController,
                decoration: InputDecoration(
                  hintText: "Service Location",
                  border: InputBorder.none,
                  suffixIcon: !isLoadingLocation &&
                          searchLocationController.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            Icons.cancel_outlined,
                            size: 16,
                          ),
                          onPressed: () {
                            searchLocationController.clear();
                            setState(() {
                              _suggestions.clear();
                              _showDropdown = false;
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  _searchDebounceTimer?.cancel();
                  _searchDebounceTimer = Timer(
                    const Duration(milliseconds: 500),
                    () => _searchLocationsWithService(value),
                  );
                },
              ),
            ),
            if (isLoadingLocation)
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                    strokeWidth: 1,
                  )),
            if (isLoadingLocation)
              SizedBox(
                width: 16,
              )
          ]),
        ),

        /// Dropdown
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  title: Text(item.mainText),
                  subtitle: Text(item.secondaryText),
                  onTap: () {
                    searchLocationController.text = "";
                    _selectedLocations.add(item.mainText);
                    setState(() {
                      _showDropdown = false;
                    });

                    /// You now have placeId
                    print("Selected placeId: ${item.placeId}");
                  },
                );
              },
            ),
          ),
        if (_selectedLocations.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 0,
            alignment: WrapAlignment.start,
            children: _selectedLocations.map((item) {
              return Stack(
                children: [
                  Container(
                    margin:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        final newList = List<String>.from(_selectedLocations)
                          ..remove(item);
                        setState(() {
                          _selectedLocations = newList;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 0, bottom: 5),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(30)),
                              border:
                                  Border.all(color: Colors.black, width: 1)),
                          child: const Icon(
                            Icons.close,
                            size: 10,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  List<PlaceSuggestion> _suggestions = [];
  bool _showDropdown = false;

  void _searchLocationsWithService(String value) async {
    final results = await searchPlaces(value);

    setState(() {
      _suggestions = results;
      _showDropdown = results.isNotEmpty;
    });
  }

  bool isLoadingLocation = false;

  Future<List<PlaceSuggestion>> searchPlaces(String input) async {
    if (input.isEmpty) return [];
    if (mounted) {
      setState(() {
        isLoadingLocation = true;
      });
    }
    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': ApiConstants.apiKey,
        'X-Goog-FieldMask': 'suggestions.placePrediction',
      },
      body: jsonEncode({
        "input": input,
        "locationBias": {
          "rectangle": {
            "low": {"latitude": 6.0, "longitude": 68.0},
            "high": {"latitude": 36.0, "longitude": 98.0}
          }
        }
      }),
    );
    if (mounted) {
      setState(() {
        isLoadingLocation = false;
      });
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['suggestions'] as List)
          .map((e) => PlaceSuggestion.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to fetch places');
    }
  }
}

class PlaceSuggestion {
  final String placeId;
  final String mainText;
  final String secondaryText;

  PlaceSuggestion({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  });

  factory PlaceSuggestion.fromJson(Map<String, dynamic> json) {
    final structured = json['placePrediction']['structuredFormat'];
    return PlaceSuggestion(
      placeId: json['placePrediction']['placeId'],
      mainText: structured['mainText']['text'],
      secondaryText: structured['secondaryText']['text'],
    );
  }
}
