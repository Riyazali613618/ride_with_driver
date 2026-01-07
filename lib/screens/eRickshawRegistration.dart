import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/screens/registrationSyccessfulScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

import '../api/api_model/registrations/auto_rikshaw_registration_model.dart';
import '../api/api_model/user_model/user_eligibility_model.dart';
import '../api/api_service/countryStateProviderService.dart';
import '../api/api_service/media_service.dart';
import '../api/api_service/registration_services/e_rekshaw_registration_service.dart';
import '../api/api_service/user_service/user_profile_service.dart';
import '../components/app_loader.dart';
import '../constants/api_constants.dart';
import '../utils/color.dart';
import 'block/language/language_provider.dart';
import 'package:r_w_r/api/api_model/languageModel.dart' as lm;
import 'package:r_w_r/api/api_model/cityModel.dart' as cm;
import 'package:r_w_r/api/api_model/stateModel.dart' as sm;

import 'multi_step_progress_bar.dart';

class ERickshawDriverFlow extends StatefulWidget {
  @override
  _ERickshawDriverFlowState createState() => _ERickshawDriverFlowState();
}

class _ERickshawDriverFlowState extends State<ERickshawDriverFlow> {
  int currentStep = 0;
  PageController _pageController = PageController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final _selfNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _aadharCardController = TextEditingController();
  final _aboutController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _vehicleNumberController = TextEditingController();

  String? _selectedLanguage;
  final List<String> _languages = [
    'Hindi',
    'English',
    'Bengali',
    'Telugu',
    'Marathi',
    'Tamil',
    'Gujarati',
    'Urdu',
    'Malayalam',
    'Kannada',
    'Odia',
    'Punjabi',
    'Assamese'
  ];

  final List<String> stepTitles = [
    'Self Detail',
    'Address',
    'Document',
    'About',
    'Submit'
  ];

  String? _selectedCity;
  String? _selectedState;
  List<cm.Data> _cityList = [];
  List<sm.Data> _stateList = [];
  String? currentCountry;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelectedLanguage();
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
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

