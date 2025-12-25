import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/features/upgradeablePlans/upgradeable_plans_event.dart';
import 'package:r_w_r/features/upgradeablePlans/upgradeable_plans_state.dart';

import '../../features/newDashboard/dashboard_repository.dart';

class UpgradeablePlansBloc
    extends Bloc<UpgradeablePlansEvent, UpgradeablePlansState> {
  final UpgradeablePlansRepository repository;

  UpgradeablePlansBloc(this.repository) : super(UpgradeablePlansLoading()) {
    on<UpgradeablePlanLoad>(_onLoadUpgradeablePlans);
  }

  Future<void> _onLoadUpgradeablePlans(
    UpgradeablePlanLoad event,
    Emitter<UpgradeablePlansState> emit,
  ) async {
    emit(UpgradeablePlansLoading());

    try {
      final data = await repository.getUpgradeablePlan(event.type);
      emit(
        UpgradeablePlansLoaded(
          data: data,
        ),
      );
    } catch (e) {
      emit(UpgradeablePlansError(e.toString()));
    }
  }
}
