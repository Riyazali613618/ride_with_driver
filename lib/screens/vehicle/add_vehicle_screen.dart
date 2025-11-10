import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/components/custom_stepper.dart';
import 'package:r_w_r/components/custom_text_field.dart';
import 'package:r_w_r/components/media_uploader_widget.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../components/app_appbar.dart';
import '../../components/custom_activity.dart';
import '../../components/custtom_location_widget.dart';

class AddVehicleService {
  static const String _logTag = 'AddVehicleService';
  static const String _baseUrl =
      "${ApiConstants.baseUrl}/user/vehicle/add-vehicle";

  Future<bool> submitVehicleApplication(AddVehicleModel model) async {
    try {
      final token = await TokenManager.getToken();

      if (token == null) {
        developer.log('No authentication token available', name: _logTag);
        return false;
      }

      developer.log('Submitting vehicle application request to $_baseUrl',
          name: _logTag);
      developer.log('Request body: ${model.toJson()}', name: _logTag);

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(model.toJson()),
      );

      developer.log('Response status: ${response.statusCode}', name: _logTag);
      developer.log('Response body: ${response.body}', name: _logTag);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        developer.log(
          'API Error: ${response.statusCode} - ${response.body}',
          name: _logTag,
        );
        return false;
      }
    } catch (e, stackTrace) {
      developer.log(
        'Exception in submitVehicleApplication',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );
      return false;
    }
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class AddVehicleModel {
  // String? vehicleOwnership;
  String? vehicleName;
  // String? vehicleModelName;
  // String? manufacturing;
  // String? maxPower;
  // String? maxSpeed;
  // int? first2Km;
  // String? fuelType;
  // String? milage;
  // String? registrationDate;
  String? airConditioning;
  String? vehicleType;
  int? seatingCapacity;
  String? vehicleNumber;
  List<String>? vehicleSpecifications;
  List<String>? servedLocation;
  int? minimumChargePerHour;
  // String? currency;
  List<String>? images;
  List<String>? videos;
  bool? isPriceNegotiable;
  String? rcBookFrontPhoto;
  String? rcBookBackPhoto;

  AddVehicleModel({
    // this.vehicleOwnership,
    this.vehicleName,
    // this.vehicleModelName,
    // this.manufacturing,
    // this.maxPower,
    // this.maxSpeed,
    // this.fuelType,
    // this.first2Km,
    // this.milage,
    // this.registrationDate,
    this.airConditioning,
    this.vehicleType,
    this.seatingCapacity,
    this.vehicleNumber,
    this.vehicleSpecifications,
    this.servedLocation,
    this.minimumChargePerHour,
    // this.currency,
    this.images,
    this.videos,
    this.isPriceNegotiable,
    this.rcBookFrontPhoto,
    this.rcBookBackPhoto,
  });

  factory AddVehicleModel.fromJson(Map<String, dynamic> json) {
    return AddVehicleModel(
      // vehicleOwnership: json['vehicleOwnership'],
      vehicleName: json['vehicleName'],
      // vehicleModelName: json['vehicleModelName'],
      // manufacturing: json['manufacturing'],
      // maxPower: json['maxPower'],
      // maxSpeed: json['maxSpeed'],
      // fuelType: json['fuelType'],
      // milage: json['milage'],
      // registrationDate: json['registrationDate'],
      airConditioning: json['airConditioning'],
      vehicleType: json['vehicleType'],
      seatingCapacity: json['seatingCapacity'],
      vehicleNumber: json['vehicleNumber'],
      vehicleSpecifications: json['vehicleSpecifications'] != null
          ? List<String>.from(json['vehicleSpecifications'])
          : null,
      servedLocation: json['servedLocation'] != null
          ? List<String>.from(json['servedLocation'])
          : null,
      minimumChargePerHour: json['minimumChargePerHour'],
      // currency: json['currency'],
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      videos: json['videos'] != null ? List<String>.from(json['videos']) : null,
      isPriceNegotiable: json['isPriceNegotiable'],
      rcBookFrontPhoto: json['rcBookFrontPhoto'],
      rcBookBackPhoto: json['rcBookBackPhoto'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    // if (vehicleOwnership != null) data['vehicleOwnership'] = vehicleOwnership;
    if (vehicleName != null) data['vehicleName'] = vehicleName;
    // if (vehicleModelName != null) data['vehicleModelName'] = vehicleModelName;
    // if (manufacturing != null) data['manufacturing'] = manufacturing;
    // if (maxPower != null) data['maxPower'] = maxPower;
    // if (maxSpeed != null) data['maxSpeed'] = maxSpeed;
    // if (fuelType != null) data['fuelType'] = fuelType;
    // if (milage != null) data['milage'] = milage;
    // if (first2Km != null) data['first2Km'] = first2Km;
    // if (registrationDate != null) data['registrationDate'] = registrationDate;
    if (airConditioning != null) data['airConditioning'] = airConditioning;
    if (vehicleType != null) data['vehicleType'] = vehicleType;
    if (seatingCapacity != null) data['seatingCapacity'] = seatingCapacity;
    if (vehicleNumber != null) data['vehicleNumber'] = vehicleNumber;
    if (vehicleSpecifications != null) {
      data['vehicleSpecifications'] = vehicleSpecifications;
    }
    if (servedLocation != null) data['servedLocation'] = servedLocation;
    if (minimumChargePerHour != null) {
      data['minimumChargePerHour'] = minimumChargePerHour;
    }
    // if (currency != null) data['currency'] = currency;
    if (images != null) data['images'] = images;
    if (videos != null) data['videos'] = videos;
    if (isPriceNegotiable != null) {
      data['isPriceNegotiable'] = isPriceNegotiable;
    }
    if (rcBookFrontPhoto != null) data['rcBookFrontPhoto'] = rcBookFrontPhoto;
    if (rcBookBackPhoto != null) data['rcBookBackPhoto'] = rcBookBackPhoto;
    return data;
  }
}

class AddVehicleScreen extends StatefulWidget {
  final bool? removeAutoRikshaw = true;

  const AddVehicleScreen({super.key, required bool removeAutoRikshaw});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  static const String _logTag = 'AddVehicleScreen';

  final AddVehicleService _vehicleService = AddVehicleService();
  final AddVehicleModel _vehicleModel = AddVehicleModel(
    vehicleSpecifications: [],
    images: [],
    videos: [],
    servedLocation: [],
  );

  // Form Keys
  final _basicInfoFormKey = GlobalKey<FormState>();
  final _specsFormKey = GlobalKey<FormState>();
  final _serviceInfoFormKey = GlobalKey<FormState>();
  final _documentFormKey = GlobalKey<FormState>();

  // Text Controllers
  final _vehicleNameController = TextEditingController();
  //final _vehicleModelNameController = TextEditingController();
  // final _manufacturingController = TextEditingController();
  // final _maxPowerController = TextEditingController();
  // final _maxSpeedController = TextEditingController();
  // final _milageController = TextEditingController();
  // final _registrationDateController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _minimumChargeController = TextEditingController();
  final _seatingCapacityController = TextEditingController();

  // Step variables
  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Basic Info',
    'Specifications',
    'Service Info',
    'Documents',
    'Review',
  ];

  // Dropdown values
  // String? _selectedVehicleOwnership;
  // final List<String> _ownershipTypes = ['OWNED', 'RENTED'];

  // String? _selectedFuelType;
  // final List<String> _fuelTypes = [
  //   'Petrol',
  //   'Diesel',
  //   'Electric',
  //   'CNG',
  //   'Battery'
  // ];

  String? _selectedAirConditioning;
  final List<String> _acTypes = ['AC', 'Non-AC', 'Automatic', 'None'];

  String? _selectedVehicleType;

  List<String> _vehicleTypes() {
    if (widget.removeAutoRikshaw == true) {
      return ['Car', 'SUV', 'MiniVan', 'Bus', 'Other'];
    } else {
      return ['Car', 'Auto', 'SUV', 'Bus', 'MiniVan', 'E-RICKSHAW', 'Other'];
    }
  }

  String? _selectedCurrency;
  final List<String> _currencies = ['INR'];

  // Specification options
  final List<String> _specificationOptions = [
    'ABS',
    'Airbags',
    'Navigation System',
    'Bluetooth',
    'Rear Camera',
    'Sunroof',
    'Leather Seats',
    'Cruise Control'
  ];

  // Error texts
  Map<String, String?> _errorTexts = {};
  bool _isSubmitting = false;
  bool _isPriceNegotiable = true;

  // RC Book photos
  String? _rcBookFrontPhoto;
  String? _rcBookBackPhoto;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _initializeControllers() {
    // Initialize with default values if needed
    _minimumChargeController.text = "500"; // Default value
    _selectedCurrency = "INR"; // Default value
    _isPriceNegotiable = true; // Default value
    _seatingCapacityController.text = "4"; // Default value
  }

  void _disposeControllers() {
    _vehicleNameController.dispose();
   // _vehicleModelNameController.dispose();
   //  _manufacturingController.dispose();
   //  _maxPowerController.dispose();
   //  _maxSpeedController.dispose();
   //  _milageController.dispose();
   //  _registrationDateController.dispose();
    _vehicleNumberController.dispose();
    _minimumChargeController.dispose();
    _seatingCapacityController.dispose();
  }

  // Validation Methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateNumber(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'Enter a valid number';
    }
    return null;
  }

  // String? _validateYear(String? value) {
  //   if (value == null || value.trim().isEmpty) {
  //     return 'Manufacturing year is required';
  //   }
  //   if (value.length != 4 || !RegExp(r'^[0-9]{4}$').hasMatch(value)) {
  //     return 'Enter a valid 4-digit year';
  //   }
  //   return null;
  // }

  // String? _validateSelection(dynamic value, String fieldName) {
  //   if (value == null) {
  //     return 'Please select $fieldName';
  //   }
  //   return null;
  // }

  void _updateErrorText(String field, String? error) {
    setState(() {
      _errorTexts[field] = error;
    });
  }

  // Navigation Methods
  void _nextStep() {
    bool isValid = false;

    switch (_currentStep) {
      case 0: // Basic Info
        isValid = _basicInfoFormKey.currentState?.validate() ?? false;

        // if (_selectedVehicleOwnership == null) {
        //   _updateErrorText('vehicleOwnership', 'Please select ownership type');
        //   isValid = false;
        // }

        if (_selectedVehicleType == null) {
          _updateErrorText('vehicleType', 'Please select vehicle type');
          isValid = false;
        }

        if (isValid) {
          _updateBasicInfoModel();
        }
        break;

      case 1: // Specifications
        isValid = _specsFormKey.currentState?.validate() ?? false;

        // if (_selectedFuelType == null) {
        //   _updateErrorText('fuelType', 'Please select fuel type');
        //   isValid = false;
        // }

        if (_selectedAirConditioning == null) {
          _updateErrorText('airConditioning', 'Please select AC type');
          isValid = false;
        }

        if (isValid) {
          _updateSpecsModel();
        }
        break;

      case 2: // Service Info
        isValid = _serviceInfoFormKey.currentState?.validate() ?? false;

        if (_selectedCurrency == null) {
          _updateErrorText('currency', 'Please select currency');
          isValid = false;
        }

        if (_vehicleModel.servedLocation == null ||
            _vehicleModel.servedLocation!.isEmpty) {
          _updateErrorText(
              'servedLocation', 'Please select at least one service location');
          isValid = false;
        }

        if (_vehicleModel.images == null || _vehicleModel.images!.isEmpty) {
          AddVehicleService.showErrorSnackBar(
              context, 'At least one vehicle image is required');
          return;
        }

        if (isValid) {
          _updateServiceInfoModel();
        }
        break;

      case 3: // Documents
        isValid = _documentFormKey.currentState?.validate() ?? false;

        if (_vehicleModel.rcBookFrontPhoto == null ||
            _vehicleModel.rcBookFrontPhoto!.isEmpty) {
          AddVehicleService.showErrorSnackBar(
              context, 'RC Book Front Photo is required');
          return;
        }

        if (_vehicleModel.rcBookBackPhoto == null ||
            _vehicleModel.rcBookBackPhoto!.isEmpty) {
          AddVehicleService.showErrorSnackBar(
              context, 'RC Book Back Photo is required');
          return;
        }

        if (isValid) {
          // No need to update model, photos are set directly when uploaded
        }
        break;

      case 4: // Review - Submit
        _submitApplication();
        return;
    }

    if (isValid) {
      setState(() {
        _currentStep += 1;
      });
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
    }
  }

  // Model Update Methods
  void _updateBasicInfoModel() {
    // _vehicleModel.vehicleOwnership = _selectedVehicleOwnership;
    _vehicleModel.vehicleName = _vehicleNameController.text;
    // _vehicleModel.vehicleModelName = _vehicleModelNameController.text;
    // _vehicleModel.manufacturing = _manufacturingController.text;
    _vehicleModel.vehicleNumber = _vehicleNumberController.text;
    _vehicleModel.vehicleType = convertVehicleType(_selectedVehicleType ?? " ");
    _vehicleModel.seatingCapacity =
        int.tryParse(_seatingCapacityController.text);
  }

  void _updateSpecsModel() {
    // _vehicleModel.maxPower = _maxPowerController.text;
    // _vehicleModel.maxSpeed = _maxSpeedController.text;
    // _vehicleModel.fuelType = _selectedFuelType;
    // _vehicleModel.milage = _milageController.text;
    // _vehicleModel.registrationDate = _registrationDateController.text;
    _vehicleModel.airConditioning = _selectedAirConditioning;
  }

  void _updateServiceInfoModel() {
    _vehicleModel.minimumChargePerHour =
        int.tryParse(_minimumChargeController.text);
    // _vehicleModel.currency = _selectedCurrency;
    _vehicleModel.isPriceNegotiable = _isPriceNegotiable;
  }

  // Form Submission
  Future<void> _submitApplication() async {
    setState(() {
      _isSubmitting = true;
    });

    try {
      developer.log('Submitting vehicle application: ${_vehicleModel.toJson()}',
          name: _logTag);

      final bool result =
          await _vehicleService.submitVehicleApplication(_vehicleModel);

      if (result) {
        AddVehicleService.showSuccessSnackBar(
          context,
          'Vehicle added successfully!',
        );
        Navigator.of(context).pop();
      } else {
        AddVehicleService.showErrorSnackBar(
          context,
          'Failed to add vehicle. Please try again.',
        );
      }
    } catch (e, stackTrace) {
      developer.log(
        'Error submitting application',
        error: e,
        stackTrace: stackTrace,
        name: _logTag,
      );

      AddVehicleService.showErrorSnackBar(
        context,
        'An error occurred. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: CustomAppBar(
        title: 'Add Vehicle',
        backgroundColor: ColorConstants.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(1.0),
              child: CustomStepper(
                currentStep: _currentStep,
                stepTitles: _stepTitles,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: _buildCurrentStepContent(),
              ),
            ),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentStep > 0)
            ElevatedButton(
              onPressed: _isSubmitting ? null : _previousStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: ColorConstants.black,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Previous'),
            )
          else
            const SizedBox(),
          ElevatedButton(
            onPressed: _isSubmitting ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    _currentStep == _stepTitles.length - 1 ? 'Submit' : 'Next',
                    style: const TextStyle(
                      color: ColorConstants.white,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBasicInfoStep();
      case 1:
        return _buildSpecsStep();
      case 2:
        return _buildServiceInfoStep();
      case 3:
        return _buildDocumentsStep();
      case 4:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  // Step 1: Basic Information
  Widget _buildBasicInfoStep() {
    return Form(
      key: _basicInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CustomDropdown<String>(
          //   label: 'Vehicle Ownership',
          //   hint: 'Select ownership type',
          //   value: _selectedVehicleOwnership,
          //   required: true,
          //   items: _ownershipTypes.map((String type) {
          //     return DropdownMenuItem<String>(
          //       value: type,
          //       child: Text(type),
          //     );
          //   }).toList(),
          //   onChanged: (value) {
          //     setState(() {
          //       _selectedVehicleOwnership = value;
          //       _errorTexts['vehicleOwnership'] = null;
          //     });
          //   },
          //   errorText: _errorTexts['vehicleOwnership'],
          // ),
          CustomDropdown<String>(
            label: 'Vehicle Type',
            hint: 'Select vehicle type',
            value: _selectedVehicleType,
            required: true,
            items: _vehicleTypes().map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedVehicleType = value;
                _errorTexts['vehicleType'] = null;
              });
            },
            errorText: _errorTexts['vehicleType'],
          ),
          CustomTextField(
            label: 'Vehicle Name',
            controller: _vehicleNameController,
            validator: (value) => _validateRequired(value, 'Vehicle name'),
          ),
          // CustomTextField(
          //   label: 'Model Name',
          //   controller: _vehicleModelNameController,
          //   validator: (value) => _validateRequired(value, 'Model name'),
          // ),
          // CustomTextField(
          //   label: 'Manufacturing Year',
          //   controller: _manufacturingController,
          //   keyboardType: TextInputType.number,
          //   validator: _validateYear,
          // ),
          CustomTextField(
            label: 'Vehicle Number',
            controller: _vehicleNumberController,
            validator: (value) => _validateRequired(value, 'Vehicle number'),
          ),
          CustomTextField(
            label: 'Seating Capacity',
            controller: _seatingCapacityController,
            keyboardType: TextInputType.number,
            validator: (value) => _validateNumber(value, 'Seating capacity'),
          ),
        ],
      ),
    );
  }

  // Step 2: Specifications
  Widget _buildSpecsStep() {
    return Form(
      key: _specsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CustomTextField(
          //   label: 'Max Power (HP)',
          //   controller: _maxPowerController,
          //   keyboardType: TextInputType.text,
          //   validator: (value) => _validateRequired(value, 'Max power'),
          // ),
          // CustomTextField(
          //   label: 'Max Speed (km/h)',
          //   controller: _maxSpeedController,
          //   keyboardType: TextInputType.text,
          //   validator: (value) => _validateRequired(value, 'Max speed'),
          // ),
          // CustomDropdown<String>(
          //   label: 'Fuel Type',
          //   hint: 'Select fuel type',
          //   value: _selectedFuelType,
          //   required: true,
          //   items: _fuelTypes.map((String type) {
          //     return DropdownMenuItem<String>(
          //       value: type,
          //       child: Text(type),
          //     );
          //   }).toList(),
          //   onChanged: (value) {
          //     setState(() {
          //       _selectedFuelType = value;
          //       _errorTexts['fuelType'] = null;
          //     });
          //   },
          //   errorText: _errorTexts['fuelType'],
          // ),
          // CustomTextField(
          //   label: 'Milage (km/l)',
          //   controller: _milageController,
          //   keyboardType: TextInputType.text,
          //   validator: (value) => _validateRequired(value, 'Milage'),
          // ),
          // CustomTextField(
          //   label: 'Registration Date',
          //   controller: _registrationDateController,
          //   validator: (value) => _validateRequired(value, 'Registration date'),
          //   onTap: () async {
          //     final DateTime? picked = await showDatePicker(
          //       context: context,
          //       initialDate: DateTime.now(),
          //       firstDate: DateTime(2000),
          //       lastDate: DateTime.now(),
          //     );
          //     if (picked != null) {
          //       setState(() {
          //         _registrationDateController.text =
          //             "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
          //       });
          //     }
          //   },
          // ),
          CustomDropdown<String>(
            label: 'Air Conditioning',
            hint: 'Select AC type',
            value: _selectedAirConditioning,
            required: true,
            items: _acTypes.map((String type) {
              return DropdownMenuItem<String>(
                value: type,
                child: Text(type),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedAirConditioning = value;
                _errorTexts['airConditioning'] = null;
              });
            },
            errorText: _errorTexts['airConditioning'],
          ),
          const SizedBox(height: 16),
          const Text(
            'Vehicle Specifications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _specificationOptions.map((spec) {
              final bool isSelected =
                  _vehicleModel.vehicleSpecifications?.contains(spec) ?? false;
              return FilterChip(
                label: Text(spec),
                selected: isSelected,
                selectedColor: ColorConstants.primaryColor.withOpacity(0.2),
                checkmarkColor: ColorConstants.primaryColor,
                onSelected: (bool selected) {
                  setState(() {
                    if (selected) {
                      _vehicleModel.vehicleSpecifications ??= [];
                      if (!_vehicleModel.vehicleSpecifications!
                          .contains(spec)) {
                        _vehicleModel.vehicleSpecifications!.add(spec);
                      }
                    } else {
                      _vehicleModel.vehicleSpecifications?.remove(spec);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Step 3: Service Information
  Widget _buildServiceInfoStep() {
    return Form(
      key: _serviceInfoFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Text(
            'Service Location',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          Card(
            color: ColorConstants.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: LocationSearchScreen(
                allowMultipleLocations: true,
                initialLocations: (_vehicleModel.servedLocation ?? [])
                    .map((cityName) => LocationData(
                          placeId: cityName,
                          mainText: cityName,
                          secondaryText: '',
                        ))
                    .toList(),
                onLocationSelected: (location) {
                  print('Selected location: ${location.toJson()}');
                  setState(() {
                    _vehicleModel.servedLocation ??= [];
                    String cityName = location.mainText;
                    if (!_vehicleModel.servedLocation!.contains(cityName)) {
                      _vehicleModel.servedLocation!.add(cityName);
                    }
                    _errorTexts['servicesCities'] = null;
                  });
                },
              ),
            ),
          ),

          if (_errorTexts['servicesCities'] != null)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                _errorTexts['servicesCities']!,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
          // Wrap(
          //   spacing: 8.0,
          //   runSpacing: 8.0,
          //   children: _locationOptions.map((location) {
          //     final bool isSelected =
          //         _vehicleModel.servedLocation?.contains(location) ?? false;
          //     return FilterChip(
          //       label: Text(location),
          //       selected: isSelected,
          //       selectedColor: ColorConstants.primaryColor.withOpacity(0.2),
          //       checkmarkColor: ColorConstants.primaryColor,
          //       onSelected: (bool selected) {
          //         setState(() {
          //           if (selected) {
          //             _vehicleModel.servedLocation ??= [];
          //             if (!_vehicleModel.servedLocation!.contains(location)) {
          //               _vehicleModel.servedLocation!.add(location);
          //             }
          //             _errorTexts['servedLocation'] = null;
          //           } else {
          //             _vehicleModel.servedLocation?.remove(location);
          //           }
          //         });
          //       },
          //     );
          //   }).toList(),
          // ),
          // if (_errorTexts['servedLocation'] != null)
          //   Padding(
          //     padding: const EdgeInsets.only(left: 16, top: 4),
          //     child: Text(
          //       _errorTexts['servedLocation']!,
          //       style: const TextStyle(
          //         color: Colors.red,
          //         fontSize: 12,
          //       ),
          //     ),
          //   ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: CustomTextField(
                  label: 'Minimum Charge per Hour',
                  controller: _minimumChargeController,
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      _validateNumber(value, 'Minimum charge'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: CustomDropdown<String>(
                  label: 'Currency',
                  hint: 'Select currency',
                  value: _selectedCurrency,
                  required: true,
                  items: _currencies.map((String currency) {
                    return DropdownMenuItem<String>(
                      value: currency,
                      child: Text(currency),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCurrency = value;
                      _errorTexts['currency'] = null;
                    });
                  },
                  errorText: _errorTexts['currency'],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Checkbox(
                value: _isPriceNegotiable,
                activeColor: ColorConstants.primaryColor,
                onChanged: (value) {
                  setState(() {
                    _isPriceNegotiable = value ?? true;
                  });
                },
              ),
              const Text('Price is negotiable'),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Vehicle Images',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          MediaUploader(
            label: 'Vehicle Images',
            multipleFiles: true,
            onMultipleMediaUploaded: (urls) {
              setState(() {
                _vehicleModel.images = urls;
              });
            },
            kind: 'vehicle',
            showDirectImage: true,
            required: true,
            onMediaUploaded: (String) {},
          ),
          const SizedBox(height: 24),
          const Text(
            'Vehicle Videos (Optional)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          MediaUploader(
            label: 'Vehicle Video',
            multipleFiles: true,
            onMultipleMediaUploaded: (urls) {
              setState(() {
                _vehicleModel.videos = urls;
              });
            },
            kind: 'vehicle',
            showDirectImage: true,
            required: true,
            onMediaUploaded: (String) {},
          ),
        ],
      ),
    );
  }

  // Step 4: Documents
  Widget _buildDocumentsStep() {
    return Form(
      key: _documentFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Registration Documents',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'RC Book Front Photo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          MediaUploader(
            label: 'Upload RC Book Front',
            multipleFiles: false,
            onMediaUploaded: (url) {
              setState(() {
                _vehicleModel.rcBookFrontPhoto = url;
              });
            },
            kind: 'Vehicle',
            showDirectImage: true,
            required: true,
            onMultipleMediaUploaded: (urls) {},
          ),
          const SizedBox(height: 24),
          const Text(
            'RC Book Back Photo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          MediaUploader(
            label: 'RC Book Back Photo',
            multipleFiles: false,
            onMediaUploaded: (url) {
              setState(() {
                _vehicleModel.rcBookBackPhoto = url;
              });
            },
            kind: 'Vehicle',
            showDirectImage: true,
            required: true,
            onMultipleMediaUploaded: (urls) {},
          ),
        ],
      ),
    );
  }

  // Step 5: Review
  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Review Your Vehicle Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        _buildReviewSection(
          'Basic Information',
          [
            // _buildReviewItem('Ownership Type', _vehicleModel.vehicleOwnership),
            _buildReviewItem('Vehicle Type', _vehicleModel.vehicleType),
            _buildReviewItem('Vehicle Name', _vehicleModel.vehicleName),
            // _buildReviewItem('Model Name', _vehicleModel.vehicleModelName),
            // _buildReviewItem('Manufacturing Year', _vehicleModel.manufacturing),
            _buildReviewItem('Vehicle Number', _vehicleModel.vehicleNumber),
            _buildReviewItem(
                'Seating Capacity', '${_vehicleModel.seatingCapacity}'),
          ],
        ),
        _buildReviewSection(
          'Specifications',
          [
            // _buildReviewItem('Max Power', _vehicleModel.maxPower),
            // _buildReviewItem('Max Speed', _vehicleModel.maxSpeed),
            // _buildReviewItem('Fuel Type', _vehicleModel.fuelType),
            // _buildReviewItem('Mileage', _vehicleModel.milage),
            // _buildReviewItem(
            //     'Registration Date', _vehicleModel.registrationDate),
            _buildReviewItem('Air Conditioning', _vehicleModel.airConditioning),
            if (_vehicleModel.vehicleSpecifications != null &&
                _vehicleModel.vehicleSpecifications!.isNotEmpty)
              _buildReviewItem('Specifications',
                  _vehicleModel.vehicleSpecifications!.join(', ')),
          ],
        ),
        _buildReviewSection(
          'Service Information',
          [
            if (_vehicleModel.servedLocation != null &&
                _vehicleModel.servedLocation!.isNotEmpty)
              _buildReviewItem('Service Locations',
                  _vehicleModel.servedLocation!.join(', ')),
            // _buildReviewItem(
            //   'Minimum Charge',
            //   '${_vehicleModel.minimumChargePerHour} ${_vehicleModel.currency}',
            // ),
            _buildReviewItem(
              'Price Negotiable',
              _vehicleModel.isPriceNegotiable == true ? 'Yes' : 'No',
            ),
          ],
        ),
        const SizedBox(height: 24),
        if (_vehicleModel.images != null && _vehicleModel.images!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vehicle Images',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _vehicleModel.images!.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          _vehicleModel.images![index],
                          width: 120,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 120,
                              height: 100,
                              color: Colors.grey[300],
                              child: const Icon(Icons.error),
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
        const SizedBox(height: 16),
        if (_vehicleModel.videos != null && _vehicleModel.videos!.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vehicle Videos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('${_vehicleModel.videos!.length} video(s) uploaded'),
            ],
          ),
        const SizedBox(height: 24),
        const Text(
          'Registration Documents',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RC Book Front'),
                  const SizedBox(height: 4),
                  if (_vehicleModel.rcBookFrontPhoto != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _vehicleModel.rcBookFrontPhoto!,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('RC Book Back'),
                  const SizedBox(height: 4),
                  if (_vehicleModel.rcBookBackPhoto != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _vehicleModel.rcBookBackPhoto!,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        const Text(
          'Please review all the information carefully before submitting.',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            color: ColorConstants.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(
              color: Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items,
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildReviewItem(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value ?? 'Not provided',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Dropdown Widget
class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final String hint;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? errorText;
  final bool required;

  const CustomDropdown({
    Key? key,
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
    this.required = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              children: required
                  ? const [
                      TextSpan(
                        text: ' *',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ]
                  : [],
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: errorText != null ? Colors.red : Colors.grey.shade300,
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<T>(
                value: value,
                icon: const Icon(Icons.keyboard_arrow_down),
                iconSize: 24,
                elevation: 16,
                isExpanded: true,
                hint: Padding(
                  padding: const EdgeInsets.only(left: 16),
                  child: Text(
                    hint,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
                style: const TextStyle(color: Colors.black),
                onChanged: onChanged,
                items: items,
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
            ),
          ),
          if (errorText != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, top: 4),
              child: Text(
                errorText!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
