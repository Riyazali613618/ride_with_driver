import 'package:equatable/equatable.dart';

abstract class PlanEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUserStatusEvent extends PlanEvent {
  final String category;
  FetchUserStatusEvent(this.category);
}

class FetchPlansEvent extends PlanEvent {
  final String planFor;
  final String countryId;
  final String stateId;
  FetchPlansEvent(this.planFor, this.countryId, this.stateId);
}
