// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart'; // Make sure to add this dependency
//
// import '../../constants/color_constants.dart';
//
// class PlanRegistrationScreen extends StatefulWidget {
//   final String planType;
//
//   const PlanRegistrationScreen({
//     Key? key,
//     required this.planType,
//   }) : super(key: key);
//
//   @override
//   State<PlanRegistrationScreen> createState() => _PlanRegistrationScreenState();
// }
//
// class _PlanRegistrationScreenState extends State<PlanRegistrationScreen> {
//   int _currentStep = 0;
//   final _formKey = GlobalKey<FormState>();
//
//   // Common Controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _whatsappController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//
//   // Vehicle Related Controllers
//   final TextEditingController _vehicleNumberController =
//       TextEditingController();
//   final TextEditingController _minimumFareController = TextEditingController();
//   String _vehicleType = '';
//   String _fuelType = '';
//   String _seatingCapacity = '';
//   String _vehicleOwnership = 'Own';
//
//   // Document Related Controllers
//   final TextEditingController _aadharNumberController = TextEditingController();
//   final TextEditingController _licenseNumberController =
//       TextEditingController();
//   final TextEditingController _gstNumberController = TextEditingController();
//   XFile? _rcBookImage;
//   XFile? _licenseImage;
//   XFile? _aadharImage;
//   XFile? _profileImage;
//   XFile? _vehicleImage;
//
//   // Business Related Controllers
//   final TextEditingController _companyNameController = TextEditingController();
//   final TextEditingController _registrationNumberController =
//       TextEditingController();
//   String _legalStructure = '';
//   List<String> _serviceCities = [];
//   List<String> _spokenLanguages = [];
//
//   // Service Preferences
//   bool _allowDailyHire = false;
//   bool _allowHourlyHire = false;
//   bool _allowOutstationHire = false;
//   bool _allowBargaining = true;
//   bool _showContactDetails = true;
//   bool _useInAppChat = true;
//
//   // Additional fields for Transporter
//   List<Map<String, dynamic>> _vehicleFleet = [];
//   String _fleetSize = '';
//
//   bool _isLoading = false;
//   bool _agreeToPolicies = false;
//
//   // Plan type configurations
//   final Map<String, Map<String, String>> planTypeConfig = {
//     'Stand Alone Driver': {'title': 'Stand Alone Driver', 'icon': '🚖'},
//     'Auto Rickshaw': {'title': 'Auto Rickshaw', 'icon': '🛺'},
//     'E_RICKSHAW': {'title': 'E_RICKSHAW', 'icon': '🔋🛺'},
//     'Transporter': {'title': 'Transporter', 'icon': '🚚'},
//   };
//
//   Future<void> _pickImage(String type) async {
//     final ImagePicker picker = ImagePicker();
//     try {
//       final XFile? image = await picker.pickImage(source: ImageSource.gallery);
//       if (image != null) {
//         setState(() {
//           switch (type) {
//             case 'rcBook':
//               _rcBookImage = image;
//               break;
//             case 'license':
//               _licenseImage = image;
//               break;
//             case 'aadhar':
//               _aadharImage = image;
//               break;
//             case 'profile':
//               _profileImage = image;
//               break;
//             case 'vehicle':
//               _vehicleImage = image;
//               break;
//           }
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking image: $e')),
//       );
//     }
//   }
//
//   List<Step> getSteps() {
//     return [
//       Step(
//         state: _currentStep > 0 ? StepState.complete : StepState.indexed,
//         isActive: _currentStep >= 0,
//         title: const Text('Basic Info'),
//         content: _buildBasicInfoSection(),
//       ),
//       Step(
//         state: _currentStep > 1 ? StepState.complete : StepState.indexed,
//         isActive: _currentStep >= 1,
//         title: const Text('Documents'),
//         content: _buildDocumentsSection(),
//       ),
//       if (widget.planType != 'Transporter') ...[
//         Step(
//           state: _currentStep > 2 ? StepState.complete : StepState.indexed,
//           isActive: _currentStep >= 2,
//           title: const Text('Vehicle Details'),
//           content: _buildVehicleDetailsSection(),
//         ),
//       ] else ...[
//         Step(
//           state: _currentStep > 2 ? StepState.complete : StepState.indexed,
//           isActive: _currentStep >= 2,
//           title: const Text('Fleet Details'),
//           content: _buildFleetDetailsSection(),
//         ),
//       ],
//       Step(
//         state: _currentStep > 3 ? StepState.complete : StepState.indexed,
//         isActive: _currentStep >= 3,
//         title: const Text('Service Details'),
//         content: _buildServiceDetailsSection(),
//       ),
//       Step(
//         state: _currentStep > 4 ? StepState.complete : StepState.indexed,
//         isActive: _currentStep >= 4,
//         title: const Text('Contact Details'),
//         content: _buildContactDetailsSection(),
//       ),
//       Step(
//         state: _currentStep > 5 ? StepState.complete : StepState.indexed,
//         isActive: _currentStep >= 5,
//         title: const Text('Review & Submit'),
//         content: _buildReviewSection(),
//       ),
//     ];
//   }
//
//   Widget _buildBasicInfoSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: _nameController,
//           decoration: const InputDecoration(
//             labelText: 'Full Name*',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.person),
//           ),
//           validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//         ),
//         const SizedBox(height: 16),
//         if (widget.planType == 'Transporter') ...[
//           TextFormField(
//             controller: _companyNameController,
//             decoration: const InputDecoration(
//               labelText: 'Company Name*',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.business),
//             ),
//             validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//           ),
//           const SizedBox(height: 16),
//           DropdownButtonFormField<String>(
//             decoration: const InputDecoration(
//               labelText: 'Legal Structure*',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.business_center),
//             ),
//             value: _legalStructure.isEmpty ? null : _legalStructure,
//             items: [
//               'Partnership',
//               'Proprietorship',
//               'Trust',
//               'Non Profit',
//               'Other'
//             ]
//                 .map((type) => DropdownMenuItem(value: type, child: Text(type)))
//                 .toList(),
//             onChanged: (value) {
//               setState(() => _legalStructure = value ?? '');
//             },
//             validator: (value) => value == null ? 'Required' : null,
//           ),
//         ],
//         const SizedBox(height: 16),
//         TextFormField(
//           controller: _emailController,
//           decoration: const InputDecoration(
//             labelText: 'Email*',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.email),
//           ),
//           keyboardType: TextInputType.emailAddress,
//           validator: (value) {
//             if (value?.isEmpty ?? true) return 'Required';
//             if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
//               return 'Enter valid email';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDocumentsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (widget.planType == 'Transporter') ...[
//           TextFormField(
//             controller: _gstNumberController,
//             decoration: const InputDecoration(
//               labelText: 'GST Number*',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.receipt),
//             ),
//             validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//           ),
//           const SizedBox(height: 16),
//         ] else ...[
//           TextFormField(
//             controller: _aadharNumberController,
//             decoration: const InputDecoration(
//               labelText: 'Aadhar Number*',
//               border: OutlineInputBorder(),
//               prefixIcon: Icon(Icons.credit_card),
//             ),
//             keyboardType: TextInputType.number,
//             inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//             validator: (value) {
//               if (value?.isEmpty ?? true) return 'Required';
//               if (value!.length != 12) return 'Must be 12 digits';
//               return null;
//             },
//           ),
//         ],
//         const SizedBox(height: 16),
//         _buildImageUploadField(
//           'Upload License*',
//           _licenseImage,
//           () => _pickImage('license'),
//         ),
//         if (widget.planType != 'Transporter') ...[
//           const SizedBox(height: 16),
//           _buildImageUploadField(
//             'Upload RC Book*',
//             _rcBookImage,
//             () => _pickImage('rcBook'),
//           ),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildVehicleDetailsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         DropdownButtonFormField<String>(
//           decoration: const InputDecoration(
//             labelText: 'Vehicle Type*',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.directions_car),
//           ),
//           value: _vehicleType.isEmpty ? null : _vehicleType,
//           items: ['Car', 'Auto Rickshaw', 'E_RICKSHAW', 'Van']
//               .map((type) => DropdownMenuItem(value: type, child: Text(type)))
//               .toList(),
//           onChanged: (value) {
//             setState(() => _vehicleType = value ?? '');
//           },
//           validator: (value) => value == null ? 'Required' : null,
//         ),
//         const SizedBox(height: 16),
//         DropdownButtonFormField<String>(
//           decoration: const InputDecoration(
//             labelText: 'Seating Capacity*',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.airline_seat_recline_normal),
//           ),
//           value: _seatingCapacity.isEmpty ? null : _seatingCapacity,
//           items: ['2', '3', '4', '5', '6', '7', '8']
//               .map((seats) =>
//                   DropdownMenuItem(value: seats, child: Text('$seats Seats')))
//               .toList(),
//           onChanged: (value) {
//             setState(() => _seatingCapacity = value ?? '');
//           },
//           validator: (value) => value == null ? 'Required' : null,
//         ),
//         const SizedBox(height: 16),
//         TextFormField(
//           controller: _minimumFareController,
//           decoration: const InputDecoration(
//             labelText: 'Minimum Fare (₹)*',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.currency_rupee),
//           ),
//           keyboardType: TextInputType.number,
//           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFleetDetailsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         DropdownButtonFormField<String>(
//           decoration: const InputDecoration(
//             labelText: 'Fleet Size*',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.directions_car),
//           ),
//           value: _fleetSize.isEmpty ? null : _fleetSize,
//           items: ['2-5', '6-15', '15+']
//               .map((size) =>
//                   DropdownMenuItem(value: size, child: Text('$size vehicles')))
//               .toList(),
//           onChanged: (value) {
//             setState(() => _fleetSize = value ?? '');
//           },
//           validator: (value) => value == null ? 'Required' : null,
//         ),
//         const SizedBox(height: 16),
//         // Add fleet details form here
//       ],
//     );
//   }
//
//   Widget _buildServiceDetailsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           decoration: const InputDecoration(
//             labelText: 'Service City*',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.location_city),
//           ),
//           onChanged: (value) {
//             if (value.isNotEmpty) {
//               setState(() {
//                 _serviceCities.add(value);
//               });
//             }
//           },
//         ),
//         const SizedBox(height: 16),
//         Wrap(
//           spacing: 8,
//           children: _serviceCities
//               .map((city) => Chip(
//                     label: Text(city),
//                     onDeleted: () {
//                       setState(() {
//                         _serviceCities.remove(city);
//                       });
//                     },
//                   ))
//               .toList(),
//         ),
//         const SizedBox(height: 16),
//         SwitchListTile(
//           title: const Text('Allow Daily Hire'),
//           value: _allowDailyHire,
//           onChanged: (value) {
//             setState(() => _allowDailyHire = value);
//           },
//         ),
//         SwitchListTile(
//           title: const Text('Allow Hourly Hire'),
//           value: _allowHourlyHire,
//           onChanged: (value) {
//             setState(() => _allowHourlyHire = value);
//           },
//         ),
//         SwitchListTile(
//           title: const Text('Allow Outstation Hire'),
//           value: _allowOutstationHire,
//           onChanged: (value) {
//             setState(() => _allowOutstationHire = value);
//           },
//         ),
//         SwitchListTile(
//           title: const Text('Allow Bargaining'),
//           value: _allowBargaining,
//           onChanged: (value) {
//             setState(() => _allowBargaining = value);
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildContactDetailsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         TextFormField(
//           controller: _phoneController,
//           decoration: const InputDecoration(
//             labelText: 'Phone Number*',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.phone),
//           ),
//           keyboardType: TextInputType.phone,
//           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//           validator: (value) {
//             if (value?.isEmpty ?? true) return 'Required';
//             if (value!.length != 10) return 'Must be 10 digits';
//             return null;
//           },
//         ),
//         const SizedBox(height: 16),
//         TextFormField(
//           controller: _whatsappController,
//           decoration: const InputDecoration(
//             labelText: 'WhatsApp Number',
//             border: OutlineInputBorder(),
//             prefixIcon: Icon(Icons.media_bluetooth_off),
//           ),
//           keyboardType: TextInputType.phone,
//           inputFormatters: [FilteringTextInputFormatter.digitsOnly],
//         ),
//         const SizedBox(height: 16),
//         SwitchListTile(
//           title: const Text('Show Contact Details'),
//           value: _showContactDetails,
//           onChanged: (value) {
//             setState(() => _showContactDetails = value);
//           },
//         ),
//         SwitchListTile(
//           title: const Text('Use In-App Chat'),
//           value: _useInAppChat,
//           onChanged: (value) {
//             setState(() => _useInAppChat = value);
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildReviewSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         CheckboxListTile(
//           title: const Text('I confirm all documents are genuine'),
//           value: _agreeToPolicies,
//           onChanged: (value) {
//             setState(() => _agreeToPolicies = value ?? false);
//           },
//         ),
//         const SizedBox(height: 16),
//         if (!_agreeToPolicies)
//           const Text(
//             'Please confirm that all documents are genuine to proceed',
//             style: TextStyle(color: Colors.red),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildImageUploadField(String label, XFile? file, VoidCallback onTap) {
//     return InkWell(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.grey),
//           borderRadius: BorderRadius.circular(4),
//         ),
//         child: Row(
//           children: [
//             Icon(
//               file == null ? Icons.upload_file : Icons.check_circle,
//               color: file == null ? Colors.grey : Colors.green,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Text(
//                 file?.name ?? label,
//                 style: TextStyle(
//                   color: file == null ? Colors.grey : Colors.black,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Future<void> _submitForm() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       if (!_agreeToPolicies) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Please confirm all documents are genuine')),
//         );
//         return;
//       }
//
//       setState(() => _isLoading = true);
//
//       try {
//         // Create registration data
//         final Map<String, dynamic> registrationData = {
//           'planType': widget.planType,
//           'basicInfo': {
//             'name': _nameController.text,
//             'email': _emailController.text,
//             'phone': _phoneController.text,
//           },
//           'serviceDetails': {
//             'serviceCities': _serviceCities,
//             'allowDailyHire': _allowDailyHire,
//             'allowHourlyHire': _allowHourlyHire,
//             'allowOutstationHire': _allowOutstationHire,
//             'allowBargaining': _allowBargaining,
//           },
//           'contactDetails': {
//             'whatsapp': _whatsappController.text,
//             'showContactDetails': _showContactDetails,
//             'useInAppChat': _useInAppChat,
//           },
//         };
//
//         // TODO: Implement API call
//         // await YourApiService.register(registrationData);
//
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Registration successful!')),
//         );
//
//         // Navigate to next screen
//         // Navigator.pushReplacement(
//         //   context,
//         //   MaterialPageRoute(builder: (context) => NextScreen()),
//         // );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Registration failed: $e')),
//         );
//       } finally {
//         setState(() => _isLoading = false);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: ColorConstants.primaryColor,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () => Navigator.of(context).pop(),
//         ),
//         title: Row(
//           children: [
//             Text(
//               planTypeConfig[widget.planType]?['icon'] ?? '',
//               style: const TextStyle(fontSize: 24),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               planTypeConfig[widget.planType]?['title'] ?? '',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//       body: Form(
//         key: _formKey,
//         child: Stepper(
//           type: StepperType.vertical,
//           currentStep: _currentStep,
//           onStepContinue: () {
//             final isLastStep = _currentStep == getSteps().length - 1;
//             if (isLastStep) {
//               _submitForm();
//             } else {
//               setState(() => _currentStep += 1);
//             }
//           },
//           onStepCancel: _currentStep == 0
//               ? null
//               : () => setState(() => _currentStep -= 1),
//           steps: getSteps(),
//         ),
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     // Dispose all controllers
//     _nameController.dispose();
//     _emailController.dispose();
//     _phoneController.dispose();
//     _whatsappController.dispose();
//     _addressController.dispose();
//     _vehicleNumberController.dispose();
//     _minimumFareController.dispose();
//     _aadharNumberController.dispose();
//     _licenseNumberController.dispose();
//     _gstNumberController.dispose();
//     _companyNameController.dispose();
//     _registrationNumberController.dispose();
//     super.dispose();
//   }
// }
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'constants/color_constants.dart';

class TransporterRegistration {
  String? companyName;
  String? registeredAddress;
  AddressType? addressType;
  LegalStructure? legalStructure;
  String? ownerName;
  String? ownerDesignation;
  List<String> serviceCities;

  // Document Info
  String? gstin;
  String? businessCertificate;
  String? aadharNumber;
  String? transportPermit;

  // Vehicle Info
  FleetSize? fleetSize;
  Map<VehicleType, int> vehicles;
  bool isNegotiable;
  List<String> vehiclePhotos;

  // Contact Info
  String? contactName;
  String? mobileNumber;
  String? whatsappNumber;
  bool showContactOnWebsite;
  bool showWhatsappOnWebsite;
  bool enableInAppChat;

  TransporterRegistration({
    this.companyName,
    this.registeredAddress,
    this.addressType,
    this.legalStructure,
    this.ownerName,
    this.ownerDesignation,
    this.serviceCities = const [],
    this.gstin,
    this.businessCertificate,
    this.aadharNumber,
    this.transportPermit,
    this.fleetSize,
    this.vehicles = const {},
    this.isNegotiable = true,
    this.vehiclePhotos = const [],
    this.contactName,
    this.mobileNumber,
    this.whatsappNumber,
    this.showContactOnWebsite = true,
    this.showWhatsappOnWebsite = true,
    this.enableInAppChat = true,
  });
}

enum AddressType { headOffice, branch, plantAndFactory }

enum LegalStructure { partnership, proprietorship, trust, nonProfit, other }

enum FleetSize {
  small, // 2-5
  medium, // 6-15
  large // 15+
}

enum VehicleType { car, van, minibus }

class TransporterRegistrationScreen extends StatefulWidget {
  final String planType;

  const TransporterRegistrationScreen({
    Key? key,
    required this.planType,
  }) : super(key: key);

  @override
  State<TransporterRegistrationScreen> createState() =>
      _TransporterRegistrationScreenState();
}

class _TransporterRegistrationScreenState
    extends State<TransporterRegistrationScreen> {
  final PageController _pageController = PageController();
  final TransporterRegistration _registration = TransporterRegistration();
  int _currentStep = 0;

  final List<String> _steps = [
    'Business Info',
    'Documents',
    'Vehicles',
    'Contact',
    'Review'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Step ${_currentStep + 1} of ${_steps.length}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              _pageController.previousPage(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
              );
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          LinearProgressIndicator(
            value: (_currentStep + 1) / _steps.length,
            backgroundColor: Colors.grey[200],
            valueColor:
                AlwaysStoppedAnimation<Color>(ColorConstants.primaryColor),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() => _currentStep = index);
              },
              children: [
                _BusinessInfoStep(registration: _registration),
                _DocumentUploadStep(
                    registration: _registration), // Add this line
                _VehicleInfoStep(registration: _registration),
                _ContactInfoStep(
                  registration: _registration,
                  currentUserLogin: '',
                ),
                _ReviewStep(
                  registration: _registration,
                  currentDateTime: '',
                  currentUserLogin: '',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Previous'),
                  ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < _steps.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _submitRegistration();
                    }
                  },
                  child: Text(
                      _currentStep < _steps.length - 1 ? 'Next' : 'Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _submitRegistration() async {
    // TODO: Implement API call to submit registration
    // Show loading indicator
    // Handle success/error
  }
}

class _BusinessInfoStep extends StatelessWidget {
  final TransporterRegistration registration;

  const _BusinessInfoStep({
    Key? key,
    required this.registration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Company Name',
                hintText: 'Enter your company name',
              ),
              initialValue: registration.companyName,
              onChanged: (value) => registration.companyName = value,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'Company name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Registered Address',
                hintText: 'Enter your registered address',
              ),
              maxLines: 3,
              initialValue: registration.registeredAddress,
              onChanged: (value) => registration.registeredAddress = value,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<AddressType>(
              decoration: const InputDecoration(
                labelText: 'Address Type',
              ),
              value: registration.addressType,
              items: AddressType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) => registration.addressType = value,
            ),
            // Add remaining fields...
          ],
        ),
      ),
    );
  }
}

