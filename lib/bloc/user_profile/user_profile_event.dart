import 'package:equatable/equatable.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfileEvent extends UserProfileEvent {
  const LoadUserProfileEvent();
}

class UpdateUserProfileEvent extends UserProfileEvent {
  final Map<String, dynamic> profileData;

  const UpdateUserProfileEvent({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

class GetPaymentStatusEvent extends UserProfileEvent {
  const GetPaymentStatusEvent();
}
