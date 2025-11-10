// import 'dart:developer' as developer;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';
// import 'package:r_w_r/constants/api_constants.dart';
// import 'package:r_w_r/screens/layout.dart';
// import 'package:r_w_r/screens/registration_screens/r_widgets/custom_chips.dart';
// import 'package:r_w_r/screens/registration_screens/r_widgets/doc_priview_dialog.dart';
// import 'package:r_w_r/screens/registration_screens/r_widgets/select_city_state.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
//
// import '../../api/api_model/language/language_model.dart';
// import '../../api/api_model/rating_and_reviews_model/indicar_model.dart';
// import '../../api/api_service/registration_services/become_driver_registration_service.dart';
// import '../../bloc/driver/driver_bloc.dart';
// import '../../bloc/driver/driver_event.dart';
// import '../../bloc/driver/driver_state.dart';
// import '../../components/app_appbar.dart';
// import '../../components/app_snackbar.dart';
// import '../../components/custom_stepper.dart';
// import '../../components/custom_text_field.dart';
// import '../../components/custtom_location_widget.dart';
// import '../../components/media_uploader_widget.dart';
// import '../../constants/color_constants.dart';
// import '../block/provider/profile_provider.dart';
// import '../other/terms_and_coditions_bottom_sheet.dart';
// import 'doc_verification/adhar_dl_image_verification_widget.dart';
// import 'doc_verification/view_image_button.dart';
// import 'e_rikshaw_registration_screen.dart';
//
// class BecomeDriverScreen extends StatefulWidget {
//   const BecomeDriverScreen({Key? key}) : super(key: key);
//
//   @override
//   State<BecomeDriverScreen> createState() => _BecomeDriverScreenState();
// }
//
// class _BecomeDriverScreenState extends State<BecomeDriverScreen> {
//   static const String _logTag = 'BecomeDriverScreen';
//
//   final BecomeDriverService _driverService = BecomeDriverService();
//   final BecomeDriverModel _driverModel = BecomeDriverModel(
//     languageSpoken: [],
//     address: Address(),
//     vehicleType: [], // Added back
//     servicesCities: [], // Added back
//   );
//
//   // Verification flags
//   bool _isAadhaarVerified = false;
//   bool _isDLVerified = false;
//   bool _isAadhaarImageVerified = false;
//   bool _isDLImageVerified = false;
//   String? _aadhaarImageVerificationError;
//   String? _dlImageVerificationError;
//   final ScrollController _scrollController = ScrollController();
//
//   final _personalInfoFormKey = GlobalKey<FormState>();
//   final _documentsFormKey = GlobalKey<FormState>();
//   final _vehicleInfoFormKey = GlobalKey<FormState>();
//   final _addressFormKey = GlobalKey<FormState>();
//   final _experienceFormKey = GlobalKey<FormState>();
//   final _fullNameController = TextEditingController();
//   final _mobileNumberController = TextEditingController();
//   final _dobController = TextEditingController();
//   final _bioController = TextEditingController();
//   final _experienceController = TextEditingController();
//   final _minimumChargesController = TextEditingController();
//   final _addressLineController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _pincodeController = TextEditingController();
//   final _drivingLicenceNumberController = TextEditingController();
//   final _aadharCardNumberController = TextEditingController();
//
//   // Location controllers
//   final _serviceLocationController = TextEditingController();
//   double? _serviceLat;
//   double? _serviceLng;
//
//   bool _isNegotiable = false;
//   bool _isLoadingLocation = false;
//
//   // Step variables
//   int _currentStep = 0;
//   final List<String> _stepTitles = [
//     'Personal Info',
//     'Documents',
//     'Vehicle & Service',
//     'Review',
//   ];
//
//   String? _selectedGender;
//   final List<String> _genders = ['Male', 'Female', 'Other'];
//
//   // Vehicle options - restored
//   final List<String> _vehicleOptions = [
//     'Car',
//     'SUV',
//     'Bus',
//     'Van',
//     'Auto Rickshaw',
//     'Motorcycle',
//     'Tempo',
//     'Other'
//   ];
//
//   final List<String> _languageOptions = [
//     "English",
//     "Hindi",
//     'Tamil',
//     'Telugu',
//     'Kannada',
//     'Marathi',
//     'Gujarati',
//     'Bengali',
//     'Malayalam',
//     'Punjabi',
//     'Urdu'
//   ];
//
//   // Service cities options - restored
//   final List<String> _cityOptions = [
//     'Mumbai',
//     'Delhi',
//     'Bangalore',
//     'Chennai',
//     'Kolkata',
//     'Hyderabad',
//     'Pune',
//     'Ahmedabad',
//     'Jaipur',
//     'Lucknow',
//     'Surat',
//     'Kanpur',
//     'Nagpur',
//     'Patna',
//     'Indore',
//     'Thane',
//     'Bhopal',
//     'Visakhapatnam',
//     'Pimpri-Chinchwad',
//     'Vadodara'
//   ];
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _prefillData();
//     _loadFormData();
//     _loadCurrentStep();
//     _markApplicationAsStarted();
//
//     // Set default bio
//     _bioController.text =
//         'Experienced and reliable driver providing safe transportation services';
//   }
//
//   void _initializeControllers() {
//     _drivingLicenceNumberController.addListener(() {
//       if (_drivingLicenceNumberController.text.isNotEmpty) {
//         setState(() {});
//       }
//     });
//
//     _aadharCardNumberController.addListener(() {
//       if (_aadharCardNumberController.text.isNotEmpty) {
//         setState(() {});
//       }
//     });
//
//     // Add pincode listener for auto-fill
//     _pincodeController.addListener(() {
//       if (_pincodeController.text.length == 6) {
//         _fetchLocationByPincode(_pincodeController.text);
//       }
//     });
//   }
//
//   // Enhanced validation methods
//   String? _validateRequired(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }
//     return null;
//   }
//
//   String? _validateMobileNumber(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Mobile number is required';
//     }
//     if (value.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//       return 'Enter a valid 10-digit mobile number';
//     }
//     return null;
//   }
//
//   String? _validatePincode(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Pincode is required';
//     }
//     if (value.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(value)) {
//       return 'Enter a valid 6-digit pincode';
//     }
//     return null;
//   }
//
//   String? _validateAadhaarNumber(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Aadhaar number is required';
//     }
//     if (value.length != 12 || !RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//       return 'Enter a valid 12-digit Aadhaar number';
//     }
//     return null;
//   }
//
//   String? _validateAge(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Date of birth is required';
//     }
//
//     try {
//       DateTime dob = DateFormat('yyyy-MM-dd').parse(value);
//       DateTime now = DateTime.now();
//       int age = now.year - dob.year;
//
//       if (now.month < dob.month ||
//           (now.month == dob.month && now.day < dob.day)) {
//         age--;
//       }
//
//       if (age < 18) {
//         return 'You must be at least 18 years old to register as a driver';
//       }
//
//       if (age > 70) {
//         return 'Maximum age limit is 70 years for driver registration';
//       }
//
//       return null;
//     } catch (e) {
//       return 'Please enter a valid date';
//     }
//   }
//
//   String? _validateNumber(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return 'Enter a valid number';
//     }
//     return null;
//   }
//
//   String? _validateExperience(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Experience is required';
//     }
//     int? experience = int.tryParse(value);
//     if (experience == null || experience < 0) {
//       return 'Enter a valid experience in years';
//     }
//     if (experience > 50) {
//       return 'Maximum experience limit is 50 years';
//     }
//     return null;
//   }
//
//   String? _validateMinimumCharges(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Minimum charges is required';
//     }
//     double? charges = double.tryParse(value);
//     if (charges == null || charges <= 0) {
//       return 'Enter a valid amount';
//     }
//     if (charges > 10000) {
//       return 'Maximum charges limit is ₹10,000';
//     }
//     return null;
//   }
//
//   String? _validateSelection(List<String>? values, String fieldName) {
//     if (values == null || values.isEmpty) {
//       return 'Please select at least one $fieldName';
//     }
//     return null;
//   }
//
//   // Location services
//   Future<void> _getCurrentLocation() async {
//     setState(() {
//       _isLoadingLocation = true;
//     });
//
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         throw Exception('Location services are disabled');
//       }
//
//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           throw Exception('Location permissions are denied');
//         }
//       }
//
//       if (permission == LocationPermission.deniedForever) {
//         throw Exception('Location permissions are permanently denied');
//       }
//
//       Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );
//
//       if (placemarks.isNotEmpty) {
//         Placemark place = placemarks.first;
//         setState(() {
//           _serviceLat = position.latitude;
//           _serviceLng = position.longitude;
//           _serviceLocationController.text =
//               '${place.name}, ${place.locality}, ${place.administrativeArea}';
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error getting location: $e')),
//       );
//     } finally {
//       setState(() {
//         _isLoadingLocation = false;
//       });
//     }
//   }
//
//   Future<void> _fetchLocationByPincode(String pincode) async {
//     try {
//       List<Location> locations = await locationFromAddress(pincode);
//       if (locations.isNotEmpty) {
//         List<Placemark> placemarks = await placemarkFromCoordinates(
//           locations.first.latitude,
//           locations.first.longitude,
//         );
//
//         if (placemarks.isNotEmpty) {
//           Placemark place = placemarks.first;
//           setState(() {
//             _cityController.text = place.locality ?? '';
//             _stateController.text = place.administrativeArea ?? '';
//           });
//         }
//       }
//     } catch (e) {
//       print('Error fetching location by pincode: $e');
//     }
//   }
//
//   Map<String, String?> _errorTexts = {};
//   bool _isSubmitting = false;
//
//   void _updateErrorText(String field, String? error) {
//     setState(() {
//       _errorTexts[field] = error;
//     });
//   }
//
//   // Navigation Methods
//   void _nextStep() {
//     bool isValid = false;
//
//     switch (_currentStep) {
//       case 0: // Personal Info
//         isValid = _personalInfoFormKey.currentState?.validate() ?? false;
//         isValid = _addressFormKey.currentState?.validate() ?? false && isValid;
//         isValid =
//             _experienceFormKey.currentState?.validate() ?? false && isValid;
//
//         if (_selectedGender == null) {
//           _updateErrorText('gender', 'Please select a gender');
//           isValid = false;
//         } else {
//           _updateErrorText('gender', null);
//         }
//
//         if (isValid && _driverModel.profilePhoto != null) {
//           _updatePersonalInfoModel();
//           _updateAddressModel();
//           _updateExperienceModel();
//         } else if (_driverModel.profilePhoto == null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Profile photo is required')),
//           );
//           return;
//         }
//         break;
//
//       case 1: // Documents
//         isValid = _documentsFormKey.currentState?.validate() ?? false;
//         if (isValid &&
//             _driverModel.drivingLicencePhoto != null &&
//             _driverModel.aadharCardPhoto != null) {
//           _updateDocumentsModel();
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('All documents are required')),
//           );
//           return;
//         }
//         break;
//
//       case 2: // Vehicle & Service
//         isValid = _vehicleInfoFormKey.currentState?.validate() ?? false;
//         if (isValid) {
//           if (_driverModel.languageSpoken!.isEmpty) {
//             _updateErrorText(
//                 'languageSpoken', 'Please select at least one language');
//             return;
//           }
//           if (_driverModel.vehicleType!.isEmpty) {
//             _updateErrorText(
//                 'vehicleType', 'Please select at least one vehicle type');
//             return;
//           }
//           // if (_driverModel.servicesCities!.isEmpty) {
//           //   _updateErrorText(
//           //       'servicesCities', 'Please select at least one service city');
//           //   return;
//           // }
//
//           _updateVehicleInfoModel();
//         }
//         break;
//
//       case 3: // Review - Submit
//         _submitApplication();
//         return;
//     }
//
//     if (isValid) {
//       setState(() {
//         _currentStep += 1;
//       });
//       _saveCurrentStep();
//       _saveFormData();
//       _scrollToTop();
//     }
//   }
//
//   void _previousStep() {
//     if (_currentStep > 0) {
//       setState(() {
//         _currentStep -= 1;
//       });
//       _saveCurrentStep();
//       _scrollToTop();
//     }
//   }
//
//   // Model Update Methods
//   void _updatePersonalInfoModel() {
//     _driverModel.fullName = _fullNameController.text;
//     _driverModel.mobileNumber = _mobileNumberController.text;
//     _driverModel.dob = _dobController.text;
//     _driverModel.gender = _selectedGender;
//     _driverModel.bio = _bioController.text;
//   }
//
//   void _updateDocumentsModel() {
//     _driverModel.drivingLicenceNumber = _drivingLicenceNumberController.text;
//     _driverModel.aadharCardNumber = _aadharCardNumberController.text;
//   }
//
//   void _updateAddressModel() {
//     _driverModel.address ??= Address();
//     _driverModel.address!.addressLine = _addressLineController.text;
//     _driverModel.address!.city = _cityController.text;
//     _driverModel.address!.state = _stateController.text;
//     _driverModel.address!.pincode = int.tryParse(_pincodeController.text);
//   }
//
//   void _updateExperienceModel() {
//     _driverModel.experience = int.tryParse(_experienceController.text);
//     _driverModel.minimumCharges =
//         double.tryParse(_minimumChargesController.text);
//     _driverModel.negotiable = _isNegotiable;
//   }
//
//   void _updateVehicleInfoModel() {
//     if (_serviceLat != null && _serviceLng != null) {
//       _driverModel.serviceLocation = ServiceLocation(
//         lat: _serviceLat,
//         lng: _serviceLng,
//       );
//     }
//   }
//
//   // Date Picker with age validation
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().subtract(const Duration(days: 365 * 25)),
//       firstDate: DateTime(1950),
//       lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
//       builder: (BuildContext context, Widget? child) {
//         return Theme(
//           data: ThemeData.light().copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: ColorConstants.primaryColor,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//
//     if (picked != null) {
//       setState(() {
//         _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }
//
//   // Save/Load methods (existing methods maintained)
//   Future<void> _saveFormData() async {
//     final prefs = await SharedPreferences.getInstance();
//     // Save all form data as before
//     await prefs.setString('driver_full_name', _fullNameController.text);
//     await prefs.setString('driver_mobile_number', _mobileNumberController.text);
//     await prefs.setString('driver_bio', _bioController.text);
//     await prefs.setString(
//         'driver_dl_number', _drivingLicenceNumberController.text);
//     await prefs.setString(
//         'driver_aadhar_number', _aadharCardNumberController.text);
//     await prefs.setString('driver_address_line', _addressLineController.text);
//     await prefs.setString('driver_city', _cityController.text);
//     await prefs.setString('driver_state', _stateController.text);
//     await prefs.setString('driver_pincode', _pincodeController.text);
//
//     // Save location data
//     if (_serviceLat != null)
//       await prefs.setDouble('driver_service_lat', _serviceLat!);
//     if (_serviceLng != null)
//       await prefs.setDouble('driver_service_lng', _serviceLng!);
//     await prefs.setString(
//         'driver_service_location', _serviceLocationController.text);
//   }
//
//   Future<void> _loadFormData() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _fullNameController.text = prefs.getString('driver_full_name') ?? '';
//       _mobileNumberController.text =
//           prefs.getString('driver_mobile_number') ?? '';
//       _bioController.text = prefs.getString('driver_bio') ??
//           'Experienced and reliable driver providing safe transportation services';
//       _drivingLicenceNumberController.text =
//           prefs.getString('driver_dl_number') ?? '';
//       _aadharCardNumberController.text =
//           prefs.getString('driver_aadhar_number') ?? '';
//       _addressLineController.text =
//           prefs.getString('driver_address_line') ?? '';
//       _cityController.text = prefs.getString('driver_city') ?? '';
//       _stateController.text = prefs.getString('driver_state') ?? '';
//       _pincodeController.text = prefs.getString('driver_pincode') ?? '';
//
//       // Load location data
//       _serviceLat = prefs.getDouble('driver_service_lat');
//       _serviceLng = prefs.getDouble('driver_service_lng');
//       _serviceLocationController.text =
//           prefs.getString('driver_service_location') ?? '';
//
//       // Update model
//       _updateModelFromControllers();
//     });
//   }
//
//   void _updateModelFromControllers() {
//     _driverModel.fullName = _fullNameController.text;
//     _driverModel.mobileNumber = _mobileNumberController.text;
//     _driverModel.bio = _bioController.text;
//     _driverModel.drivingLicenceNumber = _drivingLicenceNumberController.text;
//     _driverModel.aadharCardNumber = _aadharCardNumberController.text;
//
//     _driverModel.address ??= Address();
//     _driverModel.address!.addressLine = _addressLineController.text;
//     _driverModel.address!.city = _cityController.text;
//     _driverModel.address!.state = _stateController.text;
//     _driverModel.address!.pincode = _pincodeController.text.isNotEmpty
//         ? int.tryParse(_pincodeController.text)
//         : null;
//   }
//
//   Future<void> _saveCurrentStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('driver_current_step', _currentStep);
//   }
//
//   Future<void> _loadCurrentStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedStep = prefs.getInt('driver_current_step');
//     if (savedStep != null) {
//       setState(() {
//         _currentStep = savedStep;
//       });
//     }
//   }
//
//   Future<void> _clearSavedStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('driver_current_step');
//   }
//
//   Future<void> _saveApplicationStatus(ApplicationStatus status) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('driver_status', status.toString());
//   }
//
//   Future<ApplicationStatus> _getApplicationStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final statusString = prefs.getString('driver_status');
//     if (statusString != null) {
//       return ApplicationStatus.values.firstWhere(
//         (e) => e.toString() == statusString,
//         orElse: () => ApplicationStatus.notStarted,
//       );
//     }
//     return ApplicationStatus.notStarted;
//   }
//
//   Future<void> _markApplicationAsStarted() async {
//     final currentStatus = await _getApplicationStatus();
//     if (currentStatus == ApplicationStatus.notStarted) {
//       await _saveApplicationStatus(ApplicationStatus.personalInfoComplete);
//     }
//   }
//
//   void _prefillData() {
//     UserPrefillUtility.prefillUserData(
//       contactPersonController: _fullNameController,
//       phoneController: _mobileNumberController,
//     );
//   }
//
//   void _scrollToTop() {
//     if (_scrollController.hasClients) {
//       _scrollController.animateTo(
//         0.0,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//       );
//     }
//   }
//
//   void _ensureModelCompleteness() {
//     _driverModel.languageSpoken ??= [];
//     _driverModel.vehicleType ??= [];
//     _driverModel.servicesCities ??= [];
//
//     if (_driverModel.address == null) {
//       _driverModel.address = Address();
//       _updateAddressModel();
//     }
//
//     _updatePersonalInfoModel();
//     _updateDocumentsModel();
//     _updateVehicleInfoModel();
//
//     developer.log('Final submission data: ${_driverModel.toJson()}',
//         name: _logTag);
//   }
//
//   Future<void> _submitApplication() async {
//     final accepted = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => TermsConditionsBottomSheet(
//         type: 'DRIVER_AGREEMENT',
//       ),
//     );
//
//     if (accepted != true) {
//       return;
//     }
//
//     if (!mounted) return;
//     setState(() => _isSubmitting = true);
//     try {
//       _ensureModelCompleteness();
//       context.read<DriverBloc>().add(
//             BecomeDriverRegistrationEvent(
//               data: _driverModel.toJson(),
//             ),
//           );
//       final response =
//           await BecomeDriverService().submitDriverApplication(_driverModel);
//       if (response is bool && response == true) {
//         if (!mounted) return;
//         _clearSavedStep();
//         _saveApplicationStatus(ApplicationStatus.submitted);
//         BecomeDriverService.showSuccessSnackBar(
//             context, 'Application submitted successfully!');
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const Layout()),
//         );
//       } else {
//         if (!mounted) return;
//         BecomeDriverService.showApiErrorSnackBar(
//           context,
//           response['message'] ?? 'Submission failed',
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       BecomeDriverService.showApiErrorSnackBar(
//         context,
//         'An unexpected error occurred',
//       );
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }
//
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _mobileNumberController.dispose();
//     _dobController.dispose();
//     _bioController.dispose();
//     _experienceController.dispose();
//     _minimumChargesController.dispose();
//     _addressLineController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _pincodeController.dispose();
//     _drivingLicenceNumberController.dispose();
//     _aadharCardNumberController.dispose();
//     _serviceLocationController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<DriverBloc, DriverState>(
//       listener: (context, state) {
//         if (state is DriverLoading) {
//           setState(() {
//             _isSubmitting = true;
//           });
//         } else {
//           setState(() {
//             _isSubmitting = false;
//           });
//         }
//
//         if (state is BecomeDriverRegistrationSuccess) {
//           _clearSavedStep();
//           _saveApplicationStatus(ApplicationStatus.submitted);
//
//           CustomSnackBar.showCustomSnackBar(
//             context: context,
//             message: state.message,
//             success: true,
//           );
//
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const Layout()),
//           );
//         } else if (state is DriverError) {
//           CustomSnackBar.showCustomSnackBar(
//             context: context,
//             message: state.message,
//             success: false,
//           );
//         }
//       },
//       child: Scaffold(
//         backgroundColor: ColorConstants.backgroundColor,
//         appBar: CustomAppBar(
//           title: 'Become a Driver',
//           backgroundColor: ColorConstants.primaryColor,
//           elevation: 0,
//         ),
//         body: SafeArea(
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.all(1.0),
//                 child: CustomStepper(
//                   currentStep: _currentStep,
//                   stepTitles: _stepTitles,
//                 ),
//               ),
//               Expanded(
//                 child: SingleChildScrollView(
//                   controller: _scrollController,
//                   padding: const EdgeInsets.all(16.0),
//                   child: _buildCurrentStepContent(),
//                 ),
//               ),
//               _buildNavigationButtons(),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildNavigationButtons() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 5,
//             offset: const Offset(0, -3),
//           ),
//         ],
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           if (_currentStep > 0)
//             ElevatedButton(
//               onPressed: _isSubmitting ? null : _previousStep,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.grey[200],
//                 foregroundColor: ColorConstants.black,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text('Previous'),
//             )
//           else
//             const SizedBox(),
//           ElevatedButton(
//             onPressed: _isSubmitting ? null : _nextStep,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: ColorConstants.primaryColor,
//               padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(5),
//               ),
//             ),
//             child: _isSubmitting
//                 ? const SizedBox(
//                     width: 24,
//                     height: 24,
//                     child: CircularProgressIndicator(
//                       color: Colors.white,
//                       strokeWidth: 2,
//                     ),
//                   )
//                 : Text(
//                     _currentStep == _stepTitles.length - 1 ? 'Submit' : 'Next',
//                     style: const TextStyle(
//                       color: ColorConstants.white,
//                     ),
//                   ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildCurrentStepContent() {
//     switch (_currentStep) {
//       case 0:
//         return _buildPersonalInfoStep();
//       case 1:
//         return _buildDocumentsStep();
//       case 2:
//         return _buildVehicleInfoStep();
//       case 3:
//         return _buildReviewStep();
//       default:
//         return const SizedBox();
//     }
//   }
//
//   // Step 1: Personal Information
//   Widget _buildPersonalInfoStep() {
//     return Column(
//       children: [
//         Form(
//           key: _personalInfoFormKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: MediaUploader(
//                   label: 'Profile Photo',
//                   useEyeBlinkDetection: true,
//                   useGallery: false,
//                   showPreview: true,
//                   showDirectImage: true,
//                   icon: Icons.person,
//                   kind: "Driver",
//                   initialUrl: _driverModel.profilePhoto,
//                   required: true,
//                   onMediaUploaded: (url) {
//                     setState(() {
//                       _driverModel.profilePhoto = url;
//                     });
//                   },
//                   allowedExtensions: ['jpg', 'jpeg', 'png'],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               CustomTextField(
//                 label: 'Full Name',
//                 controller: _fullNameController,
//                 keyboardType: TextInputType.name,
//                 validator: (value) => _validateRequired(value, 'Full name'),
//               ),
//               CustomTextField(
//                 label: 'Mobile Number',
//                 controller: _mobileNumberController,
//                 validator: _validateMobileNumber,
//                 prefix: const Text("+91"),
//                 keyboardType: TextInputType.phone,
//               ),
//               CustomTextField(
//                 label: 'Date of Birth',
//                 controller: _dobController,
//                 enabled: true,
//                 suffixIcon: const Icon(Icons.calendar_today),
//                 onTap: () => _selectDate(context),
//                 validator: _validateAge,
//               ),
//               CustomDropdown<String>(
//                 label: 'Gender',
//                 hint: 'Select your gender',
//                 value: _selectedGender,
//                 required: true,
//                 items: _genders.map((String gender) {
//                   return DropdownMenuItem<String>(
//                     value: gender,
//                     child: Text(gender),
//                   );
//                 }).toList(),
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedGender = value;
//                     _errorTexts['gender'] = null;
//                   });
//                 },
//                 errorText: _errorTexts['gender'],
//               ),
//               CustomTextField(
//                 label: 'About Yourself',
//                 controller: _bioController,
//                 maxLines: 3,
//                 keyboardType: TextInputType.multiline,
//                 validator: (value) =>
//                     _validateRequired(value, 'About yourself'),
//               ),
//             ],
//           ),
//         ),
//         Form(
//           key: _addressFormKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 16),
//               const Text(
//                 'Address Information',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: ColorConstants.primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               CustomTextField(
//                 label: 'Address Line',
//                 controller: _addressLineController,
//                 maxLines: 2,
//                 keyboardType: TextInputType.streetAddress,
//                 validator: (value) => _validateRequired(value, 'Address'),
//               ),
//               CustomTextField(
//                 label: 'Pincode',
//                 controller: _pincodeController,
//                 keyboardType: TextInputType.number,
//                 validator: _validatePincode,
//                 onChanged: (value) {
//                   if (value.length == 6) {
//                     _fetchLocationByPincode(value);
//                   }
//                 },
//               ),
//               CustomTextField(
//                 label: 'City',
//                 controller: _cityController,
//                 keyboardType: TextInputType.text,
//                 validator: (value) => _validateRequired(value, 'City'),
//               ),
//               CustomTextField(
//                 label: 'State',
//                 controller: _stateController,
//                 keyboardType: TextInputType.text,
//                 validator: (value) => _validateRequired(value, 'State'),
//               ),
//             ],
//           ),
//         ),
//         Form(
//           key: _experienceFormKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 16),
//               const Text(
//                 'Experience & Charges',
//                 style: TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                   color: ColorConstants.primaryColor,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               CustomTextField(
//                 label: 'Years of Experience',
//                 controller: _experienceController,
//                 keyboardType: TextInputType.number,
//                 validator: _validateExperience,
//               ),
//               CustomTextField(
//                 label: 'Minimum Charges (₹)',
//                 controller: _minimumChargesController,
//                 keyboardType: TextInputType.number,
//                 validator: _validateMinimumCharges,
//               ),
//               const SizedBox(height: 16),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey.shade300),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: CheckboxListTile(
//                   title: const Text(
//                     'Charges are negotiable',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   subtitle: const Text(
//                     'Check if you are open to negotiate your minimum charges',
//                     style: TextStyle(fontSize: 12, color: Colors.grey),
//                   ),
//                   value: _isNegotiable,
//                   onChanged: (bool? value) {
//                     setState(() {
//                       _isNegotiable = value ?? false;
//                     });
//                   },
//                   controlAffinity: ListTileControlAffinity.leading,
//                   activeColor: ColorConstants.primaryColor,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   // Step 2: Documents
//   Widget _buildDocumentsStep() {
//     return Form(
//       key: _documentsFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Document Verification',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 16),
//
//           // Aadhaar Card Section
//           CustomTextField(
//             label: 'Aadhaar Card Number',
//             controller: _aadharCardNumberController,
//             keyboardType: TextInputType.number,
//             validator: _validateAadhaarNumber,
//           ),
//           const SizedBox(height: 16),
//
//           DocumentVerificationCard(
//             type: 'AADHAR_IMAGE',
//             kind: "driver",
//             name: _fullNameController.text,
//             frontImageUrl: _driverModel.aadharCardPhoto,
//             backImageUrl: _driverModel.aadharCardPhotoBack,
//             isVerified: _isAadhaarImageVerified,
//             onVerificationSuccess: () {
//               setState(() {
//                 _isAadhaarImageVerified = true;
//                 _aadhaarImageVerificationError = null;
//               });
//             },
//             onError: (error) {
//               setState(() {
//                 _isAadhaarImageVerified = false;
//                 _aadhaarImageVerificationError = error;
//               });
//             },
//             onFrontImageUploaded: (url) {
//               setState(() {
//                 _driverModel.aadharCardPhoto = url;
//               });
//             },
//             onBackImageUploaded: (url) {
//               setState(() {
//                 _driverModel.aadharCardPhotoBack = url;
//               });
//             },
//           ),
//           const SizedBox(height: 16),
//
//           // Driving License Section
//           CustomTextField(
//             label: 'Driving License Number',
//             controller: _drivingLicenceNumberController,
//             keyboardType: TextInputType.text,
//             validator: (value) =>
//                 _validateRequired(value, 'Driving license number'),
//           ),
//           const SizedBox(height: 16),
//
//           DocumentVerificationCard(
//             type: 'DRIVING_LICENSE_IMAGE',
//             name: _fullNameController.text,
//             kind: "driver",
//             frontImageUrl: _driverModel.drivingLicencePhoto,
//             isVerified: _isDLImageVerified,
//             onVerificationSuccess: () {
//               setState(() {
//                 _isDLImageVerified = true;
//                 _dlImageVerificationError = null;
//               });
//             },
//             onError: (error) {
//               setState(() {
//                 _isDLImageVerified = false;
//                 _dlImageVerificationError = error;
//               });
//             },
//             onFrontImageUploaded: (url) {
//               setState(() {
//                 _driverModel.drivingLicencePhoto = url;
//               });
//             },
//           ),
//
//           const SizedBox(height: 20),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: (_driverModel.aadharCardPhoto != null &&
//                       _driverModel.drivingLicencePhoto != null)
//                   ? Colors.green.shade50
//                   : Colors.orange.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: (_driverModel.aadharCardPhoto != null &&
//                         _driverModel.drivingLicencePhoto != null)
//                     ? Colors.green.shade200
//                     : Colors.orange.shade200,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   (_driverModel.aadharCardPhoto != null &&
//                           _driverModel.drivingLicencePhoto != null)
//                       ? Icons.check_circle
//                       : Icons.info_outline,
//                   color: (_driverModel.aadharCardPhoto != null &&
//                           _driverModel.drivingLicencePhoto != null)
//                       ? Colors.green.shade600
//                       : Colors.orange.shade600,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     (_driverModel.aadharCardPhoto != null &&
//                             _driverModel.drivingLicencePhoto != null)
//                         ? 'All documents have been uploaded successfully!'
//                         : 'Please ensure all documents are uploaded.',
//                     style: TextStyle(
//                       color: (_driverModel.aadharCardPhoto != null &&
//                               _driverModel.drivingLicencePhoto != null)
//                           ? Colors.green.shade700
//                           : Colors.orange.shade700,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // Step 3: Vehicle & Service Information
//   Widget _buildVehicleInfoStep() {
//     return Form(
//       key: _vehicleInfoFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ChipSelection(
//             label: 'Vehicle Types You Drive',
//             options: _vehicleOptions,
//             selectedOptions: _driverModel.vehicleType ?? [],
//             required: true,
//             errorText: _errorTexts['vehicleType'],
//             onSelectionChanged: (selected) {
//               setState(() {
//                 _driverModel.vehicleType = selected;
//                 _errorTexts['vehicleType'] = null;
//               });
//             },
//           ),
//           const SizedBox(height: 16),
//
//           ChipSelection(
//             label: 'Languages Spoken',
//             options: _languageOptions,
//             selectedOptions: _driverModel.languageSpoken ?? [],
//             required: true,
//             errorText: _errorTexts['languageSpoken'],
//             onSelectionChanged: (selected) {
//               setState(() {
//                 _driverModel.languageSpoken = selected;
//                 _errorTexts['languageSpoken'] = null;
//               });
//             },
//           ),
//           const SizedBox(height: 16),
//
//           ChipSelection(
//             label: 'Service Cities',
//             options: _cityOptions,
//             selectedOptions: _driverModel.servicesCities ?? [],
//             required: true,
//             errorText: _errorTexts['servicesCities'],
//             onSelectionChanged: (selected) {
//               setState(() {
//                 _driverModel.servicesCities = selected;
//                 _errorTexts['servicesCities'] = null;
//               });
//             },
//           ),
//           const SizedBox(height: 16),
//
//           // Service Location Section
//           const Text(
//             'Service Location',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 8),
//
//           Card(
//             color: ColorConstants.backgroundColor,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: LocationSearchScreen(
//                 allowMultipleLocations: false,
//                 onLocationSelected: (location) {
//                   setState(() {
//                     _driverModel.serviceLocation = ServiceLocation(
//                         lat: location.latitude, lng: location.longitude);
//                     _errorTexts['serviceLocation'] = null;
//                   });
//                 },
//               ),
//             ),
//           ),
//           if (_errorTexts['serviceLocation'] != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Text(
//                 _errorTexts['serviceLocation']!,
//                 style: const TextStyle(color: Colors.red, fontSize: 12),
//               ),
//             ),
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
//
//   // Step 4: Review
//   Widget _buildReviewStep() {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.1),
//             blurRadius: 10,
//             spreadRadius: 0,
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Personal Information',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: ColorConstants.primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     _buildReviewItem('Full Name', _driverModel.fullName ?? ''),
//                     _buildReviewItem(
//                         'Mobile', '+91 ${_driverModel.mobileNumber ?? ''}'),
//                     _buildReviewItem('Date of Birth', _driverModel.dob ?? ''),
//                     _buildReviewItem('Gender', _driverModel.gender ?? ''),
//                     _buildReviewItem(
//                         'Experience', '${_driverModel.experience ?? ''} years'),
//                     _buildReviewItem('Min. Charges',
//                         '₹${_driverModel.minimumCharges ?? ''}'),
//                     _buildReviewItem('Negotiable',
//                         _driverModel.negotiable == true ? 'Yes' : 'No'),
//                   ],
//                 ),
//               ),
//               if (_driverModel.profilePhoto != null)
//                 Container(
//                   width: 90,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(
//                         color: ColorConstants.primaryColor, width: 2),
//                     image: DecorationImage(
//                       image: NetworkImage(_driverModel.profilePhoto!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//
//           if (_driverModel.bio != null && _driverModel.bio!.isNotEmpty)
//             _buildReviewItem('About', _driverModel.bio!),
//
//           const Divider(height: 32),
//
//           // Address Section
//           const Text(
//             'Address',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem('Address', _driverModel.address?.addressLine ?? ''),
//           _buildReviewItem('City', _driverModel.address?.city ?? ''),
//           _buildReviewItem('State', _driverModel.address?.state ?? ''),
//           _buildReviewItem(
//               'Pincode', _driverModel.address?.pincode?.toString() ?? ''),
//
//           const Divider(height: 32),
//
//           // Documents Section
//           const Text(
//             'Documents',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem(
//               'Aadhaar Number', _driverModel.aadharCardNumber ?? ''),
//           _buildReviewItem(
//               'Driving License', _driverModel.drivingLicenceNumber ?? ''),
//
//           if (_driverModel.aadharCardPhoto != null &&
//               _driverModel.drivingLicencePhoto != null)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 const Text("Uploaded Files: "),
//                 const SizedBox(width: 20),
//                 ImagePreviewWidget(
//                   imageUrls: [
//                     _driverModel.aadharCardPhoto!,
//                     if (_driverModel.aadharCardPhotoBack != null)
//                       _driverModel.aadharCardPhotoBack!,
//                     _driverModel.drivingLicencePhoto!
//                   ],
//                 ),
//               ],
//             ),
//
//           const Divider(height: 32),
//
//           // Service Information
//           const Text(
//             'Service Information',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem(
//               'Vehicle Types', _driverModel.vehicleType?.join(', ') ?? ''),
//           _buildReviewItem(
//               'Languages', _driverModel.languageSpoken?.join(', ') ?? ''),
//           _buildReviewItem(
//               'Service Cities', _driverModel.servicesCities?.join(', ') ?? ''),
//
//           if (_serviceLat != null && _serviceLng != null)
//             _buildReviewItem(
//               'Service Location',
//               'Lat: ${_serviceLat!.toStringAsFixed(4)}, Lng: ${_serviceLng!.toStringAsFixed(4)}',
//             ),
//
//           const SizedBox(height: 20),
//
//           // Status indicator
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: _allRequiredFieldsComplete()
//                   ? Colors.green.shade50
//                   : Colors.orange.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: _allRequiredFieldsComplete()
//                     ? Colors.green.shade200
//                     : Colors.orange.shade200,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   _allRequiredFieldsComplete()
//                       ? Icons.verified_rounded
//                       : Icons.warning,
//                   color: _allRequiredFieldsComplete()
//                       ? Colors.green.shade600
//                       : Colors.orange.shade600,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     _allRequiredFieldsComplete()
//                         ? 'All information provided! Ready to submit your driver application.'
//                         : 'Please ensure all required fields are completed.',
//                     style: TextStyle(
//                       color: _allRequiredFieldsComplete()
//                           ? Colors.green.shade700
//                           : Colors.orange.shade700,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 16),
//           const Text(
//             'By submitting this application, you confirm that all the information provided is accurate and true. You also agree to our terms and conditions for driver partners.',
//             style: TextStyle(
//               fontSize: 14,
//               fontStyle: FontStyle.italic,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReviewItem(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value.isNotEmpty ? value : 'Not provided',
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: value.isNotEmpty ? Colors.black87 : Colors.red.shade600,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   bool _allRequiredFieldsComplete() {
//     return _driverModel.fullName?.isNotEmpty == true &&
//         _driverModel.mobileNumber?.isNotEmpty == true &&
//         _driverModel.dob?.isNotEmpty == true &&
//         _driverModel.gender?.isNotEmpty == true &&
//         _driverModel.bio?.isNotEmpty == true &&
//         _driverModel.address?.addressLine?.isNotEmpty == true &&
//         _driverModel.address?.city?.isNotEmpty == true &&
//         _driverModel.address?.state?.isNotEmpty == true &&
//         _driverModel.address?.pincode != null &&
//         _driverModel.experience != null &&
//         _driverModel.minimumCharges != null &&
//         _driverModel.aadharCardNumber?.isNotEmpty == true &&
//         _driverModel.drivingLicenceNumber?.isNotEmpty == true &&
//         _driverModel.aadharCardPhoto?.isNotEmpty == true &&
//         _driverModel.drivingLicencePhoto?.isNotEmpty == true &&
//         _driverModel.profilePhoto?.isNotEmpty == true &&
//         _driverModel.vehicleType?.isNotEmpty == true &&
//         _driverModel.languageSpoken?.isNotEmpty == true &&
//         _driverModel.servicesCities?.isNotEmpty == true &&
//         _serviceLat != null &&
//         _serviceLng != null;
//   }
// }
