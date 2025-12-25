import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../api/api_service/countryStateProviderService.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/auth/auth_event.dart';
import '../../bloc/auth/auth_state.dart';
import '../../components/app_button.dart';
import '../../components/app_snackbar.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';
import '../block/language/language_provider.dart';
import 'otp_screen.dart';
import 'package:r_w_r/api/api_model/countryModel.dart' as cm;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+91';
  String? _errorMessage;
  bool _isPhoneValid = false;
  bool _isLoading = false;
  List<cm.Data> countryModel=[];
  LocationProvider locationProvider=LocationProvider();

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_validatePhoneNumber);
    fetchSelectedCountry();
  }

  void fetchSelectedCountry(){
    locationProvider.fetchCountries();
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber() {
    final phoneNumber = _phoneController.text;
    final localizations = AppLocalizations.of(context)!;
    setState(() {
      if (phoneNumber.isEmpty) {
        _errorMessage = null;
        _isPhoneValid = false;
      } else if (phoneNumber.length < 10) {
        _errorMessage = localizations.phone_number_10_digits;
        _isPhoneValid = false;
      } else if (!RegExp(r'^[0-9]+$').hasMatch(phoneNumber)) {
        _errorMessage = localizations.only_digits_allowed;
        _isPhoneValid = false;
      } else {
        _errorMessage = null;
        _isPhoneValid = true;
      }
    });
  }

  void _handleContinue() {
    if (!_isPhoneValid) return;
    // Get just the phone number without country code for the API
    final phoneNumber = _phoneController.text;
    countryModel=locationProvider.countries;
    for(var cm in countryModel){
      if(cm.dialCode==_selectedCountryCode){
        locationProvider.setSelectedCountry(cm.id!);
        break;
      }
    }
    // Trigger BLoC event
    context.read<AuthBloc>().add(SendOtpEvent(phoneNumber: phoneNumber));
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }

        if (state is OtpSentSuccess) {
          CustomSnackBar.showCustomSnackBar(
            context: context,
            message: state.message,
            success: true,
          );

          // Full phone number for the next screen
          final fullPhoneNumber = '$_selectedCountryCode${state.phoneNumber}';

          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => OtpVerificationScreen(
                phoneNumber: fullPhoneNumber,
                countryId:locationProvider.selectedCountry??"",
              ),
            ),
          );
        } else if (state is AuthError) {
          CustomSnackBar.showCustomSnackBar(
            context: context,
            message: state.message,
            success: false,
          );
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors:[
                gradientFirst,
                gradientSecond,
                gradientThird,
                Colors.white
              ],
              stops: [0.0, 0.15, 0.30, .90],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  Text(
                    localizations.log_in,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 105),
                  Row(
                    children: [
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: _errorMessage != null
                                ? ColorConstants.red
                                : gradientFirst,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            value: _selectedCountryCode,
                            items: ['+234', '+1', '+44', '+91', '+81', '+86']
                                .map((code) => DropdownMenuItem(
                              value: code,
                              child: Text(
                                code,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              ),
                            ))
                                .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedCountryCode = value;
                                  _validatePhoneNumber();
                                });
                              }
                            },
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Phone number input field
                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.black87,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              hintText: localizations.enter_mobile_number,
                              hintStyle: TextStyle(
                                color: Colors.grey[400],
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _errorMessage != null
                                      ? ColorConstants.red
                                      : gradientFirst,
                                  width: 2,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _errorMessage != null
                                      ? ColorConstants.red
                                      : gradientFirst,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(
                                  color: _errorMessage != null
                                      ? ColorConstants.red
                                      : gradientFirst,
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      _errorMessage ?? "",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                  if (_errorMessage != null) const SizedBox(height: 8),
                  const SizedBox(height: 22),
                  const SizedBox(height: 24),
                  if (_isLoading)
                    Center(
                        child: Container(
                            height: 50,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    color: ColorConstants.primaryColor,
                                  ),
                                ),
                              ],
                            )))
                  else
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: CustomButton(
                        text: localizations.continue_co,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        onPressed: _isPhoneValid && !_isLoading
                            ? _handleContinue
                            : () {
                          if (!_isPhoneValid) {
                            CustomSnackBar.showCustomSnackBar(
                              context: context,
                              message: localizations.enter_correct_phone,
                              success: false,
                            );
                          }
                        },
                        backgroundColor:gradientFirst,
                        textColor: Colors.white,
                        height: 56,
                        borderRadius: 15,
                        isFullWidth: true,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}