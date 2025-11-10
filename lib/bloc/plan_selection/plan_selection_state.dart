
import '../../api/api_model/payment/payment_model.dart';
import '../../api/api_model/user_model/plan_model.dart';

abstract class PlanSelectionState {}

class PlanSelectionInitial extends PlanSelectionState {}

class PlanSelectionLoading extends PlanSelectionState {}

class PlanSelectionLoaded extends PlanSelectionState {
  final List<Plan> subscriptionPlans;
  final Plan? registrationPlan;
  final String paymentPhase;

  PlanSelectionLoaded({
    required this.subscriptionPlans,
    this.registrationPlan,
    required this.paymentPhase,
  });
}

class PlanSelectionError extends PlanSelectionState {
  final String message;
  PlanSelectionError(this.message);
}

class PlanSelectionNavigating extends PlanSelectionState {}

class PlanSelectionNavigateToLayout extends PlanSelectionState {}

class PlanSelectionNavigateToRegistration extends PlanSelectionState {
  final String planType;
  PlanSelectionNavigateToRegistration(this.planType);
}
