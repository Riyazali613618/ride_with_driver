// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:r_w_r/constants/api_constants.dart';
// import 'package:r_w_r/constants/token_manager.dart';
//
// import '../../../components/media_uploader_widget.dart';
// import '../../../constants/color_constants.dart';
//
// class DocumentVerificationCard extends StatefulWidget {
//   final String type; // 'AADHAR_IMAGE' or 'DRIVING_LICENSE_IMAGE'
//   final String kind;
//   final String? frontImageUrl;
//
//   final String? backImageUrl; // Only for Aadhaar
//   final String name;
//   final VoidCallback? onVerificationSuccess;
//   final ValueChanged<String>? onError;
//   final ValueChanged<String>? onFrontImageUploaded;
//   final ValueChanged<String>? onBackImageUploaded;
//   final bool isVerified;
//
//   const DocumentVerificationCard({
//     super.key,
//     required this.type,
//     required this.kind,
//     required this.name,
//     this.frontImageUrl,
//     this.backImageUrl,
//     this.onVerificationSuccess,
//     this.onError,
//     this.onFrontImageUploaded,
//     this.onBackImageUploaded,
//     this.isVerified = false,
//   });
//
//   @override
//   State<DocumentVerificationCard> createState() =>
//       _DocumentVerificationCardState();
// }
//
// class _DocumentVerificationCardState extends State<DocumentVerificationCard> {
//   bool _isVerifying = false;
//   late bool _isVerified;
//   String? _errorMessage;
//   String? _frontImageUrl;
//   String? _backImageUrl;
//
//   @override
//   void initState() {
//     super.initState();
//     _isVerified = widget.isVerified;
//     _frontImageUrl = widget.frontImageUrl;
//     _backImageUrl = widget.backImageUrl;
//   }
//
//   bool get _isFormValid {
//     if (widget.type == 'AADHAR_IMAGE') {
//       return _frontImageUrl != null &&
//           _backImageUrl != null &&
//           widget.name.isNotEmpty;
//     } else {
//       return _frontImageUrl != null && widget.name.isNotEmpty;
//     }
//   }
//
//   Future<void> _verifyImages() async {
//     if (!_isFormValid) return;
//
//     setState(() {
//       _isVerifying = true;
//       _errorMessage = null;
//     });
//
//     try {
//       final baseUrl = ApiConstants.baseUrl;
//       final url = Uri.parse('$baseUrl/user/register/verify');
//       final Map<String, dynamic> requestBody;
//       final token = await TokenManager.getToken();
//
//       if (widget.type == 'AADHAR_IMAGE') {
//         requestBody = {
//           "TYPE": "AADHAR_IMAGE",
//           "image": _frontImageUrl,
//           "back_image": _backImageUrl,
//           "name": widget.name,
//         };
//       } else {
//         requestBody = {
//           "TYPE": "DRIVING_LICENSE_IMAGE",
//           "image": _frontImageUrl,
//           "name": widget.name,
//         };
//       }
//
//       final response = await http
//           .post(
//             url,
//             headers: {
//               'Content-Type': 'application/json',
//               'Authorization': 'Bearer $token',
//             },
//             body: json.encode(requestBody),
//           )
//           .timeout(const Duration(seconds: 30));
//
//       final responseData = json.decode(response.body);
//
//       if (response.statusCode == 200) {
//         setState(() {
//           _isVerified = true;
//         });
//         widget.onVerificationSuccess?.call();
//         if (responseData['message'] != null) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(responseData['message']),
//               backgroundColor: Colors.green,
//             ),
//           );
//         }
//       } else {
//         throw Exception(responseData['message'] ?? 'Image verification failed');
//       }
//     } catch (e) {
//       setState(() {
//         _errorMessage = e.toString().replaceAll('Exception: ', '');
//       });
//       widget.onError?.call(_errorMessage!);
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text(
//               _errorMessage ?? 'An error occurred during image verification'),
//           backgroundColor: Colors.red,
//         ),
//       );
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isVerifying = false;
//         });
//       }
//     }
//   }
//
//   void _handleFrontImageUploaded(String url) {
//     setState(() {
//       _frontImageUrl = url;
//       _isVerified = false; // Reset verification if image changes
//     });
//     widget.onFrontImageUploaded?.call(url);
//   }
//
//   void _handleBackImageUploaded(String url) {
//     setState(() {
//       _backImageUrl = url;
//       _isVerified = false; // Reset verification if image changes
//     });
//     widget.onBackImageUploaded?.call(url);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(
//           color: _isVerified
//               ? ColorConstants.appColorGreen
//               : ColorConstants.greyLight,
//           width: 2,
//         ),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               children: [
//                 Icon(
//                   widget.type == 'AADHAR_IMAGE'
//                       ? Icons.credit_card
//                       : Icons.drive_eta,
//                   color: Theme.of(context).primaryColor,
//                 ),
//                 const SizedBox(width: 8),
//                 Text(
//                   widget.type == 'AADHAR_IMAGE'
//                       ? 'Aadhaar Image Verification'
//                       : 'DL Image Verification',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           // Front Image Uploader
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 8.0),
//             child: MediaUploader(
//               label: widget.type == 'AADHAR_IMAGE'
//                   ? 'Aadhaar Front Photo'
//                   : 'Driving License Photo',
//               kind: widget.kind,
//               showPreview: true,
//               showDirectImage: false,
//               initialUrl: _frontImageUrl,
//               onMediaUploaded: _handleFrontImageUploaded,
//               required: true,
//               allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
//             ),
//           ),
//
//           // Back Image Uploader (only for Aadhaar)
//           if (widget.type == 'AADHAR_IMAGE') ...[
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 8.0),
//               child: MediaUploader(
//                 label: 'Aadhaar Back Photo',
//                 kind: widget.kind,
//                 showPreview: true,
//                 showDirectImage: false,
//                 initialUrl: _backImageUrl,
//                 onMediaUploaded: _handleBackImageUploaded,
//                 required: true,
//                 allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
//               ),
//             ),
//           ],
//
//           if (_isVerified)
//             Container(
//               width: double.infinity,
//               decoration: BoxDecoration(
//                 color: ColorConstants.appColorGreen.withAlpha(180),
//                 borderRadius: BorderRadius.only(
//                     bottomLeft: Radius.circular(8),
//                     bottomRight: Radius.circular(8)),
//               ),
//               child: Center(
//                 child: Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         'Successfully Verified',
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                       SizedBox(
//                         width: 10,
//                       ),
//                       Icon(Icons.verified, color: Colors.white)
//                     ],
//                   ),
//                 ),
//               ),
//             )
//           else
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   backgroundColor: _isFormValid && !_isVerifying
//                       ? Theme.of(context).primaryColor
//                       : Colors.grey[400],
//                 ),
//                 onPressed: _isVerifying || !_isFormValid ? null : _verifyImages,
//                 child: _isVerifying
//                     ? const SizedBox(
//                         height: 20,
//                         width: 20,
//                         child: CircularProgressIndicator(
//                           color: Colors.white,
//                           strokeWidth: 2,
//                         ),
//                       )
//                     : const Text(
//                         'Verify Images',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.white,
//                         ),
//                       ),
//               ),
//             ),
//
//           if (_errorMessage != null && !_isVerified)
//             Padding(
//               padding: const EdgeInsets.only(top: 8.0),
//               child: Text(
//                 _errorMessage!,
//                 style: const TextStyle(color: Colors.red),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../../components/media_uploader_widget.dart';
import '../../../constants/color_constants.dart';

class DocumentVerificationCard extends StatefulWidget {
  final String type; // 'AADHAR_IMAGE' or 'DRIVING_LICENSE_IMAGE'
  final String kind;
  final String? frontImageUrl;
  final String? backImageUrl; // Only for Aadhaar
  final String name;
  final VoidCallback? onVerificationSuccess;
  final ValueChanged<String>? onError;
  final ValueChanged<String>? onFrontImageUploaded;
  final ValueChanged<String>? onBackImageUploaded;
  final bool isVerified;

  const DocumentVerificationCard({
    super.key,
    required this.type,
    required this.kind,
    required this.name,
    this.frontImageUrl,
    this.backImageUrl,
    this.onVerificationSuccess,
    this.onError,
    this.onFrontImageUploaded,
    this.onBackImageUploaded,
    this.isVerified = false,
  });

  @override
  State<DocumentVerificationCard> createState() =>
      _DocumentVerificationCardState();
}

class _DocumentVerificationCardState extends State<DocumentVerificationCard> {
  String? _frontImageUrl;
  String? _backImageUrl;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    print("DocumentVerificationCard initState - type: ${widget.type}");
    print("DocumentVerificationCard initState - frontImageUrl: ${widget.frontImageUrl}");
    print("DocumentVerificationCard initState - backImageUrl: ${widget.backImageUrl}");
    _frontImageUrl = widget.frontImageUrl;
    _backImageUrl = widget.backImageUrl;
    _validateImages();
  }

  void _validateImages() {
    print("DocumentVerificationCard _validateImages called");
    print("DocumentVerificationCard _validateImages - frontImageUrl: $_frontImageUrl");
    print("DocumentVerificationCard _validateImages - backImageUrl: $_backImageUrl");
    print("DocumentVerificationCard _validateImages - type: ${widget.type}");

    setState(() {
      if (widget.type == 'AADHAR_IMAGE') {
        if (_frontImageUrl == null && _backImageUrl == null) {
          _validationError = 'Please upload both front and back images of Aadhaar card';
        } else if (_frontImageUrl == null) {
          _validationError = 'Please upload front image of Aadhaar card';
        } else if (_backImageUrl == null) {
          _validationError = 'Please upload back image of Aadhaar card';
        } else {
          _validationError = null;
        }
      } else {
        if (_frontImageUrl == null) {
          _validationError = 'Please upload driving license image';
        } else {
          _validationError = null;
        }
      }
    });

    print("DocumentVerificationCard _validateImages - validationError: $_validationError");
  }

  void _handleFrontImageUploaded(String url) {
    print("DocumentVerificationCard _handleFrontImageUploaded - url: $url");
    setState(() {
      _frontImageUrl = url;
    });
    _validateImages();
    print("DocumentVerificationCard _handleFrontImageUploaded - calling callback");
    widget.onFrontImageUploaded?.call(url);
  }

  void _handleBackImageUploaded(String url) {
    print("DocumentVerificationCard _handleBackImageUploaded - url: $url");
    setState(() {
      _backImageUrl = url;
    });
    _validateImages();
    print("DocumentVerificationCard _handleBackImageUploaded - calling callback");
    widget.onBackImageUploaded?.call(url);
  }

  @override
  Widget build(BuildContext context) {
    print("DocumentVerificationCard build called");
    print("DocumentVerificationCard build - validationError: $_validationError");
    print("DocumentVerificationCard build - frontImageUrl: $_frontImageUrl");
    print("DocumentVerificationCard build - backImageUrl: $_backImageUrl");

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
          color: ColorConstants.greyLight,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Icon(
                  widget.type == 'AADHAR_IMAGE'
                      ? Icons.credit_card
                      : Icons.drive_eta,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  widget.type == 'AADHAR_IMAGE'
                      ? 'Upload Aadhaar Images'
                      : 'Upload Driving License Image',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Front Image Uploader
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: MediaUploader(
              label: widget.type == 'AADHAR_IMAGE'
                  ? 'Aadhaar Front Photo'
                  : 'Driving License Photo',
              kind: widget.kind,
              showPreview: true,
              showDirectImage: false,
              initialUrl: _frontImageUrl,
              onMediaUploaded: _handleFrontImageUploaded,
              required: true,
              allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
            ),
          ),

          // Back Image Uploader (only for Aadhaar)
          if (widget.type == 'AADHAR_IMAGE') ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: MediaUploader(
                label: 'Aadhaar Back Photo',
                kind: widget.kind,
                showPreview: true,
                showDirectImage: false,
                initialUrl: _backImageUrl,
                onMediaUploaded: _handleBackImageUploaded,
                required: true,
                allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Validation Error Message
          if (_validationError != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _validationError!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}