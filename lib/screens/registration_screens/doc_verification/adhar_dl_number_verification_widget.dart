import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../../constants/color_constants.dart';

class VerificationCard extends StatefulWidget {
  final String type; // 'AADHAR' or 'DRIVING_LICENSE'
  final VoidCallback? onVerificationSuccess;
  final ValueChanged<String>? onError;
  final TextEditingController? aadhaarNumberController;
  final TextEditingController? dlNumberController;
  final TextEditingController? nameController;
  final TextEditingController? dobController;
  final bool isVerified; // Add this parameter

  const VerificationCard({
    super.key,
    required this.type,
    this.onVerificationSuccess,
    this.onError,
    this.aadhaarNumberController,
    this.dlNumberController,
    this.nameController,
    this.dobController,
    this.isVerified = false, // Default to false
  });

  @override
  State<VerificationCard> createState() => _VerificationCardState();
}

class _VerificationCardState extends State<VerificationCard> {
  final _formKey = GlobalKey<FormState>();
  bool _isVerifying = false;
  late bool _isVerified; // Remove initialization here

  String? _errorMessage;

  // Internal controllers as fallback
  late TextEditingController _internalAadhaarController;
  late TextEditingController _internalDLController;
  late TextEditingController _internalNameController;
  late TextEditingController _internalDobController;

  @override
  void initState() {
    super.initState();
    _isVerified = widget.isVerified;

    // Initialize controllers - use provided ones or create new
    _internalAadhaarController =
        widget.aadhaarNumberController ?? TextEditingController();
    _internalDLController =
        widget.dlNumberController ?? TextEditingController();
    _internalNameController = widget.nameController ?? TextEditingController();
    _internalDobController = widget.dobController ?? TextEditingController();

    // Add listeners to update button state
    _internalAadhaarController.addListener(_updateButtonState);
    _internalDLController.addListener(_updateButtonState);
    _internalNameController.addListener(_updateButtonState);
    _internalDobController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    // Only dispose internal controllers, not the ones passed in
    if (widget.aadhaarNumberController == null)
      _internalAadhaarController.dispose();
    if (widget.dlNumberController == null) _internalDLController.dispose();
    if (widget.nameController == null) _internalNameController.dispose();
    if (widget.dobController == null) _internalDobController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    if (mounted) {
      setState(() {});
    }
  }

  bool _validateAadhaar(String value) {
    // Aadhaar validation (12 digits, doesn't start with 0 or 1)
    if (value.isEmpty) return false;
    final aadhaarRegex = RegExp(r'^[2-9]{1}[0-9]{11}$');
    return aadhaarRegex.hasMatch(value);
  }

  bool _validateDLNumber(String value) {
    if (value.isEmpty) return false;
    final dlRegex = RegExp(r'^[a-zA-Z0-9]{5,}$');
    return dlRegex.hasMatch(value);
  }

  bool _validateName(String value) {
    // Name should have at least 3 characters
    if (value.isEmpty) return false;
    final nameRegex = RegExp(r'^[a-zA-Z ]{3,}$');
    return nameRegex.hasMatch(value);
  }

  bool _validateDob(String value) {
    // Basic date validation
    return value.isNotEmpty;
  }

  bool get _isFormValid {
    if (widget.type == 'AADHAR') {
      return _validateAadhaar(_internalAadhaarController.text) &&
          _validateName(_internalNameController.text);
    } else {
      return _validateDLNumber(_internalDLController.text) &&
          _validateName(_internalNameController.text) &&
          _validateDob(_internalDobController.text);
    }
  }

