// import 'dart:convert';
// import 'dart:developer' as developer;
// import 'package:http/http.dart' as http;
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:r_w_r/screens/layout.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../api/api_model/language/language_model.dart';
// import '../../api/api_model/registrations/auto_rikshaw_registration_model.dart';
// import '../../api/api_service/registration_services/e_rekshaw_registration_service.dart';
// import '../../bloc/driver/driver_bloc.dart';
// import '../../bloc/driver/driver_event.dart';
// import '../../bloc/driver/driver_state.dart';
// import '../../components/app_appbar.dart';
// import '../../components/custom_stepper.dart';
// import '../../components/custom_text_field.dart';
// import '../../components/custtom_location_widget.dart';
// import '../../components/media_uploader_widget.dart';
// import '../../constants/color_constants.dart';
// import '../../l10n/app_localizations.dart';
// import '../block/provider/profile_provider.dart';
// import '../other/terms_and_coditions_bottom_sheet.dart';
// import 'doc_verification/adhar_dl_image_verification_widget.dart';
// import 'doc_verification/view_image_button.dart';
//
// class UpperCaseTextFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     return TextEditingValue(
//       text: newValue.text.toUpperCase(),
//       selection: newValue.selection,
//     );
//   }
// }
//
// class OneToEightInputFormatter extends TextInputFormatter {
//   @override
//   TextEditingValue formatEditUpdate(
//     TextEditingValue oldValue,
//     TextEditingValue newValue,
//   ) {
//     if (newValue.text.isEmpty) {
//       return newValue;
//     }
//
//     final int? value = int.tryParse(newValue.text);
//     if (value == null || value < 1 || value > 8) {
//       return oldValue;
//     }
//
//     return newValue;
//   }
// }
//
// class BecomeErickshawScreen extends StatefulWidget {
//   const BecomeErickshawScreen({Key? key}) : super(key: key);
//
//   @override
//   State<BecomeErickshawScreen> createState() => _BecomeErickshawScreenState();
// }
//
// class _BecomeErickshawScreenState extends State<BecomeErickshawScreen> {
//   static const String _logTag = 'BecomeErickshawScreen';
//
//   final BecomeErickshawService _erickshawService = BecomeErickshawService();
//   final AutoRickshawModel _erickshawModel = AutoRickshawModel(
//     vehicleImages: [],
//     languageSpoken: [],
//     address: Address(),
//   );
//
//   final _personalInfoFormKey = GlobalKey<FormState>();
//   final _documentsFormKey = GlobalKey<FormState>();
//   final _vehicleInfoFormKey = GlobalKey<FormState>();
//   final _fareInfoFormKey = GlobalKey<FormState>();
//
//   final ScrollController _scrollController = ScrollController();
//
//   final _nameController = TextEditingController();
//   final _vehicleNumberController = TextEditingController();
//   final _phoneNumberController = TextEditingController();
//   final _bioController = TextEditingController();
//   final _addressLineController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _pincodeController = TextEditingController();
//   final _aadharCardNumberController = TextEditingController();
//   final _seatingCapacityController = TextEditingController();
//   final _minimumFareController = TextEditingController();
//
//   int _currentStep = 0;
//
//   final List<String> _availableLanguages = [
//     "English",
//     "हिन्दी",
//     "தமிழ்",
//     "తెలుగు",
//     "ಕನ್ನಡ",
//     "मराठी",
//     "ગુજરાતી",
//     "বাংলা",
//     "മലയാളം"
//   ];
//   final List<String> _selectedLanguages = [];
//
//   bool _isAadhaarVerified = false;
//   String? _aadhaarVerificationError;
//   bool _isAadhaarImageVerified = false;
//   String? _aadhaarImageVerificationError;
//   bool _isVerifyingAadhaar = false;
//
//   Map<String, bool> verificationStatus = {};
//   Map<String, String?> verificationErrors = {};
//
//   Map<String, String?> _errorTexts = {};
//   bool _isSubmitting = false;
//   bool _allowNegotiation = true;
//
//   bool _isAutoFillingLocation = false;
//
//   Future<void> _saveCurrentStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('er_current_step', _currentStep);
//   }
//
//   Future<void> _loadCurrentStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedStep = prefs.getInt('er_current_step');
//     if (savedStep != null) {
//       setState(() {
//         _currentStep = savedStep;
//       });
//     }
//   }
//
//   Future<void> _clearSavedStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('er_current_step');
//   }
//
//   Future<void> _saveApplicationStatus(ApplicationStatus status) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('er_status', status.toString());
//   }
//
//   Future<void> _saveWhoRegStatus(String status) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('who_reg', status.toString());
//   }
//
//   Future<void> _markApplicationAsStarted() async {
//     final currentStatus = await _getApplicationStatus();
//     if (currentStatus == ApplicationStatus.notStarted) {
//       await _saveApplicationStatus(ApplicationStatus.personalInfoComplete);
//     }
//   }
//
//   Future<ApplicationStatus> _getApplicationStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final statusString = prefs.getString('er_status');
//     if (statusString != null) {
//       return ApplicationStatus.values.firstWhere(
//         (e) => e.toString() == statusString,
//         orElse: () => ApplicationStatus.notStarted,
//       );
//     }
//     return ApplicationStatus.notStarted;
//   }
//
//   Future<void> _fetchCityStateFromPincode(String pincode) async {
//     if (pincode.length == 6 && !_isAutoFillingLocation) {
//       setState(() {
//         _isAutoFillingLocation = true;
//       });
//
//       try {
//         final response = await http.get(
//           Uri.parse('https://api.postalpincode.in/pincode/$pincode'),
//         );
//
//         if (response.statusCode == 200) {
//           final data = json.decode(response.body);
//           if (data[0]['Status'] == 'Success' && data[0]['PostOffice'] != null) {
//             final postOffice = data[0]['PostOffice'][0];
//             setState(() {
//               _cityController.text = postOffice['District'] ?? '';
//               _stateController.text = postOffice['State'] ?? '';
//             });
//           } else {
//             _showErrorSnackBar('Invalid pincode or no data found');
//           }
//         }
//       } catch (e) {
//         developer.log('Error fetching city/state from pincode: $e',
//             name: _logTag);
//         _showErrorSnackBar('Error fetching location data');
//       } finally {
//         setState(() {
//           _isAutoFillingLocation = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _verifyAadhaarNumber(String aadhaarNumber) async {
//     if (aadhaarNumber.length != 12) return;
//
//     setState(() {
//       _isVerifyingAadhaar = true;
//       _isAadhaarVerified = false;
//       _aadhaarVerificationError = null;
//     });
//
//     try {
//       await Future.delayed(const Duration(seconds: 2));
//       final isValid = await _simulateAadhaarVerification(aadhaarNumber);
//
//       setState(() {
//         _isAadhaarVerified = isValid;
//         if (!isValid) {
//           _aadhaarVerificationError =
//               'Aadhaar verification failed. Please check the number.';
//         }
//       });
//
//       if (isValid) {
//         _showSuccessSnackBar('Aadhaar number verified successfully');
//       }
//     } catch (e) {
//       setState(() {
//         _isAadhaarVerified = false;
//         _aadhaarVerificationError = 'Verification error: ${e.toString()}';
//       });
//       _showErrorSnackBar('Verification failed');
//     } finally {
//       setState(() {
//         _isVerifyingAadhaar = false;
//       });
//     }
//   }
//
//   Future<bool> _simulateAadhaarVerification(String aadhaarNumber) async {
//     return aadhaarNumber.isNotEmpty && aadhaarNumber.length == 12;
//   }
//
//   Future<void> _getLocationCoordinates(LocationData location) async {
//     try {
//       if (location.latitude != null && location.longitude != null) {
//         setState(() {
//           _erickshawModel.serviceLocation = ServiceLocation(
//             lat: location.latitude,
//             lng: location.longitude,
//           );
//           _erickshawModel.servicesCities = [location.mainText];
//           _errorTexts['servicesCities'] = null;
//         });
//         return;
//       }
//
//       final coordinates = await _geocodeLocation(location.mainText);
//
//       if (coordinates != null) {
//         setState(() {
//           _erickshawModel.serviceLocation = ServiceLocation(
//             lat: coordinates['lat'],
//             lng: coordinates['lng'],
//           );
//           _erickshawModel.servicesCities = [location.mainText];
//           _errorTexts['servicesCities'] = null;
//         });
//       } else {
//         _showErrorSnackBar('Could not get coordinates for selected location');
//       }
//     } catch (e) {
//       _showErrorSnackBar('Error getting location coordinates: $e');
//     }
//   }
//
//   Future<Map<String, double>?> _geocodeLocation(String locationName) async {
//     try {
//       final response = await http.get(
//         Uri.parse(
//             'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(locationName)}&format=json&limit=1'),
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data != null && data.isNotEmpty) {
//           return {
//             'lat': double.parse(data[0]['lat']),
//             'lng': double.parse(data[0]['lon']),
//           };
//         }
//       }
//       return null;
//     } catch (e) {
//       developer.log('Geocoding error: $e', name: _logTag);
//       return null;
//     }
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.red,
//       ),
//     );
//   }
//
//   void _showSuccessSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         backgroundColor: Colors.green,
//       ),
//     );
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _prefillData();
//     _loadCurrentStep();
//     _markApplicationAsStarted();
//   }
//
//   void _prefillData() {
//     UserPrefillUtility.prefillUserData(
//       contactPersonController: _nameController,
//       phoneController: _phoneNumberController,
//     );
//   }
//
//   @override
//   void dispose() {
//     _disposeControllers();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _initializeControllers() {
//     _seatingCapacityController.text = "3";
//     _minimumFareController.text = "55";
//     _allowNegotiation = true;
//
//     _aadharCardNumberController.addListener(() {
//       if (_aadharCardNumberController.text.isNotEmpty) {
//         setState(() {});
//       }
//     });
//
//     _pincodeController.addListener(() {
//       final pincode = _pincodeController.text;
//       if (pincode.length == 6) {
//         _fetchCityStateFromPincode(pincode);
//       }
//     });
//   }
//
//   void _disposeControllers() {
//     _nameController.dispose();
//     _bioController.dispose();
//     _addressLineController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _pincodeController.dispose();
//     _aadharCardNumberController.dispose();
//     _seatingCapacityController.dispose();
//     _minimumFareController.dispose();
//     _vehicleNumberController.dispose();
//     _phoneNumberController.dispose();
//   }
//
//   String? _validateRequired(String? value, String fieldName) {
//     final localization = AppLocalizations.of(context)!;
//
//     if (value == null || value.trim().isEmpty) {
//       return localization.fieldRequired(fieldName);
//     }
//     return null;
//   }
//
//   String? _validatePhoneNumber(String? value) {
//     final localization = AppLocalizations.of(context)!;
//
//     if (value == null || value.trim().isEmpty) {
//       return localization.fieldRequired(localization.phoneNumber);
//     }
//     if (value.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//       return localization.phone_number_10_digits;
//     }
//     return null;
//   }
//
//   String? _validateNumber(String? value, String fieldName) {
//     final localization = AppLocalizations.of(context)!;
//
//     if (value == null || value.trim().isEmpty) {
//       return localization.fieldRequired(fieldName);
//     }
//     if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//       return localization.enter_correct_phone;
//     }
//     return null;
//   }
//
//   String? _validatePincode(String? value) {
//     final localization = AppLocalizations.of(context)!;
//
//     if (value == null || value.trim().isEmpty) {
//       return localization.fieldRequired(localization.pincode);
//     }
//     if (value.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(value)) {
//       return localization.sixDigitPinIsRequired;
//     }
//     return null;
//   }
//
//   String? _validateAadhaarNumber(String? value) {
//     final localization = AppLocalizations.of(context)!;
//
//     if (value == null || value.trim().isEmpty) {
//       return localization.fieldRequired('Aadhaar Card Number');
//     }
//
//     String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');
//
//     if (cleanValue.length != 12) {
//       return 'Aadhaar number must be 12 digits';
//     }
//
//     if (!RegExp(r'^[0-9]{12}$').hasMatch(cleanValue)) {
//       return 'Please enter a valid Aadhaar number';
//     }
//
//     return null;
//   }
//
//   String? _validateVehicleNumber(String? value) {
//     final localization = AppLocalizations.of(context)!;
//
//     if (value == null || value.trim().isEmpty) {
//       return localization.fieldRequired(localization.vehicleNumber);
//     }
//
//     String cleanValue = value.replaceAll(' ', '').toUpperCase();
//
//     if (!RegExp(r'^[A-Z]{2}[0-9]{2}[A-Z]{1,2}[0-9]{4}$').hasMatch(cleanValue)) {
//       return 'Please enter a valid vehicle number (e.g., DL01AB1234)';
//     }
//
//     return null;
//   }
//
//   String? _validateSelection(List<String>? values, String fieldName) {
//     final localization = AppLocalizations.of(context)!;
//
//     if (values == null || values.isEmpty) {
//       return localization.pleaseSelectAtLeastOne(fieldName);
//     }
//     return null;
//   }
//
//   void _updateErrorText(String field, String? error) {
//     setState(() {
//       _errorTexts[field] = error;
//     });
//   }
//
//   bool get allDocumentsVerified {
//     return _isAadhaarVerified && _isAadhaarImageVerified;
//   }
//
//   void _nextStep() {
//     bool isValid = false;
//
//     switch (_currentStep) {
//       case 0:
//         isValid = _personalInfoFormKey.currentState?.validate() ?? false;
//         final localization = AppLocalizations.of(context)!;
//
//         if (_selectedLanguages.isEmpty) {
//           _updateErrorText(localization.language,
//               localization.pleaseSelectAtLeastOne(localization.language));
//           isValid = false;
//         }
//
//         if (isValid && _erickshawModel.photo != null) {
//           _updatePersonalInfoModel();
//         } else if (_erickshawModel.photo == null) {
//           _showErrorSnackBar(localization.profile_photo_required);
//           return;
//         }
//         break;
//
//       case 1:
//         isValid = _documentsFormKey.currentState?.validate() ?? false;
//         if (isValid &&
//             _erickshawModel.aadharCardPhoto != null &&
//             _erickshawModel.aadharCardPhotoBack != null) {
//           _updateDocumentsModel();
//         } else {
//           _showErrorSnackBar('Please upload all required documents');
//           return;
//         }
//         break;
//
//       case 2:
//         isValid = _vehicleInfoFormKey.currentState?.validate() ?? false;
//
//         if (_erickshawModel.vehicleImages == null ||
//             _erickshawModel.vehicleImages!.isEmpty) {
//           _showErrorSnackBar('Please upload at least one vehicle photo');
//           return;
//         }
//
//         if (isValid) {
//           _updateVehicleInfoModel();
//         }
//         break;
//
//       case 3:
//         isValid = _fareInfoFormKey.currentState?.validate() ?? false;
//
//         if (_erickshawModel.serviceLocation == null ||
//             _erickshawModel.serviceLocation!.lat == null ||
//             _erickshawModel.serviceLocation!.lng == null) {
//           _updateErrorText('servicesCities',
//               'Please select a service area with valid location coordinates');
//           isValid = false;
//         } else {
//           final lat = _erickshawModel.serviceLocation!.lat!;
//           final lng = _erickshawModel.serviceLocation!.lng!;
//
//           if (lat < -90 || lat > 90) {
//             _updateErrorText('servicesCities', 'Invalid latitude coordinates');
//             isValid = false;
//           }
//
//           if (lng < -180 || lng > 180) {
//             _updateErrorText('servicesCities', 'Invalid longitude coordinates');
//             isValid = false;
//           }
//         }
//
//         if (isValid) {
//           _updateFareDetailsModel();
//         }
//         break;
//
//       case 4:
//         _submitApplication();
//         return;
//     }
//
//     if (isValid) {
//       setState(() {
//         _currentStep += 1;
//       });
//       _saveCurrentStep();
//
//       ApplicationStatus status;
//       switch (_currentStep) {
//         case 1:
//           status = ApplicationStatus.personalInfoComplete;
//           break;
//         case 2:
//           status = ApplicationStatus.documentsComplete;
//           break;
//         case 3:
//           status = ApplicationStatus.vehicleInfoComplete;
//           break;
//         case 4:
//           status = ApplicationStatus.fareAndCitiesComplete;
//           break;
//         default:
//           status = ApplicationStatus.personalInfoComplete;
//       }
//       _saveApplicationStatus(status);
//       _saveWhoRegStatus("Driver");
//
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
//       _saveWhoRegStatus("Driver");
//       _scrollToTop();
//     }
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
//   void _updatePersonalInfoModel() {
//     _erickshawModel.name = _nameController.text;
//     _erickshawModel.about = _bioController.text;
//     _erickshawModel.phoneNumber = _phoneNumberController.text;
//     _erickshawModel.languageSpoken = _selectedLanguages;
//
//     _erickshawModel.address ??= Address();
//     _erickshawModel.address!.addressLine = _addressLineController.text;
//     _erickshawModel.address!.city = _cityController.text;
//     _erickshawModel.address!.state = _stateController.text;
//     _erickshawModel.address!.pincode = int.tryParse(_pincodeController.text);
//   }
//
//   void _updateDocumentsModel() {
//     _erickshawModel.aadharCardNumber = _aadharCardNumberController.text;
//   }
//
//   void _updateVehicleInfoModel() {
//     _erickshawModel.vehicleNumber = _vehicleNumberController.text;
//     _erickshawModel.seatingCapacity =
//         int.tryParse(_seatingCapacityController.text);
//   }
//
//   void _updateFareDetailsModel() {
//     _erickshawModel.minimumCharges =
//         int.tryParse(_minimumFareController.text)?.toDouble();
//     _erickshawModel.negotiable = _allowNegotiation;
//   }
//
//   void _ensureModelCompleteness() {
//     _erickshawModel.languageSpoken ??= [];
//     _erickshawModel.vehicleImages ??= [];
//
//     if (_erickshawModel.vehicleVideo != null) {
//       final url = _erickshawModel.vehicleVideo!.toLowerCase();
//       if (!url.contains('.mp4') &&
//           !url.contains('.mov') &&
//           !url.contains('.avi') &&
//           !url.contains('.wmv') &&
//           !url.contains('video')) {
//         _erickshawModel.vehicleVideo = null;
//       }
//     }
//
//     if (_erickshawModel.address == null) {
//       _erickshawModel.address = Address();
//       _updatePersonalInfoModel();
//     }
//
//     if (_erickshawModel.serviceLocation == null &&
//         _erickshawModel.servicesCities != null &&
//         _erickshawModel.servicesCities!.isNotEmpty) {
//       developer.log('Warning: Service location coordinates missing',
//           name: _logTag);
//     }
//
//     developer.log('Final submission data: ${_erickshawModel.toJson()}',
//         name: _logTag);
//   }
//
//   Future<void> _submitApplication() async {
//     final accepted = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => TermsConditionsBottomSheet(
//         type: 'E_RICKSHAW_AGREEMENT',
//       ),
//     );
//
//     if (accepted != true) {
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       _ensureModelCompleteness();
//
//       context.read<DriverBloc>().add(
//             BecomeDriverRegistrationEvent(
//               type: 'E_RICKSHAW',
//               data: _erickshawModel.toJson(),
//             ),
//           );
//
//       final response = await BecomeErickshawService()
//           .submitErickshawApplication(_erickshawModel);
//
//       if (response['success'] == true) {
//         if (!mounted) return;
//         _clearSavedStep();
//         _saveApplicationStatus(ApplicationStatus.submitted);
//         BecomeErickshawService.showSuccessSnackBar(
//             context, 'Application submitted successfully!');
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const Layout()),
//         );
//       } else {
//         if (!mounted) return;
//         BecomeErickshawService.showApiErrorSnackBar(
//           context,
//           response['message'] ?? 'Submission failed',
//         );
//       }
//     } catch (e) {
//       if (mounted) {
//         setState(() => _isSubmitting = false);
//         BecomeErickshawService.showApiErrorSnackBar(
//           context,
//           'An unexpected error occurred',
//         );
//         _showErrorSnackBar('An error occurred: ${e.toString()}');
//       }
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final localization = AppLocalizations.of(context)!;
//     final _stepTitles = [
//       localization.personal_information,
//       localization.documents,
//       localization.vehicle_information,
//       localization.fareAndCities,
//       localization.review,
//     ];
//
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
//           _saveWhoRegStatus("Driver");
//
//           _showSuccessSnackBar(localization.submission_confirmation_complete);
//
//           Navigator.pushReplacement(
//             context,
//             MaterialPageRoute(builder: (context) => const Layout()),
//           );
//         } else if (state is DriverError) {
//           _showErrorSnackBar(state.message);
//         }
//       },
//       child: Scaffold(
//         backgroundColor: ColorConstants.backgroundColor,
//         appBar: CustomAppBar(
//           title: localization.e_rickshaw_registration,
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
//     final localization = AppLocalizations.of(context)!;
//
//     final _stepTitles = [
//       localization.personal_information,
//       localization.documents,
//       localization.vehicle_information,
//       localization.fareAndCities,
//       localization.review,
//     ];
//
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
//               child: Text(localization.previous),
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
//                     _currentStep == _stepTitles.length - 1
//                         ? localization.submit
//                         : localization.next,
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
//         return _buildFareDetailsStep();
//       case 4:
//         return _buildReviewStep();
//       default:
//         return const SizedBox();
//     }
//   }
//
//   Widget _buildPersonalInfoStep() {
//     final localization = AppLocalizations.of(context)!;
//
//     return Form(
//       key: _personalInfoFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Column(
//               children: [
//                 MediaUploader(
//                   label: localization.profilePhoto,
//                   useEyeBlinkDetection: true,
//                   useGallery: false,
//                   showPreview: true,
//                   showDirectImage: true,
//                   icon: Icons.person,
//                   kind: "e_rickshaw",
//                   initialUrl: _erickshawModel.photo,
//                   required: true,
//                   onMediaUploaded: (url) {
//                     setState(() {
//                       _erickshawModel.photo = url;
//                     });
//                   },
//                   allowedExtensions: ['jpg', 'jpeg', 'png'],
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           CustomTextField(
//             label: localization.fullName,
//             controller: _nameController,
//             keyboardType: TextInputType.name,
//             validator: (value) =>
//                 _validateRequired(value, localization.fullName),
//           ),
//           CustomTextField(
//             label: localization.phoneNumber,
//             controller: _phoneNumberController,
//             keyboardType: TextInputType.phone,
//             prefix: Text("+91"),
//             validator: _validatePhoneNumber,
//           ),
//           CustomTextField(
//             label: localization.about,
//             controller: _bioController,
//             maxLines: 3,
//             keyboardType: TextInputType.multiline,
//           ),
//           Text(
//             localization.address,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 16),
//           CustomTextField(
//             label: localization.address,
//             controller: _addressLineController,
//             maxLines: 2,
//             keyboardType: TextInputType.streetAddress,
//             validator: (value) =>
//                 _validateRequired(value, localization.address),
//           ),
//           CustomTextField(
//             label: localization.pincode,
//             controller: _pincodeController,
//             keyboardType: TextInputType.number,
//             validator: _validatePincode,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(6),
//             ],
//             suffix: _isAutoFillingLocation
//                 ? const SizedBox(
//                     width: 20,
//                     height: 20,
//                     child: CircularProgressIndicator(strokeWidth: 2),
//                   )
//                 : null,
//           ),
//           CustomTextField(
//             label: localization.city,
//             controller: _cityController,
//             keyboardType: TextInputType.text,
//             validator: (value) => _validateRequired(value, localization.city),
//           ),
//           CustomTextField(
//             label: localization.state,
//             controller: _stateController,
//             keyboardType: TextInputType.text,
//             validator: (value) => _validateRequired(value, localization.state),
//           ),
//           _buildLanguageSelection(),
//           const SizedBox(height: 16),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildLanguageSelection() {
//     final localization = AppLocalizations.of(context)!;
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           localization.language_spoken,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//         const SizedBox(height: 8),
//         Wrap(
//           spacing: 8.0,
//           runSpacing: 8.0,
//           children: _availableLanguages.map((language) {
//             final bool isSelected =
//                 _selectedLanguages.contains(language.toLowerCase());
//             return FilterChip(
//               label: Text(language),
//               selected: isSelected,
//               selectedColor: ColorConstants.primaryColor.withOpacity(0.2),
//               checkmarkColor: ColorConstants.primaryColor,
//               onSelected: (bool selected) {
//                 setState(() {
//                   if (selected) {
//                     if (!_selectedLanguages.contains(language.toLowerCase())) {
//                       _selectedLanguages.add(language.toLowerCase());
//                     }
//                   } else {
//                     _selectedLanguages.remove(language.toLowerCase());
//                   }
//                   _erickshawModel.languageSpoken = _selectedLanguages;
//                 });
//               },
//             );
//           }).toList(),
//         ),
//         if (_errorTexts['language'] != null)
//           Padding(
//             padding: const EdgeInsets.only(top: 8.0, left: 12.0),
//             child: Text(
//               _errorTexts['language']!,
//               style: const TextStyle(
//                 color: Colors.red,
//                 fontSize: 12.0,
//               ),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildDocumentsStep() {
//     final localization = AppLocalizations.of(context)!;
//
//     return Form(
//       key: _documentsFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             localization.doc_verification,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 16),
//           Card(
//             elevation: 2,
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Aadhaar Card Details',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   CustomTextField(
//                     label: 'Aadhaar Card Number',
//                     controller: _aadharCardNumberController,
//                     keyboardType: TextInputType.number,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(12),
//                     ],
//                     validator: _validateAadhaarNumber,
//                     onChanged: (String vlaue) {
//                       if (vlaue.length == 12) {
//                         _verifyAadhaarNumber(_aadharCardNumberController.text);
//                       }
//                     },
//                   ),
//                   if (_aadhaarVerificationError != null)
//                     Padding(
//                       padding: const EdgeInsets.only(top: 8.0),
//                       child: Text(
//                         _aadhaarVerificationError!,
//                         style: const TextStyle(color: Colors.red, fontSize: 12),
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 16),
//           DocumentVerificationCard(
//             type: 'AADHAR_IMAGE',
//             kind: "e_rickshaw",
//             name: _nameController.text,
//             frontImageUrl: _erickshawModel.aadharCardPhoto,
//             backImageUrl: _erickshawModel.aadharCardPhotoBack,
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
//                 _erickshawModel.aadharCardPhoto = url;
//               });
//             },
//             onBackImageUploaded: (url) {
//               setState(() {
//                 _erickshawModel.aadharCardPhotoBack = url;
//               });
//             },
//           ),
//           const SizedBox(height: 16),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: allDocumentsVerified
//                   ? Colors.green.shade50
//                   : Colors.orange.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: allDocumentsVerified
//                     ? Colors.green.shade200
//                     : Colors.orange.shade200,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   allDocumentsVerified
//                       ? Icons.check_circle
//                       : Icons.info_outline,
//                   color: allDocumentsVerified
//                       ? Colors.green.shade600
//                       : Colors.orange.shade600,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     allDocumentsVerified
//                         ? localization.allDocumentsVerifiedSuccessfully
//                         : localization.pleaseEnsureAllDocumentsUploadedVerified,
//                     style: TextStyle(
//                       color: allDocumentsVerified
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
//   Widget _buildVehicleInfoStep() {
//     final localization = AppLocalizations.of(context)!;
//
//     return Form(
//       key: _vehicleInfoFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CustomTextField(
//             label: localization.vehicleNumber,
//             controller: _vehicleNumberController,
//             textCapitalization: TextCapitalization.characters,
//             inputFormatters: [
//               UpperCaseTextFormatter(),
//               LengthLimitingTextInputFormatter(10),
//             ],
//             validator: _validateVehicleNumber,
//           ),
//           const SizedBox(height: 12),
//           CustomTextField(
//             label: localization.seating_capacity,
//             controller: _seatingCapacityController,
//             keyboardType: TextInputType.number,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               OneToEightInputFormatter()
//             ],
//             validator: (value) => _validateRequired(
//                 value, localization.seating_capacity_value(8)),
//           ),
//           const SizedBox(height: 12),
//           MediaUploader(
//             label: localization.vehicle_photos,
//             multipleFiles: true,
//             onMediaUploaded: (url) {},
//             onMultipleMediaUploaded: (urls) {
//               setState(() {
//                 _erickshawModel.vehicleImages = urls;
//               });
//             },
//             kind: 'e_rickshaw',
//             showDirectImage: true,
//             required: true,
//           ),
//           const SizedBox(height: 12),
//           MediaUploader(
//             label: localization.vehicleVideos,
//             allowVideo: true,
//             multipleFiles: false,
//             onMediaUploaded: (url) {
//               if (url != null) {
//                 final lowercaseUrl = url.toLowerCase();
//                 if (lowercaseUrl.contains('.mp4') ||
//                     lowercaseUrl.contains('.mov') ||
//                     lowercaseUrl.contains('.avi') ||
//                     lowercaseUrl.contains('video') ||
//                     lowercaseUrl.contains('.wmv')) {
//                   setState(() {
//                     _erickshawModel.vehicleVideo = url;
//                   });
//                 } else {
//                   _showErrorSnackBar(
//                       'Please upload a valid video file (mp4, mov, avi, wmv)');
//                 }
//               }
//             },
//             kind: 'e_rickshaw',
//             showDirectImage: false,
//             allowedExtensions: ['mp4', 'mov', 'avi', 'wmv'],
//             required: false,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFareDetailsStep() {
//     final localization = AppLocalizations.of(context)!;
//
//     return Form(
//       key: _fareInfoFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CustomTextField(
//             label: localization.minimum_charges,
//             controller: _minimumFareController,
//             keyboardType: TextInputType.number,
//             validator: (value) =>
//                 _validateNumber(value, localization.minimum_charges),
//           ),
//           SwitchListTile(
//             title: Text(localization.allow_fare_negotiation),
//             value: _allowNegotiation,
//             activeColor: ColorConstants.primaryColor,
//             onChanged: (bool value) {
//               setState(() {
//                 _allowNegotiation = value;
//               });
//             },
//           ),
//           const SizedBox(height: 20),
//           Text(
//             localization.services_cities,
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Card(
//             color: ColorConstants.backgroundColor,
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: LocationSearchScreen(
//                 allowMultipleLocations: false,
//                 initialLocations: _erickshawModel.serviceLocation != null
//                     ? [
//                         LocationData(
//                           placeId: 'current',
//                           mainText: _erickshawModel.servicesCities?.first ??
//                               'Selected Location',
//                           secondaryText: '',
//                         )
//                       ]
//                     : [],
//                 onLocationSelected: (location) {
//                   _getLocationCoordinates(location);
//                 },
//               ),
//             ),
//           ),
//           if (_errorTexts['servicesCities'] != null)
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Text(
//                 _errorTexts['servicesCities']!,
//                 style: const TextStyle(color: Colors.red, fontSize: 12),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReviewStep() {
//     final localization = AppLocalizations.of(context)!;
//
//     return Container(
//       padding: EdgeInsets.all(16),
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
//                     Text(
//                       localization.personal_information,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: ColorConstants.primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     _buildReviewItem(
//                         localization.fullName, _erickshawModel.name ?? ''),
//                     _buildReviewItem(localization.phoneNumber,
//                         _erickshawModel.phoneNumber ?? ''),
//                     _buildReviewItem(localization.language,
//                         _erickshawModel.languageSpoken?.join(', ') ?? ''),
//                     _buildReviewItem(
//                         localization.about, _erickshawModel.about ?? ''),
//                     Divider(),
//                     Text(
//                       localization.address,
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: ColorConstants.primaryColor,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     _buildReviewItem(localization.address,
//                         _erickshawModel.address?.addressLine ?? ''),
//                     _buildReviewItem(
//                         localization.city, _erickshawModel.address?.city ?? ''),
//                     _buildReviewItem(localization.state,
//                         _erickshawModel.address?.state ?? ''),
//                     _buildReviewItem(localization.pincode,
//                         _erickshawModel.address?.pincode?.toString() ?? ''),
//                   ],
//                 ),
//               ),
//               if (_erickshawModel.photo != null)
//                 Container(
//                   width: 90,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                     border: Border.all(
//                         color: ColorConstants.primaryColor, width: 2),
//                     image: DecorationImage(
//                       image: NetworkImage(_erickshawModel.photo!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           const Divider(height: 32),
//           Text(
//             localization.doc_verification_status,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem(
//             localization.aadhaarNumber,
//             _erickshawModel.aadharCardNumber ?? '',
//             trailing: _isAadhaarVerified
//                 ? Icon(Icons.verified, color: Colors.green)
//                 : Icon(Icons.error_outline, color: Colors.red),
//           ),
//           if (_erickshawModel.aadharCardPhoto != null &&
//               _erickshawModel.aadharCardPhotoBack != null)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(localization.uploaded),
//                 SizedBox(width: 20),
//                 ImagePreviewWidget(
//                   imageUrls: [
//                     _erickshawModel.aadharCardPhoto!,
//                     _erickshawModel.aadharCardPhotoBack!,
//                   ],
//                 ),
//               ],
//             ),
//           const Divider(height: 32),
//           Text(
//             localization.vehicle_information,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem(
//               localization.vehicleNumber, _erickshawModel.vehicleNumber ?? ''),
//           _buildReviewItem(localization.seating_capacity,
//               _erickshawModel.seatingCapacity?.toString() ?? ''),
//           _buildReviewItem(localization.vehicle_photos,
//               '${_erickshawModel.vehicleImages?.length ?? 0} ${localization.uploaded}'),
//           _buildReviewItem(
//               localization.vehicleVideos,
//               _erickshawModel.vehicleVideo != null
//                   ? '1 ${localization.uploaded}'
//                   : '0 ${localization.uploaded}'),
//           if (_erickshawModel.vehicleImages != null &&
//               _erickshawModel.vehicleImages!.isNotEmpty)
//             Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Text(localization.uploaded_files),
//                 SizedBox(width: 20),
//                 ImagePreviewWidget(
//                   imageUrls: _erickshawModel.vehicleImages!,
//                 ),
//               ],
//             ),
//           const Divider(height: 32),
//           Text(
//             localization.fare_details,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem(localization.minimum_charges,
//               '₹${_erickshawModel.minimumCharges ?? 'Not provided'}'),
//           _buildReviewItem(
//               localization.allow_negotiation,
//               _erickshawModel.negotiable == true
//                   ? localization.yes
//                   : localization.no),
//           _buildReviewItem(localization.services_cities,
//               _erickshawModel.servicesCities?.join(', ') ?? 'Not selected'),
//           if (_erickshawModel.serviceLocation != null)
//             _buildReviewItem(
//               'Service Location Coordinates',
//               'Lat: ${_erickshawModel.serviceLocation!.lat?.toStringAsFixed(6)}, '
//                   'Lng: ${_erickshawModel.serviceLocation!.lng?.toStringAsFixed(6)}',
//             ),
//           const SizedBox(height: 20),
//           Text(
//             localization.submission_confirmation,
//             style: TextStyle(
//               fontStyle: FontStyle.italic,
//               color: Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReviewSection(String title, List<Widget> items) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Container(
//           margin: const EdgeInsets.symmetric(vertical: 12.0),
//           padding: const EdgeInsets.all(12.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(8.0),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.grey.withOpacity(0.1),
//                 spreadRadius: 1,
//                 blurRadius: 3,
//                 offset: const Offset(0, 1),
//               ),
//             ],
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.bold,
//                   color: ColorConstants.primaryColor,
//                 ),
//               ),
//               const Divider(),
//               ...items,
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildReviewItem(String label, String value,
//       {VoidCallback? onButtonPressed, Widget? trailing}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 90,
//             child: Text(
//               '$label:',
//               style: const TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Flexible(
//                   child: Text(
//                     value,
//                     style: const TextStyle(
//                         fontWeight: FontWeight.w500, wordSpacing: 4),
//                   ),
//                 ),
//                 if (onButtonPressed != null)
//                   GestureDetector(
//                     onTap: onButtonPressed,
//                     child: Padding(
//                       padding: const EdgeInsets.only(left: 8.0),
//                       child: Icon(
//                         Icons.remove_red_eye_outlined,
//                         color: ColorConstants.primaryColor,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           if (trailing != null) trailing,
//         ],
//       ),
//     );
//   }
// }
//
// class CustomDropdown<T> extends StatelessWidget {
//   final String label;
//   final String hint;
//   final T? value;
//   final List<DropdownMenuItem<T>> items;
//   final ValueChanged<T?> onChanged;
//   final String? errorText;
//   final bool required;
//
//   const CustomDropdown({
//     Key? key,
//     required this.label,
//     required this.hint,
//     this.value,
//     required this.items,
//     required this.onChanged,
//     this.errorText,
//     this.required = false,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//         padding: const EdgeInsets.only(bottom: 16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             RichText(
//               text: TextSpan(
//                 children: [
//                   TextSpan(
//                     text: label,
//                     style: const TextStyle(
//                       fontSize: 14,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   if (required)
//                     const TextSpan(
//                       text: ' *',
//                       style: TextStyle(
//                         color: Colors.red,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 8),
//             Container(
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(
//                   color: errorText != null ? Colors.red : Colors.grey.shade300,
//                 ),
//               ),
//               child: DropdownButtonHideUnderline(
//                 child: ButtonTheme(
//                   alignedDropdown: true,
//                   child: DropdownButton<T>(
//                     value: value,
//                     isExpanded: true,
//                     hint: Text(
//                       hint,
//                       style: TextStyle(
//                         color: Colors.grey.shade600,
//                       ),
//                     ),
//                     onChanged: onChanged,
//                     items: items,
//                     padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                   ),
//                 ),
//               ),
//             ),
//             if (errorText != null)
//               Padding(
//                 padding: const EdgeInsets.only(top: 4.0, left: 12.0),
//                 child: Text(
//                   errorText!,
//                   style: const TextStyle(
//                     color: Colors.red,
//                     fontSize: 12.0,
//                   ),
//                 ),
//               ),
//           ],
//         ));
//   }
// }
