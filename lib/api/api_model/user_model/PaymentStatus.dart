// class PaymentStatus {
//   final bool success;
//   final PaymentStatusData? data;
//
//   PaymentStatus({
//     required this.success,
//     this.data,
//   });
//
//   factory PaymentStatus.fromJson(Map<String, dynamic> json) {
//     return PaymentStatus(
//       success: json['success'] ?? false,
//       data: json['data'] != null ? PaymentStatusData.fromJson(json['data']) : null,
//     );
//   }
// }
//
// class PaymentStatusData {
//   final bool canPay;
//   final List<String> reasons;
//   final List<String> warnings;
//   final bool hasRestriction;
//   final Restriction? restriction;
//
//   PaymentStatusData({
//     required this.canPay,
//     required this.reasons,
//     required this.warnings,
//     required this.hasRestriction,
//     this.restriction,
//   });
//
//   factory PaymentStatusData.fromJson(Map<String, dynamic> json) {
//     return PaymentStatusData(
//       canPay: json['canPay'] ?? false,
//       reasons: (json['reasons'] as List?)?.map((e) => e.toString()).toList() ?? [],
//       warnings: (json['warnings'] as List?)?.map((e) => e.toString()).toList() ?? [],
//       hasRestriction: json['hasRestriction'] ?? false,
//       restriction: json['restriction'] != null
//           ? Restriction.fromJson(json['restriction'])
//           : null,
//     );
//   }
// }
//
// class Restriction {
//   final String id;
//   final String paymentPhase;
//   final String expiresAt;
//   final int remindersSent;
//
//   Restriction({
//     required this.id,
//     required this.paymentPhase,
//     required this.expiresAt,
//     required this.remindersSent,
//   });
//
//   factory Restriction.fromJson(Map<String, dynamic> json) {
//     return Restriction(
//       id: json['id'] ?? '',
//       paymentPhase: json['paymentPhase'] ?? '',
//       expiresAt: json['expiresAt'] ?? '',
//       remindersSent: json['remindersSent'] ?? 0,
//     );
//   }
// }
class PaymentStatus {
  bool? success;
  String? message;
  PaymentStatusData? data;

  PaymentStatus({this.success, this.message, this.data});

  PaymentStatus.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new PaymentStatusData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class PaymentStatusData {
  String? category;
  bool? hasRegistrationFee;
  dynamic? registrationPaidAt;
  bool? hasActiveSubscription;
  dynamic? subscriptionEndDate;
  dynamic? subscriptionType;
  dynamic? subscriptionId;
  String? paymentRequired;
  String? nextAction;
  bool? needsRenewal;
  String? paymentPhase;
  bool? isFormSubmitted;
  bool? canUpgrade;
  bool? isUpgrade;
  dynamic? vehicleEligibleCategory;
  dynamic? effectiveCategory;
  bool? hasAnyCompletedRegistration;

  PaymentStatusData(
      {this.category,
        this.hasRegistrationFee,
        this.registrationPaidAt,
        this.hasActiveSubscription,
        this.subscriptionEndDate,
        this.subscriptionType,
        this.subscriptionId,
        this.paymentRequired,
        this.nextAction,
        this.needsRenewal,
        this.paymentPhase,
        this.isFormSubmitted,
        this.canUpgrade,
        this.isUpgrade,
        this.vehicleEligibleCategory,
        this.effectiveCategory,
        this.hasAnyCompletedRegistration});

  PaymentStatusData.fromJson(Map<String, dynamic> json) {
    category = json['category'];
    hasRegistrationFee = json['hasRegistrationFee'];
    registrationPaidAt = json['registrationPaidAt'];
    hasActiveSubscription = json['hasActiveSubscription'];
    subscriptionEndDate = json['subscriptionEndDate'];
    subscriptionType = json['subscriptionType'];
    subscriptionId = json['subscriptionId'];
    paymentRequired = json['paymentRequired'];
    nextAction = json['nextAction'];
    needsRenewal = json['needsRenewal'];
    paymentPhase = json['paymentPhase'];
    isFormSubmitted = json['isFormSubmitted'];
    canUpgrade = json['canUpgrade'];
    isUpgrade = json['isUpgrade'];
    vehicleEligibleCategory = json['vehicleEligibleCategory'];
    effectiveCategory = json['effectiveCategory'];
    hasAnyCompletedRegistration = json['hasAnyCompletedRegistration'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['category'] = this.category;
    data['hasRegistrationFee'] = this.hasRegistrationFee;
    data['registrationPaidAt'] = this.registrationPaidAt;
    data['hasActiveSubscription'] = this.hasActiveSubscription;
    data['subscriptionEndDate'] = this.subscriptionEndDate;
    data['subscriptionType'] = this.subscriptionType;
    data['subscriptionId'] = this.subscriptionId;
    data['paymentRequired'] = this.paymentRequired;
    data['nextAction'] = this.nextAction;
    data['needsRenewal'] = this.needsRenewal;
    data['paymentPhase'] = this.paymentPhase;
    data['isFormSubmitted'] = this.isFormSubmitted;
    data['canUpgrade'] = this.canUpgrade;
    data['isUpgrade'] = this.isUpgrade;
    data['vehicleEligibleCategory'] = this.vehicleEligibleCategory;
    data['effectiveCategory'] = this.effectiveCategory;
    data['hasAnyCompletedRegistration'] = this.hasAnyCompletedRegistration;
    return data;
  }
}

