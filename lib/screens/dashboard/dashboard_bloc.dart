import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/newDashboard/dashboard_repository.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final DashboardRepository repository;

  DashboardBloc(this.repository) : super(DashboardLoading()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<ChangeRange>(_onChangeRange);
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event,
      Emitter<DashboardState> emit,
      ) async {
    emit(DashboardLoading());

    try {
      final data = await repository.getDashboard(event.range);
      emit(
        DashboardLoaded(
          selectedRange: event.range,
          data: data,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }

  Future<void> _onChangeRange(
      ChangeRange event,
      Emitter<DashboardState> emit,
      ) async {
    if (state is DashboardLoaded) {
      add(LoadDashboard(range: event.range));
    }
  }
}