class _DocumentUploadStep extends StatefulWidget {
  final TransporterRegistration registration;

  const _DocumentUploadStep({
    Key? key,
    required this.registration,
  }) : super(key: key);

  @override
  State<_DocumentUploadStep> createState() => _DocumentUploadStepState();
}

class _DocumentUploadStepState extends State<_DocumentUploadStep> {
  final _gstinController = TextEditingController();
  final _aadharController = TextEditingController();
  File? _businessCertificate;
  File? _transportPermit;
  bool _isVerifyingGSTIN = false;
  String? _gstinError;

  @override
  void initState() {
    super.initState();
    _gstinController.text = widget.registration.gstin ?? '';
    _aadharController.text = widget.registration.aadharNumber ?? '';
  }

  Future<void> _verifyGSTIN(String gstin) async {
    if (gstin.isEmpty) {
      setState(() => _gstinError = 'GSTIN is required');
      return;
    }

    setState(() {
      _isVerifyingGSTIN = true;
      _gstinError = null;
    });

    try {
      // TODO: Implement GSTIN verification API call
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      setState(() {
        _isVerifyingGSTIN = false;
        widget.registration.gstin = gstin;
      });
    } catch (e) {
      setState(() {
        _isVerifyingGSTIN = false;
        _gstinError = 'Failed to verify GSTIN: ${e.toString()}';
      });
    }
  }

