import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/screens/layout.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api_model/language/language_model.dart';
import '../../api/api_model/registrations/transporter_model.dart';
import '../../api/api_service/registration_services/transporter_service.dart';
import '../../bloc/driver/driver_bloc.dart';
import '../../bloc/driver/driver_event.dart';
import '../../bloc/driver/driver_state.dart';
import '../../components/app_appbar.dart';
import '../../components/custom_stepper.dart';
import '../../components/custom_text_field.dart';
import '../../components/media_uploader_widget.dart';
import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../block/provider/profile_provider.dart';
import '../other/terms_and_coditions_bottom_sheet.dart';
import '../registrationSyccessfulScreen.dart';

class TransporterScreen extends StatefulWidget {
  const TransporterScreen({super.key});

  @override
  State<TransporterScreen> createState() => _TransporterScreenState();
}

class _TransporterScreenState extends State<TransporterScreen> {
  final TransporterService _transporterService = TransporterService();
  TransporterModel _transporterModel = TransporterModel.empty();
  bool _isAadhaarVerified = false;
  bool _isAadhaarImageVerified = false;
  bool _isGstVerifying = false;
  bool _isGstVerified = false;

  final _businessFormKey = GlobalKey<FormState>();
  final _documentsFormKey = GlobalKey<FormState>();
  final _fleetFormKey = GlobalKey<FormState>();
  final ScrollController _scrollController = ScrollController();

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

  String? _selectedAddressType;
  String? _selectedFleetSize;

  int _currentStep = 0;
  final List<String> _stepTitles = [
    'Business Details',
    'Documents',
    'Fleet Details',
    'Review',
  ];

  final List<String> _addressTypeOptions = ['Home', 'Office', 'Work', 'Other'];

  final List<String> _fleetSizeOptions = [
    'small',
    'medium',
    'large',
  ];

  Map<String, bool> verificationStatus = {};
  Map<String, String?> verificationErrors = {};
  final Map<String, String?> _errorTexts = {};

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

