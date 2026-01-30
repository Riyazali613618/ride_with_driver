import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rwd/api/api_model/user_model/my_profile_model.dart';

import 'package:rwd/api/api_model/stateModel.dart' as sm;
import 'package:rwd/constants/api_constants.dart';
import 'package:rwd/api/api_model/cityModel.dart' as cM;
import 'package:rwd/constants/token_manager.dart';
import '../../../../api/api_service/countryStateProviderService.dart';
import '../../../../constants/api_constants.dart';
import '../../../../constants/color_constants.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../utils/color.dart';
import '../../../../utils/common_utils.dart';
import '../../../block/provider/profile_provider.dart';
import '../../../widgets/common_submit_button.dart';

class ProfileForm extends StatefulWidget {
  final MyProfileData? profile;
  final VoidCallback onUpdate;

  const ProfileForm({
    super.key,
    required this.profile,
    required this.onUpdate,
  });

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _nameController = TextEditingController();
  final _mobileController = TextEditingController();
  final _addressController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _carCountController = TextEditingController();
  final _suvCountController = TextEditingController();
  final _miniVanCountController = TextEditingController();
  final _busCountController = TextEditingController();
  final _totalVehicleCountController = TextEditingController();
  final _aboutController = TextEditingController();
  String? _selectedCity;
  String? _selectedState;
  List<cM.Data> _cityList = [];
  List<sm.Data> _stateList = [];
  String? currentCountry;
  bool submittingForm = false;

  int totalVehicles = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      MyProfileData? profile = await getProfile();
      _selectedState = profile?.state?.id;
      _selectedCity = profile?.city?.id;
      _initializeLocation();
    });
  }

  Future<void> _initializeLocation() async {
    final langProvider = Provider.of<LocationProvider>(context, listen: false);
    currentCountry =
        langProvider.selectedCountry ?? ApiConstants.defaultCountryCodeInd;

    await langProvider.fetchStates(currentCountry!);
    _stateList = langProvider.states;

    await langProvider.fetchCity(_selectedState ?? "");
    if (mounted) {
      setState(() {
        _cityList = langProvider.cities;
      });
    }
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
            validator: (value) => value == null ? 'Please select a city' : null,
          ),
          SizedBox(height: 20),
          Text(
            'Vehicle Counts',
            style: CommonUtils.commonTextLabelsStyle(),
          ),
          SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(
              children: [
                Text(
                  "Car",
                  style: vehicleCountStyle(),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  child: Container(
                    width: boxWidth,
                    alignment: Alignment.center,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: ColorConstants.inputFieldBorderColor),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Center(
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLength: 2,
                        style: vehicleCountStyle(),
                        buildCounter: (
                          context, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) {
                          return null; // 👈 hides the counter
                        },
                        controller: _carCountController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          updateVehicleCount();
                        },
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration.collapsed(
                          hintText: '0',
                          hintStyle: vehicleCountStyle(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "SUV",
                  style: vehicleCountStyle(),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  child: Container(
                    width: boxWidth,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: ColorConstants.inputFieldBorderColor),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Center(
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLength: 2,
                        style: vehicleCountStyle(),
                        buildCounter: (
                          context, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) {
                          return null; // 👈 hides the counter
                        },
                        onChanged: (value) {
                          updateVehicleCount();
                        },
                        controller: _suvCountController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration.collapsed(
                          hintText: '0',
                          hintStyle: vehicleCountStyle(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Mini Van",
                  style: vehicleCountStyle(),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  child: Container(
                    width: boxWidth,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: ColorConstants.inputFieldBorderColor),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Center(
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLength: 2,
                        style: vehicleCountStyle(),
                        buildCounter: (
                          context, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) {
                          return null; // 👈 hides the counter
                        },
                        controller: _miniVanCountController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          updateVehicleCount();
                        },
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration.collapsed(
                          hintText: '0',
                          hintStyle: vehicleCountStyle(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  "Bus",
                  style: vehicleCountStyle(),
                ),
                SizedBox(width: 4),
                GestureDetector(
                  child: Container(
                    width: boxWidth,
                    height: boxHeight,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: ColorConstants.inputFieldBorderColor),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Center(
                      child: TextField(
                        textAlign: TextAlign.center,
                        maxLength: 2,
                        style: vehicleCountStyle(),
                        buildCounter: (
                          context, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) {
                          return null; // 👈 hides the counter
                        },
                        controller: _busCountController,
                        onChanged: (value) {
                          updateVehicleCount();
                        },
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration.collapsed(
                          hintText: '0',
                          hintStyle: vehicleCountStyle(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ]),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Total Number of Vehicles',
                          style: CommonUtils.commonTextLabelsStyle(),
                        ),
                        SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Vehicle Count Info'),
                                content: Text(
                                  'Tap on vehicle count boxes to increase count.\nLong press to decrease count.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.grey[400],
                            ),
                            child: Icon(
                              Icons.info_outline,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: ColorConstants.inputFieldBorderColor),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        textAlign: TextAlign.start,
                        maxLength: 2,
                        buildCounter: (
                          context, {
                          required int currentLength,
                          required bool isFocused,
                          required int? maxLength,
                        }) {
                          return null; // 👈 hides the counter
                        },
                        style: CommonUtils.commonInputTextStyle(),
                        readOnly: true,
                        controller: _totalVehicleCountController,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration.collapsed(
                          hintText: '0',
                          hintStyle: CommonUtils.commonHintTextStyle(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField("About", _aboutController),
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

  String? _validateMobileNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Mobile number is required';
    }
    if (value.length != 10 || !RegExp(r'^[0-9]{10}$').hasMatch(value)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  vehicleCountStyle() {
    return TextStyle(
      fontFamily: AppConstants.ptSansFont,
      fontWeight: FontWeight.w400,
      fontSize: 10,
      color: Color(0xFF9E9E9E),
    );
  }

  void updateVehicleCount() {
    int car = _carCountController.text.toString().isNotEmpty
        ? int.parse(_carCountController.text.toString())
        : 0;
    int bus = _busCountController.text.toString().isNotEmpty
        ? int.parse(_busCountController.text.toString())
        : 0;
    int van = _miniVanCountController.text.toString().isNotEmpty
        ? int.parse(_miniVanCountController.text.toString())
        : 0;
    int suv = _suvCountController.text.toString().isNotEmpty
        ? int.parse(_suvCountController.text.toString())
        : 0;

    totalVehicles = car + bus + van + suv;
    _totalVehicleCountController.text = totalVehicles.toString();
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
    _suvCountController.text =
        (profile?.independentCarOwnerFleetSize?.suv ?? 0).toString();
    _miniVanCountController.text =
        (profile?.independentCarOwnerFleetSize?.minivans ?? 0).toString();
    _carCountController.text =
        (profile?.independentCarOwnerFleetSize?.cars ?? 0).toString();
    _busCountController.text =
        (profile?.independentCarOwnerFleetSize?.bus ?? 0).toString();
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
    } else if (_totalVehicleCountController.text.toString().trim().isEmpty) {
      errorMsg = "Please select at lest one vehicle count";
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
}
