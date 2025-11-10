class DocumentVerificationModel {
  final String type;
  final String number;
  final String? imageUrl;
  final bool isVerified;
  final bool isLoading;
  final String? errorMessage;
  final bool hasAttemptedVerification;

  DocumentVerificationModel({
    required this.type,
    required this.number,
    this.imageUrl,
    this.isVerified = false,
    this.isLoading = false,
    this.errorMessage,
    this.hasAttemptedVerification = false,
  });

  DocumentVerificationModel copyWith({
    String? type,
    String? number,
    String? imageUrl,
    bool? isVerified,
    bool? isLoading,
    String? errorMessage,
    bool? hasAttemptedVerification,
  }) {
    return DocumentVerificationModel(
      type: type ?? this.type,
      number: number ?? this.number,
      imageUrl: imageUrl ?? this.imageUrl,
      isVerified: isVerified ?? this.isVerified,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      hasAttemptedVerification:
          hasAttemptedVerification ?? this.hasAttemptedVerification,
    );
  }

  bool get canAutoVerify =>
      number.isNotEmpty &&
      imageUrl != null &&
      imageUrl!.isNotEmpty &&
      !hasAttemptedVerification;
}

class DocumentVerificationResult {
  final bool isSuccess;
  final String? errorMessage;
  final Map<String, dynamic>? data;

  DocumentVerificationResult._({
    required this.isSuccess,
    this.errorMessage,
    this.data,
  });

  factory DocumentVerificationResult.success(Map<String, dynamic> data) {
    return DocumentVerificationResult._(
      isSuccess: true,
      data: data,
    );
  }

  factory DocumentVerificationResult.failure(String errorMessage) {
    return DocumentVerificationResult._(
      isSuccess: false,
      errorMessage: errorMessage,
    );
  }
}