        if (data['status'] == true && data['data'] != null) {
          setState(() {
            _cityController.text = data['data']['city'] ?? '';
            _stateController.text = data['data']['state'] ?? '';
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to fetch location for this pincode'),
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

      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final userId = profileProvider.userId;
      final token = await TokenManager.getToken();

      final submitResponse = await http.post(
        Uri.parse(
            '${ApiConstants.baseUrl}/user/register/submit-gst-verification'),
        headers: {
          'Content-Type': 'application/json',
          'x-user-id': userId ?? '',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'gst_number': gstNumber.trim().toUpperCase(),
        }),
      );

      if (submitResponse.statusCode == 200) {
        final submitData = json.decode(submitResponse.body);

        if (submitData['status'] == true) {
          final requestId = submitData['request_id'];
          await Future.delayed(const Duration(seconds: 3));
          await _getGstVerificationResult(requestId);
        }
      }
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

  @override
  void initState() {
    super.initState();
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
    _scrollController.dispose();
    super.dispose();
  }

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

    // final gstRegex = RegExp(r'^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}[Z0-9A-Z]{1}$');
    // if (!gstRegex.hasMatch(gstin)) {
    //   return 'Invalid GST number format';
    // }

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

  bool get allDocumentsVerified {
    return true;
  }

  void _nextStep() {
    bool isValid = false;
    String? errorMessage;

    switch (_currentStep) {
      case 0:
        isValid = _businessFormKey.currentState?.validate() ?? false;
        if (isValid) {
          if (_transporterModel.photo == null ||
              _transporterModel.photo!.isEmpty) {
            errorMessage = 'Company photo is required';
            isValid = false;
          } else if (_selectedAddressType == null) {
            errorMessage = 'Please select an address type';
            isValid = false;
          }

          if (isValid) {
            _updateBusinessModel();
          }
        }
        break;

      case 1:
        isValid = _documentsFormKey.currentState?.validate() ?? false;
        if (isValid) {
          _updateDocumentsModel();
        }
        break;

      case 2:
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

      case 3:
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

    if (isValid) {
      setState(() {
        _currentStep += 1;
      });
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

      _scrollToTop();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep -= 1;
      });
      _saveCurrentStep();
      _saveWhoRegStatus("Transporter");
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _updateBusinessModel() {
    setState(() {
      _transporterModel = _transporterModel.copyWith(
        companyName: _companyNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim(),
        bio: _bioController.text.trim(),
        contactPersonName: _contactPersonNameController.text.trim(),
        address: _transporterModel.address.copyWith(
          addressLine: _addressLineController.text.trim(),
          state: _stateController.text.trim(),
          city: _cityController.text.trim(),
          pincode: int.tryParse(_pincodeController.text.trim()),
        ),
      );
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
    final validationErrors = <String>[];

    final addressError =
        _validateAddressLine(_transporterModel.address.addressLine);
    if (addressError != null) {
      validationErrors.add(addressError);
    }

    final fleetError = _validateFleetSize();
    if (fleetError != null) {
      validationErrors.add(fleetError);
    }

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

    if (kDebugMode) {
      print("Transport Data : ${_transporterModel.toJson()}");
    }

    try {
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
          MaterialPageRoute(builder: (context) => const RegistrationSuccessfulScreen(userType: "TRANSPORTER",)),
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
    } finally {}
  }

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
      child: Scaffold(
        backgroundColor: ColorConstants.backgroundColor,
        appBar: CustomAppBar(
          title: 'Become a Transporter',
          backgroundColor: ColorConstants.primaryColor,
          elevation: 0,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(1.0),
                child: CustomStepper(
                  currentStep: _currentStep,
                  stepTitles: _stepTitles,
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16.0),
                  child: _buildCurrentStepContent(),
                ),
              ),
              _buildNavigationButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              style:
                  const TextStyle(fontWeight: FontWeight.w500, wordSpacing: 4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return BlocBuilder<DriverBloc, DriverState>(
      builder: (context, state) {
        final bool isSubmitting = state is DriverRegistrationLoading;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5.0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 5,
                offset: const Offset(0, -3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (_currentStep > 0)
                ElevatedButton(
                  onPressed: isSubmitting ? null : _previousStep,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[200],
                    foregroundColor: ColorConstants.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Previous'),
                )
              else
                const SizedBox(),
              ElevatedButton(
                onPressed: isSubmitting ? null : _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
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
                        _currentStep == _stepTitles.length - 1
                            ? 'Submit'
                            : 'Next',
                        style: const TextStyle(
                          color: ColorConstants.white,
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildBusinessStep();
      case 1:
        return _buildDocumentsStep();
      case 2:
        return _buildFleetStep();
      case 3:
        return _buildReviewStep();
      default:
        return const SizedBox();
    }
  }

  Widget _buildGstField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          label: 'GSTIN',
          controller: _gstinController,
          validator: _validateGSTINFormat,
          textCapitalization: TextCapitalization.characters,
          maxLength: 15,
          onChanged: (value) {
            if (value.length == 15) {
              _verifyGST(value);
            } else {
              setState(() {
                _isGstVerified = false;
              });
            }
          },
          suffixIcon: _isGstVerifying
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : _isGstVerified
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
        ),
        if (_isGstVerified)
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Text(
              'GST verified successfully! Details auto-filled.',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          'GST Format: 15 characters (e.g., 27AAPFU0939F1ZV)',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildBusinessStep() {
    return Form(
      key: _businessFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                MediaUploader(
                  label: 'Company Photo*',
                  useGallery: true,
                  showPreview: true,
                  showDirectImage: true,
                  icon: Icons.business,
                  kind: "transporter",
                  initialUrl: _transporterModel.photo,
                  required: true,
                  onMediaUploaded: (url) {
                    setState(() {
                      _transporterModel =
                          _transporterModel.copyWith(photo: url);
                    });
                  },
                  allowedExtensions: ['jpg', 'jpeg', 'png'],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildGstField(),
          const SizedBox(height: 16),
          CustomTextField(
            label: 'Company Name*',
            controller: _companyNameController,
            validator: (value) => _validateRequired(value, 'Company name'),
          ),
          CustomTextField(
            label: 'Phone Number*',
            controller: _phoneNumberController,
            validator: _validateMobileNumber,
            keyboardType: TextInputType.phone,
            prefix: const Text("+91 "),
          ),
          CustomTextField(
            label: 'Contact Person Name*',
            controller: _contactPersonNameController,
            validator: (value) =>
                _validateRequired(value, 'Contact person name'),
          ),
          CustomTextField(
            label: 'Bio',
            controller: _bioController,
            maxLines: 3,
            keyboardType: TextInputType.multiline,
            validator: (value) {
              if (value != null && value.length > 500) {
                return 'Bio must be less than 500 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Address Type*',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            value: _selectedAddressType,
            validator: (value) => _validateRequired(value, 'Address type'),
            onChanged: (String? newValue) {
              setState(() {
                _selectedAddressType = newValue;
              });
            },
            items: _addressTypeOptions
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'Address Line*',
            controller: _addressLineController,
            validator: _validateAddressLine,
            maxLines: 2,
          ),
          const SizedBox(height: 12),
          CustomTextField(
            label: 'PinCode*',
            controller: _pincodeController,
            keyboardType: TextInputType.number,
            validator: _validatePincode,
            maxLength: 6,
            onChanged: (value) {
              if (value.length == 6) {
                _fetchLocationFromPincode(value);
              }
            },
          ),

          CustomTextField(
            label: 'State',
            controller: _stateController,
            enabled: false,
            validator: (value) => _validateRequired(value, 'State'),
          ),
          CustomTextField(
            label: 'City',
            controller: _cityController,
            enabled: false,
            validator: (value) => _validateRequired(value, 'City'),
          ),
          // StateCityDropdownWidget(
          //   baseUrl: ApiConstants.baseUrl,
          //   stateController: _stateController,
          //   cityController: _cityController,
          //   stateValidator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please select a state';
          //     }
          //     return null;
          //   },
          //   cityValidator: (value) {
          //     if (value == null || value.isEmpty) {
          //       return 'Please select a city';
          //     }
          //     return null;
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return Form(
      key: _documentsFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Document Verification',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Card(
            color: ColorConstants.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  MediaUploader(
                    label: 'Transportation Permit (Optional)',
                    kind: "transporter",
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
                  const SizedBox(height: 8),
                  Text(
                    'Upload a clear image or PDF of your transportation permit (optional)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
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
        ],
      ),
    );
  }

  Widget _buildFleetStep() {
    return Form(
      key: _fleetFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fleet Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Fleet Size*',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              helperText: 'Small: 1-5, Medium: 6-10, Large: 11+ vehicles',
            ),
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
          const SizedBox(height: 16),
          const Text(
            'Vehicle Counts',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Cars',
                  controller: _carCountController,
                  keyboardType: TextInputType.number,
                  validator: (value) => _validateNumber(value, 'Car count'),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Vans',
                  controller: _vanCountController,
                  keyboardType: TextInputType.number,
                  validator: (value) => _validateNumber(value, 'Van count'),
                  onChanged: (value) => setState(() {}),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomTextField(
                  label: 'Buses',
                  controller: _busCountController,
                  keyboardType: TextInputType.number,
                  validator: (value) => _validateNumber(value, 'Bus count'),
                  onChanged: (value) => setState(() {}),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
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
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Business Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildReviewItem(
                        'Company', _transporterModel.companyName ?? ''),
                    _buildReviewItem('Phone No.',
                        '+91 ${_transporterModel.phoneNumber ?? ''}'),
                    _buildReviewItem('Contact Person',
                        _transporterModel.contactPersonName ?? 'Not specified'),
                    _buildReviewItem(
                        'GSTIN', _transporterModel.gstin ?? 'Not provided'),
                  ],
                ),
              ),
              if (_transporterModel.photo != null)
                Container(
                  width: 90,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                        color: ColorConstants.primaryColor, width: 2),
                    image: DecorationImage(
                      image: NetworkImage(_transporterModel.photo!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ),
          _buildReviewItem('Bio', _transporterModel.bio ?? 'Not specified'),
          const Divider(height: 32),
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewItem('Address Type', _selectedAddressType ?? ''),
          _buildReviewItem(
              'Address Line', _transporterModel.address.addressLine ?? ''),
          _buildReviewItem('City', _transporterModel.address.city ?? ''),
          _buildReviewItem('State', _transporterModel.address.state ?? ''),
          _buildReviewItem(
              'Pincode', _transporterModel.address.pincode?.toString() ?? ''),
          const Divider(height: 32),
          const Text(
            'Documents',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          Card(
            color: ColorConstants.backgroundColor,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildReviewItem(
                      'Transportation Permit',
                      _transporterModel.transportationPermit?.isNotEmpty == true
                          ? 'Uploaded'
                          : 'Not uploaded (Optional)'),
                  if (_transporterModel.transportationPermit != null)
                    Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: ColorConstants.primaryColor, width: 2),
                        image: DecorationImage(
                          image: NetworkImage(
                              _transporterModel.transportationPermit!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 32),
          const Text(
            'Fleet Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.primaryColor,
            ),
          ),
          const SizedBox(height: 12),
          _buildReviewItem('Fleet Size',
              '${_transporterModel.fleetSize ?? 'Not specified'}'),
          _buildReviewItem('Cars', '${_transporterModel.counts.car}'),
          _buildReviewItem('Vans', '${_transporterModel.counts.van}'),
          _buildReviewItem('Buses', '${_transporterModel.counts.bus}'),
          _buildReviewItem('Total Vehicles', '${_getTotalVehicleCount()}'),
          const Divider(height: 32),
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
                            : 'Please review and fix the issues below:',
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
          const SizedBox(height: 20),
          const Text(
            'By submitting this application, you confirm that all information provided is accurate and documents are valid.',
            style: TextStyle(
              fontSize: 14,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  bool _isReadyForSubmission() {
    return _getValidationIssues().isEmpty;
  }

  List<String> _getValidationIssues() {
    final issues = <String>[];

    final addressError =
        _validateAddressLine(_transporterModel.address.addressLine);
    if (addressError != null) {
      issues.add(addressError);
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
}
