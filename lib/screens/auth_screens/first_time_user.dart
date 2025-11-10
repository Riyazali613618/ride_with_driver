import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/constants/api_constants.dart';

import '../../api/api_service/countryStateProviderService.dart';
import '../../api/api_service/user_service/user_profile_service.dart';
import '../../components/app_appbar.dart';
import '../../components/app_button.dart';
import '../../components/app_snackbar.dart';
import '../../components/media_uploader_widget.dart';
import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';
import '../common_screens/language_screen.dart';
import '../layout.dart';
import '../other/terms_and_coditions_bottom_sheet.dart';
import 'package:r_w_r/api/api_model/cityModel.dart' as cm;
import 'package:r_w_r/api/api_model/stateModel.dart' as sm;

class FirstTimeUserScreen extends StatefulWidget {
  const FirstTimeUserScreen({super.key});

  @override
  State<FirstTimeUserScreen> createState() => _FirstTimeUserScreenState();
}

class _FirstTimeUserScreenState extends State<FirstTimeUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  // State and City dropdown variables
  String? _selectedState;
  String? _selectedCity;

  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  List<cm.Data> _cityList = [];
  List<sm.Data> _stateList = [];

  // Indian states and cities data
  final Map<String, List<String>> _statesAndCities = {
    'Andhra Pradesh': [
      'Visakhapatnam',
      'Vijayawada',
      'Guntur',
      'Nellore',
      'Kurnool',
      'Rajahmundry',
      'Tirupati'
    ],
    'Arunachal Pradesh': [
      'Itanagar',
      'Naharlagun',
      'Pasighat',
      'Tezpur',
      'Bomdila'
    ],
    'Assam': [
      'Guwahati',
      'Silchar',
      'Dibrugarh',
      'Jorhat',
      'Nagaon',
      'Tinsukia'
    ],
    'Bihar': [
      'Patna',
      'Gaya',
      'Bhagalpur',
      'Muzaffarpur',
      'Purnia',
      'Darbhanga',
      'Bihar Sharif'
    ],
    'Chhattisgarh': [
      'Raipur',
      'Bhilai',
      'Korba',
      'Bilaspur',
      'Durg',
      'Rajnandgaon'
    ],
    'Goa': ['Panaji', 'Vasco da Gama', 'Margao', 'Mapusa', 'Ponda'],
    'Gujarat': [
      'Ahmedabad',
      'Surat',
      'Vadodara',
      'Rajkot',
      'Bhavnagar',
      'Jamnagar',
      'Gandhi Nagar'
    ],
    'Haryana': [
      'Gurgaon',
      'Faridabad',
      'Panipat',
      'Ambala',
      'Yamunanagar',
      'Rohtak',
      'Hisar'
    ],
    'Himachal Pradesh': [
      'Shimla',
      'Manali',
      'Dharamshala',
      'Solan',
      'Mandi',
      'Una'
    ],
    'Jharkhand': [
      'Ranchi',
      'Jamshedpur',
      'Dhanbad',
      'Bokaro',
      'Deoghar',
      'Hazaribagh'
    ],
    'Karnataka': [
      'Bangalore',
      'Mysore',
      'Hubli',
      'Mangalore',
      'Belgaum',
      'Gulbarga',
      'Davanagere'
    ],
    'Kerala': [
      'Kochi',
      'Thiruvananthapuram',
      'Kozhikode',
      'Thrissur',
      'Kollam',
      'Palakkad',
      'Alappuzha'
    ],
    'Madhya Pradesh': [
      'Bhopal',
      'Indore',
      'Gwalior',
      'Jabalpur',
      'Ujjain',
      'Sagar',
      'Dewas'
    ],
    'Maharashtra': [
      'Mumbai',
      'Pune',
      'Nagpur',
      'Thane',
      'Nashik',
      'Aurangabad',
      'Solapur'
    ],
    'Manipur': ['Imphal', 'Thoubal', 'Bishnupur', 'Churachandpur'],
    'Meghalaya': ['Shillong', 'Tura', 'Jowai', 'Nongpoh'],
    'Mizoram': ['Aizawl', 'Lunglei', 'Saiha', 'Champhai'],
    'Nagaland': ['Kohima', 'Dimapur', 'Mokokchung', 'Tuensang'],
    'Odisha': [
      'Bhubaneswar',
      'Cuttack',
      'Rourkela',
      'Berhampur',
      'Sambalpur',
      'Puri'
    ],
    'Punjab': [
      'Chandigarh',
      'Ludhiana',
      'Amritsar',
      'Jalandhar',
      'Patiala',
      'Bathinda',
      'Mohali'
    ],
    'Rajasthan': [
      'Jaipur',
      'Jodhpur',
      'Kota',
      'Bikaner',
      'Ajmer',
      'Udaipur',
      'Bhilwara'
    ],
    'Sikkim': ['Gangtok', 'Namchi', 'Gyalshing', 'Mangan'],
    'Tamil Nadu': [
      'Chennai',
      'Coimbatore',
      'Madurai',
      'Tiruchirappalli',
      'Salem',
      'Tirunelveli',
      'Erode'
    ],
    'Telangana': [
      'Hyderabad',
      'Warangal',
      'Nizamabad',
      'Khammam',
      'Karimnagar',
      'Ramagundam'
    ],
    'Tripura': ['Agartala', 'Dharmanagar', 'Udaipur', 'Kailashahar'],
    'Uttar Pradesh': [
      'Lucknow',
      'Kanpur',
      'Ghaziabad',
      'Agra',
      'Varanasi',
      'Meerut',
      'Allahabad'
    ],
    'Uttarakhand': [
      'Dehradun',
      'Haridwar',
      'Roorkee',
      'Haldwani',
      'Kashipur',
      'Rishikesh'
    ],
    'West Bengal': [
      'Kolkata',
      'Howrah',
      'Durgapur',
      'Asansol',
      'Siliguri',
      'Malda',
      'Bardhaman'
    ],
    'Delhi': [
      'New Delhi',
      'Central Delhi',
      'North Delhi',
      'South Delhi',
      'East Delhi',
      'West Delhi'
    ],
  };

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeLocation();
    });
  }

  String? currentCountry;

  void _initializeLocation() {
    final langProvider = Provider.of<LocationProvider>(context, listen: false);
    currentCountry = langProvider.selectedCountry ?? '68dabd590b3041213387d616';

    langProvider.fetchStates(currentCountry!).then((_) {
      if (mounted) {
        setState(() {
          _stateList = langProvider.states;
        });
      }
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  void showUserTerms() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TermsConditionsBottomSheet(
        buttonHide: true,
        type: 'TERMS_AND_CONDITIONS',
      ),
    );
  }

  void showUserTermsPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TermsConditionsBottomSheet(
        buttonHide: true,
        type: 'PRIVACY_POLICY',
      ),
    );
  }

  Future<void> _updateUserProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Get the saved token
      final token = await TokenManager.getToken();
      final baseUrl = ApiConstants.baseUrl;
      if (!mounted) return;
      final localizations = AppLocalizations.of(context)!;
      if (token == null) {
        CustomSnackBar.showCustomSnackBar(
          context: context,
          message: localizations.auth_token_not_found,
          success: false,
        );
        return;
      }
      // Prepare the request body
      final requestBody = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'state': _selectedState ?? '',
        'city': _selectedCity ?? '',
        'image': imageUrl ?? '', // Empty as specified
      };
      if (kDebugMode) {
        print('Updating user profile with data: $requestBody');
      }
      // Create HTTP client with timeout
      final client = http.Client();
      try {
        // Make the API call with timeout
        final response = await client
            .put(
          Uri.parse('$baseUrl/user/profile'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: json.encode(requestBody),
        )
            .timeout(
          Duration(seconds: 30), // 30 seconds timeout
          onTimeout: () async {
            if (kDebugMode) {
              print('Profile update request timed out, verifying update...');
            }

            // Wait a moment for server to potentially complete the update
            await Future.delayed(Duration(seconds: 2));

            try {
              // Try to fetch current profile to verify if update was successful
              final verifyResponse = await http.get(
                Uri.parse('$baseUrl/user/profile'),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              ).timeout(Duration(seconds: 15));
              if (verifyResponse.statusCode == 200) {
                final verifyData = json.decode(verifyResponse.body);
                if (verifyData['status'] == true) {
                  // Create a mock successful response since update likely succeeded
                  return http.Response(
                    json.encode({
                      'status': true,
                      'message': 'Profile updated successfully',
                      'data': verifyData['data']
                    }),
                    200,
                  );
                }
              }
            } catch (e) {
              if (kDebugMode) {
                print('Verification request failed: $e');
              }
            }
            // Return timeout error if verification fails
            return http.Response(
              json.encode({'status': false, 'message': 'Request timed out'}),
              504,
            );
          },
        );
        if (kDebugMode) {
          print('Profile update response: ${response.statusCode}');
          print('Profile update body: ${response.body}');
        }
        if (response.statusCode == 200) {
          if (!mounted) return;
          final responseData = json.decode(response.body);
          if (responseData['success'] == true) {
            TokenManager.setFirstTimeStatus(true);
            CustomSnackBar.showCustomSnackBar(
              context: context,
              message: responseData['message'] ??
                  localizations.profile_updated_success,
              success: true,
            );
            // Update stored user data with new name
            final userData = await TokenManager.getUserData();
            if (userData != null) {
              userData['name'] =
                  '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}';
              await TokenManager.saveUserData(userData);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const Layout(isFirstTime: true)),
              );
            }

            // Navigate to language selection
            // _navigateToLanguageSelection();
          } else {
            CustomSnackBar.showCustomSnackBar(
              context: context,
              message: responseData['message'] ??
                  localizations.failed_to_update_profile,
              success: false,
            );
          }
        } else if (response.statusCode == 504) {
          // Handle 504 specifically - might be a timeout but update could be successful
          if (!mounted) return;
          CustomSnackBar.showCustomSnackBar(
            context: context,
            message:
                "Profile update in progress. Please check if changes were saved.",
            success: false,
          );
        } else {
          if (!mounted) return;

          CustomSnackBar.showCustomSnackBar(
            context: context,
            message: localizations.server_error,
            success: false,
          );
        }
      } finally {
        client.close();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error updating profile: $e');
      }
      if (!mounted) return;
      final localizations = AppLocalizations.of(context)!;

      CustomSnackBar.showCustomSnackBar(
        context: context,
        message: localizations.check_internet_and_retry,
        success: false,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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

  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

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

  UserProfileService _profileService = UserProfileService();

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
        _profileService
            .uploadProfilePhoto(_selectedImage!.absolute.path)
            .then((value) {
          print("value uploaded:${value}");
          setState(() {
            imageUrl = value;
          });
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image from camera');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  String? imageUrl;

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
        _profileService
            .uploadProfilePhoto(_selectedImage!.absolute.path)
            .then((value) {
          print("profile photo uploaded:${value}");
          setState(() {
            imageUrl = value;
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
    });
  }

//this is the language model part tht we have to add with ne screen tht i have made
  void _navigateToLanguageSelection() async {
    final selectedLanguage = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => const LanguageSelectionScreen(),
      ),
    );
    if (!mounted) return;

    if (selectedLanguage != null) {
      // Language was selected successfully, navigate back to previous screen
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
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
            stops: [0.0, 0.25, 0.45, .90],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Welcome text
                    Text(
                      localizations.welcome,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      localizations.complete_profile_to_continue,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Center(
                      child: GestureDetector(
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
                    ),
                    SizedBox(height: 12),
                    Center(
                      child: GestureDetector(
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
                    ),
                    SizedBox(height: 12),
                    // First Name Field
                    TextFormField(
                      controller: _firstNameController,
                      decoration: InputDecoration(
                        labelText: localizations.first_name_required,
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xffBD8CE8)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return localizations.first_name_required;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Last Name Field
                    TextFormField(
                      controller: _lastNameController,
                      decoration: InputDecoration(
                        labelText: localizations.last_name,
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xffBD8CE8)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Email Field
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: localizations.email_optional,
                        labelStyle: const TextStyle(color: Colors.black54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: Color(0xffBD8CE8)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                      validator: (value) {
                        if (value != null && value.trim().isNotEmpty) {
                          // Basic email validation
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return localizations.enter_valid_email;
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
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
                        _selectedState = newValue;
                        _stateController.text = newValue ?? '';
                        if (newValue != null) {
                          final locProvider = Provider.of<LocationProvider>(
                              context,
                              listen: false);
                          locProvider.fetchCity(newValue).then((_) {
                            setState(() {
                              _cityList = locProvider.cities;
                              _selectedCity =
                                  null; // Reset city when state changes
                            });
                          });
                        }
                      },
                      validator: (value) =>
                          value == null ? 'Please select a state' : null,
                    ),
                    const SizedBox(height: 20),
                    // State Dropdown
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
                    SizedBox(height: 20),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8.0, vertical: 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  text: localizations.by_continuing_agree_to,
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500),
                                  children: [
                                    TextSpan(
                                      text: ' T&C ',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () => showUserTerms(),
                                    ),
                                    TextSpan(text: '${localizations.and}\n '),
                                    TextSpan(
                                      text: localizations.privacy_policy,
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap =
                                            () => showUserTermsPrivacyPolicy(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _isLoading
                              ? Container(
                                  height: 56,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: ColorConstants.primaryColorLight,
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  child: const Center(
                                    child: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        color: ColorConstants.primaryColor,
                                        strokeWidth: 2.5,
                                      ),
                                    ),
                                  ),
                                )
                              : CustomButton(
                                  text: localizations.continue_co,
                                  onPressed: _updateUserProfile,
                                  backgroundColor: gradientFirst,
                                  isFullWidth: true,
                                  height: 56,
                                  borderRadius: 17,
                                  textColor: Colors.white,
                                ),
                          const SizedBox(height: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
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
        SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black54),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xffBD8CE8)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }
}
