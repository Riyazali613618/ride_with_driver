import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_model/cityModel.dart' as cM;
import 'package:r_w_r/api/api_model/languageModel.dart' as lm;
import 'package:r_w_r/api/api_model/stateModel.dart' as sm;
import 'package:r_w_r/api/api_model/user_model/my_profile_model.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../../../api/api_service/countryStateProviderService.dart';
import '../../../../constants/color_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/color.dart';
import '../../../../utils/common_utils.dart';
import '../../../components/app_loader.dart';
import '../../../features/vehicles/presentation/pages/add_new_vehicle_screen.dart';
import '../../block/language/language_provider.dart';
import '../../block/provider/profile_provider.dart' show ProfileProvider;
import '../../widgets/common_submit_button.dart';

class DriverProfileForm extends StatefulWidget {
  final MyProfileData? profile;
  final VoidCallback onUpdate;

  const DriverProfileForm({
    super.key,
    required this.profile,
    required this.onUpdate,
  });

  @override
  State<DriverProfileForm> createState() => _DriverProfileFormState();
}

class _DriverProfileFormState extends State<DriverProfileForm> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _experienceController = TextEditingController();
  final _minChargeController = TextEditingController();
  final _aboutController = TextEditingController();
  bool isNegotiable = false;
  String? _selectedCity;
  String? _selectedState;
  String? _selectedSeatingCount;
  List<String> seatingList = [];
  List<String> selectedServiceLocations = [];
  List<String> selectedSpokenLanguages = [];
  List<String> vehicleImagesList = [];
  List<String> vehicleVideosList = [];
  List<cM.Data> _cityList = [];

  List<sm.Data> _stateList = [];
  String? currentCountry;
  bool submittingForm = false;

  int totalVehicles = 0;
  List<File> _vehicleImages = [];
  List<String> _vehicleImagesServer = [];
  List<File> _vehicleVideos = [];
  List<String> _vehicleVideosServer = [];
  MyProfileData? profile;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
       profile = await getProfile();
      _initializeLocation();
    });
  }

  List<lm.Data> langData = [];

  Future<void> _initializeLocation() async {
    final langProvider = Provider.of<LocationProvider>(context, listen: false);
    currentCountry =
        langProvider.selectedCountry ?? ApiConstants.defaultCountryCodeInd;

    await langProvider.fetchStates(currentCountry!);
    _stateList = langProvider.states;
    final languageProvider =
    Provider.of<LanguageProvider>(context, listen: false);
    langData = languageProvider.language ?? [];
    await langProvider.fetchCity(_selectedState??"");
    _cityList=langProvider.cities;
    setState(() {
    });
  /*  await langProvider.fetchCity(stateData?.sId ?? "");
    if (mounted) {
      setState(() {
        _cityList = langProvider.cities;
      });
    }*/
  }

  @override
  Widget build(BuildContext context) {
    double boxWidth = 36;
    double boxHeight = 43;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            "Name",
            _nameController,
          ),
          SizedBox(height: 20),
          _buildTextField(
            "Mobile Number",
            _mobileController,
            isReadOnly: true,
            validator: _validateMobileNumber,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 20),
          _buildTextField("Address", _addressController),
          SizedBox(height: 20),
          _buildTextField(
            'Pin Code',
            _pinCodeController,
            placeholder: '788799',
            validator: _validatePincode,
            inputFormater: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
            maxLength: 6,
          ),
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
            value == null ? 'Please select a city' : null,
          ),
          SizedBox(height: 20),
          _buildTextField(
            'Vehicle Number',
            _vehicleNoController,
            placeholder: '',
            inputFormater: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          _buildTextField(
            'Experience',
            _experienceController,
            placeholder: '',
            inputFormater: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 20),
          Text(
            'Minimum Charge Per Hour',
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _minChargeController,
                  keyboardType: TextInputType.number,
                  style: CommonUtils.commonInputTextStyle(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.commonBorderColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.commonBorderColor,
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.commonBorderColor,
                        width: 1,
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: AppColors.commonBorderColor,
                        width: 1,
                      ),
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
                      value: false,
                      groupValue: isNegotiable,
                      toggleable: true,
                      onChanged: (value) {
                        setState(() {
                          isNegotiable = value!;
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    Text(
                      'Negotiable',
                      style: CommonUtils.commonTextLabelsStyle(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          _buildDropdown(
            'Seating Capacity',
            _selectedSeatingCount,
            seatingList
                .map((value) => DropdownMenuItem(
              value: value,
              child: Text(value),
            ))
                .toList(),
                (newValue) {
              setState(() {
                _selectedSeatingCount = newValue;
                _cityController.text = newValue ?? '';
              });
            },
            validator: (value) =>
            value == null ? 'Please seating capacity' : null,
          ),
          SizedBox(height: 20),
          _googlePlaceSearch(),
          SizedBox(height: 20),
          Text(
            "Select Spoken Languages",
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          const SizedBox(height: 8),
          _languageMultiSelectDropdown(),
          SizedBox(height: 20),
          _buildFileUploadSection(
            title: 'Upload Vehicle Image',
            files: _vehicleImages,
            filesServer: _vehicleImagesServer,
            onAddFile: () => _pickImage('vehicle'),
            onRemoveFile: (index) => _removeFile('vehicle', index),
            fileType: 'image',
          ),
          SizedBox(height: 20),
          _buildFileUploadSection(
            title: 'Upload Vehicle Video',
            files: _vehicleVideos,
            filesServer: _vehicleVideosServer,
            onAddFile: () => _pickVideo(),
            onRemoveFile: (index) => _removeFile('video', index),
            fileType: 'video',
          ),
          SizedBox(height: 20),
          _buildAboutTextField("About", _aboutController),
          const SizedBox(height: 20),
          Container(
            alignment: Alignment.center,
            child: CommonSubmitButton(
              gradientColors: [gradientFirst, gradientSecond],
              onPressed: () {
                if (isValidated()) _updateProfile();
              },
              text: "Update",
              borderRadius: 12,
              isLoading: _submitting,
            ),
          ),
        ],
      ),
    );
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
      }
    });
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

  Widget _buildFileUploadSection({
    required String title,
    required List<File> files,
    required List<String> filesServer,
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
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          const SizedBox(height: 8),
          Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: onAddFile,
              child: DottedBorder(
                options: RoundedRectDottedBorderOptions(
                  color: Color(0x80000000),
                  strokeWidth: 1,
                  dashPattern: [5, 2],
                  radius: Radius.circular(6),
                ),
                child: SizedBox(
                  width: 75,
                  height: 75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add, color: Colors.black, size: 16),
                      Text(
                        'Add',
                        style: CommonUtils.commonTextLabelsStyle(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            if (files.isNotEmpty)
              Expanded(
                child: SizedBox(
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
              ),
            const SizedBox(width: 8),
            if (filesServer.isNotEmpty)
              Expanded(
                child: SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: filesServer.length,
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
                                child: CachedNetworkImage(
                                  imageUrl: filesServer[index],
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
              ),
          ]),
        ],
      ),
    );
  }

  bool _isDropdownOpen = false;
  List<String> langIds = [];
  List<String> _selectedLangs = [];

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
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedLangs.isEmpty
                        ? 'Select languages'
                        : '${_selectedLangs.length} selected',
                    style: TextStyle(
                      fontFamily: AppConstants.ptSansFont,
                      fontSize: 14,
                      color:
                      _selectedLangs.isEmpty ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                Icon(
                  _isDropdownOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: Colors.grey.shade400,
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
                final isSelected = _selectedLangs.contains(language.name);
                return CheckboxListTile(
                  contentPadding:
                  EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  value: isSelected,
                  title: Text(language.name!),
                  controlAffinity: ListTileControlAffinity.leading,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedLangs.add(language.name!);
                        langIds.add(language.id!);
                      } else {
                        _selectedLangs.remove(language.name);
                        langIds.remove(language.id);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 12),
        Wrap(
          spacing: 4,
          runSpacing: 0,
          alignment: WrapAlignment.start,
          children: _selectedLangs.map((item) {
            return Stack(
              children: [
                Container(
                  margin:
                  const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0x1F641BB4).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF641BB4).withOpacity(0.3),
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
                    ],
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () {
                      final newList = List<String>.from(_selectedLangs)
                        ..remove(item);
                      setState(() {
                        _selectedLangs = newList;
                      });
                    },
                    child: Padding(
                      padding: EdgeInsets.only(left: 10, right: 0, bottom: 5),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(Radius.circular(30)),
                            border: Border.all(color: Colors.black, width: 1)),
                        child: const Icon(
                          Icons.close,
                          size: 10,
                          color: Color(0xFF9C27B0),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }).toList(),
        ),

        /// Selected Chips
        /* Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _selectedLangs.map((language) {
            return Chip(
              label: Text(language),
              deleteIcon: const Icon(Icons.close, size: 18),
              onDeleted: () {
                setState(() {
                  _selectedLangs.remove(language);
                });
              },
            );
          }).toList(),
        ),*/
      ],
    );
  }

  vehicleCountStyle() {
    return TextStyle(
      fontFamily: AppConstants.ptSansFont,
      fontWeight: FontWeight.w400,
      fontSize: 10,
      color: Color(0xFF9E9E9E),
    );
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

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        String? placeholder,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormater,
        TextInputType? keyboardType,
        int? maxLength,
        bool isReadOnly = false,
        Function(String)? onChanged,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: CommonUtils.commonInputBoxDecoration(),
          child: TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLength: maxLength,
            onChanged: onChanged,
            readOnly: isReadOnly,
            inputFormatters: inputFormater,
            style: CommonUtils.commonInputTextStyle(
                color: isReadOnly ? Colors.grey : Colors.black),
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
              hintStyle: CommonUtils.commonHintTextStyle(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutTextField(
      String label,
      TextEditingController controller, {
        String? placeholder,
        String? Function(String?)? validator,
        List<TextInputFormatter>? inputFormater,
        TextInputType? keyboardType,
        int? maxLength,
        bool isReadOnly = false,
        Function(String)? onChanged,
      }) {
    return Container(
      height: 140,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration:
      CommonUtils.commonInputBoxDecoration(color: Color(0x0A641BB4)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: CommonUtils.commonTitleStyle(
                weight: FontWeight.w700, fontSize: 16),
          ),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            maxLength: maxLength,
            onChanged: onChanged,
            readOnly: isReadOnly,
            inputFormatters: inputFormater,
            style: CommonUtils.commonInputTextStyle(
                size: 11,
                fWeight: FontWeight.w400,
                color: isReadOnly ? Colors.grey : Colors.black),
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
              hintStyle: CommonUtils.commonHintTextStyle(),
            ),
          )
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
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: value,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide:
              BorderSide(color: ColorConstants.inputFieldBorderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
              BorderSide(color: ColorConstants.inputFieldBorderColor),
            ),
          ),
          items: items,
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Future<MyProfileData?> getProfile() async {
    final profile = await TokenManager.getProfile();
    _selectedState = profile?.state?.id ?? "";
    _selectedCity = profile?.city?.id ?? "";

    _nameController.text =
    "${profile?.firstName ?? ""} ${profile?.lastName ?? ""}";
    _mobileController.text = profile?.mobileNumber ?? "";
    _addressController.text = profile?.address?.addressLine ?? "";
    _pinCodeController.text = "${profile?.address?.pincode ?? ""}";
    _aboutController.text = profile?.bio ?? "";
    if(profile?.vehicles!=null && profile!.vehicles.isNotEmpty) {
      _vehicleNoController.text = profile?.vehicles[0].vehicleNumber ?? "";
      _selectedSeatingCount =
          (profile?.vehicles[0].seatingCapacity ?? 0).toString();
    }
    _experienceController.text = (profile?.experience ?? 0).toString();
    _minChargeController.text = (profile?.minimumCharges ?? 0).toString();
    isNegotiable = profile?.negotiable ?? false;

    // selectedServiceLocations=(profile?.serviceLocation.[0].seatingCapacity??0).toString();

    return profile;
  }

  bool _submitting = false;

  Future<void> _updateProfile() async {
    final provider = context.read<ProfileProvider>();

    // Ensure we're in a loading state while updating
    if (mounted) {
      setState(() {
        _submitting = true;
      });
    }

    var profileData = {
      "firstName": _nameController.text.toString(),
      "address": widget.profile?.address?.copyWith(
          addressLine: _addressController.text.toString(),
          city: _selectedCity,
          state: _selectedState,
          pincode: int.parse(_pinCodeController.text.toString())),
    };

    try {
      final success =
      await context.read<ProfileProvider>().updateProfile(profileData);

      if (mounted) {
        if (success) {
          final localizations = AppLocalizations.of(context)!;

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Profile photo updated successfully"),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 2),
            ),
          );

          // Optional: Navigate back after a short delay
          // Uncomment the lines below if you want to automatically go back
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });
        } else {
          // Handle error case
          final provider = context.read<ProfileProvider>();
          final errorMessage = provider.error ?? 'Failed to update profile';

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 8),
                  Expanded(child: Text(errorMessage)),
                ],
              ),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(child: Text('An error occurred: ${e.toString()}')),
              ],
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  bool isValidated() {
    bool isValid = true;
    String errorMsg = "";
    if (_nameController.text.toString().trim().isEmpty) {
      isValid = false;
    } else if (_mobileController.text.toString().trim().isEmpty) {
      isValid = false;
    } else if (_addressController.text.toString().trim().isEmpty) {
      isValid = false;
    } else if (_pinCodeController.text.toString().trim().isEmpty) {
      isValid = false;
    } else if (_selectedState == null || _selectedState!.isEmpty) {
      isValid = false;
    } else if (_selectedCity == null || _selectedCity!.isEmpty) {
      isValid = false;
    } else if (_pinCodeController.text.toString().trim().isEmpty) {
      isValid = false;
    } else if (_vehicleNoController.text.toString().trim().isEmpty) {
      isValid = false;
    } else if (_experienceController.text.toString().trim().isEmpty) {
      isValid = false;
    } else if (_minChargeController.text.toString().trim().isEmpty) {
      isValid = false;
    } else if (selectedSpokenLanguages.isEmpty) {
      isValid = false;
    }
    if (errorMsg.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                  child: Text(errorMsg.isNotEmpty
                      ? errorMsg
                      : "Please enter all fields")),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
    return isValid;
  }

  final searchLocationController = TextEditingController();
  Timer? _searchDebounceTimer;

  _googlePlaceSearch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Service Locations",
          style: CommonUtils.commonTextLabelsStyle(),
        ),
        const SizedBox(height: 8),
        Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 16),
          decoration: CommonUtils.commonInputBoxDecoration(),
          child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
            Expanded(
              child: TextField(
                controller: searchLocationController,
                style: CommonUtils.commonTextLabelsStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: "Service Location",
                  border: InputBorder.none,
                  hintStyle: CommonUtils.commonHintTextStyle(),
                  suffixIcon: !isLoadingLocation &&
                      searchLocationController.text.isNotEmpty
                      ? IconButton(
                    icon: Icon(
                      Icons.cancel_outlined,
                      size: 16,
                    ),
                    onPressed: () {
                      searchLocationController.clear();
                      setState(() {
                        _suggestions.clear();
                        _showDropdown = false;
                      });
                    },
                  )
                      : null,
                ),
                onChanged: (value) {
                  _searchDebounceTimer?.cancel();
                  _searchDebounceTimer = Timer(
                    const Duration(milliseconds: 500),
                        () => _searchLocationsWithService(value),
                  );
                },
              ),
            ),
            if (isLoadingLocation)
              SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.purple,
                    strokeWidth: 1,
                  )),
            if (isLoadingLocation)
              SizedBox(
                width: 16,
              ),
            if (searchLocationController.text.toString().isEmpty) ...[
              Icon(
                Icons.arrow_drop_down,
                size: 24,
                color: Colors.grey.shade400,
              ),
              SizedBox(
                width: 14,
              ),
            ]
          ]),
        ),

        /// Dropdown
        if (_showDropdown)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              itemBuilder: (context, index) {
                final item = _suggestions[index];
                return ListTile(
                  title: Text(item.mainText),
                  subtitle: Text(item.secondaryText),
                  onTap: () {
                    searchLocationController.text = "";
                    selectedServiceLocations.add(item.mainText);
                    setState(() {
                      _showDropdown = false;
                    });

                    /// You now have placeId
                    print("Selected placeId: ${item.placeId}");
                  },
                );
              },
            ),
          ),
        if (selectedServiceLocations.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 4,
            runSpacing: 0,
            alignment: WrapAlignment.start,
            children: selectedServiceLocations.map((item) {
              return Stack(
                children: [
                  Container(
                    margin:
                    const EdgeInsets.symmetric(vertical: 4, horizontal: 2),
                    padding:
                    const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0x1F641BB4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF641BB4).withOpacity(0.3),
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
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () {
                        final newList =
                        List<String>.from(selectedServiceLocations)
                          ..remove(item);
                        setState(() {
                          selectedServiceLocations = newList;
                        });
                      },
                      child: Padding(
                        padding: EdgeInsets.only(left: 10, right: 0, bottom: 5),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                              BorderRadius.all(Radius.circular(30)),
                              border:
                              Border.all(color: Colors.black, width: 1)),
                          child: const Icon(
                            Icons.close,
                            size: 10,
                            color: Color(0xFF9C27B0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  List<PlaceSuggestion> _suggestions = [];
  bool _showDropdown = false;

  void _searchLocationsWithService(String value) async {
    final results = await searchPlaces(value);

    setState(() {
      _suggestions = results;
      _showDropdown = results.isNotEmpty;
    });
  }

  bool isLoadingLocation = false;

  Future<List<PlaceSuggestion>> searchPlaces(String input) async {
    if (input.isEmpty) return [];
    if (mounted) {
      setState(() {
        isLoadingLocation = true;
      });
    }
    final url = Uri.parse(
      'https://places.googleapis.com/v1/places:autocomplete',
    );

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-Goog-Api-Key': ApiConstants.apiKey,
        'X-Goog-FieldMask': 'suggestions.placePrediction',
      },
      body: jsonEncode({
        "input": input,
        "locationBias": {
          "rectangle": {
            "low": {"latitude": 6.0, "longitude": 68.0},
            "high": {"latitude": 36.0, "longitude": 98.0}
          }
        }
      }),
    );
    if (mounted) {
      setState(() {
        isLoadingLocation = false;
      });
    }
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['suggestions'] as List)
          .map((e) => PlaceSuggestion.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to fetch places');
    }
  }

  Future<void> _pickImage(String type) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _vehicleImages.add(File(image.path));
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
}
