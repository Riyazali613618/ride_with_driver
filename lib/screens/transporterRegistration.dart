import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rwd/api/api_model/cityModel.dart' as cm;
import 'package:rwd/api/api_model/stateModel.dart' as sm;
import 'package:rwd/api/api_model/user_model/my_profile_model.dart' hide Counts;
import 'package:rwd/constants/api_constants.dart';
import 'package:rwd/screens/commonWidgets/city_dropdown_widget.dart';
import 'package:rwd/screens/layout.dart';
import 'package:rwd/screens/registrationSyccessfulScreen.dart';
import 'package:rwd/screens/widgets/common_submit_button.dart';
import 'package:rwd/utils/common_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_model/registrations/transporter_model.dart';
import '../../api/api_service/registration_services/transporter_service.dart';
import '../../bloc/driver/driver_bloc.dart';
import '../../bloc/driver/driver_event.dart';
import '../../bloc/driver/driver_state.dart';
import '../../constants/token_manager.dart';
import '../api/api_model/user_model/user_eligibility_model.dart';
import '../api/api_service/countryStateProviderService.dart';
import '../api/api_service/media_service.dart';
import '../api/api_service/user_service/user_profile_service.dart';
import '../components/app_loader.dart';
import '../constants/color_constants.dart';
import '../utils/color.dart';
import 'block/provider/profile_provider.dart';
import 'commonWidgets/state_dropdown_widget.dart';
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

  final _carCountController = TextEditingController(text: '');
  final _vanCountController = TextEditingController(text: '');
  final _suvCountController = TextEditingController(text: '');
  final _busCountController = TextEditingController(text: '');
  final _totalVehicleCountController = TextEditingController(text: '');

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
  MyProfileData? profile;

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
    _loadTransporterData();
    //_loadCurrentStep();
    _markApplicationAsStarted();
  }

  Future<void> _prefillData() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      profile = await TokenManager.getProfile();
      if (profile == null) return;
      _contactPersonNameController.text =
          "${profile?.firstName ?? ""} ${profile?.lastName ?? ""}";
      _phoneNumberController.text =
          profile?.mobileNumber ?? profile?.businessMobileNumber ?? "";
      _transporterModel = _transporterModel.copyWith(
        firstName: profile?.firstName ?? '',
        lastName: profile?.lastName ?? '',
        contactPersonName: _contactPersonNameController.text.toString().trim(),
        phoneNumber: _phoneNumberController.text.toString().trim(),
      );
      setState(() {});
    });
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

  Future<void> _saveTransporterData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('transporter_data', jsonEncode(_transporterModel));
    _saveCurrentStep();
  }

  Future<void> _loadTransporterData() async {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        try {
          final prefs = await SharedPreferences.getInstance();
          String data = prefs.getString('transporter_data') ?? '';
          /*if (data.isNotEmpty) {
            _transporterModel = TransporterModel.fromJson(jsonDecode(data));
            _transporterModel = _transporterModel.copyWith(photo: "");
          } else*/
          {
            profile ??= await TokenManager.getProfile();
            if (profile != null) {
              _transporterModel.copyWith(
                  firstName: profile?.firstName ?? "",
                  lastName: profile?.lastName ?? "",
                  companyName: profile?.companyName ?? "",
                  bio: profile?.bio ?? "",
                  phoneNumber: profile?.mobileNumber ?? "",
                  gstin: profile?.gstin ?? "",
                  address: _transporterModel.address.copyWith(
                    addressLine: profile?.address?.addressLine ?? "",
                    city: profile?.address?.city ?? "",
                    state: profile?.address?.state ?? "",
                    pincode: profile?.address?.pincode,
                  ));

              _addressLineController.text = profile?.address?.addressLine ?? "";
              _pincodeController.text =
                  profile?.address?.pincode!.toString() ?? "";
              if (_stateList.isNotEmpty) {
                String stateId = profile?.address?.state!.toString() ?? "";
                for (final state in _stateList) {
                  if (state.sId == stateId) {
                    _selectedState = state.name;
                    break;
                  }
                }
              }
              if (_cityList.isNotEmpty) {
                String cityId = profile?.address?.city!.toString() ?? "";
                for (final city in _cityList) {
                  if (city.sId == cityId) {
                    _selectedCity = city.name;
                    break;
                  }
                }
              }
            }
          }
          populateData();
        } catch (e) {
          print(e);
        }
      },
    );
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
    if (gstNumber.trim().isEmpty) {
      return;
    }

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
    final suv = int.tryParse(_suvCountController.text) ?? 0;
    return cars + vans + buses + suv;
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
    _saveTransporterData();

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
      _saveTransporterData();
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
      _saveTransporterData();
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
        bio: _bioController.text.trim().isEmpty
            ? "bio"
            : _bioController.text.trim(),
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

  bool isSubmitting = false;

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
    String orderId = "";
    String paymentId = "";
    String subscriptionPlanId = "";

    if (!mounted) return;
    bool isUpgrade = await getUserProfile();
    if (isUpgrade) {
      final data = await getEligibilityData();
      if (data.data != null) {
        subscriptionPlanId = data.data?.subscriptionId ?? "";
        paymentId = data.data?.paymentId ?? "";
        orderId = data.data?.orderId ?? "";
      }
    }

    context.read<DriverBloc>().add(
          TransporterRegistrationEvent(
            registrationData: _transporterModel.toJson(),
          ),
        );

    try {
      isSubmitting = true;
      updateState();
      final userData = await TokenManager.getUserData();
      if (_transporterModel.photo != null &&
          _transporterModel.photo!.isNotEmpty &&
          !_transporterModel.photo!.startsWith("https")) {
        final XFile photo = XFile(_transporterModel.photo ?? "");
        final photoUrl = await MediaService()
            .uploadMedia(photo, kind: "coverImage", type: "coverImage");
        _transporterModel =
            _transporterModel.copyWith(photo: photoUrl.url ?? "");
      }
      final profilePhoto = userData?['profilePhoto'] ?? _transporterModel.photo;
      if (permit != null) {
        final XFile photo = XFile(permit!.path);
        final documentUrl = await MediaService()
            .uploadMedia(photo, kind: "document", type: "document");
        _transporterModel = _transporterModel.copyWith(
            transportationPermit: documentUrl.url ?? "");
      }
      _transporterModel = _transporterModel.copyWith(
          profilePhoto: profilePhoto,
          firstName: _transporterModel.contactPersonName,
          bio: _bioController.text.trim().isEmpty
              ? "bio"
              : _bioController.text.trim(),
          lastName: (_transporterModel.lastName ?? "").isEmpty
              ? "aa"
              : _transporterModel.lastName!);
      final response = isUpgrade
          ? await TransporterService().submitUpgradeTransporterApplication(
              _transporterModel,
              context,
              "become-upgradable",
              subscriptionPlanId,
              paymentId,
              orderId)
          : await TransporterService().submitTransporterApplication(
              _transporterModel, context, "become-transporter");
      isSubmitting = false;
      updateState();
      if (response['success'] == true) {
        if (!mounted) return;
        _clearSavedStep();
        _saveApplicationStatus(ApplicationStatus.submitted);
        TransporterService.showSuccessSnackBar(
            context, 'Application submitted successfully!');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  const RegistrationSuccessfulScreen(userType: "Transporter")),
        );
      } else {
        if (!mounted) return;
        TransporterService.showApiErrorSnackBar(
          context,
          response['message'] ?? 'Submission failed',
        );
      }
    } catch (e) {
      isSubmitting = false;
      updateState();
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
      child: PopScope(
          canPop: false, // Prevents default pop behavior
          onPopInvoked: (didPop) {
            if (didPop) {
              return;
            }
            // Call your existing logic
            previousStep();
          },
          child: Scaffold(
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
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                    Colors.white,
                  ],
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
              style: CommonUtils.commonTitleStyle(
                  fontSize: 20, weight: FontWeight.w400, color: Colors.black),
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
                        fontFamily: AppConstants.ptSansFont,
                        fontWeight: FontWeight.w400,
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
    return Container(
      alignment: Alignment.bottomRight,
      child: CommonSubmitButton(
        gradientColors: [gradientFirst, gradientSecond],
        onPressed: nextStep,
        text: _currentStep == 4 ? 'Submit' : 'Continue',
        borderRadius: 12,
        isLoading: false,
      ),
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
              fontSize: 20,
              fontFamily: AppConstants.ptSansFont,
              fontWeight: FontWeight.w400,
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
          Text(
            "State*",
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          SizedBox(height: 8),
          StateDropdownWidget(
            stateList: _stateList,
            selectedState: _selectedState,
            onChanged: (newValue) {
              final locProvider =
                  Provider.of<LocationProvider>(context, listen: false);

              setState(() {
                _selectedState = newValue;
                _selectedCity = null;
                _cityList = [];
              });

              if (newValue != null) {
                locProvider.fetchCity(newValue).then((_) {
                  setState(() {
                    _cityList = locProvider.cities;
                  });
                });
              }
            },
          ),
          SizedBox(height: 20),
          Text(
            "City*",
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          SizedBox(height: 8),
          CityDropdownWidget(
            cityList: _cityList,
            selectedCity: _selectedCity,
            onChanged: (newValue) {
              setState(() {
                _selectedCity = newValue;
              });
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
      labelText: "",
      labelStyle: TextStyle(
        color: Colors.grey[600],
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderSide: BorderSide(color: ColorConstants.inputFieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorConstants.inputFieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorConstants.inputFieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      errorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorConstants.inputFieldBorderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                fontSize: 20,
                fontFamily: AppConstants.ptSansFont,
                fontWeight: FontWeight.w400,
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
                  width: 70,
                  margin: EdgeInsets.symmetric(horizontal: 6, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    border: Border.all(
                        color: _isGstVerified
                            ? Color(0xFF1FAF38)
                            : Color(0xFF1FAF38)),
                    borderRadius: BorderRadius.circular(30),
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
                              fontFamily: AppConstants.ptSansFont,
                              color: _isGstVerified
                                  ? Color(0xFF1FAF38)
                                  : Color(0xFF1FAF38),
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

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Transportation Permit (Optional)',
                  style: CommonUtils.commonTextLabelsStyle(),
                ),
                SizedBox(height: 8),
                Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: ColorConstants.inputFieldBorderColor),
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
                          _showDocumentPickerBottomSheet();
                        },
                      ),
                      if (permit != null)
                        _showPermitImage()
                      else
                        SizedBox(
                          height: 10,
                        )
                    ],
                  ),
                ),
              ],
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

  Widget _showPermitImage() {
    return Stack(
      children: [
        Container(
            clipBehavior: Clip.hardEdge,
            margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.grey.shade400,
              border: Border.all(color: AppColors.blue, width: 1),
            ),
            child: Image.file(
              File(permit?.path ?? ""),
              width: 50,
              fit: BoxFit.cover,
              height: 50,
            )),
        Positioned(
            right: 5,
            top: 12,
            child: GestureDetector(
              onTap: () {
                permit = null;
                updateState();
              },
              child: SvgPicture.asset(
                "assets/svg/cross.svg",
                width: 15,
                height: 15,
              ),
            ))
      ],
    );
  }

  void _showDocumentPickerBottomSheet() {
    FocusManager.instance.primaryFocus?.unfocus();

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
                        'Upload Document',
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
                          _buildDocumentSourceOption(
                            icon: Icons.camera_alt,
                            label: 'Camera',
                            onTap: () {
                              Navigator.pop(context);
                              _pickDocumentFromCamera();
                            },
                          ),
                          _buildDocumentSourceOption(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            onTap: () {
                              Navigator.pop(context);
                              _pickDocumentFromGallery();
                            },
                          ),
                        ],
                      ),
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

  XFile? permit;

  Future<void> _pickDocumentFromCamera() async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        permit = image;
        updateState();
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture document from camera');
    }
  }

  Future<void> _pickDocumentFromGallery() async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        permit = image;
        updateState();
        // _showSuccessSnackBar('Document selected from gallery');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick document from gallery');
    }
  }

  Widget _buildDocumentSourceOption({
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
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gradientFirst.withOpacity(0.2),
                  gradientSecond.withOpacity(0.2),
                ],
              ),
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
                fontSize: 20,
                fontFamily: AppConstants.ptSansFont,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 40),
            Text(
              'Fleet Size*',
              style: CommonUtils.commonTextLabelsStyle(),
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
                  child: Text(
                    'Small (1-5 vehicles)',
                    style: CommonUtils.commonTextLabelsStyle(),
                  ),
                ),
                DropdownMenuItem(
                  value: 'medium',
                  child: Text(
                    'Medium (6-10 vehicles)',
                    style: CommonUtils.commonTextLabelsStyle(),
                  ),
                ),
                DropdownMenuItem(
                  value: 'large',
                  child: Text(
                    'Large (11+ vehicles)',
                    style: CommonUtils.commonTextLabelsStyle(),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Vehicle Counts*',
              style: CommonUtils.commonTextLabelsStyle(),
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVehicleCountField(),
                /* _buildVehicleCountField('Van', _vanCountController),
                _buildVehicleCountField('Bus', _busCountController),*/
              ],
            ),
            SizedBox(height: 24),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: Border.all(color: ColorConstants.inputFieldBorderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextField(
                textAlign: TextAlign.start,
                maxLength: 2,
                buildCounter: (
                  context, {
                  required int currentLength,
                  required bool isFocused,
                  required int? maxLength,
                }) {
                  return null; // 👈 hides the counter
                },
                style: CommonUtils.commonInputTextStyle(),
                readOnly: true,
                controller: _totalVehicleCountController,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                keyboardType: TextInputType.phone,
                decoration: InputDecoration.collapsed(
                  hintText: '0',
                  hintStyle: CommonUtils.commonHintTextStyle(),
                ),
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
              placeholder:
                  'Briefly describe your transport business. Mention the type of vehicles you operate, service areas, years of experience, and what makes your service reliable (on-time service, clean vehicles, professional drivers, etc.).',
              maxLines: 5,
            ),
            SizedBox(height: 40),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleCountField() {
    double boxWidth = 36;
    double boxHeight = 43;

    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Row(
        children: [
          Text(
            "Car",
            style: vehicleCountStyle(),
          ),
          SizedBox(width: 4),
          GestureDetector(
            child: Container(
              width: boxWidth,
              alignment: Alignment.center,
              height: boxHeight,
              decoration: BoxDecoration(
                border: Border.all(color: ColorConstants.inputFieldBorderColor),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.center,
                  maxLength: 2,
                  style: vehicleCountStyle(),
                  buildCounter: (
                    context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return null; // 👈 hides the counter
                  },
                  controller: _carCountController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    updateVehicleCount();
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration.collapsed(
                    hintText: '0',
                    hintStyle: vehicleCountStyle(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        width: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "SUV",
            style: vehicleCountStyle(),
          ),
          SizedBox(width: 4),
          GestureDetector(
            child: Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                border: Border.all(color: ColorConstants.inputFieldBorderColor),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.center,
                  maxLength: 2,
                  style: vehicleCountStyle(),
                  buildCounter: (
                    context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return null; // 👈 hides the counter
                  },
                  onChanged: (value) {
                    updateVehicleCount();
                  },
                  controller: _suvCountController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration.collapsed(
                    hintText: '0',
                    hintStyle: vehicleCountStyle(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        width: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Mini Van",
            style: vehicleCountStyle(),
          ),
          SizedBox(width: 4),
          GestureDetector(
            child: Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                border: Border.all(color: ColorConstants.inputFieldBorderColor),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.center,
                  maxLength: 2,
                  style: vehicleCountStyle(),
                  buildCounter: (
                    context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return null; // 👈 hides the counter
                  },
                  controller: _vanCountController,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  onChanged: (value) {
                    updateVehicleCount();
                  },
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration.collapsed(
                    hintText: '0',
                    hintStyle: vehicleCountStyle(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(
        width: 10,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Text(
            "Bus",
            style: vehicleCountStyle(),
          ),
          SizedBox(width: 4),
          GestureDetector(
            child: Container(
              width: boxWidth,
              height: boxHeight,
              decoration: BoxDecoration(
                border: Border.all(color: ColorConstants.inputFieldBorderColor),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: Center(
                child: TextField(
                  textAlign: TextAlign.center,
                  maxLength: 2,
                  style: vehicleCountStyle(),
                  buildCounter: (
                    context, {
                    required int currentLength,
                    required bool isFocused,
                    required int? maxLength,
                  }) {
                    return null; // 👈 hides the counter
                  },
                  controller: _busCountController,
                  onChanged: (value) {
                    updateVehicleCount();
                  },
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration.collapsed(
                    hintText: '0',
                    hintStyle: vehicleCountStyle(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ]);
  }

  int totalVehicles = 0;

  void updateVehicleCount() {
    int car = _carCountController.text.toString().isNotEmpty
        ? int.parse(_carCountController.text.toString())
        : 0;
    int bus = _busCountController.text.toString().isNotEmpty
        ? int.parse(_busCountController.text.toString())
        : 0;
    int van = _vanCountController.text.toString().isNotEmpty
        ? int.parse(_vanCountController.text.toString())
        : 0;
    int suv = _suvCountController.text.toString().isNotEmpty
        ? int.parse(_suvCountController.text.toString())
        : 0;

    totalVehicles = car + bus + van + suv;
    _totalVehicleCountController.text = totalVehicles.toString();
  }

  vehicleCountStyle() {
    return TextStyle(
      fontSize: 10,
      color: Color(0xFF9E9E9E),
    );
  }

  Widget _buildPreviewStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Preview',
            style: TextStyle(
              fontFamily: AppConstants.ptSansFont,
              fontSize: 20,
              fontWeight: FontWeight.w400,
              color: Colors.black,
            ),
          ),
          Expanded(
              child: ListView(
            children: [
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
                        fontFamily: AppConstants.ptSansFont,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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
              _buildPreviewItem('Total Number of Vehicles',
                  _getTotalVehicleCount().toString()),
              SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About',
                    style: TextStyle(
                      fontFamily: AppConstants.ptSansFont,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _bioController.text.isEmpty
                        ? 'Not specified'
                        : _bioController.text,
                    style: TextStyle(
                      fontFamily: AppConstants.ptSansFont,
                      fontSize: 12,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
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
            ],
          )),
          BlocBuilder<DriverBloc, DriverState>(
            builder: (context, state) {
              final bool isLoading = state is DriverRegistrationLoading;

              return SizedBox(
                width: double.infinity,
                child: Container(
                  alignment: Alignment.bottomRight,
                  child: CommonSubmitButton(
                    gradientColors: [gradientFirst, gradientSecond],
                    onPressed: isSubmitting ? null : nextStep,
                    text: "Submit",
                    borderRadius: 12,
                    isLoading: isSubmitting,
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
            flex: 5,
            child: Text(
              label,
              style: CommonUtils.commonTitleStyle(
                  color: Colors.black, fontSize: 12, weight: FontWeight.w700),
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: CommonUtils.commonTitleStyle(
                  color: Colors.black, fontSize: 12, weight: FontWeight.w400),
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
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(
        label,
        style: CommonUtils.commonTextLabelsStyle(),
      ),
      SizedBox(height: 8),
      Container(
        child: TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines ?? 1,
          maxLength: maxLength,
          enabled: enabled,
          textInputAction: textInputAction ?? TextInputAction.done,
          onChanged: onChanged,
          textCapitalization: textCapitalization,
          decoration: _dropdownDecoration("").copyWith(
            hintText: placeholder ?? '',
            hintStyle: CommonUtils.commonHintTextStyle(),
            suffixIcon: suffixIcon,
          ),
          buildCounter: (
            context, {
            required int currentLength,
            required bool isFocused,
            required int? maxLength,
          }) {
            return null; // 👈 hides the counter
          },
          style: CommonUtils.commonInputTextStyle(),
        ),
      ),
    ]);
  }

  void backButtonAction() {
    if (_currentStep == 0) {
      canPope = true;
      setState(() {});
    } else {
      previousStep();
    }
  }

  Future<bool> getUserProfile() async {
    final data = await UserProfileService().getUserProfile();
    final prefs = await SharedPreferences.getInstance();
    if (data!.subscriptions != null && data!.subscriptions!.isNotEmpty) {
      for (var sub in data!.subscriptions!) {
        if ((sub.status ?? "").toLowerCase() == "active" &&
            (sub.isUpgrade ?? false)) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  Future<UserEligibilityModel> getEligibilityData() async {
    final data = await UserProfileService().getEligibility();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstants.planEligibilityKey, jsonEncode(data.data));
    return data;
  }

  void populateData() {
    _companyNameController.text = _transporterModel.companyName ?? "";
    _phoneNumberController.text = _transporterModel.phoneNumber ?? "";
    _bioController.text = _transporterModel.bio ?? "";
    _addressLineController.text = _transporterModel.address.addressLine ?? "";
    _cityController.text = _transporterModel.address.city ?? "";
    _stateController.text = _transporterModel.address.state ?? "";
    _pincodeController.text = _transporterModel.address.pincode! > 0
        ? _transporterModel.address.pincode.toString()
        : "";
    _contactPersonNameController.text =
        _transporterModel.contactPersonName ?? "";
    _phoneNumberController.text = _transporterModel.phoneNumber ?? "";
    _contactPersonNameController.text =
        _transporterModel.contactPersonName ?? "";
    _gstinController.text = _transporterModel.gstin ?? "";
    _carCountController.text = _transporterModel.counts.car.toString() ?? "";
    _vanCountController.text = _transporterModel.counts.van.toString() ?? "";
    _busCountController.text = _transporterModel.counts.bus.toString() ?? "";
    _selectedFleetSize = _transporterModel.fleetSize;
    _selectedCity = _cityController.text.toString() ?? "";
    _selectedState = _stateController.text.toString();
    setState(() {});
  }

  void updateState() {
    if (mounted) setState(() {});
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
