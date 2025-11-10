abstract class PaymentStatusEvent {}

class FetchPaymentStatus extends PaymentStatusEvent {
  final String category;
  FetchPaymentStatus(this.category);
}

class ResetPaymentStatus extends PaymentStatusEvent {}
