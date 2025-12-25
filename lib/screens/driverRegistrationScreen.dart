import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/screens/block/language/language_provider.dart';
import 'package:r_w_r/screens/registrationSyccessfulScreen.dart';
import 'dart:io';
import 'package:r_w_r/api/api_model/languageModel.dart' as lm;
import 'package:shared_preferences/shared_preferences.dart';
import '../api/api_model/rating_and_reviews_model/indicar_model.dart';
import '../api/api_service/countryStateProviderService.dart';
import '../api/api_service/media_service.dart';
import '../api/api_service/registration_services/become_driver_registration_service.dart';
import '../utils/color.dart';
import 'package:r_w_r/api/api_model/cityModel.dart' as cm;
import 'package:r_w_r/api/api_model/stateModel.dart' as sm;

import 'multi_step_progress_bar.dart';

class DriverRegistrationFlow extends StatefulWidget {
  @override
  _DriverRegistrationFlowState createState() => _DriverRegistrationFlowState();
}

class _DriverRegistrationFlowState extends State<DriverRegistrationFlow> {
  int currentStep = 0;
  PageController _pageController = PageController();
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  // Form controllers
  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _aadharCardController = TextEditingController();
  final _drivingLicenseController = TextEditingController();
  final _experienceController = TextEditingController();
  final _minimumChargeController = TextEditingController();
  final _aboutController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedGender;
  String? _selectedLanguage;
  List<String> _selectedLangs = [];
  String? _selectedVehicleType;
  List<String> vehicleType = [];
  String? _selectedServiceLocation;
  List<String> _serviceCities = [];
  bool _isNegotiable = false;
  String? _selectedCity;
  String? _selectedState;
  List<cm.Data> _cityList = [];
  List<sm.Data> _stateList = [];

  final List<String> _genders = ['Male', 'Female', 'Other'];
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
  final List<String> _vehicleTypes = [
    'Car',
    'SUV',
    'Mini Van',
    'Bus',
    'Auto Rickshaw',
    'E-Rickshaw',
    'Bike',
    'Tempo'
  ];
  final List<String> _serviceLocations = [
    'Delhi',
    'Gurgaon',
    'Mumbai',
    'Kolkata'
  ];

  final List<String> stepTitles = [
    'Company Detail',
    'Address',
    'Document',
    'About',
    'Submit'
  ];

