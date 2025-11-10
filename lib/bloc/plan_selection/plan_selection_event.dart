import '../../api/api_model/payment/payment_model.dart';

abstract class PlanSelectionEvent {}

class FetchPlans extends PlanSelectionEvent {
  final String planType;
  final String planFor;
  final String countryId;
  final String stateId;
  FetchPlans(this.planType, this.planFor, this.countryId, this.stateId);
}

class SelectPlan extends PlanSelectionEvent {
  final Plan plan;
  SelectPlan(this.plan);
}

class NavigateToLayout extends PlanSelectionEvent {}

class NavigateToRegistration extends PlanSelectionEvent {
  final String planType;
  final String planFor;
  final String countryId;
  final String stateId;
  NavigateToRegistration(this.planType, this.planFor, this.countryId, this.stateId);
}

class RetryFetchPlans extends PlanSelectionEvent {
  final String planType;
  final String planFor;
  final String countryId;
  final String stateId;
  RetryFetchPlans(this.planType, this.planFor, this.countryId, this.stateId);
}

