import '../../data/models/plan_model.dart';
import '../../data/services/plan_service.dart';

class PlanRepository {
  Future<Map<String, dynamic>?> fetchUserStatus(String type) {
    return PlanService.getUserStatus(type);
  }

  Future<List<PlanModel>> fetchPlans({
    required String planFor,
    required String countryId,
    required String stateId,
  }) async {
    final response = await PlanService.getPlans(
      planFor: planFor,
      countryId: countryId,
      stateId: stateId,
    );

    if (response != null && response['success'] == true) {
      final List<dynamic> planList = response['data']['plans']['SUBSCRIPTION'];
      return planList.map((e) => PlanModel.fromJson(e)).toList();
    }
    return [];
  }
}
