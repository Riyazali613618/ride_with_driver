class PlanResponse {
  final bool success;
  final String message;
  final PaymentStatusData? data;

  PlanResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PlanResponse.fromJson(Map<String, dynamic> json) {
    try {
      return PlanResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: json['data'] != null
            ? PaymentStatusData.fromJson(json['data'])
            : null,
      );
    } catch (e) {
      print("Error parsing PaymentStatusResponse: $e");
      return PlanResponse(
        success: false,
        message: 'Failed to parse response',
        data: null,
      );
    }
  }
}

class PaymentStatusData {
  final String category;
  final bool hasRegistrationFee;
  final String? registrationPaidAt;
  final bool hasActiveSubscription;
  final String? subscriptionEndDate;
  final String? subscriptionType;
  final String? subscriptionId;
  final String paymentRequired;
  final String nextAction;
  final bool needsRenewal;
  final String paymentPhase;
  final bool isFormSubmitted;
  final bool canUpgrade;
  final bool isUpgrade;
  final String? vehicleEligibleCategory;
  final String? effectiveCategory;
  final bool hasAnyCompletedRegistration;

  PaymentStatusData({
    required this.category,
    required this.hasRegistrationFee,
    this.registrationPaidAt,
    required this.hasActiveSubscription,
    this.subscriptionEndDate,
    this.subscriptionType,
    this.subscriptionId,
    required this.paymentRequired,
    required this.nextAction,
    required this.needsRenewal,
    required this.paymentPhase,
    required this.isFormSubmitted,
    required this.canUpgrade,
    required this.isUpgrade,
    this.vehicleEligibleCategory,
    this.effectiveCategory,
    required this.hasAnyCompletedRegistration,
  });

  factory PaymentStatusData.fromJson(Map<String, dynamic> json) {
    try {
      return PaymentStatusData(
        category: json['category']?.toString() ?? '',
        hasRegistrationFee: json['hasRegistrationFee'] ?? false,
        registrationPaidAt: json['registrationPaidAt']?.toString(),
        hasActiveSubscription: json['hasActiveSubscription'] ?? false,
        subscriptionEndDate: json['subscriptionEndDate']?.toString(),
        subscriptionType: json['subscriptionType']?.toString(),
        subscriptionId: json['subscriptionId']?.toString(),
        paymentRequired: json['paymentRequired']?.toString() ?? '',
        nextAction: json['nextAction']?.toString() ?? '',
        needsRenewal: json['needsRenewal'] ?? false,
        paymentPhase: json['paymentPhase']?.toString() ?? '',
        isFormSubmitted: json['isFormSubmitted'] ?? false,
        canUpgrade: json['canUpgrade'] ?? false,
        isUpgrade: json['isUpgrade'] ?? false,
        vehicleEligibleCategory: json['vehicleEligibleCategory']?.toString(),
        effectiveCategory: json['effectiveCategory']?.toString(),
        hasAnyCompletedRegistration: json['hasAnyCompletedRegistration'] ?? false,
      );
    } catch (e) {
      print("Error parsing PaymentStatusData: $e");
      rethrow;
    }
  }

  // Helper methods to check payment state
  bool get requiresRegistration => paymentRequired == 'registration_required';
  bool get requiresSubscription => paymentRequired == 'subscription_required';
  bool get isInPreRegistrationPhase => paymentPhase == 'PRE_REGISTRATION';
  bool get isInActivePhase => paymentPhase == 'ACTIVE';
}