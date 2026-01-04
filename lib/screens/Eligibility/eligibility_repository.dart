import 'eligibility_remote_source.dart';
import 'model/eligibility_model.dart';

class EligibilityRepository {
  final EligibilityRemoteSource remoteSource;

  EligibilityRepository(this.remoteSource);

  Future<EligibilityModel> getEligibility() {
    return remoteSource.fetchEligibility();
  }
}
