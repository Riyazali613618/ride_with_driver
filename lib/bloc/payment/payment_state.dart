abstract class PaymentState {}

class PaymentInitial extends PaymentState {}

class PaymentLoading extends PaymentState {}

class PaymentOrderCreated extends PaymentState {
  final Map<String, dynamic> orderData;
  final String? registrationFeeId;

  PaymentOrderCreated({
    required this.orderData,
    this.registrationFeeId,
  });
}

class PaymentProcessing extends PaymentState {}

class PaymentCompleted extends PaymentState {
  final String planType;
  final bool isRenewal;
  PaymentCompleted(this.planType,{this.isRenewal=false});
}

class PaymentError extends PaymentState {
  final String message;
  PaymentError(this.message);
}
