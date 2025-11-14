import 'package:flutter_bloc/flutter_bloc.dart';
import 'plan_event.dart';
import 'plan_state.dart';
import '../../data/repositories/plan_repository.dart';

class PlanBloc extends Bloc<PlanEvent, PlanState> {
  final PlanRepository repository;

  PlanBloc(this.repository) : super(const PlanState()) {
    on<FetchUserStatusEvent>(_onFetchStatus);
    on<FetchPlansEvent>(_onFetchPlans);
  }

  Future<void> _onFetchStatus(
      FetchUserStatusEvent event, Emitter<PlanState> emit) async {
    emit(state.copyWith(loading: true));
    final data = await repository.fetchUserStatus(event.category);
    if (data != null && data['success'] == true) {
      var map= data['data'] as Map<String, dynamic>;
      map['category']=event.category;
      emit(state.copyWith(loading: false, statusData: data['data']));
    } else {
      emit(state.copyWith(loading: false, error: "Failed to fetch status"));
    }
  }

  Future<void> _onFetchPlans(
      FetchPlansEvent event, Emitter<PlanState> emit) async {
    emit(state.copyWith(loading: true));
    final plans = await repository.fetchPlans(
        planFor: event.planFor,
        countryId: event.countryId,
        stateId: event.stateId);
    emit(state.copyWith(loading: false, plans: plans));
  }
}
