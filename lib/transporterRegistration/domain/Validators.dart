// lib/features/transporter_registration/domain/validators/validators.dart
class Validators {
  static String? required(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? mobile(String? value) {
    if (value == null || value.isEmpty) return 'Mobile number is required';
    if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) return 'Invalid mobile number';
    return null;
  }

  static String? pincode(String? value) {
    if (value == null || !RegExp(r'^[0-9]{6}$').hasMatch(value)) {
      return 'Enter valid 6-digit pincode';
    }
    return null;
  }

  static String? gst(String? value) {
    if (value == null || value.isEmpty) return null;
    if (value.length != 15) return 'GSTIN must be exactly 15 characters';
    return null;
  }
}
