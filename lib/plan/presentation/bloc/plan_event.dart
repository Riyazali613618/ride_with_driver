import 'package:equatable/equatable.dart';

abstract class PlanEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUserStatusEvent extends PlanEvent {
  final String selectedCategory;
  final String currentCategory;
  FetchUserStatusEvent(this.selectedCategory,this.currentCategory);
}

class FetchPlansEvent extends PlanEvent {
  final String planFor;
  final String countryId;
  final String stateId;
  FetchPlansEvent(this.planFor, this.countryId, this.stateId);
}

class ResetStatusDataEvent extends PlanEvent {}
