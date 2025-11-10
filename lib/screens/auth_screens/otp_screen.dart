import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/screens/auth_screens/not_allowed.dart';
import 'package:r_w_r/screens/layout.dart';

import '../../api/api_service/countryStateProviderService.dart';
import '../../api/api_service/verify_otp_service.dart';
import '../../components/app_appbar.dart';
import '../../components/app_button.dart';
import '../../components/app_snackbar.dart';
import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/color.dart';
import '../block/language/language_provider.dart';
import '../common_screens/language_screen.dart';
import 'first_time_user.dart';

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final String countryId;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.countryId,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final List<TextEditingController> _otpControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    4,
    (_) => FocusNode(),
  );
  final VerifyOtpService _apiService = VerifyOtpService();

  bool _resendLoading = false;
  bool _verifyLoading = false;
  final bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    if (kDebugMode) {
      print(
          "OTP Verification Screen initialized for number: ${widget.phoneNumber}");
    }
    LocationProvider().setCountry(widget.countryId);
  }

  @override
  void dispose() {
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleOtpSubmission() async {
    final localizations = AppLocalizations.of(context)!;
    final langProvider = Provider.of<LanguageProvider>(context, listen: false);
    final enteredOtp =
        _otpControllers.map((controller) => controller.text).join();
    if (enteredOtp.length != 4) {
      CustomSnackBar.showCustomSnackBar(
        context: context,
        message: localizations.enter_all_4_digits,
        success: false,
      );
      return;
    }
    setState(() => _verifyLoading = true);
    try {
      if (!mounted) return;
      final response = await _apiService.verifyOtp(
          widget.phoneNumber,
          enteredOtp,
          (langProvider.langCode != null && langProvider.langCode!.isNotEmpty)
              ? '${langProvider.langCode}'
              : '68d4052ce5417ced85c8b0fd',
          '${widget.countryId}');
      print("verifyOtp${langProvider.langCode!.isEmpty} ${widget.countryId}");
      if (response.success == true && response.data != null) {
        // Check if user is allowed
        print("isAllowed:${response.data!.isAllowed}");
        if (response.data != null && !response.data!.isAllowed!) {
          if (!mounted) return;
          setState(() => _verifyLoading = false);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  NotAllowed(message: response.data!.message!),
            ),
          );
          return;
        }

        // Save authentication data
        await TokenManager.saveToken(response.data!.accessToken!);
        await TokenManager.saveRefreshToken(response.data!.refreshToken!);
        await TokenManager.savePhoneNumber(widget.phoneNumber);
        final userDataMap = {
          'name': response.data!.name,
          // 'isRegisteredAsDriver': response.data!.is,
          // 'isRegisteredAsTransporter': response.data!.isRegisteredAsTransporter,
          'isAllowed': response.data!.isAllowed,
          'language': response.data!.language,
          'fcm': response.data!.fcm,
          'isFirstTimeUser': response.data!.isFirstTimeUser,
        };
        await TokenManager.saveUserData(userDataMap);
        // Handle first-time user flow
        if (response != null &&
            response.data != null &&
            response.data!.isFirstTimeUser!) {
          if (!mounted) return;
          final profileCompleted = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
                builder: (context) => const FirstTimeUserScreen()),
          );

          if (profileCompleted == true) {
            await _handleLanguageSelection();
            _navigateToHome();
          }
        }
        // Handle existing user flow
        else {
          if (response.data!.language == null) {
            await _handleLanguageSelection();
          }
          final languageProvider =
              Provider.of<LanguageProvider>(context, listen: false);
          languageProvider.setLangCode(response.data!.language!.id!);
          _navigateToHome();
        }
      } else {
        if (!mounted) return;
        setState(() => _verifyLoading = false);
        CustomSnackBar.showCustomSnackBar(
          context: context,
          message: response.message!.isNotEmpty
              ? response.message!
              : response.message!,
          success: false,
        );
        _clearOtpFields();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _verifyLoading = false);
      CustomSnackBar.showCustomSnackBar(
        context: context,
        message: localizations.failed_to_send_otp,
        success: false,
      );
      _clearOtpFields();
    }
  }

  Future<void> _handleLanguageSelection() async {
    final selectedLanguage = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.95,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => const LanguageSelectionScreen(),
      ),
    );

    if (selectedLanguage != null) {
      // Save the selected language
      final userData = await TokenManager.getUserData();
      if (userData != null) {
        userData['language'] = selectedLanguage;
        await TokenManager.saveUserData(userData);
      }
    }
  }

  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Layout()),
      (route) => false,
    );
  }

  void _clearOtpFields() {
    for (var controller in _otpControllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  void _resendCode() async {
    if (kDebugMode) {
      print("Resending OTP code...");
    }

    setState(() {
      _resendLoading = true;
    });

    try {
      final localizations = AppLocalizations.of(context)!;

      // Here you would make an API call to resend the OTP
      // For now, we'll just simulate it with a delay
      await Future.delayed(const Duration(seconds: 1));

      if (kDebugMode) {
        print("OTP resent successfully");
      }
      if (!mounted) return;
      setState(() {
        _resendLoading = false;
      });

      CustomSnackBar.showCustomSnackBar(
        context: context,
        message: localizations.otp_resent,
        success: true,
      );

      // Clear previous OTP fields when resending
      _clearOtpFields();
    } catch (e) {
      final localizations = AppLocalizations.of(context)!;

      if (kDebugMode) {
        print("Failed to resend OTP: $e");
      }

      setState(() {
        _resendLoading = false;
      });

      CustomSnackBar.showCustomSnackBar(
        context: context,
        message: localizations.failed_to_resend_otp,
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
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
            stops: [0.01, 0.25, 0.49, .95],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Stack(
              children: [
                SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Text(
                        localizations.verify_phone_number,
                        // 'Verify your phone number',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtitle
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          children: [
                            TextSpan(
                              text: localizations.enter_code_whatsapp,
                              // text:'Enter the code that was sent to your WhatsApp number\n',
                            ),
                            TextSpan(
                              text: " ${widget.phoneNumber}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),
                      // OTP input fields
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: List.generate(
                          4,
                          (index) => Padding(
                            padding: const EdgeInsets.only(right: 15.0),
                            child: _buildOtpField(index),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        localizations.did_not_receive_code,
                        // 'Did not receive the code?',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Resend code button
                      SizedBox(
                        height: 44,
                        child: OutlinedButton(
                          onPressed: _resendLoading ? null : _resendCode,
                          style: OutlinedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                            ),
                            side: BorderSide(color: Colors.black54, width: 2),
                          ),
                          child: _resendLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.grey),
                                  ),
                                )
                              : Text(
                                  localizations.resend_code,
                                  // 'Resend Code',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5.0, vertical: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _verifyLoading
                                ? Container(
                                    height: 56,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: ColorConstants.primaryColorLight,
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    child: const Center(
                                      child: SizedBox(
                                        height: 24,
                                        width: 24,
                                        child: CircularProgressIndicator(
                                          color: ColorConstants.primaryColor,
                                          strokeWidth: 2.5,
                                        ),
                                      ),
                                    ),
                                  )
                                : CustomButton(
                                    // text: 'Verify',
                                    text: localizations.log_in,
                                    onPressed: _handleOtpSubmission,
                                    backgroundColor: gradientFirst,
                                    isFullWidth: true,
                                    height: 56,
                                    borderRadius: 14,
                                    textColor: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                            const SizedBox(height: 18),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black54, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: _otpControllers[index],
        focusNode: _focusNodes[index],
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty) {
            if (index < 3) {
              _focusNodes[index + 1].requestFocus();
            } else {
              FocusScope.of(context).unfocus();
              _handleOtpSubmission();
            }
          }
        },
        onTap: () {
          _otpControllers[index].selection = TextSelection(
            baseOffset: 0,
            extentOffset: _otpControllers[index].text.length,
          );
        },
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}
