import 'package:flutter/material.dart';

import '../api/api_model/verification_model/document_model.dart';
import '../api/api_service/verification_service/document_verification_service.dart';

// Global verification state manager - Add this as a separate file or at the top
class DocumentVerificationStateManager {
  static final DocumentVerificationStateManager _instance =
      DocumentVerificationStateManager._internal();
  factory DocumentVerificationStateManager() => _instance;
  DocumentVerificationStateManager._internal();

  // Store verified documents globally
  final Map<String, DocumentVerificationState> _verifiedDocuments = {};

  static String _generateDocumentKey(
      String type, String number, String? imageUrl) {
    return '${type}_${number}_${imageUrl ?? 'no_image'}';
  }

  void markAsVerified(String type, String number, String? imageUrl) {
    final key = _generateDocumentKey(type, number, imageUrl);
    _verifiedDocuments[key] = DocumentVerificationState(
      isVerified: true,
      timestamp: DateTime.now(),
    );
  }

  void markAsFailed(
      String type, String number, String? imageUrl, String errorMessage) {
    final key = _generateDocumentKey(type, number, imageUrl);
    _verifiedDocuments[key] = DocumentVerificationState(
      isVerified: false,
      errorMessage: errorMessage,
      timestamp: DateTime.now(),
    );
  }

  DocumentVerificationState? getVerificationState(
      String type, String number, String? imageUrl) {
    final key = _generateDocumentKey(type, number, imageUrl);
    return _verifiedDocuments[key];
  }

  bool isVerified(String type, String number, String? imageUrl) {
    final state = getVerificationState(type, number, imageUrl);
    return state?.isVerified ?? false;
  }

  void clearVerificationState(String type, String number, String? imageUrl) {
    final key = _generateDocumentKey(type, number, imageUrl);
    _verifiedDocuments.remove(key);
  }

  void clearAllStates() {
    _verifiedDocuments.clear();
  }
}

class DocumentVerificationState {
  final bool isVerified;
  final String? errorMessage;
  final DateTime timestamp;

  DocumentVerificationState({
    required this.isVerified,
    this.errorMessage,
    required this.timestamp,
  });
}

class DocumentVerificationWidget extends StatefulWidget {
  final String documentType;
  final String documentNumber;
  final String? imageUrl;
  final String displayName;
  final VoidCallback? onPreviewPressed;
  final Function(bool isVerified, String? errorMessage)? onVerificationChanged;
  final bool initialVerificationStatus;
  final bool enableAutoVerification;
  final bool showPreviewButton;

  const DocumentVerificationWidget({
    Key? key,
    required this.documentType,
    required this.documentNumber,
    this.imageUrl,
    required this.displayName,
    this.onPreviewPressed,
    this.onVerificationChanged,
    this.initialVerificationStatus = false,
    this.enableAutoVerification = true,
    this.showPreviewButton = false,
  }) : super(key: key);

  @override
  State<DocumentVerificationWidget> createState() =>
      _DocumentVerificationWidgetState();
}

