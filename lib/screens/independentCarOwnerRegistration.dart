import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_model/cityModel.dart' as cm;
import 'package:r_w_r/api/api_model/stateModel.dart' as sm;
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/screens/registrationSyccessfulScreen.dart';
import 'package:r_w_r/screens/widgets/common_submit_button.dart';
import 'package:r_w_r/screens/widgets/gradient_button.dart';
import 'package:r_w_r/screens/widgets/profile_image_capture.dart';
import 'package:r_w_r/utils/common_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../api/api_model/language/language_model.dart';
import '../api/api_model/registrations/become_driver_registration_model.dart';
import '../api/api_service/countryStateProviderService.dart';
import '../api/api_service/media_service.dart';
import '../api/api_service/registration_services/indi_car_service.dart';
import '../api/api_service/registration_services/transporter_service.dart';
import '../components/app_loader.dart';
import '../constants/api_constants.dart';
import '../constants/color_constants.dart';
import '../constants/token_manager.dart';
import '../utils/color.dart';
import 'block/provider/profile_provider.dart';
import 'multi_step_progress_bar.dart';

class IndependentTaxiOwnerFlow extends StatefulWidget {
  @override
  _IndependentTaxiOwnerFlowState createState() =>
      _IndependentTaxiOwnerFlowState();
}

class _IndependentTaxiOwnerFlowState extends State<IndependentTaxiOwnerFlow> {
  int currentStep = 0;
  PageController _pageController = PageController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Form keys for validation
  final _selfDetailFormKey = GlobalKey<FormState>();
  final _addressFormKey = GlobalKey<FormState>();
  final _documentFormKey = GlobalKey<FormState>();
  final _aboutFormKey = GlobalKey<FormState>();

  // Form controllers
  final _selfNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _aadharCardController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _aboutController = TextEditingController();
  final _carCountController = TextEditingController();
  final _suvCountController = TextEditingController();
  final _miniVanCountController = TextEditingController();
  final _busCountController = TextEditingController();
  final _totalVehicleCountController = TextEditingController();

  final List<String> stepTitles = [
    'Self Detail',
    'Address',
    'Document',
    'About',
    'Submit'
  ];

  // State and city management
  String? _selectedCity;
  String? _selectedState;
  List<cm.Data> _cityList = [];
  List<sm.Data> _stateList = [];
  String? currentCountry;

