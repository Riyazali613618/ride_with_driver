import 'package:r_w_r/api/api_model/upgradeable_plans.dart';

import '../../features/newDashboard/dashboard_model.dart';

abstract class UpgradeablePlansState {}

class UpgradeablePlansLoading extends UpgradeablePlansState {}

class UpgradeablePlansLoaded extends UpgradeablePlansState {
  final UpgradeablePlans data;

  UpgradeablePlansLoaded({
    required this.data,
  });

  UpgradeablePlansLoaded copyWith({
    UpgradeablePlans? data,
  }) {
    return UpgradeablePlansLoaded(
      data: data ?? this.data,
    );
  }
}

class UpgradeablePlansError extends UpgradeablePlansState {
  final String message;

  UpgradeablePlansError(this.message);
}