class _DocumentVerificationWidgetState
    extends State<DocumentVerificationWidget> {
  final DocumentVerificationStateManager _stateManager =
      DocumentVerificationStateManager();

  late DocumentVerificationModel _document;
  bool _mounted = true;
  bool _hasTriggeredAutoVerification = false;
  bool _isCurrentlyVerifying = false;

  @override
  void initState() {
    super.initState();
    _initializeDocumentState();

    // Trigger auto-verification only once after widget is built
    if (widget.enableAutoVerification) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _attemptAutoVerification();
      });
    }
  }

  @override
  void didUpdateWidget(DocumentVerificationWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Only reinitialize if document details changed
    if (oldWidget.documentType != widget.documentType ||
        oldWidget.documentNumber != widget.documentNumber ||
        oldWidget.imageUrl != widget.imageUrl) {
      _hasTriggeredAutoVerification = false;
      _initializeDocumentState();

      // Trigger auto-verification for new document
      if (widget.enableAutoVerification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _attemptAutoVerification();
        });
      }
    }
  }

  @override
  void dispose() {
    _mounted = false;
    super.dispose();
  }

  void _initializeDocumentState() {
    // Check global verification state first
    final globalState = _stateManager.getVerificationState(
      widget.documentType,
      widget.documentNumber,
      widget.imageUrl,
    );

    bool isVerified = false;
    String? errorMessage;
    bool hasAttemptedVerification = false;

    if (globalState != null) {
      // Use global verification state
      isVerified = globalState.isVerified;
      errorMessage = globalState.errorMessage;
      hasAttemptedVerification = true;
    } else if (widget.initialVerificationStatus) {
      // Use initial status and save to global state
      isVerified = true;
      hasAttemptedVerification = true;
      _stateManager.markAsVerified(
        widget.documentType,
        widget.documentNumber,
        widget.imageUrl,
      );
    }

    _document = DocumentVerificationModel(
      type: widget.documentType,
      number: widget.documentNumber,
      imageUrl: widget.imageUrl,
      isVerified: isVerified,
      hasAttemptedVerification: hasAttemptedVerification,
      errorMessage: errorMessage,
    );

    // Notify parent about current state
    if (hasAttemptedVerification && widget.onVerificationChanged != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onVerificationChanged?.call(isVerified, errorMessage);
      });
    }
  }

  void _attemptAutoVerification() {
    if (!_mounted ||
        _hasTriggeredAutoVerification ||
        _isCurrentlyVerifying ||
        !widget.enableAutoVerification) {
      return;
    }

    // Don't auto-verify if already verified globally
    if (_stateManager.isVerified(
        widget.documentType, widget.documentNumber, widget.imageUrl)) {
      _hasTriggeredAutoVerification = true;
      return;
    }

    // Check if document can be auto-verified
    if (_document.canAutoVerify && !_document.hasAttemptedVerification) {
      _hasTriggeredAutoVerification = true;
      debugPrint('Auto-verifying ${widget.displayName}...');
      _verifyDocument(isAutoVerification: true);
    } else {
      _hasTriggeredAutoVerification = true;
    }
  }

  Future<void> _verifyDocument({bool isAutoVerification = false}) async {
    if (!_mounted || _isCurrentlyVerifying) return;

    // Check if already verified globally
    if (_stateManager.isVerified(
        widget.documentType, widget.documentNumber, widget.imageUrl)) {
      debugPrint('Document ${widget.displayName} is already verified globally');
      _refreshFromGlobalState();
      return;
    }

    // Validation checks
    if (_document.number.trim().isEmpty) {
      _handleVerificationError(
          'Document number is required', isAutoVerification);
      return;
    }

    if (_document.imageUrl == null || _document.imageUrl!.isEmpty) {
      _handleVerificationError(
          'Document image is required', isAutoVerification);
      return;
    }

    _isCurrentlyVerifying = true;

    setState(() {
      _document = _document.copyWith(
        isLoading: true,
        errorMessage: null,
        hasAttemptedVerification: true,
      );
    });

    try {
      final imageBase64 = await _convertImageToBase64(_document.imageUrl!);
      if (imageBase64 == null) {
        _handleVerificationError(
            'Failed to process document image', isAutoVerification);
        return;
      }

      final result = await DocumentVerificationService.verifyDocument(
        type: _document.type,
        number: _document.number,
        imageBase64: imageBase64,
      );

      if (!_mounted) return;

      if (result.isSuccess) {
        // Mark as verified globally
        _stateManager.markAsVerified(
          widget.documentType,
          widget.documentNumber,
          widget.imageUrl,
        );

        setState(() {
          _document = _document.copyWith(
            isVerified: true,
            isLoading: false,
            errorMessage: null,
          );
        });

        widget.onVerificationChanged?.call(true, null);

        if (!isAutoVerification) {
          _showSuccessSnackBar('${widget.displayName} verified successfully!');
        }
      } else {
        // Mark as failed globally
        _stateManager.markAsFailed(
          widget.documentType,
          widget.documentNumber,
          widget.imageUrl,
          result.errorMessage ?? 'Verification failed',
        );

        setState(() {
          _document = _document.copyWith(
            isVerified: false,
            isLoading: false,
            errorMessage: result.errorMessage,
          );
        });

        widget.onVerificationChanged?.call(false, result.errorMessage);

        if (!isAutoVerification) {
          _showErrorSnackBar(result.errorMessage ?? 'Verification failed');
        }
      }
    } catch (e) {
      debugPrint('Verification error for ${widget.displayName}: $e');
      _handleVerificationError(
          'Verification failed. Please try again.', isAutoVerification);
    } finally {
      _isCurrentlyVerifying = false;
    }
  }

  void _refreshFromGlobalState() {
    final globalState = _stateManager.getVerificationState(
      widget.documentType,
      widget.documentNumber,
      widget.imageUrl,
    );

    if (globalState != null) {
      setState(() {
        _document = _document.copyWith(
          isVerified: globalState.isVerified,
          errorMessage: globalState.errorMessage,
          hasAttemptedVerification: true,
          isLoading: false,
        );
      });
    }
  }

  void _handleVerificationError(String errorMessage, bool isAutoVerification) {
    if (!_mounted) return;

    _isCurrentlyVerifying = false;

    // Mark as failed globally
    _stateManager.markAsFailed(
      widget.documentType,
      widget.documentNumber,
      widget.imageUrl,
      errorMessage,
    );

    setState(() {
      _document = _document.copyWith(
        isVerified: false,
        isLoading: false,
        errorMessage: errorMessage,
        hasAttemptedVerification: true,
      );
    });

    widget.onVerificationChanged?.call(false, errorMessage);

    if (!isAutoVerification) {
      _showErrorSnackBar(errorMessage);
    }
  }

  Future<String?> _convertImageToBase64(String imageUrl) async {
    try {
      return imageUrl;
    } catch (e) {
      debugPrint('Error processing image URL: $e');
      return null;
    }
  }

  void _showErrorSnackBar(String message) {
    if (!_mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    if (!_mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: _document.isVerified
              ? Colors.green.shade300
              : _document.errorMessage != null
                  ? Colors.red.shade300
                  : Colors.grey.shade300,
        ),
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.displayName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.documentNumber.isNotEmpty
                          ? widget.documentNumber
                          : 'Not provided',
                      style: TextStyle(
                        fontSize: 14,
                        color: widget.documentNumber.isNotEmpty
                            ? Colors.black87
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              _buildVerificationStatus(),
            ],
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
          if (_document.errorMessage != null && !_document.isVerified)
            _buildErrorSection(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (widget.imageUrl != null &&
            widget.imageUrl!.isNotEmpty &&
            widget.showPreviewButton) ...[
          ElevatedButton.icon(
            onPressed: widget.onPreviewPressed,
            icon: const Icon(Icons.visibility, size: 16),
            label: const Text('Preview'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade50,
              foregroundColor: Colors.blue.shade700,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
          const SizedBox(width: 12),
        ],
        if (_shouldShowVerifyButton())
          ElevatedButton.icon(
            onPressed: _document.isLoading || _isCurrentlyVerifying
                ? null
                : () => _verifyDocument(),
            icon: _document.isLoading || _isCurrentlyVerifying
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.verified_user, size: 16),
            label: Text((_document.isLoading || _isCurrentlyVerifying)
                ? 'Verifying...'
                : _document.hasAttemptedVerification
                    ? 'Re-verify'
                    : 'Verify'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _document.errorMessage != null
                  ? Colors.red.shade50
                  : Colors.orange.shade50,
              foregroundColor: _document.errorMessage != null
                  ? Colors.red.shade700
                  : Colors.orange.shade700,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
      ],
    );
  }

  bool _shouldShowVerifyButton() {
    return !_document.isVerified;
  }

  Widget _buildErrorSection() {
    return Padding(
        padding: const EdgeInsets.only(top: 12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade600,
                size: 18,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verification Failed',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _document.errorMessage!,
                      style: TextStyle(
                        color: Colors.red.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _buildVerificationStatus() {
    if (_document.isLoading || _isCurrentlyVerifying) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange.shade600),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Verifying...',
            style: TextStyle(
              color: Colors.orange.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    if (_document.isVerified) {
      return _buildStatusBadge(
        icon: Icons.check_circle,
        label: 'Verified',
        color: Colors.green,
      );
    }

    if (_document.hasAttemptedVerification && _document.errorMessage != null) {
      return _buildStatusBadge(
        icon: Icons.cancel,
        label: 'Failed',
        color: Colors.red,
      );
    }

    return _buildStatusBadge(
      icon: Icons.warning_amber_rounded,
      label: 'Unverified',
      color: Colors.orange,
    );
  }

  Widget _buildStatusBadge({
    required IconData icon,
    required String label,
    required MaterialColor color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color.shade600,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color.shade700,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

///how to use it =====================================================================

// class DocumentVerificationExample extends StatefulWidget {
//   final dynamic driverModel;
//
//   const DocumentVerificationExample({Key? key, required this.driverModel})
//       : super(key: key);
//
//   @override
//   State<DocumentVerificationExample> createState() =>
//       _DocumentVerificationExampleState();
// }
//
// class _DocumentVerificationExampleState
//     extends State<DocumentVerificationExample> {
//   Map<String, bool> verificationStatus = {};
//   Map<String, String?> verificationErrors = {};
//
//   void _handleVerificationChanged(
//       String documentType, bool isVerified, String? errorMessage) {
//     setState(() {
//       verificationStatus[documentType] = isVerified;
//       verificationErrors[documentType] = errorMessage;
//     });
//
//     debugPrint('$documentType verification status: $isVerified');
//     if (errorMessage != null) {
//       debugPrint('$documentType error: $errorMessage');
//     }
//   }
//
//   bool get allDocumentsVerified {
//     return verificationStatus.values.every((status) => status == true) &&
//         verificationStatus.length == 3;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Document Verification',
//           style: TextStyle(
//             fontSize: 18,
//             fontWeight: FontWeight.bold,
//             color: Colors.black87,
//           ),
//         ),
//         const SizedBox(height: 8),
//         const Text(
//           'Documents will be automatically verified when both image and number are provided.',
//           style: TextStyle(
//             fontSize: 14,
//             color: Colors.grey,
//           ),
//         ),
//         const SizedBox(height: 16),
//         DocumentVerificationWidget(
//           documentType: 'DRIVING',
//           documentNumber: widget.driverModel.drivingLicenceNumber ?? '',
//           imageUrl: widget.driverModel.drivingLicencePhoto,
//           displayName: 'Driving License',
//           onPreviewPressed: widget.driverModel.drivingLicencePhoto != null
//               ? () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => DocumentPreviewDialog(
//                       title: "Driving License",
//                       imageUrl: widget.driverModel.drivingLicencePhoto!,
//                     ),
//                   );
//                 }
//               : null,
//           onVerificationChanged: (isVerified, errorMessage) {
//             _handleVerificationChanged('DRIVING', isVerified, errorMessage);
//           },
//         ),
//         DocumentVerificationWidget(
//           documentType: 'ADHAR',
//           documentNumber: widget.driverModel.aadharCardNumber ?? '',
//           imageUrl: widget.driverModel.aadharCardPhoto,
//           displayName: 'Aadhar Card',
//           onPreviewPressed: widget.driverModel.aadharCardPhoto != null
//               ? () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => DocumentPreviewDialog(
//                       title: "Aadhar Card",
//                       imageUrl: widget.driverModel.aadharCardPhoto!,
//                     ),
//                   );
//                 }
//               : null,
//           onVerificationChanged: (isVerified, errorMessage) {
//             _handleVerificationChanged('ADHAR', isVerified, errorMessage);
//           },
//         ),
//         DocumentVerificationWidget(
//           documentType: 'PAN',
//           documentNumber: widget.driverModel.panCardNumber ?? '',
//           imageUrl: widget.driverModel.panCardPhoto,
//           displayName: 'PAN Card',
//           onPreviewPressed: widget.driverModel.panCardPhoto != null
//               ? () {
//                   showDialog(
//                     context: context,
//                     builder: (context) => DocumentPreviewDialog(
//                       title: "PAN Card",
//                       imageUrl: widget.driverModel.panCardPhoto!,
//                     ),
//                   );
//                 }
//               : null,
//           onVerificationChanged: (isVerified, errorMessage) {
//             _handleVerificationChanged('PAN', isVerified, errorMessage);
//           },
//         ),
//         const SizedBox(height: 20),
//         Container(
//           padding: const EdgeInsets.all(16),
//           decoration: BoxDecoration(
//             color: allDocumentsVerified
//                 ? Colors.green.shade50
//                 : Colors.orange.shade50,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(
//               color: allDocumentsVerified
//                   ? Colors.green.shade200
//                   : Colors.orange.shade200,
//             ),
//           ),
//           child: Row(
//             children: [
//               Icon(
//                 allDocumentsVerified ? Icons.check_circle : Icons.info_outline,
//                 color: allDocumentsVerified
//                     ? Colors.green.shade600
//                     : Colors.orange.shade600,
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Text(
//                   allDocumentsVerified
//                       ? 'All documents have been verified successfully!'
//                       : 'Please ensure all documents are uploaded and verified.',
//                   style: TextStyle(
//                     color: allDocumentsVerified
//                         ? Colors.green.shade700
//                         : Colors.orange.shade700,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
