import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../constants/color_constants.dart';
import '../l10n/app_localizations.dart';
import '../screens/block/provider/profile_provider.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String? Function(String?)? validator;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final TextInputType keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final Widget? prefix;
  final Widget? suffix;
  final bool showLabel;
  final EdgeInsetsGeometry? contentPadding;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final Color? fillColor;
  final double borderRadius;
  final bool isPhoneField;
  final String? profileField;
  int? maxLength;
  TextCapitalization? textCapitalization;
  final bool autoFillFromProfile;

  final List<TextInputFormatter>? inputFormatters; // ✅ NEW LINE

  CustomTextField({
    super.key,
    required this.controller,
    required this.label,
    this.validator,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.enabled = true,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.suffixIcon,
    this.prefixIcon,
    this.prefix,
    this.suffix,
    this.maxLines = 1,
    this.minLines,
    this.showLabel = true,
    this.contentPadding,
    this.onTap,
    this.onChanged,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.fillColor,
    this.borderRadius = 5.0,
    this.isPhoneField = false,
    this.profileField,
    this.autoFillFromProfile = false,
    this.inputFormatters, // ✅ NEW PARAM
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;
  bool _hasError = false;
  String? _errorText;
  bool _hasFilledFromProfile = false;

  @override
  void initState() {
    super.initState();
    _validateInput(widget.controller.text);
    widget.controller.addListener(_onTextChanged);

    if (widget.autoFillFromProfile && widget.profileField != null) {
      _fillFromProfile();
    }
  }

  void _fillFromProfile() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);

      if (widget.controller.text.isEmpty &&
          profileProvider.profileData != null &&
          !_hasFilledFromProfile) {
        String? profileValue;

        switch (widget.profileField) {
          case 'phone':
            profileValue = profileProvider.phoneNumber;
            break;
          case 'name':
            profileValue = profileProvider.fullName;
            break;
          case 'firstName':
            profileValue = profileProvider.fullName;
            break;
          case 'email':
            profileValue = profileProvider.email;
            break;
          default:
            profileValue =
                profileProvider.getProfileField(widget.profileField!);
        }

        if (profileValue != null && profileValue.isNotEmpty) {
          widget.controller.text = profileValue;
          _hasFilledFromProfile = true;
          _validateInput(profileValue);
        }
      }
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _validateInput(widget.controller.text);
  }

  void _validateInput(String text) {
    String? error;
    if (widget.isPhoneField) {
      error = _validateIndianPhoneNumber(text);
    } else if (widget.validator != null) {
      error = widget.validator!(text);
    }

    if (error != _errorText) {
      setState(() {
        _errorText = error;
        _hasError = error != null && error.isNotEmpty;
      });
    }
  }

  String? _validateIndianPhoneNumber(String? value) {
    final localizations = AppLocalizations.of(context)!;

    if (value == null || value.isEmpty) {
      return localizations.phone_number_10_digits;
    }

    final cleanedNumber = value.replaceAll(RegExp(r'[^0-9]'), '');
    final phoneRegExp = RegExp(r'^[6-9]\d{9}$');

    if (!phoneRegExp.hasMatch(cleanedNumber)) {
      return localizations.phone_number_10_digits;
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, child) {
        if (widget.autoFillFromProfile &&
            widget.profileField != null &&
            widget.controller.text.isEmpty &&
            profileProvider.profileData != null &&
            !_hasFilledFromProfile) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _fillFromProfile();
          });
        }

        Color borderColor = Colors.grey.shade300;
        double borderWidth = 1.0;

        if (!widget.enabled) {
          borderColor = Colors.grey.shade200;
        } else if (_hasError) {
          borderColor = Colors.red.shade500;
          borderWidth = _isFocused ? 1.5 : 1.0;
        } else if (_isFocused) {
          borderColor = ColorConstants.primaryColor;
          borderWidth = 1.5;
        }

        Widget? profileAwareSuffixIcon = widget.suffixIcon;
        if (widget.autoFillFromProfile &&
            _hasFilledFromProfile &&
            widget.suffixIcon == null) {
          profileAwareSuffixIcon = Icon(
            Icons.person_outline,
            color: ColorConstants.primaryColor,
            size: 18,
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showLabel) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0, left: 4.0, top: 0),
                child: Row(
                  children: [
                    Text(
                      widget.label,
                      style: widget.labelStyle ??
                          TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: ColorConstants.black.withAlpha(150),
                            letterSpacing: 0.2,
                          ),
                    ),
                    if (widget.validator != null || widget.isPhoneField) ...[
                      const SizedBox(width: 4),
                      Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
            Container(
              constraints: BoxConstraints(
                minHeight: 40,
                maxHeight: widget.maxLines == 1 ? 48 : double.infinity,
              ),
              decoration: BoxDecoration(
                color: widget.enabled
                    ? (widget.fillColor ?? Colors.white)
                    : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: borderColor,
                  width: borderWidth,
                ),
                boxShadow: [
                  BoxShadow(
                    color: ColorConstants.primaryColor.withAlpha(80),
                    blurRadius: 2,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Focus(
                onFocusChange: (hasFocus) {
                  setState(() {
                    _isFocused = hasFocus;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    if (widget.prefixIcon != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0),
                        child: widget.prefixIcon!,
                      ),
                    ],
                    if (widget.prefix != null) ...[
                      Padding(
                        padding: EdgeInsets.only(
                          left: widget.prefixIcon != null ? 8.0 : 16.0,
                        ),
                        child: widget.prefix!,
                      ),
                    ],
                    Expanded(
                      child: Padding(
                        padding: widget.contentPadding ??
                            EdgeInsets.symmetric(
                              horizontal: (widget.prefixIcon != null ||
                                      widget.prefix != null)
                                  ? 8.0
                                  : 16.0,
                              vertical: widget.maxLines == 1 ? 0 : 12.0,
                            ),
                        child: TextFormField(
                          
                          textCapitalization: widget.textCapitalization!,
                          maxLength: widget.maxLength,
                          controller: widget.controller,
                          keyboardType: widget.isPhoneField
                              ? TextInputType.phone
                              : widget.keyboardType,
                          obscureText: widget.obscureText,
                          enabled: widget.enabled,
                          maxLines: widget.maxLines,
                          minLines: widget.minLines,
                          onTap: widget.onTap,
                          onChanged: (value) {
                            _validateInput(value);
                            if (widget.onChanged != null) {
                              widget.onChanged!(value);
                            }
                          },
                          inputFormatters: widget.inputFormatters,
                          // ✅ NEW LINE
                          style: widget.textStyle ??
                              const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                                color: Colors.black,
                                letterSpacing: 0.3,
                              ),
                              
                          decoration: InputDecoration(
                            
                            hintText: widget.showLabel ? null : widget.label,
                            hintStyle: widget.hintStyle ??
                                TextStyle(
                                  color: Colors.grey.shade400,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.3,
                                ),
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            focusedErrorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            errorStyle: const TextStyle(height: 0, fontSize: 0),
                          ),
                        ),
                      ),
                    ),
                    if (widget.suffix != null) ...[
                      Padding(
                        padding: EdgeInsets.only(
                          right: profileAwareSuffixIcon != null ? 8.0 : 16.0,
                        ),
                        child: widget.suffix!,
                      ),
                    ],
                    if (profileAwareSuffixIcon != null) ...[
                      Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: profileAwareSuffixIcon,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            if (_hasError && _errorText != null)
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 1.0, left: 8.0),
                  child: Text(
                    _errorText!,
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 15),
          ],
        );
      },
    );
  }
}

class OneToEightInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;

    final value = int.tryParse(newValue.text);
    if (value == null || value < 1 || value > 8) {
      return oldValue; // Reject invalid input
    }

    return newValue;
  }
}