    final profile = await UserProfileService().getUserProfile();
    _selfNameController.text =
    "${profile.firstName ?? ""} ${profile.lastName ?? ""}";
    _phoneNumberController.text = profile.mobileNumber ?? "";
  }

  List<lm.Data> langData = [];

  Future<void> _initializeSelectedLanguage() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider.fetchLanguagesFromApi();
    langData = languageProvider.language ?? [];
    if (mounted) {
      setState(() {});
    }
  }


  // Document selection methods
  void _showDocumentPickerBottomSheet(String from) {
    print(from);
    print((adhaar.length));
    if (from == "AADHAAR" && adhaar.length == 2) {
      return;
    } else if (from == "DRIVING LICENSE" && drivingLicense.length == 1) {
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

  List<XFile> adhaar = [];
  List<XFile> drivingLicense = [];

  Future<void> _pickDocumentFromCamera(String from) async {
    try {
      XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );

      if (image != null) {
        if (from == 'AADHAAR') {
          adhaar.add(image);
          image = null;
        } else {
          drivingLicense.add(image);
          image = null;
        }
        setState(() {});
        _showSuccessSnackBar('Document captured successfully');
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
        if (from == 'AADHAAR') {
          adhaar.add(image);
          image = null;
        } else {
          drivingLicense.add(image);
          image = null;
        }
        setState(() {});
        _showSuccessSnackBar('Document selected from gallery');
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick document from gallery');
    }
  }

  Future<void> _pickDocumentFromFiles() async {
    try {
      _showSuccessSnackBar(
          'File picker functionality - requires file_picker package');
    } catch (e) {
      _showErrorSnackBar('Failed to access files');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void nextStep() {
    bool isValid = false;
    String? errorMessage;

    //_saveTransporterData();

    switch (currentStep) {
      case 0: // Company Detail
        isValid = false;
        if (_selectedImage == null) {
          errorMessage = 'Profile photo is required';
          isValid = false;
        } else if (_selfNameController.text.trim().isEmpty) {
          errorMessage = 'Profile photo is required';
        } else if (_phoneNumberController.text.trim().isEmpty) {
          errorMessage = 'Phone number is required';
        } else {
          isValid = true;
          _updateSelfDetailsModel();
        }

        break;

      case 1: // Address
        if (_addressController.text.trim().isEmpty ||
            _pinCodeController.text.trim().isEmpty ||
            _selectedCity == null ||
            _selectedCity!.isEmpty ||
            _selectedState == null ||
            _selectedState!.isEmpty) {
          errorMessage = 'Please fill all address fields';
          isValid = false;
        } else {
          final addressError = _validateAddressLine(_addressController.text);
          final pincodeError = _validatePinCode(_pinCodeController.text);
          if (addressError != null) {
            errorMessage = addressError;
            isValid = false;
          } else if (pincodeError != null) {
            errorMessage = pincodeError;
            isValid = false;
          } else {
            _updateAddressDetailsModel();
            isValid = true;
          }
        }
        break;

      case 2: // Document
        if (_aadharCardController.text.toString().trim().isEmpty) {
          errorMessage = 'Please enter Aadhar Number';
          isValid = false;
        } else if (adhaar.length < 2) {
          errorMessage = 'Please add aadhar both front and back photo';
          isValid = false;
        } else if (_drivingLicenseController.text.toString().trim().isEmpty) {
          errorMessage = 'Please enter Driving License Number';
          isValid = false;
        } else if (drivingLicense.isEmpty) {
          errorMessage = 'Please add Driving License photo';
          isValid = false;
        } else if (_vehicleNumberController.text.toString().trim().isEmpty) {
          errorMessage = 'Please enter Vehicle Number';
          isValid = false;
        } else {
          isValid = true;
          _updateDocumentDetailsModel();
        }
        break;

      case 3: // About/Fleet
        if ((_selectedLanguages ?? []).isEmpty) {
          errorMessage = 'Please select language';
          isValid = false;
        } else {
          isValid = true;
          _submitAboutDetailsModel();
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(canPop: false, // Prevents default pop behavior
      onPopInvoked: (didPop) {
        if (didPop) {
          return;
        }
        // Call your existing logic
        previousStep();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                Colors.white,
              ],

            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                MultiStepProgressBar(
                  currentStep: currentStep,
                  stepTitles: stepTitles,
                  inactiveColor: Colors.grey.shade200,
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
            onTap: () => Navigator.pop(context),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 24,
            ),
          ),
          SizedBox(width: 16),
          Flexible(
            child: Text(
              'Become E-Rickshaw Driver',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProgressBar() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                height: 8,
                margin: EdgeInsets.symmetric(horizontal: 0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  height: 8,
                  width: 30 +
                      (MediaQuery.of(context).size.width * 0.25 * currentStep),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        gradientFirst,
                        gradientSecond,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SizedBox(width: 1),
                  ...List.generate(5, (index) {
                    return Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              gradientFirst,
                              gradientSecond,
                            ],
                          ),
                          color: Color(0xFF8B5CF6)),
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
                    );
                  }),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(width: 25),
              ...List.generate(5, (index) {
                return Container(
                  width: 60,
                  child: Text(
                    stepTitles[index],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
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

  bool _isAadhaarVerifying = false;
  bool _isAadhaarVerified = false;

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

  Widget _buildSelfDetailStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Expanded(child: ListView(
            children:  [
              Text(
                'Self Detail',
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
              SizedBox(height: 40),
              _buildTextField('Self Name *', _selfNameController,textLength: 50),
              SizedBox(height: 20),
              _buildTextField(
                'Phone Number*',
                _phoneNumberController,
                keyboardType: TextInputType.phone,
                textLength: 10,
                inputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),            ],
          )),
          _buildContinueButton(),
        ]
      ),
    );
  }

  Widget _buildAddressStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: ListView(
            children:[
              Text(
                'Address',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 40),
              _buildTextField('Address*', _addressController,
                  placeholder: '12 house no., XYZ STREET, Opp ABC Mall', keyboardType: TextInputType.text),
              SizedBox(height: 20),
              _buildTextField('Pin Code*', _pinCodeController,
                  placeholder: '788799',
                  keyboardType: TextInputType.phone,
                  inputFormatter: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  textLength: 6),
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
                validator: (value) => value == null ? 'Please select a city' : null,
              ),
              SizedBox(height: 20),
            ],
          ),
          ),
          _buildContinueButton(),
        ]
      ),
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
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }


  Widget _buildDocumentStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
            child: ListView(
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 35,
                              alignment: Alignment.center,
                              padding: EdgeInsets.symmetric(horizontal: 5),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey[400]!),
                                borderRadius: BorderRadius.circular(8),
                              ),
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
                          ),
                          SizedBox(width: 12),
                          Container(
                            height: 30,
                            padding: EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: _isAadhaarVerifying
                                  ? SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                CircularProgressIndicator(strokeWidth: 2),
                              )
                                  : Text(
                                _isAadhaarVerified ? 'Verified' : 'Verify',
                                style: TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ],
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
                      'Driving License Number', _drivingLicenseController,
                      textCapitalization: TextCapitalization.characters),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: _buildFileUploadSection(
                      'Upload Driving License', 'DRIVING LICENSE'),
                ),
                SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: _buildTextField('Vehicle Number', _vehicleNumberController,
                      placeholder: "Enter vehicle number",
                      textCapitalization: TextCapitalization.characters),
                ),
                SizedBox(height: 40),
              ],
            )),
        _buildContinueButton(),
      ]),
    );
  }
  Widget _buildAadhaarFileUploadSection(String title, String from) {
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
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
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
                onTap: () => _showDocumentPickerBottomSheet("AADHAAR"),
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
              if (adhaar.isNotEmpty) _showAadharCardImages()
              else
                SizedBox(height: 12),

            ],
          ),
        ),
      ],
    );
  }

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
          height: 240,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
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
              if (drivingLicense.isNotEmpty) _showDLImages(),
            ],
          ),
        ),
      ],
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
            child: Image.file(
              File(drivingLicense[0].path),
              width: 50,
              fit: BoxFit.cover,
              height: 50,
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
                  child: Image.file(
                    File(adhaar[index].path),
                    width: 50,
                    fit: BoxFit.cover,
                    height: 50,
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


  List<String> langIds=[];
  Widget _buildAboutStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Expanded(
          child: ListView(
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
                'Select Languages',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              _languageMultiSelectDropdown(),
              SizedBox(height: 24),
              Text(
                'About',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 120,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: TextField(
                  controller: _aboutController,
                  maxLines: null,
                  decoration: InputDecoration.collapsed(
                    hintText: 'Briefly describe your transport business. Mention the type of vehicles you operate, service areas, years of experience, and what makes your service reliable (on-time service, clean vehicles, professional drivers, etc.).',
                  ),
                ),
              ),
              SizedBox(height: 10),
            ],
          ),
        ),
        _buildContinueButton(),
      ]),
    );
  }

  bool _isDropdownOpen = false;

  final List<String> _selectedLanguages = [];

  Widget _languageMultiSelectDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _isDropdownOpen = !_isDropdownOpen;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedLanguages.isEmpty
                        ? 'Select languages'
                        : '${_selectedLanguages.length} selected',
                    style: TextStyle(
                      color: _selectedLanguages.isEmpty
                          ? Colors.grey
                          : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  _isDropdownOpen
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
          ),
        ),

        if (_isDropdownOpen)
          Container(
            height: 300,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: ListView(
              shrinkWrap: true,
              children: langData.map((language) {
                final isSelected = _selectedLanguages.contains(language.name);
                return CheckboxListTile(
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  value: isSelected,
                  title: Text(language.name!),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedLanguages.add(language.name!);
                        langIds.add(language.id!);
                      } else {
                        _selectedLanguages.remove(language.name);
                        langIds.remove(language.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 12),

        /// Selected Chips
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedLanguages.map((language) {
            return Chip(
              label: Text(language),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedLanguages.remove(language);
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDropdownFieldForLanguage(String label, String? value,
      List<lm.Data> items, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              hint: Text(
                'Select ${label.toLowerCase()}',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
              ),
              items: items.map((lm.Data item) {
                return DropdownMenuItem<String>(
                  value: item.name,
                  child: Text(item!.name ?? ''),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewStep() {
    return Padding(
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
          Expanded(
            child: ListView(
              children: [
                _buildPreviewItem(
                    'Self Name',
                    _selfNameController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _selfNameController.text),
                _buildPreviewItem(
                    'Phone Number',
                    _phoneNumberController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _phoneNumberController.text),
                _buildPreviewItem(
                    'Address Line',
                    _addressController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _addressController.text),
                _buildPreviewItem(
                    'Pin Code',
                    _pinCodeController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _pinCodeController.text),
                _buildPreviewItem(
                    'City',
                    _cityController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _cityController.text),
                _buildPreviewItem(
                    'State',
                    _stateController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _stateController.text),
                _buildPreviewItem(
                    'Aadhar Card No.',
                    _aadharCardController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _aadharCardController.text),
                _buildPreviewItem(
                    'Spoken Languages', _selectedLanguage ?? 'Lorem Ipsum'),
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
                      _aboutController.text.isEmpty
                          ? 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.\n\nDonec ut ipsum vulputate, amet massa. Vestibulum a nibh in'
                          : _aboutController.text,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                _buildSubmitButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          if(!isSubmitting) _submitForm();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8B5CF6),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child:isSubmitting?SizedBox(width: 20,height: 20,child: CircularProgressIndicator(color: Colors.white,strokeWidth: 2,)): Text(
          'Submit',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _submitForm() {
    _showRegistrationAgreementBottomSheet();
  }

  void _showRegistrationAgreementBottomSheet() {
    bool isAgreed = false;
    bool isScrolledToBottom = false;
    final ScrollController _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 10) {
        setState(() {
          isScrolledToBottom = true;
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
                              'Registration Agreement E-Rickshaw Driver',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            Expanded(
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
                            SizedBox(height: 20),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    if(isScrolledToBottom) {
                                      setState(() {
                                      isAgreed = !isAgreed;
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
                                          color: isScrolledToBottom
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

  AutoRickshawModel _erickshawModel = AutoRickshawModel(
    vehicleImages: [],
    languageSpoken: [],
    address: Address(),
  );

  bool isSubmitting=false;
  Future<void> _proceedToFinalStep() async {
    Navigator.of(context).pop();
    isSubmitting = true;
    updateState();
    try {
      if (adhaar.isNotEmpty && adhaar[0].path.isNotEmpty) {
        final XFile xFileAadhaarFront = XFile(adhaar[0].path);
        final imageUrl = await MediaService()
            .uploadMedia(xFileAadhaarFront, kind: "document", type: "document");
        _erickshawModel = _erickshawModel.copyWith(
          aadharCardPhotoFront: imageUrl.url,
        );
      }
      if (adhaar.isNotEmpty && adhaar[1].path.isNotEmpty) {
        final XFile xFileAadhaarFront = XFile(adhaar[1].path);
        final imageUrl = await MediaService()
            .uploadMedia(xFileAadhaarFront, kind: "document", type: "document");
        _erickshawModel = _erickshawModel.copyWith(
          aadharCardPhotoBack: imageUrl.url,
        );
      }
      String orderId = "";
      String paymentId = "";
      String subscriptionPlanId = "";

      bool isUpgrade = await getUserProfile();
      if (isUpgrade) {
        final data = await getEligibilityData();
        if (data.data != null) {
          subscriptionPlanId = data.data?.subscriptionId ?? "";
          paymentId = data.data?.paymentId ?? "";
          orderId = data.data?.orderId ?? "";
        }
      }
      if (drivingLicense.isNotEmpty) {
        final XFile xFileAadhaarFront = XFile(drivingLicense[0].path);
        final imageUrl = await MediaService()
            .uploadMedia(xFileAadhaarFront, kind: "document", type: "document");
        _erickshawModel = _erickshawModel.copyWith(
          drivingLicencePhoto: imageUrl.url,
        );
      }
      if (_selectedImage != null) {
        final XFile xFileAadhaarFront = XFile(_selectedImage!.path ?? "");
        final imageUrl = await MediaService()
            .uploadMedia(xFileAadhaarFront, kind: "document", type: "document");
        _erickshawModel = _erickshawModel.copyWith(
          profilePhoto: imageUrl.url,
        );
      }
      _erickshawModel = _erickshawModel.copyWith(
        firstName: _selfNameController.text ?? "",
        subscriptionPlanId: subscriptionPlanId,
        paymentId: paymentId,
        orderId: orderId,
        chosen_category: "E-RICKSHAW",
        languageSpoken: langIds,
        lastName: _selfNameController.text,
        address: _erickshawModel.address?.copyWith(
            addressLine: _addressController.text,
            pincode: int.parse(_pinCodeController.text),
            state: _selectedState,
            city: _selectedCity),
        aadharCardNumber: _aadharCardController.text,
        bio: _aboutController.text,
        drivingLicenceNumber: _drivingLicenseController.text.toString(),
        vehicleNumber: _vehicleNumberController.text.toString(),
        businessMobileNumber: _phoneNumberController.text,
      );

      final response = await BecomeErickshawService().submitErickshawApplication(
          _erickshawModel, isUpgrade ? "become-upgradable" : "become-e-rickshaw");
      isSubmitting=false;
      updateState();
      if (response['success'] == true) {
        if (!mounted) return;
        BecomeErickshawService.showSuccessSnackBar(
            context, 'Application submitted successfully!');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const RegistrationSuccessfulScreen(
                  userType: 'E-Rickshaw Driver')),
        );
      } else {
        if (!mounted) return;
        BecomeErickshawService.showApiErrorSnackBar(
          context,
          response['message'] ?? 'Submission failed',
        );
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Agreement accepted! Registration completed.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => RegistrationSuccessfulScreen(
                userType: 'E-Rickshaw',
              )));
    }catch(e){
      isSubmitting=false;
      updateState();
    }

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
    _aboutController.dispose();
    super.dispose();
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {String? placeholder,
        TextInputType keyboardType = TextInputType.text,
        int textLength = 50,
        TextCapitalization textCapitalization = TextCapitalization.sentences,
        List<TextInputFormatter>? inputFormatter}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            textCapitalization: textCapitalization,
            maxLength: textLength,
            keyboardType: keyboardType,
            inputFormatters: inputFormatter,
            controller: controller,
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
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 19,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildContinueButton() {
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
          'Continue',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<bool> getUserProfile() async {
    final data = await UserProfileService().getUserProfile();
    final prefs = await SharedPreferences.getInstance();
    if (data!.subscriptions!.isNotEmpty) {
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

  void _updateSelfDetailsModel() {
    _erickshawModel = _erickshawModel.copyWith(
        firstName: _selfNameController.text.toString(),
        profilePhoto: _selectedImage?.path ?? "",
        businessMobileNumber: _phoneNumberController.text.toString());
    if (currentStep < 4) {
      currentStep++;
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    updateState();
  }

  void _updateAddressDetailsModel() {
    _erickshawModel = _erickshawModel.copyWith(
        address: Address(
            addressLine: _addressController.text.toString(),
            city: _selectedCity!,
            country: "india",
            pincode: int.parse(_pinCodeController.text.toString()),
            state: _selectedState!));
    if (currentStep < 4) {
      currentStep++;
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    updateState();
  }

  updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  void _updateDocumentDetailsModel() {
    _erickshawModel = _erickshawModel.copyWith(
        aadharCardNumber: _aadharCardController.text.toString(),
        aadharCardPhotoFront: adhaar[0].path,
        aadharCardPhotoBack: adhaar[1].path,
        drivingLicenceNumber: _drivingLicenseController.text.toString(),
        drivingLicencePhoto: drivingLicense[0].path,
        vehicleNumber: _vehicleNumberController.text.toString());
    if (currentStep < 4) {
      currentStep++;
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    updateState();
  }

  void _submitAboutDetailsModel() {
    List<String> ids=[];
    langData.forEach((element) {
      if(_selectedLanguages.contains(element.name)){
        ids.add(element.id??"");
      }
    },);
    _erickshawModel = _erickshawModel.copyWith(
        languageSpoken: ids, bio: _aboutController.text.toString());
    if (currentStep < 4) {
      currentStep++;
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
    updateState();
  }

  String? _validatePinCode(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'PinCode is required';
    }
    if (value.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'Enter a valid 6-digit pin code';
    }
    try {
      int.parse(value);
    } catch (e) {
      return "Invalid Pin Code";
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

  void _submitApplication() {}
  Future<UserEligibilityModel> getEligibilityData() async {
    final data = await UserProfileService().getEligibility();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstants.planEligibilityKey, jsonEncode(data.data));
    return data;
  }
}