  Future<void> _verifyDetails() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    try {
      final baseUrl = ApiConstants.baseUrl;
      final url = Uri.parse('$baseUrl/user/register/verify');
      final Map<String, dynamic> requestBody;
      final token = await TokenManager.getToken();

      if (widget.type == 'AADHAR') {
        requestBody = {
          "TYPE": "AADHAR",
          "aadhaar_number": _internalAadhaarController.text,
          "nam": _internalNameController.text,
        };
      } else {
        requestBody = {
          "TYPE": "DRIVING_LICENSE",
          "dl_number": _internalDLController.text,
          "dob": _internalDobController.text,
          "name": _internalNameController.text,
        };
      }

      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: json.encode(requestBody),
          )
          .timeout(const Duration(seconds: 30));

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        setState(() {
          _isVerified = true;
        });
        widget.onVerificationSuccess?.call();
        if (responseData['message'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception(responseData['message'] ?? 'Verification failed');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
      widget.onError?.call(_errorMessage!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage ?? 'An error occurred'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _internalDobController.text =
          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: _isVerified
              ? ColorConstants.appColorGreen
              : ColorConstants.greyLight,
          width: 2,
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  widget.type == 'AADHAR' ? Icons.credit_card : Icons.drive_eta,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.type == 'AADHAR'
                      ? 'Aadhaar Verification'
                      : 'Driving License Verification',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (widget.type == 'AADHAR') ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _internalAadhaarController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  labelText: 'Enter Your Aadhaar Number',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withAlpha(150),
                      fontWeight: FontWeight.w600),
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // suffixIcon: _isVerified
                  //     ? const Icon(Icons.verified, color: Colors.green)
                  //     : null,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(12),
                ],
                enabled: !_isVerified,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter Aadhaar number';
                  }
                  if (!_validateAadhaar(value)) {
                    return 'Enter valid 12-digit Aadhaar';
                  }
                  return null;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _internalNameController,
                decoration: InputDecoration(
                  labelText: 'Name as on Aadhaar',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withAlpha(150),
                      fontWeight: FontWeight.w600),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                enabled: !_isVerified,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (!_validateName(value)) {
                    return 'Enter valid name (min 3 letters)';
                  }
                  return null;
                },
              ),
            ),
            if (_isVerified)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorConstants.appColorGreen.withAlpha(180),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Successfully Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.verified, color: Colors.white)
                      ],
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: _isFormValid
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                  ),
                  onPressed:
                      _isVerifying || !_isFormValid ? null : _verifyDetails,
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            if (_errorMessage != null && !_isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ] else ...[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _internalDLController,
                decoration: InputDecoration(
                  labelText: 'Enter Your Driving License Number',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withAlpha(150),
                      fontWeight: FontWeight.w600),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  prefixIcon: const Icon(Icons.numbers),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  // suffixIcon: _isVerified
                  //     ? const Icon(Icons.verified, color: Colors.green)
                  //     : null,
                ),
                inputFormatters: [
                  LengthLimitingTextInputFormatter(15),
                ],
                enabled: !_isVerified,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter DL number';
                  }
                  if (!_validateDLNumber(value)) {
                    return 'Enter valid DL number';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _internalNameController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  labelText: 'Name as on License',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withAlpha(150),
                      fontWeight: FontWeight.w600),
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                enabled: !_isVerified,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  if (!_validateName(value)) {
                    return 'Enter valid name (min 3 letters)';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                controller: _internalDobController,
                decoration: InputDecoration(
                  labelText: 'Date of Birth',
                  labelStyle: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.withAlpha(150),
                      fontWeight: FontWeight.w600),
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                  prefixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_month),
                    onPressed: !_isVerified ? () => _selectDate(context) : null,
                  ),
                ),
                readOnly: true,
                enabled: !_isVerified,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select date of birth';
                  }
                  return null;
                },
                onTap: !_isVerified ? () => _selectDate(context) : null,
              ),
            ),
            if (_isVerified)
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: ColorConstants.appColorGreen.withAlpha(180),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Successfully Verified',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Icon(Icons.verified, color: Colors.white)
                      ],
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    backgroundColor: _isFormValid
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                  ),
                  onPressed:
                      _isVerifying || !_isFormValid ? null : _verifyDetails,
                  child: _isVerifying
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Verify',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            if (_errorMessage != null && !_isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ]),
      ),
    );
  }
}
