import 'package:r_w_r/api/api_model/user_model/my_profile_model.dart';
import 'package:r_w_r/screens/profileScreens/carOwnerProfile/car_owner_profile_api_service.dart';

class CarOwnerProfileRepository {
  final CarOwnerProfileApiService api;

  CarOwnerProfileRepository(this.api);

  Future<MyProfileModel> getProfile() => api.fetchProfile();

  Future<void> updateProfile(Map<String, dynamic> body) =>
      api.updateProfile(body);
}
