import 'package:r_w_r/api/api_model/upgradeable_plans.dart';

import 'dashboard_api_service.dart';
import 'dashboard_model.dart';

class DashboardRepository {
  final DashboardApiService api;

  DashboardRepository(this.api);

  Future<DashboardResponse> getDashboard(String range) {
    return api.fetchDashboard(range);
  }
}
class UpgradeablePlansRepository {
  final DashboardApiService api;

  UpgradeablePlansRepository(this.api);

  Future<UpgradeablePlans> getUpgradeablePlan(String type) {
    return api.fetchUpgradeablePlans(type);
  }
}
