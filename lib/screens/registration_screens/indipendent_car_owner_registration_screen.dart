// import 'dart:convert';
// import 'dart:developer' as developer;
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:provider/provider.dart';
// import 'package:r_w_r/screens/layout.dart';
// import 'package:r_w_r/screens/registration_screens/r_widgets/doc_priview_dialog.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:http/http.dart' as http;
// import '../../api/api_model/language/language_model.dart';
// import '../../api/api_model/registrations/become_driver_registration_model.dart';
// import '../../api/api_service/registration_services/become_driver_registration_service.dart';
// import '../../api/api_service/registration_services/indi_car_service.dart';
// import '../../components/app_appbar.dart';
// import '../../components/custom_stepper.dart';
// import '../../components/custom_text_field.dart';
// import '../../components/media_uploader_widget.dart';
// import '../../constants/api_constants.dart';
// import '../../constants/color_constants.dart';
// import '../../constants/token_manager.dart';
// import '../block/provider/profile_provider.dart';
// import '../other/terms_and_coditions_bottom_sheet.dart';
// import 'doc_verification/adhar_dl_image_verification_widget.dart';
// import 'doc_verification/view_image_button.dart';
//
// class IndependentCarOwnerScreen extends StatefulWidget {
//   const IndependentCarOwnerScreen({super.key});
//
//   @override
//   State<IndependentCarOwnerScreen> createState() =>
//       _IndependentCarOwnerScreenState();
// }
//
// class _IndependentCarOwnerScreenState extends State<IndependentCarOwnerScreen> {
//   static const String _logTag = 'IndependentCarOwnerScreen';
//
//   final BecomeDriverModel _driverModel = BecomeDriverModel(
//     address: Address(),
//   );
//
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
//   final _addressFormKey = GlobalKey<FormState>();
//
//   final _fullNameController = TextEditingController();
//   final _mobileNumberController = TextEditingController();
//   final _bioController = TextEditingController(
//       text: 'Independent car owner providing transportation services');
//   final _addressLineController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _pincodeController = TextEditingController();
//   final _drivingLicenceNumberController = TextEditingController();
//   final _aadharCardNumberController = TextEditingController();
//
//   int _currentStep = 0;
//   final List<String> _stepTitles = [
//     'Personal Info',
//     'Documents',
//     'Address',
//     'Review',
//   ];
//
//   Map<String, String?> _errorTexts = {};
//   bool _isSubmitting = false;
//
//   Future<void> _saveFormData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     await prefs.setString('indi_full_name', _fullNameController.text);
//     await prefs.setString('indi_mobile_number', _mobileNumberController.text);
//     await prefs.setString('indi_bio', _bioController.text);
//
//     await prefs.setString('indi_dl_number', _drivingLicenceNumberController.text);
//     await prefs.setString('indi_aadhar_number', _aadharCardNumberController.text);
//
//     await prefs.setString('indi_address_line', _addressLineController.text);
//     await prefs.setString('indi_city', _cityController.text);
//     await prefs.setString('indi_state', _stateController.text);
//     await prefs.setString('indi_pincode', _pincodeController.text);
//
//     if (_driverModel.profilePhoto != null) {
//       await prefs.setString('indi_profile_photo', _driverModel.profilePhoto!);
//     }
//     if (_driverModel.aadharCardPhoto != null) {
//       await prefs.setString('indi_aadhar_photo', _driverModel.aadharCardPhoto!);
//     }
//     if (_driverModel.aadharCardPhotoBack != null) {
//       await prefs.setString('indi_aadhar_photo_back', _driverModel.aadharCardPhotoBack!);
//     }
//     if (_driverModel.drivingLicencePhoto != null) {
//       await prefs.setString('indi_dl_photo', _driverModel.drivingLicencePhoto!);
//     }
//     // if (_driverModel. != null) {
//     //   await prefs.setString('indi_permit_photo', _driverModel.transportationPermitPhoto!);
//     // }
//   }
//
//   Future<void> _loadFormData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     setState(() {
//       _fullNameController.text = prefs.getString('indi_full_name') ?? '';
//       _mobileNumberController.text = prefs.getString('indi_mobile_number') ?? '';
//       _bioController.text = prefs.getString('indi_bio') ?? 'Independent car owner providing transportation services';
//
//       _driverModel.fullName = _fullNameController.text;
//       _driverModel.mobileNumber = _mobileNumberController.text;
//       _driverModel.bio = _bioController.text;
//
//       _drivingLicenceNumberController.text = prefs.getString('indi_dl_number') ?? '';
//       _aadharCardNumberController.text = prefs.getString('indi_aadhar_number') ?? '';
//
//       _driverModel.drivingLicenceNumber = _drivingLicenceNumberController.text;
//       _driverModel.aadharCardNumber = _aadharCardNumberController.text;
//
//       _addressLineController.text = prefs.getString('indi_address_line') ?? '';
//       _cityController.text = prefs.getString('indi_city') ?? '';
//       _stateController.text = prefs.getString('indi_state') ?? '';
//       _pincodeController.text = prefs.getString('indi_pincode') ?? '';
//
//       _driverModel.address ??= Address();
//       _driverModel.address!.addressLine = _addressLineController.text;
//       _driverModel.address!.city = _cityController.text;
//       _driverModel.address!.state = _stateController.text;
//       _driverModel.address!.pincode = _pincodeController.text.isNotEmpty ? int.tryParse(_pincodeController.text) : null;
//
//       _driverModel.profilePhoto = prefs.getString('indi_profile_photo');
//       _driverModel.aadharCardPhoto = prefs.getString('indi_aadhar_photo');
//       _driverModel.aadharCardPhotoBack = prefs.getString('indi_aadhar_photo_back');
//       _driverModel.drivingLicencePhoto = prefs.getString('indi_dl_photo');
//       // _driverModel. = prefs.getString('indi_permit_photo');
//     });
//   }
//
//   void _updateModelFromControllers() {
//     _driverModel.fullName = _fullNameController.text;
//     _driverModel.mobileNumber = _mobileNumberController.text;
//     _driverModel.bio = _bioController.text;
//
//     _driverModel.drivingLicenceNumber = _drivingLicenceNumberController.text;
//     _driverModel.aadharCardNumber = _aadharCardNumberController.text;
//
//     _driverModel.address ??= Address();
//     _driverModel.address!.addressLine = _addressLineController.text;
//     _driverModel.address!.city = _cityController.text;
//     _driverModel.address!.state = _stateController.text;
//     _driverModel.address!.pincode = _pincodeController.text.isNotEmpty ? int.tryParse(_pincodeController.text) : null;
//   }
//
//   Future<void> _clearFormData() async {
//     final prefs = await SharedPreferences.getInstance();
//
//     await prefs.remove('indi_full_name');
//     await prefs.remove('indi_mobile_number');
//     await prefs.remove('indi_bio');
//
//     await prefs.remove('indi_dl_number');
//     await prefs.remove('indi_aadhar_number');
//
//     await prefs.remove('indi_address_line');
//     await prefs.remove('indi_city');
//     await prefs.remove('indi_state');
//     await prefs.remove('indi_pincode');
//
//     await prefs.remove('indi_profile_photo');
//     await prefs.remove('indi_aadhar_photo');
//     await prefs.remove('indi_aadhar_photo_back');
//     await prefs.remove('indi_dl_photo');
//     await prefs.remove('indi_permit_photo');
//   }
//
//   Future<void> _fetchLocationFromPinCode(String pincode) async {
//     if (pincode.length != 6) return;
//
//     try {
//       final profileProvider = Provider.of<ProfileProvider>(context, listen: false);
//       final userId = profileProvider.userId;
//       final token = await TokenManager.getToken();
//
//       final response = await http.get(
//         Uri.parse('${ApiConstants.baseUrl}/user/pincode/$pincode'),
//         headers: {
//           'Content-Type': 'application/json',
//           'x-user-id': userId ?? '',
//           'Authorization': 'Bearer $token',
//         },
//       );
//
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         if (data['status'] == true && data['data'] != null) {
//           setState(() {
//             _cityController.text = data['data']['city'] ?? '';
//             _stateController.text = data['data']['state'] ?? '';
//           });
//           _updateModelFromControllers();
//           _saveFormData();
//         }
//       }
//     } catch (e) {
//       print('Error fetching location from pincode: $e');
//     }
//   }
//
//   Future<void> _saveCurrentStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('indi_current_step', _currentStep);
//   }
//
//   Future<void> _loadCurrentStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedStep = prefs.getInt('indi_current_step');
//     if (savedStep != null) {
//       setState(() {
//         _currentStep = savedStep;
//       });
//     }
//   }
//
//   Future<void> _clearSavedStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('indi_current_step');
//   }
//
//   Future<void> _saveApplicationStatus(ApplicationStatus status) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('indi_status', status.toString());
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
//       await _saveFormData();
//     }
//   }
//
//   Future<ApplicationStatus> _getApplicationStatus() async {
//     final prefs = await SharedPreferences.getInstance();
//     final statusString = prefs.getString('indi_status');
//     if (statusString != null) {
//       return ApplicationStatus.values.firstWhere(
//         (e) => e.toString() == statusString,
//         orElse: () => ApplicationStatus.notStarted,
//       );
//     }
//     return ApplicationStatus.notStarted;
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _prefillData();
//     _loadCurrentStep();
//     _markApplicationAsStarted();
//     _loadFormData();
//   }
//
//   void _prefillData() {
//     UserPrefillUtility.prefillUserData(
//       contactPersonController: _fullNameController,
//       phoneController: _mobileNumberController,
//     );
//   }
//
//   @override
//   void dispose() {
//     _fullNameController.dispose();
//     _mobileNumberController.dispose();
//     _bioController.dispose();
//     _addressLineController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _pincodeController.dispose();
//     _drivingLicenceNumberController.dispose();
//     _aadharCardNumberController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   void _initializeControllers() {
//     _drivingLicenceNumberController.addListener(() {
//       if (_drivingLicenceNumberController.text.isNotEmpty) {
//         setState(() {});
//       }
//       _updateModelFromControllers();
//       _saveFormData();
//     });
//
//     _aadharCardNumberController.addListener(() {
//       if (_aadharCardNumberController.text.isNotEmpty) {
//         setState(() {});
//       }
//       _updateModelFromControllers();
//       _saveFormData();
//     });
//
//     _fullNameController.addListener(() {
//       _updateModelFromControllers();
//       _saveFormData();
//     });
//
//     _mobileNumberController.addListener(() {
//       _updateModelFromControllers();
//       _saveFormData();
//     });
//
//     _bioController.addListener(() {
//       _updateModelFromControllers();
//       _saveFormData();
//     });
//
//     _addressLineController.addListener(() {
//       _updateModelFromControllers();
//       _saveFormData();
//     });
//
//     _cityController.addListener(() {
//       _updateModelFromControllers();
//       _saveFormData();
//     });
//
//     _stateController.addListener(() {
//       _updateModelFromControllers();
//       _saveFormData();
//     });
//
//     _pincodeController.addListener(() {
//       if (_pincodeController.text.length == 6) {
//         _fetchLocationFromPinCode(_pincodeController.text.trim());
//       }
//       _updateModelFromControllers();
//       _saveFormData();
//     });
//   }
//
//   String? _validateRequired(String? value, String fieldName) {
//     if (value == null || value.trim().isEmpty) {
//       return '$fieldName is required';
//     }
//     return null;
//   }
//
//   String? _validateName(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Full name is required';
//     }
//     if (value.trim().length < 2) {
//       return 'Name must be at least 2 characters long';
//     }
//     if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
//       return 'Name should contain only letters and spaces';
//     }
//     return null;
//   }
//
//   String? _validateMobileNumber(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Mobile number is required';
//     }
//     if (value.length != 10 || !RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
//       return 'Enter a valid 10-digit mobile number';
//     }
//     return null;
//   }
//
//   String? _validatePincode(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Pincode is required';
//     }
//     if (value.length != 6 || !RegExp(r'^[1-9][0-9]{5}$').hasMatch(value)) {
//       return 'Enter a valid 6-digit pincode';
//     }
//     return null;
//   }
//
//   String? _validateAadhaarNumber(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Aadhaar number is required';
//     }
//     String cleanValue = value.replaceAll(' ', '');
//     if (cleanValue.length != 12 || !RegExp(r'^[0-9]{12}$').hasMatch(cleanValue)) {
//       return 'Enter a valid 12-digit Aadhaar number';
//     }
//     return null;
//   }
//
//   String? _validateDrivingLicense(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Driving license number is required';
//     }
//     if (value.trim().length < 10 || value.trim().length > 20) {
//       return 'Enter a valid driving license number';
//     }
//     if (!RegExp(r'^[A-Z]{2}[0-9]{2}[0-9]{11}$|^[A-Z]{2}[0-9]{13}$').hasMatch(value.trim().toUpperCase())) {
//       return 'Enter a valid driving license format (e.g., MH1420110012345)';
//     }
//     return null;
//   }
//
//   String? _validateAddressLine(String? value) {
//     if (value == null || value.trim().isEmpty) {
//       return 'Address line is required';
//     }
//     if (value.trim().length < 10) {
//       return 'Please provide a complete address (minimum 10 characters)';
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
//   bool get _isProfilePhotoValid => _driverModel.profilePhoto != null && _driverModel.profilePhoto!.isNotEmpty;
//
//   bool get _isAadhaarDocumentsValid =>
//       _driverModel.aadharCardPhoto != null &&
//       _driverModel.aadharCardPhoto!.isNotEmpty &&
//       _driverModel.aadharCardPhotoBack != null &&
//       _driverModel.aadharCardPhotoBack!.isNotEmpty;
//
//   bool get _isDLDocumentValid =>
//       _driverModel.drivingLicencePhoto != null &&
//       _driverModel.drivingLicencePhoto!.isNotEmpty;
//
//   bool get allDocumentsVerified {
//     return _isAadhaarImageVerified && _isDLImageVerified;
//   }
//
//   bool get allRequiredDocumentsUploaded {
//     return _isProfilePhotoValid && _isAadhaarDocumentsValid && _isDLDocumentValid;
//   }
//
//   void _nextStep() {
//     bool isValid = false;
//     String? validationError;
//
//     switch (_currentStep) {
//       case 0:
//         isValid = _personalInfoFormKey.currentState?.validate() ?? false;
//         if (!isValid) {
//           validationError = 'Please fill all required fields correctly';
//         } else if (!_isProfilePhotoValid) {
//           validationError = 'Profile photo is required';
//         }
//         if (isValid && _isProfilePhotoValid) {
//           _updatePersonalInfoModel();
//         }
//         break;
//
//       case 1:
//         isValid = _documentsFormKey.currentState?.validate() ?? false;
//         if (!isValid) {
//           validationError = 'Please fill all document fields correctly';
//         } else if (!_isAadhaarDocumentsValid) {
//           validationError = 'Aadhaar card front and back images are required';
//         } else if (!_isDLDocumentValid) {
//           validationError = 'Driving license image is required';
//         }
//         if (isValid && allRequiredDocumentsUploaded) {
//           _updateDocumentsModel();
//         }
//         break;
//
//       case 2:
//         isValid = _addressFormKey.currentState?.validate() ?? false;
//         if (!isValid) {
//           validationError = 'Please fill all address fields correctly';
//         } else if (_cityController.text.trim().isEmpty || _stateController.text.trim().isEmpty) {
//           validationError = 'City and State are required (auto-filled from pincode)';
//         }
//         if (isValid && _cityController.text.trim().isNotEmpty && _stateController.text.trim().isNotEmpty) {
//           _updateAddressModel();
//         }
//         break;
//
//       case 3:
//         _submitApplication();
//         return;
//     }
//
//     if (validationError != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(validationError),
//           backgroundColor: Colors.red,
//           duration: const Duration(seconds: 3),
//         ),
//       );
//       return;
//     }
//
//     if (isValid) {
//       setState(() {
//         _currentStep += 1;
//       });
//       _saveCurrentStep();
//       _saveFormData();
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
//       _saveWhoRegStatus("Indi");
//
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
//   void _previousStep() {
//     if (_currentStep > 0) {
//       setState(() {
//         _currentStep -= 1;
//       });
//       _saveCurrentStep();
//       _saveFormData();
//       _saveWhoRegStatus("Indi");
//       _scrollToTop();
//     }
//   }
//
//   void _updatePersonalInfoModel() {
//     _driverModel.fullName = _fullNameController.text.trim();
//     _driverModel.mobileNumber = _mobileNumberController.text.trim();
//     _driverModel.bio = _bioController.text.trim();
//   }
//
//   void _updateDocumentsModel() {
//     _driverModel.drivingLicenceNumber = _drivingLicenceNumberController.text.trim().toUpperCase();
//     _driverModel.aadharCardNumber = _aadharCardNumberController.text.replaceAll(' ', '').trim();
//   }
//
//   void _updateAddressModel() {
//     _driverModel.address ??= Address();
//     _driverModel.address!.addressLine = _addressLineController.text.trim();
//     _driverModel.address!.city = _cityController.text.trim();
//     _driverModel.address!.state = _stateController.text.trim();
//     _driverModel.address!.pincode = int.tryParse(_pincodeController.text.trim());
//   }
//
//   void _showDocumentPreview(String title, String? imageUrl) {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('No document uploaded yet')),
//       );
//       return;
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => DocumentPreviewDialog(
//         title: title,
//         imageUrl: imageUrl,
//       ),
//     );
//   }
//
//   void _ensureModelCompleteness() {
//     if (_driverModel.address == null) {
//       _driverModel.address = Address();
//       _updateAddressModel();
//     }
//
//     // _driverModel. ??= FleetSize();
//     // _driverModel.fleetSize!.cars = 1;
//     // _driverModel.fleetSize!.minivans = 1;
//
//     _updatePersonalInfoModel();
//     _updateDocumentsModel();
//     _updateAddressModel();
//
//     developer.log('Final submission data: ${_driverModel.toJson()}', name: _logTag);
//   }
//
//   Future<void> _submitApplication() async {
//     final accepted = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => TermsConditionsBottomSheet(
//         type: 'INDEPENDENT_CAR_OWNER_AGREEMENT',
//       ),
//     );
//
//     if (accepted != true) {
//       return;
//     }
//
//     if (!mounted) return;
//
//     if (!allRequiredDocumentsUploaded) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Please upload all required documents before submission'),
//           backgroundColor: Colors.red,
//           duration: Duration(seconds: 3),
//         ),
//       );
//       return;
//     }
//
//     setState(() => _isSubmitting = true);
//
//     try {
//       _ensureModelCompleteness();
//       final response = await BecomeDriverServiceIndi().submitDriverApplicationIndi(_driverModel);
//
//       if (response['success'] == true) {
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
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: ColorConstants.backgroundColor,
//       appBar: CustomAppBar(
//         title: 'Independent Car Owner Registration',
//         backgroundColor: ColorConstants.primaryColor,
//         elevation: 0,
//       ),
//       body: SafeArea(
//         child: Column(
//           children: [
//             Padding(
//               padding: const EdgeInsets.all(1.0),
//               child: CustomStepper(
//                 currentStep: _currentStep,
//                 stepTitles: _stepTitles,
//               ),
//             ),
//             Expanded(
//               child: SingleChildScrollView(
//                 controller: _scrollController,
//                 padding: const EdgeInsets.all(16.0),
//                 child: _buildCurrentStepContent(),
//               ),
//             ),
//             _buildNavigationButtons(),
//           ],
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
//                 padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
//         return _buildAddressStep();
//       case 3:
//         return _buildReviewStep();
//       default:
//         return const SizedBox();
//     }
//   }
//
//   Widget _buildPersonalInfoStep() {
//     return Form(
//       key: _personalInfoFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Column(
//               children: [
//                 MediaUploader(
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
//                     _saveFormData();
//                   },
//                   allowedExtensions: ['jpg', 'jpeg', 'png'],
//                 ),
//                 if (!_isProfilePhotoValid)
//                   Container(
//                     margin: const EdgeInsets.only(top: 8),
//                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//                     decoration: BoxDecoration(
//                       color: Colors.red.shade50,
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.red.shade200),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Profile photo is required',
//                           style: TextStyle(
//                             color: Colors.red.shade700,
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 16),
//           CustomTextField(
//             label: 'Full Name',
//             controller: _fullNameController,
//             keyboardType: TextInputType.name,
//             validator: _validateName,
//           ),
//           CustomTextField(
//             label: 'Mobile Number',
//             controller: _mobileNumberController,
//             validator: _validateMobileNumber,
//             keyboardType: TextInputType.phone,
//             prefix: const Text("+91 "),
//           ),
//           CustomTextField(
//             label: 'About',
//             controller: _bioController,
//             maxLines: 3,
//             keyboardType: TextInputType.multiline,
//             validator: (value) => _validateRequired(value, 'About'),
//           ),
//         ],
//       ),
//     );
//   }
//
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
//           const SizedBox(height: 8),
//
//           CustomTextField(
//             label: 'Aadhaar Card Number',
//             controller: _aadharCardNumberController,
//             keyboardType: TextInputType.number,
//             validator: _validateAadhaarNumber,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(12),
//             ],
//           ),
//           const SizedBox(height: 16),
//
//           DocumentVerificationCard(
//             type: 'AADHAR_IMAGE',
//             kind: "independent_car_owner",
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
//               _saveFormData();
//             },
//             onBackImageUploaded: (url) {
//               setState(() {
//                 _driverModel.aadharCardPhotoBack = url;
//               });
//               _saveFormData();
//             },
//           ),
//           if (!_isAadhaarDocumentsValid)
//             Container(
//               margin: const EdgeInsets.only(top: 8),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.red.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Aadhaar front and back images are required',
//                       style: TextStyle(
//                         color: Colors.red.shade700,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           const SizedBox(height: 16),
//
//           CustomTextField(
//             label: 'Driving License Number',
//             controller: _drivingLicenceNumberController,
//             keyboardType: TextInputType.text,
//             validator: _validateDrivingLicense,
//             textCapitalization: TextCapitalization.characters,
//           ),
//           const SizedBox(height: 16),
//
//           DocumentVerificationCard(
//             type: 'DRIVING_LICENSE_IMAGE',
//             name: _fullNameController.text,
//             kind: "independent_car_owner",
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
//               _saveFormData();
//             },
//           ),
//           if (!_isDLDocumentValid)
//             Container(
//               margin: const EdgeInsets.only(top: 8),
//               padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//               decoration: BoxDecoration(
//                 color: Colors.red.shade50,
//                 borderRadius: BorderRadius.circular(8),
//                 border: Border.all(color: Colors.red.shade200),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.error_outline, color: Colors.red.shade600, size: 16),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Text(
//                       'Driving license image is required',
//                       style: TextStyle(
//                         color: Colors.red.shade700,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           const SizedBox(height: 16),
//
//           const Text(
//             'Transportation Permit (Optional)',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 8),
//           // MediaUploader(
//           //   label: 'Transportation Permit',
//           //   kind: "independent_car_owner",
//           //   initialUrl: _driverModel.,
//           //   required: false,
//           //   onMediaUploaded: (url) {
//           //     setState(() {
//           //       _driverModel.transportationPermitPhoto = url;
//           //     });
//           //     _saveFormData();
//           //   },
//           //   allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
//           // ),
//           const SizedBox(height: 20),
//
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: allRequiredDocumentsUploaded
//                   ? Colors.green.shade50
//                   : Colors.orange.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: allRequiredDocumentsUploaded
//                     ? Colors.green.shade200
//                     : Colors.orange.shade200,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   allRequiredDocumentsUploaded
//                       ? Icons.check_circle
//                       : Icons.info_outline,
//                   color: allRequiredDocumentsUploaded
//                       ? Colors.green.shade600
//                       : Colors.orange.shade600,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     allRequiredDocumentsUploaded
//                         ? 'All required documents have been uploaded!'
//                         : 'Please upload all required documents to proceed.',
//                     style: TextStyle(
//                       color: allRequiredDocumentsUploaded
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
//   Widget _buildAddressStep() {
//     return Form(
//       key: _addressFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Address Information',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 16),
//           CustomTextField(
//             label: 'Address Line',
//             controller: _addressLineController,
//             maxLines: 2,
//             keyboardType: TextInputType.streetAddress,
//             validator: _validateAddressLine,
//           ),
//           CustomTextField(
//             label: 'Pincode',
//             controller: _pincodeController,
//             keyboardType: TextInputType.number,
//             validator: _validatePincode,
//             inputFormatters: [
//               FilteringTextInputFormatter.digitsOnly,
//               LengthLimitingTextInputFormatter(6),
//             ],
//             onChanged: (value) {
//               if (value.length == 6) {
//                 _fetchLocationFromPinCode(value.trim());
//               }
//             },
//           ),
//           CustomTextField(
//             label: 'City',
//             controller: _cityController,
//             enabled: false,
//             validator: (value) => _validateRequired(value, 'City'),
//
//           ),
//           CustomTextField(
//             label: 'State',
//             controller: _stateController,
//             enabled: false,
//             validator: (value) => _validateRequired(value, 'State'),
//
//           ),
//           const SizedBox(height: 16),
//           const Text(
//             'Fleet Information',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 8),
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: Colors.blue.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.blue.shade200),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Icon(Icons.directions_car, color: Colors.blue.shade600),
//                     const SizedBox(width: 8),
//                     const Text(
//                       'Vehicle Categories',
//                       style: TextStyle(
//                         fontWeight: FontWeight.w600,
//                         fontSize: 16,
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 12),
//                 const Text(
//                   '• Cars (Sedan, Hatchback, SUV)',
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 const Text(
//                   '• Minivans (7-8 seater)',
//                   style: TextStyle(fontSize: 14),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: Colors.green.shade50,
//                     borderRadius: BorderRadius.circular(8),
//                     border: Border.all(color: Colors.green.shade200),
//                   ),
//                   child: Row(
//                     children: [
//                       Icon(Icons.info_outline, color: Colors.green.shade600, size: 16),
//                       const SizedBox(width: 8),
//                       const Expanded(
//                         child: Text(
//                           'Maximum 2 vehicles allowed',
//                           style: TextStyle(
//                             fontSize: 12,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                     ],
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
//   Widget _buildReviewStep() {
//     return Container(
//       padding: const EdgeInsets.all(10),
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
//                     _buildReviewItem('Mobile', '+91 ${_driverModel.mobileNumber ?? ''}'),
//                     _buildReviewItem('About', _driverModel.bio ?? ''),
//                   ],
//                 ),
//               ),
//               if (_driverModel.profilePhoto != null)
//                 Container(
//                   width: 90,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
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
//           const Divider(height: 32),
//
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
//             'Aadhaar Number',
//             _driverModel.aadharCardNumber ?? '',
//             trailing: _isAadhaarDocumentsValid
//                 ? const Icon(Icons.verified, color: Colors.green)
//                 : const Icon(Icons.error_outline, color: Colors.red),
//           ),
//           _buildReviewItem(
//             'Driving License',
//             _driverModel.drivingLicenceNumber ?? '',
//             trailing: _isDLDocumentValid
//                 ? const Icon(Icons.verified, color: Colors.green)
//                 : const Icon(Icons.error_outline, color: Colors.red),
//           ),
//           // if (_driverModel. != null)
//           //   _buildReviewItem(
//           //     'Transportation Permit',
//           //     'Uploaded (Optional)',
//           //     onButtonPressed: () => _showDocumentPreview(
//           //         'Transportation Permit', _driverModel.transportationPermitPhoto),
//           //   ),
//
//           const SizedBox(height: 12),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               const Text("Uploaded Documents: "),
//               const SizedBox(width: 20),
//               ImagePreviewWidget(
//                 imageUrls: [
//                   if (_driverModel.aadharCardPhoto != null)
//                     _driverModel.aadharCardPhoto!,
//                   if (_driverModel.aadharCardPhotoBack != null)
//                     _driverModel.aadharCardPhotoBack!,
//                   if (_driverModel.drivingLicencePhoto != null)
//                     _driverModel.drivingLicencePhoto!,
//                   if (_driverModel.profilePhoto != null)
//                     _driverModel.profilePhoto!,
//                   // if (_driverModel. != null)
//                   //   _driverModel.transportationPermitPhoto!,
//                 ].whereType<String>().toList(),
//               ),
//             ],
//           ),
//
//           const Divider(height: 32),
//
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
//           _buildReviewItem('Pincode', _driverModel.address?.pincode?.toString() ?? ''),
//           _buildReviewItem('City', _driverModel.address?.city ?? ''),
//           _buildReviewItem('State', _driverModel.address?.state ?? ''),
//
//           const Divider(height: 32),
//
//           const Text(
//             'Fleet Information',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem('Vehicle Categories', 'Cars and Minivans'),
//           _buildReviewItem('Maximum Fleet Size', '2 vehicles'),
//
//           const SizedBox(height: 20),
//
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: allRequiredDocumentsUploaded
//                   ? Colors.green.shade50
//                   : Colors.red.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: allRequiredDocumentsUploaded
//                     ? Colors.green.shade200
//                     : Colors.red.shade200,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   allRequiredDocumentsUploaded ? Icons.verified_rounded : Icons.warning,
//                   color: allRequiredDocumentsUploaded
//                       ? Colors.green.shade600
//                       : Colors.red.shade600,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     allRequiredDocumentsUploaded
//                         ? 'All required documents uploaded! Ready to submit.'
//                         : 'Please ensure all required documents are uploaded before submission.',
//                     style: TextStyle(
//                       color: allRequiredDocumentsUploaded
//                           ? Colors.green.shade700
//                           : Colors.red.shade700,
//                       fontWeight: FontWeight.w600,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           const SizedBox(height: 20),
//           const Text(
//             'By submitting this application, you confirm that all the information provided is accurate and true.',
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
//   Widget _buildReviewItem(String label, String value,
//       {VoidCallback? onButtonPressed, Widget? trailing}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 120,
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