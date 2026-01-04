abstract class EligibilityState {}

class EligibilityInitial extends EligibilityState {}

class EligibilityLoading extends EligibilityState {}

class EligibilityLoaded extends EligibilityState {
  final String paymentPhase;
  final String userType;

  EligibilityLoaded({required this.paymentPhase,required this.userType});
}

class EligibilityError extends EligibilityState {
  final String message;

  EligibilityError(this.message);
}
