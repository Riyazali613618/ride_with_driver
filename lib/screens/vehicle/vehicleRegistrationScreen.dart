// vehicle_registration_provider.dart
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_service/media_service.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/screens/block/language/language_provider.dart';

import '../../constants/token_manager.dart';
import '../../utils/color.dart';
import '../layout.dart';

class VehicleRegistrationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;

  String? get error => _error;

  static const String baseUrl = '${ApiConstants.baseUrl}';
  static String authToken = 'YOUR_AUTH_TOKEN';

  Future<void> getToken() async {
    final token = await TokenManager.getToken();
    authToken = token.toString();
    if (token == null) {
      throw Exception('Authentication token not found');
    }
  }

  Future<bool> submitVehicleRegistration({
    required String userType,
    String? vehicleType,
    String? vehicleName,
    required String vehicleNumber,
    required int seatingCapacity,
    required String airConditioning,
    required List<String> vehicleSpecifications,
    required Map<String, double> serviceLocation,
    required double minimumChargePerHour,
    required bool isPriceNegotiable,
    required List<String> images,
    required List<String> videos,
    String? rcBookFrontPhoto,
    String? rcBookBackPhoto,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      var headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken'
      };
      print(authToken.substring(0, 100));
      print(authToken.substring(100));

      var request = http.Request('POST', Uri.parse('$baseUrl/user/vehicles'));

      // Build request body based on user type
      Map<String, dynamic> requestBody = {
        "vehicleNumber": vehicleNumber,
        "seatingCapacity": seatingCapacity,
        "airConditioning": airConditioning,
        "vehicleSpecifications": vehicleSpecifications,
        "serviceLocation": serviceLocation,
        "minimumChargePerHour": minimumChargePerHour,
        "isPriceNegotiable": isPriceNegotiable,
        "images": images,
        "videos": videos,
      };

      // Add vehicleType and vehicleName only if not auto-rickshaw or e-rickshaw
      if (userType != 'Auto-Rickshaw' && userType != 'E-Rickshaw Driver') {
        if (vehicleType != null) requestBody["vehicleType"] = vehicleType;
        if (vehicleName != null) requestBody["vehicleName"] = vehicleName;
      }

      // Add RC photos only if not auto-rickshaw or e-rickshaw
      if (userType != 'Auto-Rickshaw' && userType != 'E-Rickshaw Driver') {
        if (rcBookFrontPhoto != null)
          requestBody["rcBookFrontPhoto"] = rcBookFrontPhoto;
        if (rcBookBackPhoto != null)
          requestBody["rcBookBackPhoto"] = rcBookBackPhoto;
      }
      print(requestBody);
      request.body = json.encode(requestBody);
      request.headers.addAll(headers);

      http.StreamedResponse response = await request.send();
      print('Success: ${response.statusCode}');



      if (response.statusCode == 201) {
        String responseBody = await response.stream.bytesToString();
        print('Success: $responseBody');
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        String responseBody = await response.stream.bytesToString();
        Map<String, dynamic> map = json.decode(responseBody);
        print('failed: ${responseBody}');

        try {
          _error = 'Failed to submit: ${map["errors"]["errors"].toList()[0]}';
        } catch (e, s) {
          _error = 'Failed to submit';
          print(s);
        }
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Network error: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// vehicle_registration_form.dart

class VehicleRegistrationForm extends StatefulWidget {
  final String
      userType; // 'Transporter', 'Taxi Owner', 'Auto-Rickshaw', 'E-Rickshaw Driver'

  const VehicleRegistrationForm({
    Key? key,
    required this.userType,
  }) : super(key: key);

  @override
  State<VehicleRegistrationForm> createState() =>
      _VehicleRegistrationFormState();
}

class _VehicleRegistrationFormState extends State<VehicleRegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();

  // Form Controllers
  final _vehicleNameController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _minimumChargeController = TextEditingController();

  // Form Data
  String? _selectedVehicleType;
  String? _selectedSeatingCapacity;
  String _selectedAirConditioning = 'Non-AC';
  bool _isNegotiable = false;
  List<String> _selectedLocations = [];
  List<String> _selectedSpecifications = [];
  List<File> _vehicleImages = [];
  List<File> _vehicleVideos = [];
  List<File> _rcImages = [];

  final Map<String, double> _currentLocation = {'lat': 28.6139, 'lng': 77.209};

  final List<String> _vehicleTypes = [
    'CAR',
    'SUV',
    'VAN',
    'BUS',
    'TRUCK',
    'MOTORCYCLE',
    'RICKSHAW'
  ];

  final List<String> _seatingCapacities = [
    '2',
    '3',
    '4',
    '5',
    '7',
    '9',
    '12',
    '15',
    '20',
    '25',
    '30'
  ];

  final List<String> _serviceLocations = [
    'New Delhi',
    'Faridabad',
    'Noida',
    'Gurgaon',
    'Mumbai',
    'Bangalore'
  ];

  final List<String> _specifications = [
    'Navigation System',
    'Airbags',
    'ABS',
    'Leather Seats',
    'Rear Camera',
    'Bluetooth',
    'Sunroof',
    'Petrol',
    'CNG fuel',
    'Good condition',
    'Regular maintenance',
    'Clean interior'
  ];

  // Check if field should be shown based on user type
  bool get _shouldShowVehicleType =>
      widget.userType != 'Auto-Rickshaw' &&
      widget.userType != 'E-Rickshaw Driver';

  bool get _shouldShowVehicleName =>
      widget.userType != 'Auto-Rickshaw' &&
      widget.userType != 'E-Rickshaw Driver';

  bool get _shouldShowRCPhotos =>
      widget.userType != 'Auto-Rickshaw' &&
      widget.userType != 'E-Rickshaw Driver';

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _vehicleNameController.dispose();
    _vehicleNumberController.dispose();
    _minimumChargeController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        switch (type) {
          case 'vehicle':
            _vehicleImages.add(File(image.path));

            break;
          case 'rc':
            _rcImages.add(File(image.path));
            break;
        }
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _vehicleVideos.add(File(video.path));
      });
    }
  }

  void _removeFile(String type, int index) {
    setState(() {
      switch (type) {
        case 'vehicle':
          _vehicleImages.removeAt(index);
          break;
        case 'video':
          _vehicleVideos.removeAt(index);
          break;
        case 'rc':
          _rcImages.removeAt(index);
          break;
      }
    });
  }

  Future<List<String>> _uploadFiles(List<File> files, String type) async {
    List<String> urls = [];
    int i = 0;
    for (File file in files) {
      var type = "";
      if (i == 0) {
        type = "rcBookFront";
      } else {
        type = "rcBookBack";
      }
      final String? url = await MediaService().uploadFileAndGetUrl(
        file,
        kind: type,
      );
      urls.add(url ?? "");
    }
    return urls;
  }

  bool isLoading=false;

  Future<void> _submitForm(VehicleRegistrationProvider provider) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validation based on user type
    if (_shouldShowVehicleType && _selectedVehicleType == null) {
      _showErrorSnackBar('Please select vehicle type');
      return;
    }

    if (_shouldShowVehicleName && _vehicleNameController.text.isEmpty) {
      _showErrorSnackBar('Please enter vehicle name');
      return;
    }

    if (_vehicleNumberController.text.isEmpty) {
      _showErrorSnackBar('Please enter vehicle number');
      return;
    }

    if (_selectedSeatingCapacity == null) {
      _showErrorSnackBar('Please select seating capacity');
      return;
    }

    if (_minimumChargeController.text.isEmpty) {
      _showErrorSnackBar('Please enter minimum charge');
      return;
    }

    if (_shouldShowRCPhotos && _rcImages.length < 2) {
      _showErrorSnackBar('Please upload both front and back RC images');
      return;
    }

    try{
    isLoading=true;
    setState(() {
    });
      List<String> imageUrls = [];
      for (var images in _vehicleImages) {
        final String? url = await MediaService().uploadFileAndGetUrl(
          images,
          kind: "vehicleImage",
        );
        imageUrls.add(url ?? "");
      }
      List<String> videoUrls = [];
      for (var videos in _vehicleVideos) {
        final String? url = await MediaService().uploadFileAndGetUrl(
          videos,
          kind: "vehicleVideo",
        );
        imageUrls.add(url ?? "");
      }
      print(videoUrls);
      List<String> rcUrls =
          _shouldShowRCPhotos ? await _uploadFiles(_rcImages, 'rc') : [];

      String? rcFrontUrl =
          _shouldShowRCPhotos && rcUrls.isNotEmpty ? rcUrls[0] : null;
      String? rcBackUrl =
          _shouldShowRCPhotos && rcUrls.length > 1 ? rcUrls[1] : null;

     /* final provider =
          Provider.of<VehicleRegistrationProvider>(context, listen: false);*/
      await provider.getToken();

      bool success = await provider.submitVehicleRegistration(
        userType: widget.userType,
        vehicleType: _shouldShowVehicleType ? _selectedVehicleType : null,
        vehicleName:
            _shouldShowVehicleName ? _vehicleNameController.text.trim() : null,
        vehicleNumber: _vehicleNumberController.text.trim().toUpperCase(),
        seatingCapacity: int.parse(_selectedSeatingCapacity!),
        airConditioning: _selectedAirConditioning,
        vehicleSpecifications: _selectedSpecifications,
        serviceLocation: _currentLocation,
        minimumChargePerHour: double.parse(_minimumChargeController.text),
        isPriceNegotiable: _isNegotiable,
        images: imageUrls,
        videos: videoUrls,
        rcBookFrontPhoto: rcFrontUrl,
        rcBookBackPhoto: rcBackUrl,
      );
    isLoading=false;

      if (success) {
        _showSuccessSnackBar('Vehicle registration submitted successfully!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const Layout()),
              (route) => false,
        );
      } else if (provider.error != null) {
        _showErrorSnackBar(provider.error!);
      }
    } catch (e) {
      isLoading=false;
      _showErrorSnackBar('An error occurred: $e');
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

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            stops: const [0.0, 0.15, 0.30, .90],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${widget.userType} Registration',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Form Content
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vehicle Type - Only for Transporter and Taxi Owner
                          if (_shouldShowVehicleType)
                            _buildDropdownField(
                              label: 'Vehicle Type',
                              value: _selectedVehicleType,
                              items: _vehicleTypes,
                              onChanged: (value) {
                                setState(() {
                                  _selectedVehicleType = value;
                                });
                              },
                              isRequired: true,
                            ),

                          // Vehicle Name - Only for Transporter and Taxi Owner
                          if (_shouldShowVehicleName)
                            _buildTextField(
                              label: 'Vehicle Name',
                              controller: _vehicleNameController,
                              isHighlighted: true,
                            ),

                          _buildTextField(
                            label: 'Vehicle Number',
                            controller: _vehicleNumberController,
                            isHighlighted: true,
                          ),

                          _buildDropdownField(
                            label: 'Seating Capacity',
                            value: _selectedSeatingCapacity,
                            items: _seatingCapacities,
                            onChanged: (value) {
                              setState(() {
                                _selectedSeatingCapacity = value;
                              });
                            },
                          ),

                          _buildMinimumChargeField(),

                          _buildMultiSelectField(
                            label: 'Service Locations',
                            selectedItems: _selectedLocations,
                            allItems: _serviceLocations,
                            onSelectionChanged: (locations) {
                              setState(() {
                                _selectedLocations = locations;
                              });
                            },
                          ),

                          _buildAirConditioningField(),

                          _buildMultiSelectField(
                            label: 'Specifications',
                            selectedItems: _selectedSpecifications,
                            allItems: _specifications,
                            onSelectionChanged: (specs) {
                              setState(() {
                                _selectedSpecifications = specs;
                              });
                            },
                          ),

                          _buildFileUploadSection(
                            title: 'Upload Vehicle Image',
                            files: _vehicleImages,
                            onAddFile: () => _pickImage('vehicle'),
                            onRemoveFile: (index) =>
                                _removeFile('vehicle', index),
                            fileType: 'image',
                          ),

                          _buildFileUploadSection(
                            title: 'Upload Vehicle Video',
                            files: _vehicleVideos,
                            onAddFile: () => _pickVideo(),
                            onRemoveFile: (index) =>
                                _removeFile('video', index),
                            fileType: 'video',
                          ),

                          // RC Upload - Only for Transporter and Taxi Owner
                          if (_shouldShowRCPhotos) _buildRCUploadSection(),

                          const SizedBox(height: 40),

                          // Submit Button
                          Consumer<VehicleRegistrationProvider>(
                            builder: (context, provider, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed:() {
                                    (provider.isLoading|| isLoading) ? null : _submitForm(provider);
                                  }
                                      ,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: gradientFirst,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: (provider.isLoading|| isLoading)
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          'Submit',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isHighlighted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isHighlighted ? Colors.grey : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                    color: isHighlighted ? Colors.grey : Colors.grey.shade300,
                    width: 1),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: 'Select Type',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isRequired && value == null
                      ? Colors.grey
                      : Colors.grey.shade300,
                  width: isRequired && value == null ? 2 : 1,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: isRequired && value == null
                      ? Colors.grey
                      : Colors.grey.shade300,
                  width: isRequired && value == null ? 2 : 1,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
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
        ],
      ),
    );
  }

  Widget _buildMinimumChargeField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Minimum Charge Per Hour',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _minimumChargeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: _isNegotiable,
                      onChanged: (value) {
                        setState(() {
                          _isNegotiable = value!;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    const Text(
                      'Negotiable',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultiSelectField({
    required String label,
    required List<String> selectedItems,
    required List<String> allItems,
    required Function(List<String>) onSelectionChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                hint: Text('Search $label'),
                isExpanded: true,
                items: allItems.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: (String? value) {
                  if (value != null && !selectedItems.contains(value)) {
                    final newList = List<String>.from(selectedItems)
                      ..add(value);
                    onSelectionChanged(newList);
                  }
                },
              ),
            ),
          ),
          if (selectedItems.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: selectedItems.map((item) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF9C27B0).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item,
                        style: const TextStyle(
                          color: Color(0xFF9C27B0),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: () {
                          final newList = List<String>.from(selectedItems)
                            ..remove(item);
                          onSelectionChanged(newList);
                        },
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAirConditioningField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Air Conditioning',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('AC'),
                  value: 'AC',
                  groupValue: _selectedAirConditioning,
                  onChanged: (value) {
                    setState(() {
                      _selectedAirConditioning = value!;
                    });
                  },
                  activeColor: Colors.green,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Non AC'),
                  value: 'Non-AC',
                  groupValue: _selectedAirConditioning,
                  onChanged: (value) {
                    setState(() {
                      _selectedAirConditioning = value!;
                    });
                  },
                  activeColor: Colors.green,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileUploadSection({
    required String title,
    required List<File> files,
    required VoidCallback onAddFile,
    required Function(int) onRemoveFile,
    required String fileType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          if (files.isNotEmpty) ...[
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: files.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.grey.shade200,
                          ),
                          child: fileType == 'video'
                              ? const Icon(Icons.video_file, size: 40)
                              : ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    files[index],
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () => onRemoveFile(index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
          ],
          GestureDetector(
            onTap: onAddFile,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300, width: 2),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade50,
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add, color: Colors.grey, size: 24),
                  Text(
                    'Add',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRCUploadSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'RC (Front & Back)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.grey,
                ),
                const SizedBox(height: 8),
                const Text(
                  'select your file or drag and drop',
                  style: TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'png, pdf, jpg, docx accepted',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _pickImage('rc'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gradientFirst,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'Browse',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_rcImages.isNotEmpty) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _rcImages.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _rcImages[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: -4,
                          right: -4,
                          child: GestureDetector(
                            onTap: () => _removeFile('rc', index),
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// USAGE EXAMPLE:
// How to navigate to this form with different user types:

/*
// For Transporter
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VehicleRegistrationForm(userType: 'Transporter'),
  ),
);

// For Taxi Owner
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VehicleRegistrationForm(userType: 'Taxi Owner'),
  ),
);

// For Auto-Rickshaw
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VehicleRegistrationForm(userType: 'Auto-Rickshaw'),
  ),
);

// For E-Rickshaw Driver
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => VehicleRegistrationForm(userType: 'E-Rickshaw Driver'),
  ),
);
*/