  // Document selection methods
  void _showDocumentPickerBottomSheet(String from) {
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
        if (from == 'ADHAAR') {
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
        if (from == 'ADHAAR') {
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

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ??
          DateTime.now().subtract(Duration(days: 6570)), // 18 years ago
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  /*void nextStep() {
    if (currentStep < 4) {
      setState(() {
        currentStep++;
      });
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }*/
  void nextStep() {
    bool isValid = false;
    String? errorMessage;

    switch (currentStep) {
      case 0: // Self Detail
        if (_selectedImage == null) {
          errorMessage = 'Profile image is required';
          isValid = false;
        } else if (_nameController.text.isEmpty ||
            _phoneNumberController.text.isEmpty ||
            _selectedDate == null ||
            _selectedGender == null) {
          errorMessage = 'Please fill all required fields';
          isValid = false;
        } else {
          isValid = true;
        }
        break;

      case 1: // Address
        if (_addressController.text.trim().isEmpty) {
          errorMessage = 'Please enter address first';
          isValid = false;
        } else if (_pinCodeController.text.trim().isEmpty) {
          errorMessage = 'Please enter pin code first';
          isValid = false;
        } else if (_selectedState == null) {
          errorMessage = 'Please select state first';
          isValid = false;
        } else if (_selectedCity == null) {
          errorMessage = 'Please select city first';
          isValid = false;
        } else {
          isValid = true;
        }
        break;

      case 2: // Document
        if (!_isAadhaarVerified) {
          errorMessage = 'Please verify your Aadhaar number';
          isValid = false;
        } else if (adhaar.isEmpty && adhaar.length < 2) {
          errorMessage =
              'Please upload both front and back images of Aadhaar card';
          isValid = false;
        } else if (_drivingLicenseController.text.trim().isEmpty) {
          errorMessage = 'Please enter driving license number';
          isValid = false;
        } else if (drivingLicense.isEmpty) {
          errorMessage = 'Please upload driving license';
          isValid = false;
        } else {
          isValid = true;
        }

        break;

      case 3: // About
        if (_experienceController.text.trim().isEmpty) {
          errorMessage = 'please enter experience';
          isValid = false;
        } else if (_minimumChargeController.text.trim().isEmpty) {
          errorMessage = 'please enter minimum charge';
          isValid = false;
        } else if (_selectedVehicleType == null ||
            _selectedVehicleType!.isEmpty) {
          errorMessage = 'please select vehicle type';
          isValid = false;
        } else if (_selectedServiceLocation == null ||
            _selectedServiceLocation!.isEmpty) {
          errorMessage = 'please select service location type';
          isValid = false;
        } else {
          isValid = true;
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

  Future<void> _saveCurrentStep() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('independent_driver_current_step', currentStep);
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

  String? currentCountry;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeSelectedLanguage();
      final langProvider =
          Provider.of<LocationProvider>(context, listen: false);
      currentCountry =
          langProvider.selectedCountry ?? '68dabd590b3041213387d616';
      final languageProvider =
          Provider.of<LanguageProvider>(context, listen: false);
      langData = languageProvider.language??[];
      final locProvider = Provider.of<LocationProvider>(context, listen: false);
      locProvider.fetchStates(currentCountry!).then(
        (value) {
          if (mounted) {
            setState(() {
              _stateList = langProvider.states;
              _selectedCity = null;
            });
            fetchCityList(locProvider);
          }
        },
      );
    });
  }

  List<lm.Data> langData = [];
  List<lm.Data> selectedLang = [];

  Future<void> _initializeSelectedLanguage() async {
    final languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    languageProvider.fetchLanguagesFromApi();
    if (mounted) {
      setState(() {});
    }
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
        child: Scaffold(
          body: CommonParentContainer(
            child: SafeArea(
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
                          _buildCompanyDetailStep(),
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
        ));
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
          Text(
            'Become a Driver',
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

  Widget _buildCompanyDetailStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
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
            _buildTextField('Name *', _nameController),
            SizedBox(height: 20),
            _buildTextField('Phone Number*', _phoneNumberController,textInputType: TextInputType.phone),
            SizedBox(height: 20),
            _buildDateField('Date of Birth *'),
            SizedBox(height: 20),
            _buildDropdownField('Gender *', _selectedGender, _genders, (value) {
              setState(() {
                _selectedGender = value;
              });
            }),
            SizedBox(height: 80), // Replace Spacer with fixed spacing
            _buildContinueButton(),
            SizedBox(height: 24), // Add bottom padding
          ],
        ),
      ),
    );
  }

  Widget _buildAddressStep() {
    return Padding(
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
          _buildTextField('Address*', _addressController,
              placeholder: '12 house no., XYZ STREET, Opp ABC Mall'),
          SizedBox(height: 20),
          _buildTextField('Pin Code*', _pinCodeController,
              placeholder: '788799',textInputType: TextInputType.phone),
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
                value == null ? 'Please select a city first' : null,
          ),
          Spacer(),
          _buildContinueButton(),
        ],
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
      child: SingleChildScrollView(
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
            // Aadhar Card Container with both field and verify button
            Container(
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
                          height: 40,
                          padding: EdgeInsets.symmetric(horizontal: 5),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[400]!),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: TextField(
                            controller: _aadharCardController,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration.collapsed(
                              hintText: 'Enter Aadhar Card Number',
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 16,
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
                        height: 40,
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
            Container(
              width: double.infinity,
              child: _buildFileUploadSection(
                  'Upload Aadhar Card (Front & Back)', "ADHAAR"),
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              child: _buildTextField(
                  'Driving License Number', _drivingLicenseController,),
            ),
            SizedBox(height: 24),
            Container(
              width: double.infinity,
              child: _buildFileUploadSection(
                  'Upload Driving License', "DRIVING LICENSE"),
            ),
            SizedBox(height: 40),
            _buildContinueButton(),
          ],
        ),
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

  Widget _buildAboutStep() {
    return Padding(
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
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
            _buildTextField('Experience', _experienceController,
                placeholder: 'Years of experience',textInputType: TextInputType.phone),
            SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                      'Minimum Charge', _minimumChargeController,
                      placeholder: '₹100',textInputType: TextInputType.phone),
                ),
                SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: Row(
                    children: [
                      Radio<bool>(
                        activeColor: Colors.green,
                        value: true,
                        groupValue: _isNegotiable,
                        onChanged: (value) {
                          setState(() {
                            _isNegotiable = value ?? false;
                          });
                        },
                      ),
                      Text(
                        'Negotiable',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildDropdownField(
                'Vehicle Drive Type', _selectedVehicleType, _vehicleTypes,
                (value) {
              setState(() {
                _selectedVehicleType = value;
                vehicleType.add(_selectedVehicleType!);
              });
            }),
            SizedBox(height: 20),
            _buildDropdownField(
                'Service Location', _selectedServiceLocation, _serviceLocations,
                (value) {
              setState(() {
                _selectedServiceLocation = value;
                _serviceCities.add(_selectedServiceLocation!);
              });
            }),
            SizedBox(height: 20),
            _buildDropdownFieldForLanguage(
                'Spoken Languages', _selectedLanguage, langData, (value) {
              setState(() {
                _selectedLanguage = value;
                _selectedLangs.add(_selectedLanguage!);
              });
            }),
            /*_buildDropdownField(
                'Spoken Languages', _selectedLanguage, _languages, (value) {
              setState(() {
                _selectedLanguage = value;
              });
            }),*/
            SizedBox(height: 20),
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
                  hintText: 'Tell us about yourself...',
                ),
              ),
            ),
            SizedBox(height: 40),
            _buildContinueButton(),
          ],
        ),
      ),
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
                    'Name',
                    _nameController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _nameController.text),
                _buildPreviewItem(
                    'Phone Number',
                    _phoneNumberController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _phoneNumberController.text),
                _buildPreviewItem(
                    'Date of Birth',
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Lorem Ipsum'),
                _buildPreviewItem('Gender', _selectedGender ?? 'Lorem Ipsum'),
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
                    'Driving License Number',
                    _drivingLicenseController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _drivingLicenseController.text),
                _buildPreviewItem(
                    'Experience',
                    _experienceController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : _experienceController.text),
                _buildPreviewItem(
                    'Minimum Charge',
                    _minimumChargeController.text.isEmpty
                        ? 'Lorem Ipsum'
                        : '${_minimumChargeController.text}${_isNegotiable ? ' (Negotiable)' : ''}'),
                _buildPreviewItem('Vehicle Drive Type',
                    _selectedVehicleType ?? 'Lorem Ipsum'),
                _buildPreviewItem('Service Location',
                    _selectedServiceLocation ?? 'Lorem Ipsum'),
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
          if (!uploadingFinalData) _submitForm();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF8B5CF6),
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: uploadingFinalData
            ? Center(
                child: Container(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ))
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
  }

  void _submitForm() {
    _showRegistrationAgreementBottomSheet();
  }

  void _showRegistrationAgreementBottomSheet() {
    bool isAgreed = false;

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
                              'Registration Agreement Driver',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 20),
                            Expanded(
                              child: SingleChildScrollView(
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
                                    setState(() {
                                      isAgreed = !isAgreed;
                                    });
                                  },
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

  BecomeDriverModel _becomeDriverModel = BecomeDriverModel();

  bool uploadingFinalData = false;

  Future<void> _proceedToFinalStep() async {
    Navigator.pop(context);
    setState(() {
      uploadingFinalData = true;
    });
    String aadhaarBackUrl = "";
    String aadhaarFrontUrl = "";
    String profilePhoto = "";
    String drivingLicenseUrl = "";
    try {
      if (adhaar.isNotEmpty && adhaar.length > 0 && adhaar[0].path.isNotEmpty) {
        final XFile xFileAadhaarBack = XFile(adhaar[0].path);
        final aadharCardPhotoBack = await MediaService()
            .uploadMedia(xFileAadhaarBack, kind: "document", type: "document");
        aadhaarFrontUrl = aadharCardPhotoBack.url!;
      }
      if (adhaar.isNotEmpty && adhaar.length > 1 && adhaar[1].path.isNotEmpty) {
        final XFile xFileAadhaarBack = XFile(adhaar[1].path);
        final aadharCardPhotoBack = await MediaService()
            .uploadMedia(xFileAadhaarBack, kind: "document", type: "document");
        aadhaarBackUrl = aadharCardPhotoBack.url!;
      }
      if (_selectedImage != null && _selectedImage!.path.isNotEmpty) {
        final XFile xFileAadhaarBack = XFile(_selectedImage!.path);
        final photo = await MediaService().uploadMedia(xFileAadhaarBack,
            kind: "profilePhoto", type: "profilePhoto");
        profilePhoto = photo.url!;
      }
      if (drivingLicense.isNotEmpty) {
        final XFile file = XFile(drivingLicense[0].path);
        final photo = await MediaService()
            .uploadMedia(file, kind: "document", type: "document");
        drivingLicenseUrl = photo.url!;
      }
      List<String> lanList=[];
      langData.forEach((element) {
        if(_selectedLangs.contains(element.name)){
          lanList.add(element.id??"");
        }
      },);
      Address address=Address(addressLine: _addressController.text,
          pincode: int.parse(_pinCodeController.text),
          state: _selectedState,
          city: _selectedCity );
      _becomeDriverModel = _becomeDriverModel.copyWith(
        drivingLicenceNumber: _drivingLicenseController.text ?? '',
        drivingLicencePhoto: drivingLicenseUrl,
        firstName: _nameController.text ?? '',
        lastName: _nameController.text ?? '',
        aadharCardNumber: _aadharCardController.text,
        aadharCardPhotoFront: aadhaarFrontUrl,
        aadharCardPhotoBack: aadhaarBackUrl,
        businessMobileNumber: _phoneNumberController.text,
        profilePhoto: profilePhoto,
        languageSpoken: lanList,
        vehicleType: vehicleType ?? [],
        servicesCities: _serviceCities,
        bio: _aboutController.text,
        experience: int.parse(_experienceController.text),
        address: address,
        minimumCharges: double.parse(_minimumChargeController.text) ?? 0.0,
        dob: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        gender: _selectedGender,
        negotiable: _isNegotiable,
        serviceLocation: ServiceLocation(lat: 28.6139, lng: 77.2090),
      );

      final response = await BecomeDriverService()
          .submitDriverApplication(_becomeDriverModel);
      if (response['success'] == true) {
        if (!mounted) return;
        BecomeDriverService.showSuccessSnackBar(
            context, 'Application submitted successfully!');
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const RegistrationSuccessfulScreen(
                    userType: 'DRIVER',
                  )),
        );
      } else {
        if (!mounted) return;
        BecomeDriverService.showApiErrorSnackBar(
          context,
          response['message'] ?? 'Submission failed',
        );
      }
      setState(() {
        uploadingFinalData = false;
      });
    } catch (e) {
      setState(() {
        uploadingFinalData = false;
      });
    } finally {
      setState(() {
        uploadingFinalData = false;
      });
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneNumberController.dispose();
    _addressController.dispose();
    _pinCodeController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _aadharCardController.dispose();
    _drivingLicenseController.dispose();
    _experienceController.dispose();
    _minimumChargeController.dispose();
    _aboutController.dispose();
    super.dispose();
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
      {String? placeholder,TextInputType? textInputType}) {
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
            controller: controller,
            keyboardType: textInputType,
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

  Widget _buildDateField(String label) {
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
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _selectedDate != null
                      ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                      : 'Select Date',
                  style: TextStyle(
                    color:
                        _selectedDate != null ? Colors.black : Colors.grey[400],
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  color: Colors.grey[400],
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String? value, List<String> items,
      ValueChanged<String?> onChanged) {
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
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownFieldForLanguage(String label, String? value,
      List<lm.Data> items, ValueChanged<String?> onChanged) {
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
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return Container(
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

  void fetchCityList(LocationProvider locProvider) {
    locProvider.fetchCity(_selectedState ?? "").then((_) {
      setState(() {
        _cityList = locProvider.cities;
        _selectedCity = null; // Reset city when state changes
      });
    });
  }
}