  // Verification states
  bool _isAadhaarVerifying = false;
  bool _isAadhaarVerified = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
      _prefillData();
      _loadCurrentStep();
    });
  }

  void _initializeLocation() {
    final langProvider = Provider.of<LocationProvider>(context, listen: false);
    currentCountry =
        langProvider.selectedCountry ?? ApiConstants.defaultCountryCodeInd;

    langProvider.fetchStates(currentCountry!).then((_) {
      if (mounted) {
        setState(() {
          _stateList = langProvider.states;
        });
      }
    });
  }

  void _prefillData() {
    // Prefill with user data if available
    final profileProvider =
        Provider.of<ProfileProvider>(context, listen: false);
    if (profileProvider.fullName != null) {
      _selfNameController.text = profileProvider.fullName!;
    }
    if (profileProvider.phoneNumber != null) {
      _phoneNumberController.text = profileProvider.phoneNumber!;
    }
  }

  Future<void> _saveCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('taxi_owner_current_step', currentStep);
  }

  Future<void> _loadCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    final savedStep = prefs.getInt('taxi_owner_current_step');
    if (savedStep != null && mounted) {
      setState(() {
        currentStep = savedStep;
      });
      _pageController = PageController(initialPage: savedStep);
    }
  }

  Future<void> _clearSavedStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('taxi_owner_current_step');
  }

  // Validation methods
  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) return '$fieldName is required';
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

  String? _validateAadhaar(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Aadhaar number is required';
    }
    if (value.length != 12 || !RegExp(r'^[0-9]{12}$').hasMatch(value)) {
      return 'Enter a valid 12-digit Aadhaar number';
    }
    return null;
  }

  Future<void> _fetchLocationFromPincode(String pincode) async {
    if (pincode.length != 6) return;

    try {
      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final userId = profileProvider.userId;
      final token = await TokenManager.getToken();

      final response = await http.get(
        Uri.parse('${ApiConstants.baseUrl}/user/pincode/$pincode'),
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
          });
        }
      }
    } catch (e) {
      _showErrorSnackBar('Unable to fetch location for this pincode');
    }
  }

  Future<void> _verifyAadhaar(String aadhaarNumber) async {
    if (aadhaarNumber.trim().isEmpty) return;

    final aadhaarError = _validateAadhaar(aadhaarNumber);
    if (aadhaarError != null) {
      _showErrorSnackBar(aadhaarError);
      return;
    }

    setState(() {
      _isAadhaarVerifying = true;
      _isAadhaarVerified = false;
    });

    // Simulate verification - replace with actual API call
    await Future.delayed(Duration(seconds: 2));

    setState(() {
      _isAadhaarVerifying = false;
      _isAadhaarVerified = true;
    });

    _showSuccessSnackBar('Aadhaar verified successfully!');
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

  // Document picker methods
  void _showDocumentPickerBottomSheet(String from) {
    FocusManager.instance.primaryFocus?.unfocus();
    if (from == "AADHAAR" && adhaar.length == 2) {
      return;
    } else if (from == "DRIVING LICENSE" && drivingLicense.length == 1) {
      return;
    } else if (from == "PERMIT" && permit.length == 1) {
      return;
    }
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
                              _pickDocumentFromCamera(from);
                            },
                          ),
                          _buildDocumentSourceOption(
                            icon: Icons.photo_library,
                            label: 'Gallery',
                            onTap: () {
                              Navigator.pop(context);
                              _pickDocumentFromGallery(from);
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

  List<XFile?> adhaar = [];
  List<XFile?> drivingLicense = [];
  List<XFile?> permit = [];

  Future<void> _pickDocumentFromCamera(String from) async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        if (from == "AADHAAR") {
          adhaar.add(image);
          image = null;
        } else if (from == "PERMIT") {
          permit.add(image);
          image = null;
        } else {
          drivingLicense.add(image);
          image = null;
        }
        setState(() {});
        // _showSuccessSnackBar('Document captured successfully');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture document from camera');
    }
  }

  Future<void> _pickDocumentFromGallery(String from) async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        if (from == "AADHAAR") {
          adhaar.add(image);
          image = null;
        } else if (from == "PERMIT") {
          permit.add(image);
          image = null;
        } else {
          drivingLicense.add(image);
          image = null;
        }
        print(adhaar);
        updateState();
        // _showSuccessSnackBar('Document selected from gallery');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick document from gallery');
    }
  }

  Future<void> _pickDocumentFromFiles() async {
    _showSuccessSnackBar(
        'File picker functionality - requires file_picker package');
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
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image from gallery');
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void nextStep() {
    bool isValid = false;
    String? errorMessage;

    switch (currentStep) {
      case 0: // Self Detail
        isValid = _selfDetailFormKey.currentState?.validate() ?? false;
        if (isValid && _selectedImage == null) {
          errorMessage = 'Profile image is required';
          isValid = false;
        }
        break;

      case 1: // Address
        isValid = _addressFormKey.currentState?.validate() ?? false;
        if (isValid && (_selectedCity == null || _selectedState == null)) {
          errorMessage = 'Please select both city and state';
          isValid = false;
        }
        break;

      case 2: // Document
        isValid = _documentFormKey.currentState?.validate() ?? false;
        if (_aadharCardController.text.toString().trim().isEmpty) {
          errorMessage = 'Please enter Aadhaar number';
          isValid = false;
        } else if (isValid && !_isAadhaarVerified) {
          errorMessage = 'Please verify your Aadhaar number';
          isValid = false;
        } else if (_aadharCardController.text.toString().trim().length < 12) {
          errorMessage = 'Aadhaar number should be of 12 digit long';
          isValid = false;
        } else if (adhaar.length < 2) {
          errorMessage = 'Add aadhaar card both front and back photo.';
          isValid = false;
        } else if (_drivingLicenseController.text.toString().trim().isEmpty) {
          errorMessage = 'Please add driving license number';
          isValid = false;
        } else if (drivingLicense.isEmpty) {
          errorMessage = 'Add driving license photo.';
          isValid = false;
        } else if (permit.isEmpty) {
          errorMessage = 'Please upload photo.';
          isValid = false;
        }
        break;

      case 3: // About
        isValid = _aboutFormKey.currentState?.validate() ?? false;
        if (isValid &&
            (_totalVehicleCountController.text.toString().isEmpty ||
                int.parse(_totalVehicleCountController.text.toString()) == 0)) {
          errorMessage = 'You must have at least 1 vehicle';
          isValid = false;
        }
        break;

      case 4: // Submit
        _submitForm();
        return;
    }

    if (!isValid) {
      if (errorMessage != null) {
        _showErrorSnackBar(errorMessage);
      }
      return;
    }

    if (currentStep < 4) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveCurrentStep();
    }
  }

  void previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
      _pageController.previousPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      _saveCurrentStep();
    }
  }

  void _submitForm() {
    _showRegistrationAgreementBottomSheet();
  }

  void _showRegistrationAgreementBottomSheet() {
    bool isAgreed = false;
    bool isScrolledToBottom = false;
    bool showScrollText = false;

    final ScrollController _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 10) {
        setState(() {
          isScrolledToBottom = true;
          showScrollText = false;
        });
      }
    });
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.85,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
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
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Registration Agreement Independent Taxi Owner',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: Scrollbar(
                                thumbVisibility: true,
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: Text(
                                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ut ipsum vulputate, amet massa. Vestibulum a nibh in neque aliquet aliquet quis nec nibh. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.\n\n'
                                    'Duis in ex augue. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ut ipsum vulputate, amet massa. Vestibulum a nibh in neque aliquet aliquet quis nec nibh. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Duis in ex augue. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ut ipsum vulputate, amet maaliquet quis nec nibh.\n\n'
                                    'Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos. Duis in ex augue. Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\n'
                                    'Vestibulum a nibh in neque aliquet aliquet quis nec nibh. Class aptent taciti sociosqu ad litora torquent per conubia nostra, per inceptos himenaeos.\n\n'
                                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec ut ipsum vulputate, amet massa. Vestibulum a nibh in neque aliquet aliquet quis nec nibh.',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.black87,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),
                            if (showScrollText)
                              AnimatedSize(
                                curve: Curves.easeInOutCubic,
                                duration: Duration(milliseconds: 450),
                                child: Text(
                                  'Scroll to bottom to read the complete agreement and then allow the T&C.',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red,
                                  ),
                                ),
                              ),
                            if (showScrollText) SizedBox(height: 20),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if (isScrolledToBottom) {
                                      setState(() {
                                        isAgreed = !isAgreed;
                                      });
                                    } else {
                                      setState(() {
                                        showScrollText = true;
                                      });
                                    }
                                  },
                                  child: Opacity(
                                    opacity: isScrolledToBottom ? 1.0 : 0.4,
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: isAgreed
                                            ? Color(0xFF8B5CF6)
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isAgreed
                                              ? Color(0xFF8B5CF6)
                                              : Colors.grey[400]!,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: isAgreed
                                          ? Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Container(
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: isAgreed
                                          ? () {
                                              _proceedToFinalStep();
                                            }
                                          : null,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isAgreed
                                            ? Color(0xFF8B5CF6)
                                            : Colors.grey[300],
                                        padding:
                                            EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                        ),
                                        elevation: 0,
                                      ),
                                      child: Text(
                                        'I Agree',
                                        style: TextStyle(
                                          color: isAgreed
                                              ? Colors.white
                                              : Colors.grey[600],
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _saveApplicationStatus(ApplicationStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('taxiowner_status', status.toString());
  }

  BecomeDriverModel _driverModel = BecomeDriverModel();

  bool submittingForm = false;

  int totalVehicles = 0;

  Future<void> _proceedToFinalStep() async {
    Navigator.pop(context); // Close bottom sheet
    setState(() {
      submittingForm = true;
    });
    try {
      final XFile xFile = XFile(_selectedImage!.path);
      final result = await MediaService()
          .uploadMedia(xFile, kind: "profilePhoto", type: "profilePhoto");
      final coverImage = await MediaService()
          .uploadMedia(xFile, kind: "coverImage", type: "coverImage");
      String aadhaarFrontUrl = "";
      String aadhaarBackUrl = "";
      String drivingLicencePhoto = "";
      String transportationPermitPhoto = "";

      if (adhaar.isNotEmpty && adhaar[0]!.path.isNotEmpty) {
        final XFile xFileAadhaarFront = XFile(adhaar[0]!.path);
        final aadharCardPhotoFront = await MediaService()
            .uploadMedia(xFileAadhaarFront, kind: "document", type: "document");
        aadhaarFrontUrl = aadharCardPhotoFront.url!;
      }
      if (adhaar.isNotEmpty &&
          adhaar.length > 1 &&
          adhaar[1]!.path.isNotEmpty) {
        final XFile xFileAadhaarBack = XFile(adhaar[1]!.path);
        final aadharCardPhotoBack = await MediaService()
            .uploadMedia(xFileAadhaarBack, kind: "document", type: "document");
        aadhaarBackUrl = aadharCardPhotoBack.url!;
      }
      if (drivingLicense.isNotEmpty) {
        final XFile drivingLicenseFile = XFile(drivingLicense[0]!.path);
        final drivingLicencePhotoUrl = await MediaService().uploadMedia(
            drivingLicenseFile,
            kind: "document",
            type: "document");
        drivingLicencePhoto = drivingLicencePhotoUrl.url!;
      }
      if (permit.isNotEmpty && permit[0]!.path.isNotEmpty) {
        final XFile drivingLicenseFile = XFile(permit[0]!.path);
        final transportationPermitPhotoUrl = await MediaService().uploadMedia(
            drivingLicenseFile,
            kind: "document",
            type: "document");
        transportationPermitPhoto = transportationPermitPhotoUrl.url!;
      }

      _driverModel = _driverModel.copyWith(
        coverImage: coverImage.url ?? '',
        profilePhoto: result.url ?? '',
        firstName: _selfNameController.text,
        lastName: _selfNameController.text,
        businessMobileNumber: _phoneNumberController.text,
        bio: _aboutController.text,
        address: Address(
            addressLine: _addressController.text.trim(),
            state: _stateController.text.trim(),
            city: _cityController.text.trim(),
            pincode: int.tryParse(_pinCodeController.text.trim())),
        aadharCardNumber: _aadharCardController.text,
        aadharCardPhotoFront: aadhaarFrontUrl ?? '',
        aadharCardPhotoBack: aadhaarBackUrl ?? '',
        drivingLicenceNumber: _drivingLicenseController.text,
        drivingLicencePhoto: drivingLicencePhoto,
        transportationPermitPhoto: transportationPermitPhoto,
        independentCarOwnerFleetSize: FleetSize(
            cars: int.parse(_carCountController.text.toString().isNotEmpty
                ? _carCountController.text.toString()
                : "0"),
            minivans: int.parse(
                _miniVanCountController.text.toString().isNotEmpty
                    ? _miniVanCountController.text.toString()
                    : "0"),
            buses: int.parse(_busCountController.text.toString().isNotEmpty
                ? _busCountController.text.toString()
                : "0"),
            suvs: int.parse(_suvCountController.text.toString().isNotEmpty
                ? _suvCountController.text.toString()
                : "0")),
      );
      try {
        final response = await BecomeDriverServiceIndi()
            .submitDriverApplicationIndi(_driverModel);

        if (response['success'] == true) {
          if (!mounted) return;
          _clearSavedStep();
          _saveApplicationStatus(ApplicationStatus.submitted);
          TransporterService.showSuccessSnackBar(
              context, 'Application submitted successfully!');
          if (!mounted) return;
          Future.delayed(Duration(seconds: 2), () {
            _clearSavedStep();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => RegistrationSuccessfulScreen(
                        userType: 'Taxi Owner',
                      )),
            );
          });
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
        setState(() {
          submittingForm = false;
        });
      } finally {
        if (!mounted) return;
        setState(() {
          submittingForm = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        submittingForm = false;
      });
    }
    // Simulate API call
  }

  @override
  void dispose() {
    _pageController.dispose();
    _selfNameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _aadharCardController.dispose();
    _drivingLicenseController.dispose();
    _aboutController.dispose();
    currentStep = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      // handle physical back button
      onWillPop: () async {
        if (currentStep == 0) {
          return true; // allow pop
        } else {
          previousStep();
          return false; // prevent pop
        }
      },
      child: CommonParentContainer(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                MultiStepProgressBar(
                  currentStep: currentStep,
                  stepTitles: stepTitles,
                  gradientColors: [Colors.green, Colors.green],
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: PageView(
                      controller: _pageController,
                      physics: NeverScrollableScrollPhysics(),
                      children: [
                        _buildSelfDetailStep(),
                        _buildAddressStep(),
                        _buildDocumentStep(),
                        _buildAboutStep(),
                        _buildPreviewStep(),
                      ],
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

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (currentStep == 0) {
                Navigator.of(context).pop();
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
          Flexible(
            child: Text(
              'Become Independent Taxi Owner',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfDetailStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _selfDetailFormKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: ListView(
            children: [
              Text(
                'Self Detail',
                style: TextStyle(
                  fontFamily: AppConstants.ptSansFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 40),
/*
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
                          color: Colors.grey[300],
                          border: _selectedImage != null
                              ? Border.all(color: Color(0xFF8B5CF6), width: 3)
                              : null,
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
                                Icons.camera_alt,
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
                          decoration: _selectedImage != null
                              ? TextDecoration.underline
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
*/
              ProfileImageCapture(
                label: 'Profile Image',
                useGallery: false,
                showPreview: true,
                showDirectImage: false,
                icon: Icons.camera_alt,
                kind: "profileImage",
                useEyeBlinkDetection: true,
                required: true,
                onMediaUploaded: (url) {
                  setState(() {
                    _selectedImage = File(url);
                    _driverModel = _driverModel.copyWith(profilePhoto: url);
                  });
                },
                allowedExtensions: ['jpg', 'jpeg', 'png'],
              ),
              SizedBox(height: 40),
              _buildTextField(
                'Self Name *',
                _selfNameController,
                validator: (value) => _validateRequired(value, 'Self name'),
              ),
              SizedBox(height: 20),
              _buildTextField(
                'Phone Number*',
                _phoneNumberController,
                validator: _validateMobileNumber,
                keyboardType: TextInputType.phone,
              ),
            ],
          )),
          _buildContinueButton(),
        ]),
      ),
    );
  }

  Widget _buildAddressStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Form(
        key: _addressFormKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: ListView(
            children: [
              Text(
                'Address',
                style: CommonUtils.commonTextLabelsStyle(),
              ),
              SizedBox(height: 40),
              _buildTextField(
                'Address*',
                _addressController,
                placeholder: '12 house no., XYZ STREET, Opp ABC Mall',
                validator: (value) => _validateRequired(value, 'Address'),
              ),
              SizedBox(height: 20),
              _buildTextField(
                'Pin Code*',
                _pinCodeController,
                placeholder: '788799',
                validator: _validatePincode,
                keyboardType: TextInputType.number,
                maxLength: 6,
                onChanged: (value) {
                  if (value.length == 6) {
                    _fetchLocationFromPincode(value);
                  }
                },
              ),
              SizedBox(height: 20),
              _buildDropdown(
                'State',
                _selectedState,
                _stateList
                    .map((state) => DropdownMenuItem(
                          value: state.sId,
                          child: Text(state.name.toString()),
                        ))
                    .toList(),
                (newValue) {
                  setState(() {
                    _selectedState = newValue;
                    _stateController.text = newValue ?? '';
                    if (newValue != null) {
                      final locProvider =
                          Provider.of<LocationProvider>(context, listen: false);
                      locProvider.fetchCity(newValue).then((_) {
                        setState(() {
                          _cityList = locProvider.cities;
                          _selectedCity = null; // Reset city when state changes
                        });
                      });
                    }
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a state' : null,
              ),
              SizedBox(height: 20),
              _buildDropdown(
                'City',
                _selectedCity,
                _cityList
                    .map((city) => DropdownMenuItem(
                          value: city.sId,
                          child: Text(city.name.toString()),
                        ))
                    .toList(),
                (newValue) {
                  setState(() {
                    _selectedCity = newValue;
                    _cityController.text = newValue ?? '';
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select a city' : null,
              ),
            ],
          )),
          _buildContinueButton(),
        ]),
      ),
    );
  }

  Widget _buildDocumentStep() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Form(
        key: _documentFormKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(
              child: ListView(
            children: [
              Text(
                'Document',
                style: TextStyle(
                  fontFamily: AppConstants.ptSansFont,
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    // Aadhar Card Container with both field and verify button
                    SizedBox(
                      width: double.infinity,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 5.0),
                            child: Text(
                              'Aadhar Card No.*',
                              style: CommonUtils.commonTextLabelsStyle(),
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 5),
                            decoration: CommonUtils.commonInputBoxDecoration(),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    textAlign: TextAlign.start,
                                    maxLength: 12,
                                    buildCounter: (
                                      context, {
                                      required int currentLength,
                                      required bool isFocused,
                                      required int? maxLength,
                                    }) {
                                      return null; // 👈 hides the counter
                                    },
                                    controller: _aadharCardController,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    keyboardType: TextInputType.phone,
                                    decoration: InputDecoration.collapsed(
                                      hintText: 'Enter Aadhar Card Number',
                                      hintStyle: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      if (value.length == 12) {
                                        _verifyAadhaar(value);
                                      }
                                    },
                                  ),
                                ),
                                SizedBox(width: 12),
                                Container(
                                  height: 30,
                                  padding: EdgeInsets.symmetric(horizontal: 16),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: Color(0xFF1FAF38), width: 1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Center(
                                    child: _isAadhaarVerifying
                                        ? SizedBox(
                                            width: 16,
                                            height: 16,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2),
                                          )
                                        : Text(
                                            _isAadhaarVerified
                                                ? 'Verified'
                                                : 'Verify',
                                            style: TextStyle(
                                              color: Color(0xFF1FAF38),
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: _buildAadhaarFileUploadSection(
                          'Upload Aadhar Card (Front & Back)', "AADHAAR"),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: _buildTextField(
                          'Driving License Number', _drivingLicenseController),
                    ),
                    SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: _buildFileUploadSection(
                          'Upload Driving License', 'DRIVING LICENSE'),
                    ),
                    SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      child: _buildPermitFileUploadSection(
                          'Upload Permit', 'PERMIT'),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              )
            ],
          )),
          _buildContinueButton(),
        ]),
      ),
    );
  }

  Widget _buildAadhaarFileUploadSection(String title, String from) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
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
                  _showDocumentPickerBottomSheet("AADHAAR");
                },
              ),
              if (adhaar.isNotEmpty)
                _showAadharCardImages()
              else
                SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }

  Widget _showAadharCardImages() {
    return Container(
      alignment: Alignment.centerLeft,
      height: 100,
      width: double.infinity,
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: adhaar.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
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
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    child: Image.file(
                      File(adhaar[index]?.path ?? ""),
                      width: 50,
                      fit: BoxFit.cover,
                      height: 50,
                    ),
                  )),
              Positioned(
                  right: 5,
                  top: 12,
                  child: GestureDetector(
                    onTap: () {
                      adhaar.removeAt(index);
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
        },
      ),
    );
  }

  Widget _showDLImages() {
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
            child: ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Image.file(
                File(drivingLicense[0]?.path ?? ""),
                width: 50,
                fit: BoxFit.cover,
                height: 50,
              ),
            )),
        Positioned(
            right: 5,
            top: 12,
            child: GestureDetector(
              onTap: () {
                drivingLicense.clear();
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
              File(permit[0]?.path ?? ""),
              width: 50,
              fit: BoxFit.cover,
              height: 50,
            )),
        Positioned(
            right: 5,
            top: 12,
            child: GestureDetector(
              onTap: () {
                permit.clear();
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

  Widget _buildFileUploadSection(String title, String from) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width,
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
                  _showDocumentPickerBottomSheet(from);
                },
              ),

/*
              GestureDetector(
                onTap: () => _showDocumentPickerBottomSheet(from),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        gradientFirst,
                        gradientSecond,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'browse',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
*/
              if (drivingLicense.isNotEmpty)
                _showDLImages()
              else
                SizedBox(
                  height: 10,
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermitFileUploadSection(String title, String from) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width,
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
                  _showDocumentPickerBottomSheet(from);
                },
              ),
              if (permit.isNotEmpty)
                _showPermitImage()
              else
                SizedBox(
                  height: 10,
                )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAboutStep() {
    double boxWidth = 36;
    double boxHeight = 43;
    return Padding(
      padding: EdgeInsets.all(20),
      child: Form(
        key: _aboutFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About',
              style: TextStyle(
                fontFamily: AppConstants.ptSansFont,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: ListView(
                  children: [
                    SizedBox(height: 20),
                    Text(
                      'Vehicle Counts',
                      style: CommonUtils.commonTextLabelsStyle(),
                    ),
                    SizedBox(height: 12),
                    Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                                    border: Border.all(
                                        color: ColorConstants
                                            .inputFieldBorderColor),
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
                                    border: Border.all(
                                        color: ColorConstants
                                            .inputFieldBorderColor),
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
                                    border: Border.all(
                                        color: ColorConstants
                                            .inputFieldBorderColor),
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
                                      controller: _miniVanCountController,
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
                                    border: Border.all(
                                        color: ColorConstants
                                            .inputFieldBorderColor),
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
                        ]),
                    SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Total Number of Vehicles',
                                    style: CommonUtils.commonTextLabelsStyle(),
                                  ),
                                  SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: Text('Vehicle Count Info'),
                                          content: Text(
                                            'Tap on vehicle count boxes to increase count.\nLong press to decrease count.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: Text('OK'),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.grey[400],
                                      ),
                                      child: Icon(
                                        Icons.info_outline,
                                        size: 12,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color:
                                          ColorConstants.inputFieldBorderColor),
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
                                    hintStyle:
                                        CommonUtils.commonHintTextStyle(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Text('About', style: CommonUtils.commonTextLabelsStyle()),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: ColorConstants.inputFieldBorderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _aboutController,
                        maxLines: null,
                        decoration: InputDecoration.collapsed(
                          hintStyle: CommonUtils.commonHintTextStyle(),
                          hintText:
                              'Briefly describe your transport business. Mention the type of vehicles you operate, service areas, years of experience, and what makes your service reliable (on-time service, clean vehicles, professional drivers, etc.).',
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewStep() {
    String? cityName;
    String? stateName;

    if (_selectedCity != null && _cityList.isNotEmpty) {
      final city = _cityList.firstWhere(
            (c) => c.sId == _selectedCity,
      );
      cityName = city.name;
    }
    if (_selectedState != null && _stateList.isNotEmpty) {
      final state = _stateList.firstWhere(
            (c) => c.sId == _selectedState,
      );
      stateName = state.name;
    }


    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Text('Preview',
                  style: CommonUtils.commonTextLabelsStyle(fontSize: 20)),
              SizedBox(height: 20),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                        border: _selectedImage != null
                            ? Border.all(color: Color(0xFF8B5CF6), width: 2)
                            : null,
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
                              Icons.person,
                              size: 30,
                              color: Colors.grey[600],
                            ),
                    ),
                    SizedBox(height: 8),
                    Text('Profile Image',
                        style: CommonUtils.commonTextLabelsStyle(fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24),
          Expanded(
            child: ListView(
              children: [
                _buildPreviewItem(
                    'Self Name',
                    _selfNameController.text.isEmpty
                        ? 'Not specified'
                        : _selfNameController.text),
                _buildPreviewItem(
                    'Phone Number',
                    _phoneNumberController.text.isEmpty
                        ? 'Not specified'
                        : '+91 ${_phoneNumberController.text}'),
                _buildPreviewItem(
                    'Address Line',
                    _addressController.text.isEmpty
                        ? 'Not specified'
                        : _addressController.text),
                _buildPreviewItem(
                    'Pin Code',
                    _pinCodeController.text.isEmpty
                        ? 'Not specified'
                        : _pinCodeController.text),
                _buildPreviewItem('City', cityName ?? ""),
                _buildPreviewItem('State', stateName ?? ""),
                _buildPreviewItem(
                    'Aadhar Card No.',
                    _aadharCardController.text.isEmpty
                        ? 'Not provided'
                        : _aadharCardController.text),
                _buildPreviewItem(
                    'Driving License Number',
                    _drivingLicenseController.text.isEmpty
                        ? 'Not provided'
                        : _drivingLicenseController.text),
                _buildPreviewItem(
                    'Total Number of Vehicles', totalVehicles.toString()),
                SizedBox(height: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'About',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: AppConstants.ptSansFont,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      _aboutController.text.isEmpty
                          ? 'Not specified'
                          : _aboutController.text,
                      style: TextStyle(
                        fontFamily: AppConstants.ptSansFont,
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
              ],
            ),
          ),
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {

    return Container(
      alignment:Alignment.bottomRight,
      child: CommonSubmitButton(
        gradientColors: [gradientFirst,gradientSecond],
        onPressed: submittingForm ? null : nextStep,
        text: "Submit",
        borderRadius: 12,
        isLoading:submittingForm ,

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
              style: TextStyle(
                fontFamily: AppConstants.ptSansFont,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ),
          SizedBox(
            width: 10,
          ),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                fontFamily: AppConstants.ptSansFont,
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? placeholder,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int? maxLength,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: CommonUtils.commonInputBoxDecoration(),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLength: maxLength,
            onChanged: onChanged,
            style: CommonUtils.commonInputTextStyle(),
            buildCounter: (
              context, {
              required int currentLength,
              required bool isFocused,
              required int? maxLength,
            }) {
              return null; // 👈 hides the counter
            },
            decoration: InputDecoration.collapsed(
              hintText: placeholder ?? '',
              hintStyle: CommonUtils.commonHintTextStyle(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown<T>(
    String label,
    T? value,
    List<DropdownMenuItem<T>> items,
    void Function(T?) onChanged, {
    String? Function(T?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
                  BorderSide(color: ColorConstants.inputFieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: ColorConstants.inputFieldBorderColor),
            ),
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

/*
  Widget _buildFileUploadSection(String title, String from) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: MediaQuery.of(context).size.width,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color:  ColorConstants.inputFieldBorderColor),
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
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'png, pdf, jpg, docx accepted',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
              SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showDocumentPickerBottomSheet(from),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        gradientFirst,
                        gradientSecond,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'browse',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
*/

  Widget _buildContinueButton() {
    return Container(
      alignment:Alignment.bottomRight,
      child: CommonSubmitButton(
        gradientColors: [gradientFirst,gradientSecond],
        onPressed: nextStep,
        text: "Continue",
        borderRadius: 12,
        isLoading:submittingForm ,

      ),
    );
  }

  void updateState() {
    if (mounted) setState(() {});
  }

  void updateVehicleCount() {
    int car = _carCountController.text.toString().isNotEmpty
        ? int.parse(_carCountController.text.toString())
        : 0;
    int bus = _busCountController.text.toString().isNotEmpty
        ? int.parse(_busCountController.text.toString())
        : 0;
    int van = _miniVanCountController.text.toString().isNotEmpty
        ? int.parse(_miniVanCountController.text.toString())
        : 0;
    int suv = _suvCountController.text.toString().isNotEmpty
        ? int.parse(_suvCountController.text.toString())
        : 0;

    totalVehicles = car + bus + van + suv;
    _totalVehicleCountController.text = totalVehicles.toString();
  }

  vehicleCountStyle() {
    return TextStyle(
      fontFamily: AppConstants.ptSansFont,
      fontWeight: FontWeight.w400,
      fontSize: 10,
      color: Color(0xFF9E9E9E),
    );
  }
}
