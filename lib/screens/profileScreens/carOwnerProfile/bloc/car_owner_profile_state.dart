import 'package:rwd/api/api_model/user_model/my_profile_model.dart';

abstract class CarOwnerProfileState {}

class ProfileLoading extends CarOwnerProfileState {}

class ProfileLoaded extends CarOwnerProfileState {
  final MyProfileModel profile;
  ProfileLoaded(this.profile);
}

class ProfileError extends CarOwnerProfileState {
  final String message;
  ProfileError(this.message);
}
