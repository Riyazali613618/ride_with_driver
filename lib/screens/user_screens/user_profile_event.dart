import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../api/api_model/user_model/user_profile_model.dart';
import '../../api/api_service/user_service/user_profile_service.dart';

abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

class FetchUserProfile extends UserProfileEvent {}

class UpdateUserProfile extends UserProfileEvent {
  final UserData userData;

  const UpdateUserProfile(this.userData);

  @override
  List<Object> get props => [userData];
}

abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserData userData;

  const UserProfileLoaded(this.userData);

  @override
  List<Object?> get props => [userData];
}

class UserProfileUpdating extends UserProfileState {}

class UserProfileUpdateSuccess extends UserProfileState {
  final String message;

  const UserProfileUpdateSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UserProfileService _userProfileService;

  UserProfileBloc({required UserProfileService userProfileService})
      : _userProfileService = userProfileService,
        super(UserProfileInitial()) {
    on<FetchUserProfile>(_onFetchUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  FutureOr<void> _onFetchUserProfile(
    FetchUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileLoading());
    try {
      final UserProfileModel response =
          await _userProfileService.getUserProfile();
      if (response.status && response.data != null) {
        emit(UserProfileLoaded(response.data!));
      } else {
        emit(UserProfileError(response.message));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }

  FutureOr<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<UserProfileState> emit,
  ) async {
    emit(UserProfileUpdating());
    try {
      final response =
          await _userProfileService.updateUserProfile(event.userData);
      if (response.status) {
        // Re-fetch the profile to ensure we have the latest data
        add(FetchUserProfile());
        emit(UserProfileUpdateSuccess(response.message));
      } else {
        emit(UserProfileError(response.message));
      }
    } catch (e) {
      emit(UserProfileError(e.toString()));
    }
  }
}
