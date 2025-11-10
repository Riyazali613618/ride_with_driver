import '../../api/api_model/user_model/PaymentStatus.dart';

abstract class PaymentStatusState {}

class PaymentStatusInitial extends PaymentStatusState {}

class PaymentStatusLoading extends PaymentStatusState {}

class PaymentStatusLoaded extends PaymentStatusState {
  final PaymentStatus paymentStatus;
  PaymentStatusLoaded(this.paymentStatus);
}

class PaymentStatusError extends PaymentStatusState {
  final String message;
  PaymentStatusError(this.message);
}
