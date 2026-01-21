import 'package:flutter_bloc/flutter_bloc.dart';

import '../repository/comm_repo.dart';
import 'communication_event.dart';
import 'communication_state.dart';

class CommunicationBloc
    extends Bloc<CommunicationEvent, CommunicationState> {
  final CommunicationRepository repository;

  CommunicationBloc(this.repository) : super(CommunicationInitial()) {
    on<FetchCommunications>(_onFetch);
  }

  Future<void> _onFetch(
      FetchCommunications event,
      Emitter<CommunicationState> emit) async {
    emit(CommunicationLoading());

    try {
      final data = await repository.fetchCommunications();
      emit(CommunicationLoaded(data));
    } catch (e) {
      emit(CommunicationError('Failed to load communications'));
    }
  }
}
