import 'package:flutter/material.dart';
import 'package:rwd/core/extension/buildcontext_extension.dart';
import 'package:rwd/utils/common_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/api_constants.dart';
import '../../constants/color_constants.dart';
import '../../constants/localstorage_keys.dart';
import '../../core/helper/country_phone_codes.dart';

class PhoneInputField extends StatefulWidget {
  final TextEditingController ctr;
  final bool inputPhone;
  final int length;
  final String? Function(String?)? validator;
  final int? maxlength;
  final GlobalKey<FormState>? formKey;
  final ValueChanged<CountryPhoneCode>? onCountryChanged;
  final ValueChanged<bool>? onValidationChanged;
  final CountryPhoneCode? initialCountry;

  const PhoneInputField(
      {super.key,
      this.formKey,
      this.validator,
      this.inputPhone = true,
      required this.ctr,
      required this.length,
      this.maxlength,
      this.onCountryChanged,
      this.onValidationChanged,
      this.initialCountry});

  @override
  PhoneInputFieldState createState() => PhoneInputFieldState();
}

class PhoneInputFieldState extends State<PhoneInputField> {
  CountryPhoneCode? selectedCountry;
  bool isValid = false;
  TextEditingController searchController = TextEditingController();
  List<CountryPhoneCode> filteredCountries = CountryPhoneCodes.allCountries;
  SharedPreferences? pref;

  @override
  void initState() {
    super.initState();
    getSelectedCountry();
    filteredCountries = CountryPhoneCodes.allCountries;

    // Initialize default country in SharedPreferences if not already set
    _initializeDefaultCountry();

    // Initial validation check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentLength = widget.ctr.text.length;
      isValid = selectedCountry?.isValidLength(currentLength) ?? false;
      widget.onValidationChanged?.call(isValid);
    });
  }

  void _initializeDefaultCountry() async {
    if (selectedCountry != null) {
      // Check if country code is already stored
      String? existingCountryCode =
          pref?.getString(LocalStorageKeys.countryCode.token);

      // If no country code is stored, store the default/selected country
      if (existingCountryCode == null || existingCountryCode.isEmpty) {
        await pref?.setString(
            LocalStorageKeys.countryCode.token,
            selectedCountry!
                .isoCountryCode // This stores Alpha-3 codes like "IDN"
            );
        await pref?.setString(
            'selectedCountryDialCode', selectedCountry!.dialCode);
        await pref?.setString(
            'selectedCurrencyCode', selectedCountry!.currencyCode);
      }
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        filteredCountries = CountryPhoneCodes.allCountries;
      } else {
        filteredCountries = CountryPhoneCodes.allCountries
            .where((country) =>
                country.countryName
                    .toLowerCase()
                    .contains(query.toLowerCase()) ||
                country.dialCode.contains(query) ||
                country.countryCode.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: TextFormField(
        controller: widget.ctr,
        maxLength: widget.maxlength,
        keyboardType:
            widget.inputPhone ? TextInputType.phone : TextInputType.name,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hint: Text(
            "0000000000",
            style: TextStyle(
                fontFamily: AppConstants.ptSansFont,
                color: Color(0xFF626262),
                fontSize: 16,
                fontWeight: FontWeight.w400),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: ColorConstants.primaryColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: ColorConstants.primaryColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                BorderSide(color: ColorConstants.primaryColor, width: 2),
          ),
          prefixIcon: widget.inputPhone
              ? Container(
                  margin: const EdgeInsets.only(left: 4.0),
                  child: _buildCountryCodeSelector(),
                )
              : null,
          suffixIcon: isValid
              ? const Icon(
                  Icons.check_circle,
                  color: Color(0xFF00C853), // Green checkmark color
                )
              : null,
        ),
        validator: widget.validator ??
            (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a phone number';
              }

              if (selectedCountry?.isValidLength(value.length) ?? false) {
                return null;
              }

              final minLength = selectedCountry?.phoneNumberLength ?? 10;
              final maxLength = selectedCountry?.maxPhoneNumberLength;

              if (maxLength != null && maxLength != minLength) {
                return 'Please enter a phone number with $minLength-$maxLength digits';
              } else {
                return 'Please enter a valid $minLength-digit phone number';
              }
            },
        style: CommonUtils.commonTitleStyle(fontSize: 16),
        onChanged: (phone) {
          setState(() {
            isValid = selectedCountry?.isValidLength(phone.length) ?? false;
          });
          widget.onValidationChanged?.call(isValid);
        },
      ),
    );
  }

  Widget _buildCountryCodeSelector() {
    return GestureDetector(
      onTap: _showCountryPicker,
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            color: Color(0x1F641BB4)),
        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        padding: const EdgeInsets.only(left: 8.0, top: 2, bottom: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              selectedCountry?.flag ?? '🇮🇳',
              style: const TextStyle(fontSize: 16),
            ),
            SizedBox(width: 4),
            Text(
              selectedCountry?.dialCode ?? '+91',
              style: TextStyle(
                  fontSize: 14,
                  fontFamily: AppConstants.ptSansFont,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            const Icon(
              Icons.arrow_drop_down_outlined,
              color: Color(0xFF4C4452),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker() {
    searchController.clear();
    filteredCountries = CountryPhoneCodes.allCountries;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.7,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Country',
                        style: context.textTheme.headlineSmall?.copyWith(
                          fontFamily: AppConstants.ptSansFont,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      hintText: 'Search country or code...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade500),
                      ),
                    ),
                    onChanged: (query) {
                      setModalState(() {
                        _filterCountries(query);
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredCountries.length,
                      itemBuilder: (context, index) {
                        final country = filteredCountries[index];
                        final isSelected =
                            country.countryCode == selectedCountry?.countryCode;

                        return ListTile(
                          leading: Text(
                            country.flag,
                            style: const TextStyle(fontSize: 24),
                          ),
                          title: Text(
                            country.countryName,
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontFamily: AppConstants.ptSansFont,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          trailing: Text(
                            country.dialCode,
                            style: context.textTheme.bodyMedium?.copyWith(
                              fontFamily: AppConstants.ptSansFont,
                              color: Colors.grey.shade600,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                          selected: isSelected,
                          selectedTileColor: context.colorSchema.primary
                              .withValues(alpha: 0.1),
                          onTap: () async {
                            final ctx = context; // Store context before async

                            setState(() {
                              selectedCountry = country;
                              // Re-validate current input with new country's length
                              isValid =
                                  country.isValidLength(widget.ctr.text.length);
                            });

                            // Store selected country information for API headers
                            await pref?.setString(
                                LocalStorageKeys.countryCode.token,
                                country
                                    .isoCountryCode // This stores Alpha-3 codes like "IDN"
                                );
                            await pref?.setString(
                                'selectedCountryDialCode', country.dialCode);
                            await pref?.setString(
                                'selectedCurrencyCode', country.currencyCode);

                            // Force update country to ensure it's properly set
                            await CountryPhoneCodes
                                .updateCountryFromPhoneNumber(country.dialCode);

                            widget.onCountryChanged?.call(country);
                            widget.onValidationChanged?.call(isValid);

                            if (mounted) {
                              Navigator.pop(ctx);
                            }
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> getSelectedCountry() async {
    selectedCountry =
        await (widget.initialCountry ?? CountryPhoneCodes.defaultCountry);
    pref = await SharedPreferences.getInstance();
  }
}