  Future<void> _pickDocument(String type) async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      if (file != null) {
        setState(() {
          if (type == 'business') {
            _businessCertificate = File(file.path);
            widget.registration.businessCertificate = file.path;
          } else if (type == 'permit') {
            _transportPermit = File(file.path);
            widget.registration.transportPermit = file.path;
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking document: ${e.toString()}')),
      );
    }
  }

  String _formatAadhar(String value) {
    if (value.length != 12) return value;
    return 'XXX-XXX-${value.substring(value.length - 4)}';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // GSTIN Input
          TextFormField(
            controller: _gstinController,
            decoration: InputDecoration(
              labelText: 'GSTIN',
              hintText: 'Enter your GSTIN',
              errorText: _gstinError,
              suffixIcon: _isVerifyingGSTIN
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      icon: const Icon(Icons.verified_outlined),
                      onPressed: () => _verifyGSTIN(_gstinController.text),
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Business Registration Certificate
          _buildDocumentUploadSection(
            title: 'Business Registration Certificate',
            subtitle: 'Upload Certificate of Incorporation (PDF/Image)',
            file: _businessCertificate,
            onTap: () => _pickDocument('business'),
          ),
          const SizedBox(height: 24),

          // Aadhaar Input
          TextFormField(
            controller: _aadharController,
            decoration: const InputDecoration(
              labelText: 'Authorized Person Aadhaar',
              hintText: 'Enter 12-digit Aadhaar number',
            ),
            keyboardType: TextInputType.number,
            maxLength: 12,
            onChanged: (value) {
              setState(() {
                widget.registration.aadharNumber = value;
              });
            },
          ),
          Text(
            'Displayed as: ${_formatAadhar(_aadharController.text)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 24),

          // Transportation Permit
          _buildDocumentUploadSection(
            title: 'Transportation Permit',
            subtitle: 'Upload valid transportation permit documents',
            file: _transportPermit,
            onTap: () => _pickDocument('permit'),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentUploadSection({
    required String title,
    required String subtitle,
    required File? file,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  file == null ? Icons.upload_file : Icons.check_circle,
                  size: 32,
                  color: file == null ? Colors.grey : Colors.green,
                ),
                const SizedBox(height: 8),
                Text(
                  file == null
                      ? 'Click to upload'
                      : 'File selected: ${file.path.split('/').last}',
                  style: TextStyle(
                    color: file == null ? Colors.grey : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _gstinController.dispose();
    _aadharController.dispose();
    super.dispose();
  }
}

class _VehicleInfoStep extends StatefulWidget {
  final TransporterRegistration registration;

  const _VehicleInfoStep({
    Key? key,
    required this.registration,
  }) : super(key: key);

  @override
  State<_VehicleInfoStep> createState() => _VehicleInfoStepState();
}

class _VehicleInfoStepState extends State<_VehicleInfoStep> {
  FleetSize? selectedFleetSize;
  final Map<VehicleType, TextEditingController> vehicleControllers = {
    VehicleType.car: TextEditingController(),
    VehicleType.van: TextEditingController(),
    VehicleType.minibus: TextEditingController(),
  };
  List<File> vehiclePhotos = [];

  @override
  void initState() {
    super.initState();
    selectedFleetSize = widget.registration.fleetSize;
    widget.registration.vehicles.forEach((type, count) {
      vehicleControllers[type]?.text = count.toString();
    });
  }

  Future<void> _pickVehiclePhotos() async {
    final ImagePicker picker = ImagePicker();
    try {
      final List<XFile> images = await picker.pickMultiImage();
      if (images.isNotEmpty) {
        setState(() {
          vehiclePhotos.addAll(images.map((image) => File(image.path)));
          widget.registration.vehiclePhotos =
              vehiclePhotos.map((photo) => photo.path).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: ${e.toString()}')),
      );
    }
  }

  void _removePhoto(int index) {
    setState(() {
      vehiclePhotos.removeAt(index);
      widget.registration.vehiclePhotos =
          vehiclePhotos.map((photo) => photo.path).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fleet Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Fleet Size Selection
          DropdownButtonFormField<FleetSize>(
            decoration: const InputDecoration(
              labelText: 'Total Fleet Size',
              border: OutlineInputBorder(),
            ),
            value: selectedFleetSize,
            items: [
              DropdownMenuItem(
                value: FleetSize.small,
                child: Text('Small (2-5 vehicles)'),
              ),
              DropdownMenuItem(
                value: FleetSize.medium,
                child: Text('Medium (6-15 vehicles)'),
              ),
              DropdownMenuItem(
                value: FleetSize.large,
                child: Text('Large (15+ vehicles)'),
              ),
            ],
            onChanged: (FleetSize? value) {
              setState(() {
                selectedFleetSize = value;
                widget.registration.fleetSize = value;
              });
            },
          ),
          const SizedBox(height: 24),

          const Text(
            'Vehicle Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Vehicle Type Counts
          ...VehicleType.values.map((type) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: TextFormField(
                  controller: vehicleControllers[type],
                  decoration: InputDecoration(
                    labelText: '${type.toString().split('.').last} Count',
                    border: const OutlineInputBorder(),
                    hintText:
                        'Enter number of ${type.toString().split('.').last}s',
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    final count = int.tryParse(value) ?? 0;
                    widget.registration.vehicles[type] = count;
                  },
                ),
              )),

          const SizedBox(height: 24),

          // Negotiation Settings
          SwitchListTile(
            title: const Text('Allow Negotiation'),
            subtitle: const Text(
                'Enable price negotiation through system chat/calls/WhatsApp'),
            value: widget.registration.isNegotiable,
            onChanged: (bool value) {
              setState(() {
                widget.registration.isNegotiable = value;
              });
            },
          ),

          const SizedBox(height: 24),

          // Vehicle Photos Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Vehicle Photos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Add photos of your vehicles to showcase your fleet',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Photo Grid
              if (vehiclePhotos.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: vehiclePhotos.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            vehiclePhotos[index],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),
                        Positioned(
                          right: 4,
                          top: 4,
                          child: GestureDetector(
                            onTap: () => _removePhoto(index),
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: 16),

              // Add Photos Button
              ElevatedButton.icon(
                onPressed: _pickVehiclePhotos,
                icon: const Icon(Icons.add_photo_alternate),
                label: const Text('Add Vehicle Photos'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Verification Tip
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Complete now → Get verified in 2 hours!\nIf additional information is required, we will contact you.',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    vehicleControllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}

class _ContactInfoStep extends StatefulWidget {
  final TransporterRegistration registration;
  final String currentUserLogin;

  const _ContactInfoStep({
    Key? key,
    required this.registration,
    required this.currentUserLogin,
  }) : super(key: key);

  @override
  State<_ContactInfoStep> createState() => _ContactInfoStepState();
}

class _ContactInfoStepState extends State<_ContactInfoStep> {
  final _contactNameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _whatsappController = TextEditingController();
  bool _useLoginMobileNumber = true;
  bool _useLoginWhatsappNumber = true;
  bool _isVerifyingMobile = false;
  bool _isVerifyingWhatsapp = false;

  @override
  void initState() {
    super.initState();
    _contactNameController.text = widget.registration.contactName ?? '';
    _mobileController.text = widget.registration.mobileNumber ?? '';
    _whatsappController.text = widget.registration.whatsappNumber ?? '';
  }

  Future<void> _verifyPhoneNumber(String number, bool isWhatsapp) async {
    if (number.isEmpty) return;

    setState(() {
      isWhatsapp ? _isVerifyingWhatsapp = true : _isVerifyingMobile = true;
    });

    try {
      // TODO: Implement actual OTP verification
      await Future.delayed(const Duration(seconds: 2)); // Simulate API call

      setState(() {
        if (isWhatsapp) {
          widget.registration.whatsappNumber = number;
          _isVerifyingWhatsapp = false;
        } else {
          widget.registration.mobileNumber = number;
          _isVerifyingMobile = false;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number verified successfully')),
      );
    } catch (e) {
      setState(() {
        isWhatsapp ? _isVerifyingWhatsapp = false : _isVerifyingMobile = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'These details will be displayed on our website and app for client communication',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),

          // Contact Name
          TextFormField(
            controller: _contactNameController,
            decoration: const InputDecoration(
              labelText: 'Contact Person Name',
              hintText: 'e.g., John Doe',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.registration.contactName = value,
          ),
          const SizedBox(height: 24),

          // Mobile Number Section
          const Text(
            'Mobile Number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Use Login Mobile Number Switch
          SwitchListTile(
            title: Text('Use login number (${widget.currentUserLogin})'),
            value: _useLoginMobileNumber,
            onChanged: (bool value) {
              setState(() {
                _useLoginMobileNumber = value;
                if (value) {
                  _mobileController.text = widget.currentUserLogin;
                  widget.registration.mobileNumber = widget.currentUserLogin;
                }
              });
            },
          ),

          if (!_useLoginMobileNumber) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _mobileController,
              decoration: InputDecoration(
                labelText: 'New Mobile Number',
                hintText: 'Enter mobile number',
                border: const OutlineInputBorder(),
                suffixIcon: _isVerifyingMobile
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.verified),
                        onPressed: () =>
                            _verifyPhoneNumber(_mobileController.text, false),
                      ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],

          const SizedBox(height: 24),

          // Show Mobile Number Toggle
          SwitchListTile(
            title: const Text('Show mobile number on website/app'),
            value: widget.registration.showContactOnWebsite,
            onChanged: (bool value) {
              setState(() {
                widget.registration.showContactOnWebsite = value;
              });
            },
          ),

          const Divider(height: 32),

          // WhatsApp Number Section
          const Text(
            'WhatsApp Number',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Use Login WhatsApp Number Switch
          SwitchListTile(
            title: Text('Use login number (${widget.currentUserLogin})'),
            value: _useLoginWhatsappNumber,
            onChanged: (bool value) {
              setState(() {
                _useLoginWhatsappNumber = value;
                if (value) {
                  _whatsappController.text = widget.currentUserLogin;
                  widget.registration.whatsappNumber = widget.currentUserLogin;
                }
              });
            },
          ),

          if (!_useLoginWhatsappNumber) ...[
            const SizedBox(height: 8),
            TextFormField(
              controller: _whatsappController,
              decoration: InputDecoration(
                labelText: 'New WhatsApp Number',
                hintText: 'Enter WhatsApp number',
                border: const OutlineInputBorder(),
                suffixIcon: _isVerifyingWhatsapp
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.verified),
                        onPressed: () =>
                            _verifyPhoneNumber(_whatsappController.text, true),
                      ),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],

          const SizedBox(height: 24),

          // Show WhatsApp Number Toggle
          SwitchListTile(
            title: const Text('Show WhatsApp number on website/app'),
            value: widget.registration.showWhatsappOnWebsite,
            onChanged: (bool value) {
              setState(() {
                widget.registration.showWhatsappOnWebsite = value;
              });
            },
          ),

          const Divider(height: 32),

          // In-App Chat System
          SwitchListTile(
            title: const Text('Enable In-App Chat System'),
            subtitle:
                const Text('Allow customers to contact you through our app'),
            value: widget.registration.enableInAppChat,
            onChanged: (bool value) {
              setState(() {
                widget.registration.enableInAppChat = value;
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _contactNameController.dispose();
    _mobileController.dispose();
    _whatsappController.dispose();
    super.dispose();
  }
}

class _ReviewStep extends StatelessWidget {
  final TransporterRegistration registration;
  final String currentDateTime;
  final String currentUserLogin;

  const _ReviewStep({
    Key? key,
    required this.registration,
    required this.currentDateTime,
    required this.currentUserLogin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Review Your Information',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          _buildSection(
            'Business Information',
            [
              _buildInfoRow('Company Name', registration.companyName ?? ''),
              _buildInfoRow('Address', registration.registeredAddress ?? ''),
              _buildInfoRow('Address Type',
                  registration.addressType?.toString().split('.').last ?? ''),
              _buildInfoRow(
                  'Legal Structure',
                  registration.legalStructure?.toString().split('.').last ??
                      ''),
              _buildInfoRow('Owner Name', registration.ownerName ?? ''),
              _buildInfoRow(
                  'Service Cities', registration.serviceCities.join(', ')),
            ],
          ),

          _buildSection(
            'Documents',
            [
              _buildInfoRow('GSTIN', registration.gstin ?? ''),
              _buildInfoRow(
                  'Business Certificate',
                  registration.businessCertificate != null
                      ? 'Uploaded'
                      : 'Not uploaded'),
              _buildInfoRow('Aadhaar Number',
                  'XXX-XXX-${registration.aadharNumber?.substring(8) ?? ''}'),
              _buildInfoRow(
                  'Transport Permit',
                  registration.transportPermit != null
                      ? 'Uploaded'
                      : 'Not uploaded'),
            ],
          ),

          _buildSection(
            'Vehicle Information',
            [
              _buildInfoRow('Fleet Size',
                  registration.fleetSize?.toString().split('.').last ?? ''),
              ...registration.vehicles.entries.map(
                (entry) => _buildInfoRow(
                  entry.key.toString().split('.').last,
                  entry.value.toString(),
                ),
              ),
              _buildInfoRow(
                  'Negotiable', registration.isNegotiable ? 'Yes' : 'No'),
              _buildInfoRow('Vehicle Photos',
                  '${registration.vehiclePhotos.length} uploaded'),
            ],
          ),

          _buildSection(
            'Contact Information',
            [
              _buildInfoRow('Contact Name', registration.contactName ?? ''),
              _buildInfoRow('Mobile Number', registration.mobileNumber ?? ''),
              _buildInfoRow('Show Mobile Number',
                  registration.showContactOnWebsite ? 'Yes' : 'No'),
              _buildInfoRow(
                  'WhatsApp Number', registration.whatsappNumber ?? ''),
              _buildInfoRow('Show WhatsApp Number',
                  registration.showWhatsappOnWebsite ? 'Yes' : 'No'),
              _buildInfoRow('In-App Chat',
                  registration.enableInAppChat ? 'Enabled' : 'Disabled'),
            ],
          ),

          _buildSection(
            'Submission Details',
            [
              _buildInfoRow('Submitted By', currentUserLogin),
              _buildInfoRow('Submission Date', currentDateTime),
            ],
          ),

          const SizedBox(height: 24),

          // Terms and Conditions
          // CheckboxListTile(
          //   title: const Text(
          //     'I confirm all documents are valid and information provided is accurate',
          //     style: TextStyle(fontWeight: FontWeight.bold),
          //   ),
          //   // value: registration.termsAccepted ?? false,
          //   // onChanged: (bool? value) {
          //   //   registration.termsAccepted = value ?? false;
          //   // },
          // ),

          const SizedBox(height: 16),

          // Note about verification
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.info_outline, color: Colors.blue),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Your registration will be verified within 2 hours. We may contact you if additional information is needed.',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
