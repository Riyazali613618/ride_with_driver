// import 'dart:convert';
// import 'dart:developer' as developer;
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:http/http.dart' as http;
// import 'package:provider/provider.dart';
// import 'package:r_w_r/api/api_service/registration_services/auto_rikshaw_registration_service.dart';
// import 'package:r_w_r/components/app_appbar.dart';
// import 'package:r_w_r/components/custom_stepper.dart';
// import 'package:r_w_r/components/custom_text_field.dart';
// import 'package:r_w_r/components/custtom_location_widget.dart';
// import 'package:r_w_r/components/media_uploader_widget.dart';
// import 'package:r_w_r/constants/api_constants.dart';
// import 'package:r_w_r/constants/color_constants.dart';
// import 'package:r_w_r/constants/token_manager.dart';
// import 'package:r_w_r/screens/layout.dart';
// import 'package:r_w_r/screens/registration_screens/r_widgets/custom_chips.dart';
// import 'package:r_w_r/screens/registration_screens/r_widgets/doc_priview_dialog.dart';
// import 'package:r_w_r/screens/registration_screens/r_widgets/select_city_state.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import '../../api/api_model/language/language_model.dart';
// import '../../api/api_model/registrations/auto_rikshaw_registration_model.dart';
// import '../../bloc/driver/driver_bloc.dart';
// import '../../bloc/driver/driver_event.dart';
// import '../../bloc/driver/driver_state.dart';
// import '../../components/app_snackbar.dart';
// import '../../l10n/app_localizations.dart';
// import '../block/provider/profile_provider.dart';
// import '../other/terms_and_coditions_bottom_sheet.dart';
// import 'doc_verification/adhar_dl_image_verification_widget.dart';
// import 'doc_verification/adhar_dl_number_verification_widget.dart';
// import 'doc_verification/view_image_button.dart';
//
// class AutoRickshawScreen extends StatefulWidget {
//   final bool? back;
//   const AutoRickshawScreen({super.key, this.back});
//
//   @override
//   State<AutoRickshawScreen> createState() => _AutoRickshawScreenState();
// }
//
// class _AutoRickshawScreenState extends State<AutoRickshawScreen> {
//   static const String _logTag = 'AutoRickshawScreen';
//
//   final AutoRickshawModel _autoRickshawModel = AutoRickshawModel(
//     vehicleImages: [],
//     languageSpoken: [],
//     address: Address(),
//   );
//
//   bool _isAadhaarVerified = false;
//   bool _isDLVerified = false;
//   String? _aadhaarVerificationError;
//   String? _dlVerificationError;
//   bool _isAadhaarImageVerified = false;
//   bool _isDLImageVerified = false;
//   String? _aadhaarImageVerificationError;
//   String? _dlImageVerificationError;
//
//   final _personalInfoFormKey = GlobalKey<FormState>();
//   final _documentsFormKey = GlobalKey<FormState>();
//   final _vehicleInfoFormKey = GlobalKey<FormState>();
//   final _fareInfoFormKey = GlobalKey<FormState>();
//   final _addressFormKey = GlobalKey<FormState>();
//   final _serviceAreaFormKey = GlobalKey<FormState>();
//
//   final ScrollController _scrollController = ScrollController();
//
//   final _nameController = TextEditingController();
//   final _phoneNumberController = TextEditingController();
//   final _bioController = TextEditingController();
//   final _addressLineController = TextEditingController();
//   final _cityController = TextEditingController();
//   final _stateController = TextEditingController();
//   final _pincodeController = TextEditingController();
//   final _aadharCardNumberController = TextEditingController();
//   final _drivingLicenseNumberController = TextEditingController();
//   final _vehicleNumberController = TextEditingController();
//   final _seatingCapacityController = TextEditingController();
//   final _minimumChargesController = TextEditingController();
//
//   int _currentStep = 0;
//
//   final List<String> _languageOptions = [
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
//
//   final Map<String, String?> _errorTexts = {};
//   bool _isSubmitting = false;
//   bool _allowNegotiation = true;
//
//   Map<String, bool> verificationStatus = {};
//   Map<String, String?> verificationErrors = {};
//
//   Future<void> _saveCurrentStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setInt('auto_rickshaw_current_step', _currentStep);
//   }
//
//   Future<void> _loadCurrentStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     final savedStep = prefs.getInt('auto_rickshaw_current_step');
//     if (savedStep != null) {
//       setState(() {
//         _currentStep = savedStep;
//       });
//     }
//   }
//
//   Future<void> _clearSavedStep() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('auto_rickshaw_current_step');
//   }
//
//   Future<void> _saveApplicationStatus(ApplicationStatus status) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('auto_rickshaw_status', status.toString());
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
//     final statusString = prefs.getString('auto_rickshaw_status');
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
//     _minimumChargesController.text = "55.0";
//     _allowNegotiation = true;
//
//     _drivingLicenseNumberController.addListener(() {
//       if (_drivingLicenseNumberController.text.isNotEmpty) {
//         setState(() {});
//       }
//     });
//
//     _aadharCardNumberController.addListener(() {
//       if (_aadharCardNumberController.text.isNotEmpty) {
//         setState(() {});
//       }
//     });
//   }
//
//   void _disposeControllers() {
//     _nameController.dispose();
//     _phoneNumberController.dispose();
//     _bioController.dispose();
//     _addressLineController.dispose();
//     _cityController.dispose();
//     _stateController.dispose();
//     _pincodeController.dispose();
//     _aadharCardNumberController.dispose();
//     _drivingLicenseNumberController.dispose();
//     _vehicleNumberController.dispose();
//     _seatingCapacityController.dispose();
//     _minimumChargesController.dispose();
//   }
//
//   String? _validateRequired(String? value, String fieldName) {
//     final localization = AppLocalizations.of(context)!;
//     if (value == null || value.trim().isEmpty) {
//       return '${localization.fieldRequired(fieldName)}';
//     }
//     return null;
//   }
//
//   String? _validateName(String? value) {
//     final localization = AppLocalizations.of(context)!;
//     if (value == null || value.trim().isEmpty) {
//       return '${localization.fieldRequired(localization.fullName)}';
//     }
//     if (value.trim().length < 2) {
//       return 'Name must be at least 2 characters long';
//     }
//     if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
//       return 'Name can only contain letters and spaces';
//     }
//     return null;
//   }
//
//   String? _validateMobileNumber(String? value) {
//     final localization = AppLocalizations.of(context)!;
//     if (value == null || value.trim().isEmpty) {
//       return '${localization.fieldRequired(localization.mobile_number)}';
//     }
//     if (value.length != 10 || !RegExp(r'^[6-9][0-9]{9}$').hasMatch(value)) {
//       return 'Enter a valid 10-digit mobile number';
//     }
//     return null;
//   }
//
//   String? _validatePincode(String? value) {
//     final localization = AppLocalizations.of(context)!;
//     if (value == null || value.trim().isEmpty) {
//       return localization.fieldRequired(localization.pincode);
//     }
//     if (value.length != 6 || !RegExp(r'^[0-9]{6}$').hasMatch(value)) {
//       return localization.sixDigitPinIsRequired;
//     }
//     return null;
//   }
//
//   String? _validateAadharNumber(String? value) {
//     final localization = AppLocalizations.of(context)!;
//     if (value == null || value.trim().isEmpty) {
//       return '${localization.fieldRequired('Aadhaar card number')}';
//     }
//     if (value.length != 12 || !RegExp(r'^[0-9]{12}$').hasMatch(value)) {
//       return 'Aadhaar number must be 12 digits';
//     }
//     return null;
//   }
//
//   String? _validateDrivingLicense(String? value) {
//     final localization = AppLocalizations.of(context)!;
//     if (value == null || value.trim().isEmpty) {
//       return '${localization.fieldRequired('Driving license number')}';
//     }
//     if (value.length < 8 || value.length > 20) {
//       return 'Invalid driving license format';
//     }
//     return null;
//   }
//
//   String? _validateVehicleNumber(String? value) {
//     final localization = AppLocalizations.of(context)!;
//     if (value == null || value.trim().isEmpty) {
//       return '${localization.fieldRequired(localization.vehicleNumber)}';
//     }
//     if (!RegExp(r'^[A-Z]{2}[0-9]{1,2}[A-Z]{1,2}[0-9]{4}$')
//         .hasMatch(value.toUpperCase().replaceAll(' ', ''))) {
//       return 'Enter valid vehicle number (e.g., MH12AB1234)';
//     }
//     return null;
//   }
//
//   String? _validateSeatingCapacity(String? value) {
//     final localization = AppLocalizations.of(context)!;
//     if (value == null || value.trim().isEmpty) {
//       return '${localization.fieldRequired(localization.seating_capacity)}';
//     }
//     final capacity = int.tryParse(value);
//     if (capacity == null || capacity < 1 || capacity > 8) {
//       return 'Seating capacity must be between 1 and 8';
//     }
//     return null;
//   }
//
//   String? _validateMinimumCharges(String? value) {
//     final localization = AppLocalizations.of(context)!;
//     if (value == null || value.trim().isEmpty) {
//       return localization.fieldRequired(localization.minimum_charges);
//     }
//     final charges = double.tryParse(value);
//     if (charges == null || charges <= 0) {
//       return 'Enter valid minimum charges';
//     }
//     if (charges > 1000) {
//       return 'Minimum charges cannot exceed ₹1000';
//     }
//     return null;
//   }
//
//   String? _validateSelection(List<String>? values, String fieldName) {
//     final localization = AppLocalizations.of(context)!;
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
//   void _handleVerificationChanged(
//       String documentType, bool isVerified, String? errorMessage) {
//     setState(() {
//       verificationStatus[documentType] = isVerified;
//       verificationErrors[documentType] = errorMessage;
//     });
//
//     debugPrint('$documentType verification status: $isVerified');
//     if (errorMessage != null) {
//       debugPrint('$documentType error: $errorMessage');
//     }
//   }
//
//   bool get allDocumentsVerified {
//     return _isAadhaarVerified &&
//         _isDLVerified &&
//         _isAadhaarImageVerified &&
//         _isDLImageVerified;
//   }
//
//   void _nextStep() {
//     bool isValid = false;
//
//     switch (_currentStep) {
//       case 0:
//         isValid = _personalInfoFormKey.currentState?.validate() ?? false;
//
//         if (isValid && _autoRickshawModel.photo != null) {
//           if (_stateController.text.isEmpty || _cityController.text.isEmpty) {
//             final localization = AppLocalizations.of(context)!;
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(localization.pleaseSelectCity),
//                 backgroundColor: Colors.orange,
//               ),
//             );
//             return;
//           }
//           _updatePersonalInfoModel();
//           _updateAddressModel();
//         } else if (_autoRickshawModel.photo == null) {
//           final localization = AppLocalizations.of(context)!;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(localization.profile_photo_required)),
//           );
//           return;
//         }
//         break;
//
//       case 1:
//         isValid = _documentsFormKey.currentState?.validate() ?? false;
//         if (isValid &&
//             _autoRickshawModel.drivingLicensePhoto != null &&
//             _autoRickshawModel.aadharCardPhoto != null &&
//             _autoRickshawModel.aadharCardPhotoBack != null) {
//           _updateDocumentsModel();
//         } else {
//           final localization = AppLocalizations.of(context)!;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(localization.all_docs_required)),
//           );
//           return;
//         }
//         break;
//
//       case 2:
//         isValid = _vehicleInfoFormKey.currentState?.validate() ?? false;
//
//         if (_autoRickshawModel.vehicleImages == null ||
//             _autoRickshawModel.vehicleImages!.isEmpty) {
//           final localization = AppLocalizations.of(context)!;
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(content: Text(localization.at_least_one_vehicle_photo)),
//           );
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
//         _updateFareDetailsModel();
//         final localization = AppLocalizations.of(context)!;
//
//         if (_autoRickshawModel.serviceLocation == null) {
//           _updateErrorText('serviceLocation', 'Please select a service area');
//           isValid = false;
//         }
//
//         if (_autoRickshawModel.languageSpoken == null ||
//             _autoRickshawModel.languageSpoken!.isEmpty) {
//           _updateErrorText(
//               localization.language,
//               localization.pleaseSelectAtLeastOne(
//                 localization.language,
//               ));
//           isValid = false;
//         }
//
//         if (!isValid) {
//           return;
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
//       _saveWhoRegStatus("Auto");
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
//       _saveWhoRegStatus("Auto");
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
//     _autoRickshawModel.name = _nameController.text;
//     _autoRickshawModel.phoneNumber = _phoneNumberController.text;
//     _autoRickshawModel.about = _bioController.text;
//   }
//
//   void _updateDocumentsModel() {
//     _autoRickshawModel.aadharCardNumber = _aadharCardNumberController.text;
//     _autoRickshawModel.drivingLicenseNumber =
//         _drivingLicenseNumberController.text;
//   }
//
//   void _updateAddressModel() {
//     _autoRickshawModel.address ??= Address();
//     _autoRickshawModel.address!.addressLine = _addressLineController.text;
//     _autoRickshawModel.address!.city = _cityController.text;
//     _autoRickshawModel.address!.state = _stateController.text;
//     _autoRickshawModel.address!.pincode = int.tryParse(_pincodeController.text);
//   }
//
//   void _updateVehicleInfoModel() {
//     _autoRickshawModel.vehicleNumber = _vehicleNumberController.text;
//     _autoRickshawModel.seatingCapacity =
//         int.tryParse(_seatingCapacityController.text);
//   }
//
//   void _updateFareDetailsModel() {
//     _autoRickshawModel.minimumCharges =
//         double.tryParse(_minimumChargesController.text);
//     _autoRickshawModel.negotiable = _allowNegotiation;
//   }
//
//   void _showDocumentPreview(String title, String? imageUrl) {
//     if (imageUrl == null || imageUrl.isEmpty) {
//       final localization = AppLocalizations.of(context)!;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(localization.no_document_uploaded)),
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
//     _autoRickshawModel.languageSpoken ??= [];
//     _autoRickshawModel.vehicleImages ??= [];
//
//     if (_autoRickshawModel.address == null) {
//       _autoRickshawModel.address = Address();
//       _updateAddressModel();
//     }
//
//     _updatePersonalInfoModel();
//     _updateDocumentsModel();
//     _updateVehicleInfoModel();
//     _updateFareDetailsModel();
//
//     developer.log('Final submission data: ${_autoRickshawModel.toJson()}',
//         name: _logTag);
//   }
//
//   Future<void> _submitApplication() async {
//     final accepted = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       builder: (context) => TermsConditionsBottomSheet(
//         type: 'RICKSHAW_AGREEMENT',
//       ),
//     );
//
//     if (accepted != true) {
//       return;
//     }
//
//     if (!mounted) return;
//     setState(() => _isSubmitting = true);
//
//     try {
//       _ensureModelCompleteness();
//       context.read<DriverBloc>().add(
//             AutoRikshawRegistrationEvent(
//               registrationData: _autoRickshawModel.toJson(),
//             ),
//           );
//       final response = await AutoRickshawService()
//           .submitAutoRickshawApplication(_autoRickshawModel);
//       if (response is bool && response == true) {
//         if (!mounted) return;
//         _clearSavedStep();
//         _saveApplicationStatus(ApplicationStatus.submitted);
//         AutoRickshawService.showSuccessSnackBar(
//             context, 'Application submitted successfully!');
//         if (!mounted) return;
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(builder: (context) => const Layout()),
//         );
//       } else {
//         if (!mounted) return;
//         AutoRickshawService.showApiErrorSnackBar(
//           context,
//           response['message'] ?? 'Submission failed',
//         );
//       }
//     } catch (e) {
//       if (!mounted) return;
//       AutoRickshawService.showApiErrorSnackBar(
//         context,
//         'An unexpected error occurred',
//       );
//     } finally {
//       if (mounted) setState(() => _isSubmitting = false);
//     }
//   }
//
//   Future<void> _fetchLocationFromPincode(String pincode) async {
//     if (pincode.length != 6) return;
//
//     try {
//       final profileProvider =
//           Provider.of<ProfileProvider>(context, listen: false);
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
//
//         if (data['status'] == true && data['data'] != null) {
//           setState(() {
//             _cityController.text = data['data']['city'] ?? '';
//             _stateController.text = data['data']['state'] ?? '';
//           });
//         }
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Unable to fetch location for this pincode'),
//           backgroundColor: Colors.orange,
//           duration: Duration(seconds: 2),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final localization = AppLocalizations.of(context)!;
//
//     final stepTitles = [
//       localization.personal_information,
//       localization.documents,
//       localization.vehicle_information,
//       localization.fareAndCities,
//       localization.review,
//     ];
//
//     return BlocListener<DriverBloc, DriverState>(
//         listener: (context, state) {
//           if (state is DriverLoading) {
//             setState(() {
//               _isSubmitting = true;
//             });
//           } else {
//             setState(() {
//               _isSubmitting = false;
//             });
//           }
//
//           if (state is AutoRikshawRegistrationSuccess) {
//             _clearSavedStep();
//             _saveApplicationStatus(ApplicationStatus.submitted);
//
//             CustomSnackBar.showCustomSnackBar(
//               context: context,
//               message: state.message,
//               success: true,
//             );
//
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const Layout()),
//             );
//           } else if (state is DriverError) {
//             CustomSnackBar.showCustomSnackBar(
//               context: context,
//               message: state.message,
//               success: false,
//             );
//           }
//         },
//         child: Scaffold(
//           backgroundColor: ColorConstants.backgroundColor,
//           appBar: CustomAppBar(
//             title: localization.become_auto_rickshaw_driver,
//             titleTextStyle: TextStyle(
//                 fontSize: 16,
//                 color: ColorConstants.white,
//                 fontWeight: FontWeight.w700),
//             backgroundColor: ColorConstants.primaryColor,
//             elevation: 0,
//           ),
//           body: SafeArea(
//             child: Column(
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.all(1.0),
//                   child: CustomStepper(
//                     currentStep: _currentStep,
//                     stepTitles: stepTitles,
//                   ),
//                 ),
//                 Expanded(
//                   child: SingleChildScrollView(
//                     controller: _scrollController,
//                     padding: const EdgeInsets.all(16.0),
//                     child: _buildCurrentStepContent(),
//                   ),
//                 ),
//                 _buildNavigationButtons(),
//               ],
//             ),
//           ),
//         ));
//   }
//
//   Widget _buildNavigationButtons() {
//     final localization = AppLocalizations.of(context)!;
//
//     final stepTitles = [
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
//             color: Colors.black.withAlpha(10),
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
//                     _currentStep == stepTitles.length - 1
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
//         return _buildFareAndCitiesStep();
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
//     return Column(
//       children: [
//         Form(
//           key: _personalInfoFormKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Center(
//                 child: Column(
//                   children: [
//                     MediaUploader(
//                       label: localization.profilePhoto,
//                       useEyeBlinkDetection: true,
//                       useGallery: false,
//                       showPreview: true,
//                       showDirectImage: true,
//                       icon: Icons.person,
//                       kind: "RICKSHAW",
//                       initialUrl: _autoRickshawModel.photo,
//                       required: true,
//                       onMediaUploaded: (url) {
//                         setState(() {
//                           _autoRickshawModel.photo = url;
//                         });
//                       },
//                       allowedExtensions: ['jpg', 'jpeg', 'png'],
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 16),
//               CustomTextField(
//                 label: localization.fullName,
//                 controller: _nameController,
//                 keyboardType: TextInputType.name,
//                 validator: _validateName,
//               ),
//               CustomTextField(
//                 label: localization.phoneNumber,
//                 controller: _phoneNumberController,
//                 validator: _validateMobileNumber,
//                 prefix: Text("+91"),
//                 keyboardType: TextInputType.phone,
//               ),
//               CustomTextField(
//                 label: localization.about,
//                 controller: _bioController,
//                 maxLines: 3,
//                 keyboardType: TextInputType.multiline,
//                 validator: (value) =>
//                     _validateRequired(value, localization.about),
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
//               CustomTextField(
//                 label: localization.address,
//                 controller: _addressLineController,
//                 maxLines: 2,
//                 keyboardType: TextInputType.streetAddress,
//                 validator: (value) =>
//                     _validateRequired(value, localization.address),
//               ),
//
//               CustomTextField(
//                 label: localization.pincode,
//                 controller: _pincodeController,
//                 keyboardType: TextInputType.number,
//                 validator: _validatePincode,
//                 onChanged: (value) {
//                   if (value.length == 6) {
//                     _fetchLocationFromPincode(value);
//                   }
//                 },
//               ),
//
//               CustomTextField(
//                 label: 'State',
//                 controller: _stateController,
//                 enabled: false,
//                 validator: (value) => _validateRequired(value, 'State'),
//               ),
//               CustomTextField(
//                 label: 'City',
//                 controller: _cityController,
//                 enabled: false,
//                 validator: (value) => _validateRequired(value, 'City'),
//               ),
//               // StateCityDropdownWidget(
//               //   baseUrl: ApiConstants.baseUrl,
//               //   stateController: _stateController,
//               //   cityController: _cityController,
//               // ),
//             ],
//           ),
//         ),
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
//           CustomTextField(
//             label: 'Aadhaar Card Number',
//             controller: _aadharCardNumberController,
//             keyboardType: TextInputType.number,
//             validator: _validateAadharNumber,
//           ),
//           const SizedBox(height: 16),
//           DocumentVerificationCard(
//             type: 'AADHAR_IMAGE',
//             kind: "rickshaw",
//             name: _nameController.text,
//             frontImageUrl: _autoRickshawModel.aadharCardPhoto,
//             backImageUrl: _autoRickshawModel.aadharCardPhotoBack,
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
//                 _autoRickshawModel.aadharCardPhoto = url;
//               });
//             },
//             onBackImageUploaded: (url) {
//               setState(() {
//                 _autoRickshawModel.aadharCardPhotoBack = url;
//               });
//             },
//           ),
//           SizedBox(
//             height: 10,
//           ),
//           CustomTextField(
//             label: 'Driving License Number',
//             controller: _drivingLicenseNumberController,
//             keyboardType: TextInputType.text,
//             validator: _validateDrivingLicense,
//           ),
//           const SizedBox(height: 16),
//           DocumentVerificationCard(
//             type: 'DRIVING_LICENSE_IMAGE',
//             name: _nameController.text,
//             kind: "rickshaw",
//             frontImageUrl: _autoRickshawModel.drivingLicensePhoto,
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
//                 _autoRickshawModel.drivingLicensePhoto = url;
//               });
//             },
//           ),
//           const SizedBox(height: 20),
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
//             keyboardType: TextInputType.text,
//             validator: _validateVehicleNumber,
//           ),
//           CustomTextField(
//             label: localization.seating_capacity,
//             controller: _seatingCapacityController,
//             keyboardType: TextInputType.number,
//             validator: _validateSeatingCapacity,
//           ),
//           const SizedBox(height: 12),
//           MediaUploader(
//             label: localization.vehicle_photos,
//             multipleFiles: true,
//             onMediaUploaded: (url) {},
//             onMultipleMediaUploaded: (urls) {
//               setState(() {
//                 _autoRickshawModel.vehicleImages = urls;
//               });
//             },
//             kind: 'RICKSHAW',
//             showDirectImage: true,
//             required: true,
//             allowedExtensions: ['jpg', 'jpeg', 'png'],
//           ),
//           const SizedBox(height: 12),
//           MediaUploader(
//             allowVideo: true,
//             label: localization.vehicleVideos,
//             multipleFiles: false,
//             onMediaUploaded: (url) {
//               setState(() {
//                 _autoRickshawModel.vehicleVideo = url;
//               });
//             },
//             kind: 'RICKSHAW',
//             showDirectImage: false,
//             allowedExtensions: ['mp4', 'mov', 'avi'],
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildFareAndCitiesStep() {
//     final localization = AppLocalizations.of(context)!;
//
//     return Form(
//       key: _fareInfoFormKey,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CustomTextField(
//             label: localization.minimum_charges,
//             controller: _minimumChargesController,
//             keyboardType: TextInputType.numberWithOptions(decimal: true),
//             validator: _validateMinimumCharges,
//           ),
//           SwitchListTile(
//             title: Text(
//               localization.allow_fare_negotiation,
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w500,
//               ),
//             ),
//             value: _allowNegotiation,
//             activeColor: ColorConstants.primaryColor,
//             contentPadding: const EdgeInsets.symmetric(horizontal: 0),
//             onChanged: (bool value) {
//               setState(() {
//                 _allowNegotiation = value;
//               });
//             },
//           ),
//           const SizedBox(height: 20),
//           Text(
//             'Service Areas',
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
//                 onLocationSelected: (location) {
//                   setState(() {
//                     _autoRickshawModel.serviceLocation = ServiceLocation(
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
//           ChipSelection(
//             label: localization.languages_spoken,
//             options: _languageOptions,
//             selectedOptions: _autoRickshawModel.languageSpoken ?? [],
//             required: true,
//             errorText: _errorTexts['language'],
//             onSelectionChanged: (selected) {
//               setState(() {
//                 _autoRickshawModel.languageSpoken = selected;
//                 _errorTexts['language'] = null;
//               });
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildReviewStep() {
//     final localization = AppLocalizations.of(context)!;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withAlpha(25),
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
//                         localization.fullName, _autoRickshawModel.name ?? ''),
//                     _buildReviewItem(localization.phoneNumber,
//                         _autoRickshawModel.phoneNumber ?? ''),
//                   ],
//                 ),
//               ),
//               if (_autoRickshawModel.photo != null)
//                 Container(
//                   width: 90,
//                   height: 100,
//                   decoration: BoxDecoration(
//                     borderRadius: BorderRadius.circular(5),
//                     border: Border.all(
//                         color: ColorConstants.primaryColor, width: 2),
//                     image: DecorationImage(
//                       image: NetworkImage(_autoRickshawModel.photo!),
//                       fit: BoxFit.cover,
//                     ),
//                   ),
//                 ),
//             ],
//           ),
//           _buildReviewItem(localization.about, _autoRickshawModel.about ?? ''),
//
//           const Divider(height: 32),
//
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
//             _autoRickshawModel.aadharCardNumber ?? '',
//             trailing: _isAadhaarVerified
//                 ? Icon(Icons.verified, color: Colors.green)
//                 : Icon(Icons.error_outline, color: Colors.red),
//           ),
//
//           _buildReviewItem(
//             localization.drivingLicense,
//             _autoRickshawModel.drivingLicenseNumber ?? '',
//             trailing: _isDLVerified
//                 ? Icon(Icons.verified, color: Colors.green)
//                 : Icon(Icons.error_outline, color: Colors.red),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Text("${localization.uploaded_files}:"),
//               SizedBox(width: 20),
//               ImagePreviewWidget(
//                 imageUrls: [
//                   if (_autoRickshawModel.aadharCardPhoto != null)
//                     _autoRickshawModel.aadharCardPhoto!,
//                   if (_autoRickshawModel.aadharCardPhotoBack != null)
//                     _autoRickshawModel.aadharCardPhotoBack!,
//                   if (_autoRickshawModel.drivingLicensePhoto != null)
//                     _autoRickshawModel.drivingLicensePhoto!
//                 ],
//               ),
//             ],
//           ),
//
//           const Divider(height: 32),
//
//           Text(
//             localization.vehicle_information,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem(localization.vehicleNumber,
//               _autoRickshawModel.vehicleNumber?.toString() ?? ''),
//           _buildReviewItem(localization.seating_capacity,
//               _autoRickshawModel.seatingCapacity?.toString() ?? ''),
//
//           _buildReviewItem(localization.vehicle_photos,
//               '${_autoRickshawModel.vehicleImages?.length ?? 0} ${localization.uploaded}'),
//           _buildReviewItem(
//               localization.vehicleVideos,
//               _autoRickshawModel.vehicleVideo != null
//                   ? '1 ${localization.uploaded}'
//                   : '0 ${localization.uploaded}'),
//
//           if (_autoRickshawModel.vehicleImages != null &&
//               _autoRickshawModel.vehicleImages!.isNotEmpty)
//             Row(
//               children: [
//                 Text(localization.vehicle_photos),
//                 SizedBox(width: 10),
//                 ImagePreviewWidget(
//                   imageUrls: _autoRickshawModel.vehicleImages!,
//                 ),
//               ],
//             ),
//
//           const Divider(height: 32),
//           Text(
//             localization.fareAndCities,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem(localization.minimum_charges,
//               '₹${_autoRickshawModel.minimumCharges?.toString() ?? ''}'),
//
//           _buildReviewItem(
//               localization.allow_negotiation,
//               _autoRickshawModel.negotiable == true
//                   ? localization.yes
//                   : localization.no),
//
//           const Divider(height: 32),
//           Text(
//             'Service Areas',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           // _buildReviewItem('Service Area',
//           //     _autoRickshawModel.serviceLocation?.  ?? 'None selected'),
//
//           const Divider(height: 32),
//
//           Text(
//             localization.language_spoken,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem(localization.language,
//               _autoRickshawModel.languageSpoken?.join(', ') ?? 'None selected'),
//
//           const Divider(height: 32),
//
//           Text(
//             localization.address,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//               color: ColorConstants.primaryColor,
//             ),
//           ),
//           const SizedBox(height: 12),
//           _buildReviewItem(localization.address,
//               _autoRickshawModel.address?.addressLine ?? ''),
//           _buildReviewItem(
//               localization.city, _autoRickshawModel.address?.city ?? ''),
//           _buildReviewItem(
//               localization.state, _autoRickshawModel.address?.state ?? ''),
//           _buildReviewItem(localization.pincode,
//               _autoRickshawModel.address?.pincode?.toString() ?? ''),
//
//           const SizedBox(height: 20),
//
//           Container(
//             padding: const EdgeInsets.all(16),
//             decoration: BoxDecoration(
//               color: allDocumentsVerified
//                   ? Colors.green.shade50
//                   : Colors.red.shade50,
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(
//                 color: allDocumentsVerified
//                     ? Colors.green.shade200
//                     : Colors.red.shade200,
//               ),
//             ),
//             child: Row(
//               children: [
//                 Icon(
//                   allDocumentsVerified ? Icons.check_circle : Icons.warning,
//                   color: allDocumentsVerified
//                       ? Colors.green.shade600
//                       : Colors.red.shade600,
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     allDocumentsVerified
//                         ? localization.allDocumentsVerifiedReadyToSubmit
//                         : localization.documentVerificationIncomplete,
//                     style: TextStyle(
//                       color: allDocumentsVerified
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
//           Text(
//             localization.submission_confirmation,
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
