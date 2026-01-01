// models/user_profile_model.dart

class UserEligibilityModel {
  final bool status;
  final String message;
  final UserData? data;

  UserEligibilityModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory UserEligibilityModel.fromJson(Map<String, dynamic> json) {
    return UserEligibilityModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class UserData {
  final String id;
  final String subscriptionId;
  final String? paymentRestrictionId;
  final String paymentId;
  final String orderId;
  final String paymentPhase;

  UserData({
    required this.id,
    required this.subscriptionId,
    this.paymentRestrictionId,
    required this.paymentId,
    required this.orderId,
    required this.paymentPhase,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
        id: json['id'] ?? '',
        subscriptionId: json['subscriptionId'] ?? '',
        paymentRestrictionId: json['paymentRestrictionId'],
        paymentId: json['paymentId'] ?? '',
        orderId: json['orderId'] ?? '',
        paymentPhase:
            json['paymentPhase'] ?? "");
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subscriptionId': subscriptionId,
      if (paymentRestrictionId != null)
        'paymentRestrictionId': paymentRestrictionId,
      'orderId': orderId,
      'paymentId': paymentId,
      'paymentPhase': paymentPhase,
    };
  }

  UserData copyWith({
    String? id,
    String? subscriptionId,
    String? paymentRestrictionId,
    String? orderId,
    String? paymentId,
    String? paymentPhase,
  }) {
    return UserData(
      id: id ?? this.id,
      subscriptionId: subscriptionId ?? this.subscriptionId,
      paymentRestrictionId: paymentRestrictionId ?? this.paymentRestrictionId,
      paymentId: paymentId ?? this.paymentId,
      orderId: orderId ?? this.orderId,
      paymentPhase: paymentPhase ?? this.paymentPhase,
    );
  }
}
