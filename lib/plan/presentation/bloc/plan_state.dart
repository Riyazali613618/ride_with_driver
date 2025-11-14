import 'package:equatable/equatable.dart';

import '../../data/models/plan_model.dart';

class PlanState extends Equatable {
  final bool loading;
  final Map<String, dynamic>? statusData;
  final List<PlanModel>? plans;
  final String? error;

  const PlanState({
    this.loading = false,
    this.statusData,
    this.plans,
    this.error,
  });

  PlanState copyWith({
    bool? loading,
    Map<String, dynamic>? statusData,
    List<PlanModel>? plans,
    String? error,
  }) {
    return PlanState(
      loading: loading ?? this.loading,
      statusData: statusData ?? this.statusData,
      plans: plans ?? this.plans,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [loading, statusData, plans, error];
}
