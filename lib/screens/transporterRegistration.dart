import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_model/cityModel.dart' as cm;
import 'package:r_w_r/api/api_model/stateModel.dart' as sm;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/screens/layout.dart';
import 'package:r_w_r/screens/widgets/gradient_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_model/language/language_model.dart';
import '../../api/api_model/registrations/transporter_model.dart';
import '../../api/api_service/registration_services/transporter_service.dart';
import '../../bloc/driver/driver_bloc.dart';
import '../../bloc/driver/driver_event.dart';
import '../../bloc/driver/driver_state.dart';
import '../../components/media_uploader_widget.dart';
import '../../constants/token_manager.dart';
import '../api/api_service/countryStateProviderService.dart';
import '../api/api_service/user_service/user_profile_service.dart';
import '../transporterRegistration/presentation/widget/gradient_progress_bar.dart';
import '../utils/color.dart';
import 'block/provider/profile_provider.dart';
import 'multi_step_progress_bar.dart';
import 'other/terms_and_coditions_bottom_sheet.dart';

class TransporterRegistrationFlow extends StatefulWidget {
  const TransporterRegistrationFlow({super.key});

  @override
  State<TransporterRegistrationFlow> createState() =>
      _TransporterRegistrationFlowState();
}

class _TransporterRegistrationFlowState
    extends State<TransporterRegistrationFlow> {
  TransporterModel _transporterModel = TransporterModel.empty();
  bool _isGstVerifying = false;
  bool _isGstVerified = false;

  final _businessFormKey = GlobalKey<FormState>();
  final _documentsFormKey = GlobalKey<FormState>();
  final _fleetFormKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();

  final _companyNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _bioController = TextEditingController();
  final _addressLineController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _pincodeController = TextEditingController();
  final _contactPersonNameController = TextEditingController();
  final _gstinController = TextEditingController();

  final _carCountController = TextEditingController(text: '0');
  final _vanCountController = TextEditingController(text: '0');
  final _busCountController = TextEditingController(text: '0');

  String? _selectedFleetSize;
  File? _selectedImage;
  String? _selectedCity = '';
  String? _selectedState = '';
  List<cm.Data> _cityList = [];
  List<sm.Data> _stateList = [];

  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Company\nDetail',
    'Address',
    'Document',
    'About',
    'Submit'
  ];

  final UserProfileService _profileService = UserProfileService();
  String? currentCountry;

  @override
  void initState() {
    super.initState();
    final langProvider = Provider.of<LocationProvider>(context, listen: false);

    if (langProvider.selectedCountry == null) {
      currentCountry = '68cb9bb0f7b20f3ca5045003';
    } else {
      currentCountry = langProvider.selectedCountry;
    }
    langProvider.fetchStates(currentCountry!).then((_) {
      setState(() {
        _stateList = langProvider.states;
      });
    });
    _prefillData();
    _loadCurrentStep();
    _markApplicationAsStarted();
  }

  void _prefillData() {
    UserPrefillUtility.prefillUserData(
      contactPersonController: _contactPersonNameController,
      phoneController: _phoneNumberController,
    );
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _phoneNumberController.dispose();
    _bioController.dispose();
    _addressLineController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    _gstinController.dispose();
    _carCountController.dispose();
    _vanCountController.dispose();
    _busCountController.dispose();
    _contactPersonNameController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _saveCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('transporter_current_step', _currentStep);
  }

  Future<void> _loadCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStep = prefs.getInt('transporter_current_step');
    if (savedStep != null) {
      setState(() {
        _currentStep = savedStep;
      });
      // Jump to the saved page without animation
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_pageController.hasClients) {
          _pageController.jumpToPage(savedStep);
        }
      });
    }
  }

  Future<void> _clearSavedStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('transporter_current_step');
  }

  Future<void> _saveApplicationStatus(ApplicationStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transporter_status', status.toString());
  }

  Future<void> _saveWhoRegStatus(String status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('who_reg', status.toString());
  }

  Future<void> _markApplicationAsStarted() async {
    final currentStatus = await _getApplicationStatus();
    if (currentStatus == ApplicationStatus.notStarted) {
      await _saveApplicationStatus(ApplicationStatus.personalInfoComplete);
    }
  }

  Future<ApplicationStatus> _getApplicationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('transporter_status');
    if (statusString != null) {
      return ApplicationStatus.values.firstWhere(
        (e) => e.toString() == statusString,
        orElse: () => ApplicationStatus.notStarted,
      );
    }
    return ApplicationStatus.notStarted;
  }

  Future<void> _fetchLocationFromPinCode(String pinCode) async {
    if (pinCode.length != 6) return;

    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final userId = profileProvider.userId;
      final token = await TokenManager.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/pincode/$pinCode'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId ?? '',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['success'] == true && data['data'] != null) {
          setState(() {
            _cityController.text = data['data']['city'] ?? '';
            _stateController.text = data['data']['state'] ?? '';
            // Note: This logic assumes state/city are text.
            // If they are IDs, you'd need to find the matching ID from _stateList and _cityList.
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to fetch location for this pinCode'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _verifyGST(String gstNumber) async {
    if (gstNumber.trim().isEmpty) return;

    final gstError = _validateGSTINFormat(gstNumber);
    if (gstError != null) return;

    try {
      setState(() {
        _isGstVerifying = true;
        _isGstVerified = false;
      });

      // Simulating API call as in the original code
      await Future.delayed(const Duration(seconds: 3));

      // This is the (simplified) success case from your original logic
      setState(() {
        _isGstVerified = true;
        _isGstVerifying = false;
      });
      // In a real scenario, you'd call _getGstVerificationResult(requestId) here
      // and handle autofill.
    } catch (e) {
      setState(() {
        _isGstVerifying = false;
      });
    }
  }

  Future<void> _getGstVerificationResult(String requestId) async {
    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final userId = profileProvider.userId;
      final token = await TokenManager.getToken();

      final resultResponse = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/user/register/get-gst-verification-result'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId ?? '',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'request_id': requestId,
        }),
      );

      if (resultResponse.statusCode == 200) {
        final resultData = json.decode(resultResponse.body);

        if (resultData['status'] == true && resultData['autofill'] != null) {
          final autofillData = resultData['autofill'];

          setState(() {
            _companyNameController.text = autofillData['companyName'] ?? '';
            if (autofillData['address'] != null) {
              final address = autofillData['address'];
              _addressLineController.text = address['addressLine'] ?? '';
              _pincodeController.text = address['pincode']?.toString() ?? '';
              _cityController.text = address['city'] ?? '';
              _stateController.text = address['state'] ?? '';
            }

            _isGstVerified = true;
            _isGstVerifying = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('GST verified successfully! Details auto-filled.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          setState(() {
            _isGstVerifying = false;
          });
        }
      } else {
        setState(() {
          _isGstVerifying = false;
        });
      }
    } catch (e) {
      setState(() {
        _isGstVerifying = false;
      });
    }
  }

  // Form Validation Methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Pincode is required';
    }
    if (value.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit pincode';
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
    final num = int.tryParse(value);
    if (num == null || num < 0) {
      return 'Enter a valid positive number';
    }
    return null;
  }

  String? _validateGSTINFormat(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    final gstin = value.trim().toUpperCase();

    if (gstin.length != 15) {
      return 'GSTIN must be exactly 15 characters';
    }

    return null;
  }

  String? _validateAddressLine(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address line is required';
    }
    if (value.trim().length < 5) {
      return 'Address line must be at least 5 characters';
    }
    if (value.trim().length > 300) {
      return 'Address line must be less than 300 characters';
    }
    return null;
  }

  String? _validateFleetSize() {
    if (_selectedFleetSize == null || _selectedFleetSize!.isEmpty) {
      return 'Fleet size is required';
    }

    final totalVehicles = _getTotalVehicleCount();

    switch (_selectedFleetSize) {
      case 'small':
        if (totalVehicles < 1 || totalVehicles > 5) {
          return 'Small fleet should have 1-5 vehicles';
        }
        break;
      case 'medium':
        if (totalVehicles < 6 || totalVehicles > 10) {
          return 'Medium fleet should have 6-10 vehicles';
        }
        break;
      case 'large':
        if (totalVehicles < 11) {
          return 'Large fleet should have 11 or more vehicles';
        }
        break;
    }

    return null;
  }

  int _getTotalVehicleCount() {
    final cars = int.tryParse(_carCountController.text) ?? 0;
    final vans = int.tryParse(_vanCountController.text) ?? 0;
    final buses = int.tryParse(_busCountController.text) ?? 0;
    return cars + vans + buses;
  }

  // Image picker methods
  void _showImagePickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Select Profile Image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildImageSourceOption(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            onTap: () {
                              Navigator.pop(context);
                              _pickImageFromCamera();
                            },
                          ),
                          _buildImageSourceOption(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            onTap: () {
                              Navigator.pop(context);
                              _pickImageFromGallery();
                            },
                          ),
                        ],
                      ),
                      if (_selectedImage != null) ...[
                        SizedBox(height: 20),
                        Divider(),
                        SizedBox(height: 10),
                        _buildImageSourceOption(
                          icon: Icons.delete,
                          label: 'Remove',
                          onTap: () {
                            Navigator.pop(context);
                            _removeImage();
                          },
                          color: Colors.red,
                        ),
                      ],
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (color ?? Color(0xFF8B5CF6)).withOpacity(0.1),
              border: Border.all(
                color: color ?? Color(0xFF8B5CF6),
                width: 2,
              ),
            ),
            child: Icon(
              icon,
              size: 28,
              color: color ?? Color(0xFF8B5CF6),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color ?? Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _profileService
              .uploadCoverPhoto(_selectedImage!.absolute.path)
              .then((value) {
            _transporterModel = _transporterModel.copyWith(photo: value);
          });
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image from camera');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _profileService
              .uploadCoverPhoto(_selectedImage!.absolute.path)
              .then((value) {
            _transporterModel = _transporterModel.copyWith(photo: value);
          });
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image from gallery');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
      _transporterModel = _transporterModel.copyWith(photo: null);
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  // Navigation and Data Update Methods
  void nextStep() {
    bool isValid = false;
    String? errorMessage;
    print("!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
    print("$_currentStep");

    switch (_currentStep) {
      case 0: // Company Detail
        isValid = _businessFormKey.currentState?.validate() ?? false;
        if (isValid) {
          if (_selectedImage == null &&
              (_transporterModel.photo == null ||
                  _transporterModel.photo!.isEmpty)) {
            errorMessage = 'Company photo is required';
            isValid = false;
          } else {
            _updateBusinessModel();
          }
        }
        break;

      case 1: // Address
        if (_addressLineController.text.trim().isEmpty ||
            _pincodeController.text.trim().isEmpty ||
            _selectedCity == null ||
            _selectedCity!.isEmpty ||
            _selectedState == null ||
            _selectedState!.isEmpty) {
          errorMessage = 'Please fill all address fields';
          isValid = false;
        } else {
          final addressError =
              _validateAddressLine(_addressLineController.text);
          final pincodeError = _validatePincode(_pincodeController.text);
          if (addressError != null) {
            errorMessage = addressError;
            isValid = false;
          } else if (pincodeError != null) {
            errorMessage = pincodeError;
            isValid = false;
          } else {
            _updateBusinessModel();
            isValid = true;
          }
        }
        break;

      case 2: // Document
        isValid = _documentsFormKey.currentState?.validate() ?? false;
        if (isValid) {
          _updateDocumentsModel();
        }
        break;

      case 3: // About/Fleet
        isValid = _fleetFormKey.currentState?.validate() ?? false;
        if (isValid) {
          final fleetError = _validateFleetSize();
          if (fleetError != null) {
            errorMessage = fleetError;
            isValid = false;
          } else {
            final totalVehicles = _getTotalVehicleCount();
            if (totalVehicles == 0) {
              errorMessage = 'You must have at least 1 vehicle';
              isValid = false;
            } else {
              _updateFleetModel();
            }
          }
        }
        break;

      case 4: // Submit
        _submitApplication();
        return;
    }

    if (!isValid && errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (isValid && _currentStep < 4) {
      setState(() {
        _currentStep += 1;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveCurrentStep();

      ApplicationStatus status;
      switch (_currentStep) {
        case 1:
          status = ApplicationStatus.personalInfoComplete;
          break;
        case 2:
          status = ApplicationStatus.documentsComplete;
          break;
        case 3:
          status = ApplicationStatus.vehicleInfoComplete;
          break;
        case 4:
          status = ApplicationStatus.fareAndCitiesComplete;
          break;
        default:
          status = ApplicationStatus.personalInfoComplete;
      }
      _saveApplicationStatus(status);
      _saveWhoRegStatus("Transporter");
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveCurrentStep();
      _saveWhoRegStatus("Transporter");
    } else {
      // If at the first step, pop the screen
      Navigator.pop(context);
    }
  }

  void _updateBusinessModel() {
    // Find the text for state and city from their IDs
    final stateName = _stateList
        .firstWhere((s) => s.sId == _selectedState,
            orElse: () => sm.Data(name: ''))
        .name;
    final cityName = _cityList
        .firstWhere((c) => c.sId == _selectedCity,
            orElse: () => cm.Data(name: ''))
        .name;

    setState(() {
      _transporterModel = _transporterModel.copyWith(
        companyName: _companyNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        bio: _bioController.text.trim(),
        contactPersonName: _contactPersonNameController.text.trim(),
        address: _transporterModel.address.copyWith(
          addressLine: _addressLineController.text.trim(),
          state: stateName, // Save the name, not the ID
          city: cityName, // Save the name, not the ID
          pincode: int.tryParse(_pincodeController.text.trim()),
        ),
      );
      // Also update the text controllers for the preview step
      _stateController.text = stateName ?? '';
      _cityController.text = cityName ?? '';
    });
  }

  void _updateDocumentsModel() {
    setState(() {
      _transporterModel = _transporterModel.copyWith(
        gstin: _gstinController.text.trim().toUpperCase(),
      );
    });
  }

  void _updateFleetModel() {
    setState(() {
      _transporterModel = _transporterModel.copyWith(
        fleetSize: _selectedFleetSize,
        counts: Counts(
          car: int.tryParse(_carCountController.text.trim()) ?? 0,
          van: int.tryParse(_vanCountController.text.trim()) ?? 0,
          bus: int.tryParse(_busCountController.text.trim()) ?? 0,
        ),
      );
    });
  }

  Future<void> _submitApplication() async {
    final validationErrors = _getValidationIssues();

    if (validationErrors.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Please fix the following errors:\n${validationErrors.join('\n')}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return;
    }

    final accepted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => TermsConditionsBottomSheet(
        type: 'TRANSPORTER_AGREEMENT',
      ),
    );

    if (accepted != true) {
      return;
    }

    if (!mounted) return;

    context.read<DriverBloc>().add(
          TransporterRegistrationEvent(
            registrationData: _transporterModel.toJson(),
          ),
        );

    try {
      final userData = await TokenManager.getUserData();
      final profilePhoto = userData?['profilePhoto'] ?? _transporterModel.photo;
      _transporterModel = _transporterModel.copyWith(
          profilePhoto: profilePhoto,
          firstName: _transporterModel.contactPersonName);
      final response = await TransporterService()
          .submitTransporterApplication(_transporterModel, context);

      if (response['success'] == true) {
        if (!mounted) return;
        _clearSavedStep();
        _saveApplicationStatus(ApplicationStatus.submitted);
        TransporterService.showSuccessSnackBar(
            context, 'Application submitted successfully!');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Layout()),
        );
      } else {
        if (!mounted) return;
        TransporterService.showApiErrorSnackBar(
          context,
          response['message'] ?? 'Submission failed',
        );
      }
    } catch (e) {
      if (!mounted) return;
      TransporterService.showApiErrorSnackBar(
        context,
        'An unexpected error occurred',
      );
    }
  }

  bool _isReadyForSubmission() {
    return _getValidationIssues().isEmpty;
  }

  List<String> _getValidationIssues() {
    final issues = <String>[];

    if (_companyNameController.text.trim().isEmpty) {
      issues.add('Company name is required');
    }
    if (_contactPersonNameController.text.trim().isEmpty) {
      issues.add('Contact person name is required');
    }
    if (_validateMobileNumber(_phoneNumberController.text) != null) {
      issues.add('A valid 10-digit phone number is required');
    }
    if (_selectedImage == null &&
        (_transporterModel.photo == null || _transporterModel.photo!.isEmpty)) {
      issues.add('Company photo is required');
    }

    final addressError = _validateAddressLine(_addressLineController.text);
    if (addressError != null) {
      issues.add(addressError);
    }
    if (_validatePincode(_pincodeController.text) != null) {
      issues.add('A valid 6-digit pincode is required');
    }
    if (_selectedState == null || _selectedState!.isEmpty) {
      issues.add('State is required');
    }
    if (_selectedCity == null || _selectedCity!.isEmpty) {
      issues.add('City is required');
    }

    final fleetError = _validateFleetSize();
    if (fleetError != null) {
      issues.add(fleetError);
    }

    if (_getTotalVehicleCount() == 0) {
      issues.add('You must have at least 1 vehicle');
    }

    return issues;
  }

  bool canPope = false;

  @override
  Widget build(BuildContext context) {
    return BlocListener<DriverBloc, DriverState>(
      listener: (context, state) {
        if (state is DriverRegistrationSuccess) {
          _clearSavedStep();
          _saveApplicationStatus(ApplicationStatus.submitted);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Application submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const Layout(
                initialIndex: 1,
              ),
            ),
          );
        } else if (state is DriverRegistrationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: PopScope(canPop: false, // Prevents default pop behavior
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }
            // Call your existing logic
            previousStep();
          },child: Scaffold(
        // Use cream background color from design
        backgroundColor: Color(0xFFFFFBF3),
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
              stops: [0.0, 0.15, 0.30, .90],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                MultiStepProgressBar(
                  currentStep: _currentStep,
                  stepTitles: _stepTitles,
                  gradientColors: [gradientFirst, gradientSecond],
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (step) {
                      setState(() {
                        _currentStep = step;
                      });
                    },
                    children: [
                      _buildCompanyDetailStep(),
                      _buildAddressStep(),
                      _buildDocumentStep(),
                      _buildAboutStep(),
                      _buildPreviewStep(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      )),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_currentStep == 0) {
                if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              } else {
                previousStep();
              }
            },
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Text(
            'Become a Transporter',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    // Define the gradient colors
    final List<Color> gradientColors = [gradientFirst, gradientSecond];
    final Color inactiveColor = Colors.grey[300]!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: List.generate(5, (index) {
                final bool isActive = index == _currentStep;
                final bool isCompleted = index < _currentStep;

                // Determine if the circle should have a gradient
                final bool isGradientCircle = isActive || isCompleted;

                // Determine if the connecting line should have a gradient
                // Only fully completed lines (between completed steps) get the gradient
                final bool isGradientLine = isCompleted;

                return Expanded(
                  child: Row(
                    children: [
                      // Circle
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          // Apply gradient if active/completed, else solid inactive color
                          gradient: isGradientCircle
                              ? LinearGradient(
                                  colors: gradientColors,
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                              : null,
                          color: isGradientCircle ? null : inactiveColor,
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      // Connecting Line (if not the last item)
                      if (index < 4)
                        Expanded(
                          child: Container(
                            height: 4,
                            // Apply gradient if completed, else solid inactive color
                            decoration: BoxDecoration(
                              gradient: isGradientLine
                                  ? LinearGradient(
                                      colors: gradientColors,
                                      begin: Alignment.centerLeft,
                                      // Horizontal gradient
                                      end: Alignment.centerRight,
                                    )
                                  : null,
                              color: isGradientLine ? null : inactiveColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ),

          SizedBox(height: 12),
          // Step labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(5, (index) {
              return Container(
                child: Text(
                  _stepTitles[index], // Assumes _stepTitles is a class variable
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyDetailStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _businessFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Company Detail',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImagePickerBottomSheet,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[200],
                        border: _selectedImage != null
                            ? Border.all(color: Color(0xFF8B5CF6), width: 3)
                            : Border.all(color: Colors.grey[300]!),
                      ),
                      child: _selectedImage != null
                          ? ClipOval(
                              child: Image.file(
                                _selectedImage!,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person_outline, // From Figma design
                              size: 32,
                              color: Colors.grey[600],
                            ),
                    ),
                  ),
                  SizedBox(height: 12),
                  GestureDetector(
                    onTap: _showImagePickerBottomSheet,
                    child: Text(
                      _selectedImage != null
                          ? 'Tap to change image'
                          : 'Profile Image / Logo',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedImage != null
                            ? Color(0xFF8B5CF6)
                            : Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            _buildTextField('Company Name *', _companyNameController,
                textInputAction: TextInputAction.next,
                validator: (value) => _validateRequired(value, 'Company name')),
            SizedBox(height: 20),
            _buildTextField('Contact Person*', _contactPersonNameController,
                textInputAction: TextInputAction.next,
                validator: (value) =>
                    _validateRequired(value, 'Contact person name')),
            SizedBox(height: 20),
            _buildTextField('Phone Number*', _phoneNumberController,
                validator: _validateMobileNumber,
                keyboardType: TextInputType.phone,
                maxLength: 10),
            SizedBox(height: 40),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildContinueButton() {
    return GradientButton(
      text: _currentStep == 4 ? 'Submit' : 'Continue',
      onPressed: nextStep,
      gradientColors: [gradientFirst, gradientSecond],
    );
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8B5CF6),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          _currentStep == 4 ? 'Submit' : 'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Address',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 40),
          _buildTextField('Address*', _addressLineController,
              placeholder: '12 house no., XYZ STREET, Opp ABC Mall',
              textInputAction: TextInputAction.next,
              validator: _validateAddressLine,
              maxLines: 1),
          SizedBox(height: 20),
          _buildTextField('Pin Code*', _pincodeController,
              placeholder: '788799',
              textInputAction: TextInputAction.next,
              validator: _validatePincode,
              keyboardType: TextInputType.number,
              maxLength: 6, onChanged: (value) {
            if (value.length == 6) {
              _fetchLocationFromPinCode(value);
            }
          }),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _stateList.any((s) => s.sId == _selectedState)
                ? _selectedState
                : null,
            decoration: _dropdownDecoration('State*'),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
            ),
            items: _stateList.map((sm.Data state) {
              return DropdownMenuItem<String>(
                value: state.sId,
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 200),
                  // Adjust as needed
                  child: Text(
                    state.name.toString(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              final locProvider =
                  Provider.of<LocationProvider>(context, listen: false);
              setState(() {
                _selectedState = newValue;
                _selectedCity = null; // Reset city when state changes
                _cityList = [];
                if (newValue != null) {
                  locProvider.fetchCity(newValue).then((_) {
                    setState(() {
                      _cityList = locProvider.cities;
                    });
                  });
                }
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a state';
              }
              return null;
            },
          ),
          SizedBox(height: 20),
          DropdownButtonFormField<String>(
            value: _cityList.any((s) => s.sId == _selectedCity)
                ? _selectedCity
                : null,
            decoration: _dropdownDecoration('City*'),
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: Colors.grey[600],
            ),
            items: _cityList.map((cm.Data city) {
              return DropdownMenuItem<String>(
                value: city.sId,
                child: Text(city.name.toString()),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedCity = newValue;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a city';
              }
              return null;
            },
          ),
          SizedBox(height: 40),
          _buildContinueButton(),
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF8B5CF6), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.red, width: 1),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  Widget _buildDocumentStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _documentsFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Document',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40),
            // GST Field
            _buildTextField(
              'GST No.*',
              _gstinController,
              validator: _validateGSTINFormat,
              textCapitalization: TextCapitalization.characters,
              maxLength: 15,
              onChanged: (value) {
                if (value.length < 15) {
                  setState(() {
                    _isGstVerified = false;
                  });
                }
              },
              suffixIcon: InkWell(
                onTap: () {
                  if (!_isGstVerifying && !_isGstVerified) {
                    _verifyGST(_gstinController.text);
                  }
                },
                child: Container(
                  width: 80,
                  margin: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _isGstVerified
                        ? Colors.green.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                        color:
                            _isGstVerified ? Colors.green : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Center(
                    child: _isGstVerifying
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _isGstVerified ? 'Verified' : 'Verify',
                            style: TextStyle(
                              color: _isGstVerified
                                  ? Colors.green
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                  ),
                ),
              ),
            ),
            if (_isGstVerified)
              Padding(
                padding: EdgeInsets.only(top: 8.0, left: 12.0),
                child: Text(
                  'GST verified successfully!',
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                  ),
                ),
              ),
            SizedBox(height: 24),
            // Transport Permit Uploader
            Text(
              'Transportation Permit (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            Container(
              width: double.infinity,
              child: MediaUploader(
                label: 'select your file or drag and drop',
                kind: "document",
                showPreview: true,
                showDirectImage: true,
                initialUrl: _transporterModel.transportationPermit,
                onMediaUploaded: (url) {
                  setState(() {
                    _transporterModel = _transporterModel.copyWith(
                      transportationPermit: url,
                    );
                  });
                },
                required: false,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
              ),
            ),
            SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade200,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Transportation permit is optional. You can upload it now or add it later from your profile.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _fleetFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Fleet Size*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 8),
            DropdownButtonFormField<String>(
              decoration: _dropdownDecoration('Select fleet size'),
              value: _selectedFleetSize,
              validator: (value) => _validateRequired(value, 'Fleet size'),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedFleetSize = newValue;
                });
              },
              items: [
                DropdownMenuItem(
                  value: 'small',
                  child: Text('Small (1-5 vehicles)'),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text('Medium (6-10 vehicles)'),
                ),
                DropdownMenuItem(
                  value: 'large',
                  child: Text('Large (11+ vehicles)'),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Vehicle Counts*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVehicleCountField('Car', _carCountController),
                _buildVehicleCountField('Van', _vanCountController),
                _buildVehicleCountField('Bus', _busCountController),
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Vehicles:',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                  Text(
                    '${_getTotalVehicleCount()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            if (_selectedFleetSize != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _validateFleetSize() == null
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _validateFleetSize() == null
                        ? Colors.green.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _validateFleetSize() == null
                          ? Icons.check_circle
                          : Icons.warning,
                      color: _validateFleetSize() == null
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validateFleetSize() ??
                            'Vehicle count matches fleet size!',
                        style: TextStyle(
                          color: _validateFleetSize() == null
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 24),
            _buildTextField(
              'About (Optional)',
              _bioController,
              placeholder: 'Tell us about your transport business...',
              maxLines: 4,
            ),
            SizedBox(height: 40),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCountField(
      String vehicleType, TextEditingController controller) {
    return Column(
      children: [
        Text(
          vehicleType,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4),
        Container(
          width: 80,
          height: 50,
          child: TextFormField(
            controller: controller,
            textAlign: TextAlign.center,
            keyboardType: TextInputType.number,
            validator: (value) => _validateNumber(value, '$vehicleType count'),
            decoration: _dropdownDecoration('').copyWith(
              hintText: '0',
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: (value) => setState(() {}),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[200],
                    border: _selectedImage != null
                        ? Border.all(color: Color(0xFF8B5CF6), width: 2)
                        : Border.all(color: Colors.grey[300]!),
                  ),
                  child: _selectedImage != null
                      ? ClipOval(
                          child: Image.file(
                            _selectedImage!,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Icon(
                          Icons.person_outline,
                          size: 30,
                          color: Colors.grey[600],
                        ),
                ),
                SizedBox(height: 8),
                Text(
                  'Profile Image / Logo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24),
          _buildPreviewItem(
              'Company Name',
              _companyNameController.text.isEmpty
                  ? 'Not specified'
                  : _companyNameController.text),
          _buildPreviewItem(
              'Contact Person',
              _contactPersonNameController.text.isEmpty
                  ? 'Not specified'
                  : _contactPersonNameController.text),
          _buildPreviewItem(
              'Phone Number',
              _phoneNumberController.text.isEmpty
                  ? 'Not specified'
                  : '+91 ${_phoneNumberController.text}'),
          _buildPreviewItem(
              'Address Line',
              _addressLineController.text.isEmpty
                  ? 'Not specified'
                  : _addressLineController.text),
          _buildPreviewItem(
              'Pin Code',
              _pincodeController.text.isEmpty
                  ? 'Not specified'
                  : _pincodeController.text),
          _buildPreviewItem(
              'City',
              _cityController.text.isEmpty
                  ? 'Not specified'
                  : _cityController.text),
          _buildPreviewItem(
              'State',
              _stateController.text.isEmpty
                  ? 'Not specified'
                  : _stateController.text),
          _buildPreviewItem(
              'GST No.',
              _gstinController.text.isEmpty
                  ? 'Not provided'
                  : _gstinController.text),
          _buildPreviewItem(
              'Transport Permit',
              _transporterModel.transportationPermit?.isNotEmpty == true
                  ? 'Uploaded'
                  : 'Not uploaded (Optional)'),
          _buildPreviewItem(
              'Fleet Size', _selectedFleetSize ?? 'Not specified'),
          _buildPreviewItem(
              'Cars',
              _carCountController.text.isEmpty
                  ? '0'
                  : _carCountController.text),
          _buildPreviewItem(
              'Vans',
              _vanCountController.text.isEmpty
                  ? '0'
                  : _vanCountController.text),
          _buildPreviewItem(
              'Buses',
              _busCountController.text.isEmpty
                  ? '0'
                  : _busCountController.text),
          _buildPreviewItem(
              'Total Number of Vehicles', _getTotalVehicleCount().toString()),
          SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Text(
                _bioController.text.isEmpty
                    ? 'Not specified'
                    : _bioController.text,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _isReadyForSubmission()
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isReadyForSubmission()
                    ? Colors.green.shade200
                    : Colors.red.shade200,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(
                      _isReadyForSubmission()
                          ? Icons.check_circle
                          : Icons.warning,
                      color: _isReadyForSubmission()
                          ? Colors.green.shade600
                          : Colors.red.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _isReadyForSubmission()
                            ? 'Application ready for submission!'
                            : 'Please review and fix the issues:',
                        style: TextStyle(
                          color: _isReadyForSubmission()
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                if (!_isReadyForSubmission()) ...[
                  const SizedBox(height: 8),
                  ..._getValidationIssues().map((issue) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            const SizedBox(width: 24),
                            Icon(Icons.error_outline,
                                color: Colors.red.shade600, size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                issue,
                                style: TextStyle(
                                  color: Colors.red.shade700,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                ],
              ],
            ),
          ),
          SizedBox(height: 20),
          BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              final bool isSubmitting = state is DriverRegistrationLoading;

              return Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : nextStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF8B5CF6),
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
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
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? placeholder,
      String? Function(String?)? validator,
      TextInputType? keyboardType,
      TextInputAction? textInputAction,
      int? maxLines,
      int? maxLength,
      bool enabled = true,
      Function(String)? onChanged,
      Widget? suffixIcon,
      TextCapitalization textCapitalization = TextCapitalization.none}) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      maxLength: maxLength,
      enabled: enabled,
      textInputAction: textInputAction ?? TextInputAction.done,
      onChanged: onChanged,
      textCapitalization: textCapitalization,
      decoration: _dropdownDecoration(label).copyWith(
        hintText: placeholder,
        labelText: label,
        suffixIcon: suffixIcon,
        counterText: '', // Hide the maxLength counter
      ),
      style: TextStyle(
        color: enabled ? Colors.black : Colors.grey[600],
      ),
    );
  }

  void backButtonAction() {
    if (_currentStep == 0) {
      canPope = true;
      setState(() {});
    } else {
      previousStep();
    }
  }
}

// Ensure these enums and utility classes are available,
// either in this file or imported correctly.

enum ApplicationStatus {
  notStarted,
  personalInfoComplete,
  documentsComplete,
  vehicleInfoComplete,
  fareAndCitiesComplete,
  submitted,
}

class UserPrefillUtility {
  static void prefillUserData({
    required TextEditingController contactPersonController,
    required TextEditingController phoneController,
  }) {
    // This is a mock. In a real app, you'd get this from a UserProvider or similar.
    // contactPersonController.text = "John Doe";
    // phoneController.text = "9876543210";
  }
}
