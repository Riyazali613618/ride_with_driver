import 'package:flutter_bloc/flutter_bloc.dart';

import '../eligibility_repository.dart';
import 'eligibility_event.dart';
import 'eligibility_state.dart';

class EligibilityBloc extends Bloc<EligibilityEvent, EligibilityState> {
  final EligibilityRepository repository;

  EligibilityBloc(this.repository) : super(EligibilityInitial()) {
    on<FetchEligibilityEvent>(_onFetchEligibility);
    on<RefreshEligibilityEvent>(_onFetchEligibility);
  }

  Future<void> _onFetchEligibility(
    EligibilityEvent event,
    Emitter<EligibilityState> emit,
  ) async {
    emit(EligibilityLoading());

    try {
      final response = await repository.getEligibility();

      emit(
        EligibilityLoaded(
          paymentPhase: response.data?.paymentPhase ?? "",
          userType: response.data?.category ?? "",
        ),
      );
    } catch (e) {
      emit(EligibilityError(e.toString()));
    }
  }
}
