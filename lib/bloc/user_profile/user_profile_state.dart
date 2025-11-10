import 'package:equatable/equatable.dart';

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {
  const UserProfileInitial();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileLoaded extends UserProfileState {
  final Map<String, dynamic> profileData;

  const UserProfileLoaded({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

class UserProfileUpdateSuccess extends UserProfileState {
  final String message;
  final Map<String, dynamic> updatedProfileData;

  const UserProfileUpdateSuccess({
    required this.message,
    required this.updatedProfileData,
  });

  @override
  List<Object?> get props => [message, updatedProfileData];
}

class PaymentStatusLoaded extends UserProfileState {
  final Map<String, dynamic> paymentStatusData;

  const PaymentStatusLoaded({required this.paymentStatusData});

  @override
  List<Object?> get props => [paymentStatusData];
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
