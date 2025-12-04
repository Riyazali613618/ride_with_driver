import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../api/api_model/payment/payment_model.dart';
import '../../api/api_model/user_model/plan_model.dart';
import '../../api/api_service/payment_service/payment_service.dart';
import '../../plan/data/models/plan_model.dart';

abstract class PaymentEvent {}

class InitiatePayment extends PaymentEvent {
  final PlanModel plan;
  final String planType;
  final PaymentType paymentType;
  final String? category;

  InitiatePayment({
    required this.plan,
    required this.planType,
    required this.paymentType,
    this.category,
  });
}

class PaymentSuccess extends PaymentEvent {
  final PaymentSuccessResponse response;
  final PlanModel plan;
  final String planType;
  final PaymentType paymentType;
  final String? category;
  final String? registrationFeeId;

  PaymentSuccess({
    required this.response,
    required this.plan,
    required this.planType,
    required this.paymentType,
    this.category,
    this.registrationFeeId,
  });
}

class PaymentFailed extends PaymentEvent {
  final String error;
  PaymentFailed(this.error);
}

class ResetPayment extends PaymentEvent {}
