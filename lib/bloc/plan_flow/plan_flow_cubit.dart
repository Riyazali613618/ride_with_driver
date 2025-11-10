import 'package:flutter_bloc/flutter_bloc.dart';

class PlanFlowState {
  final bool isLoading;
  final String? error;
  final bool isNavigating;

  const PlanFlowState({
    this.isLoading = false,
    this.error,
    this.isNavigating = false,
  });

  PlanFlowState copyWith({
    bool? isLoading,
    String? error,
    bool? isNavigating,
  }) {
    return PlanFlowState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }
}

class PlanFlowCubit extends Cubit<PlanFlowState> {
  PlanFlowCubit() : super(const PlanFlowState());

  void setLoading(bool isLoading) {
    emit(state.copyWith(isLoading: isLoading));
  }

  void setError(String? error) {
    emit(state.copyWith(error: error, isLoading: false));
  }

  void setNavigating(bool isNavigating) {
    emit(state.copyWith(isNavigating: isNavigating));
  }

  void reset() {
    emit(const PlanFlowState());
  }
}