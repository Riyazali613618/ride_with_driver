import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/api/api_service/api_repository.dart';

import 'user_profile_event.dart';
import 'user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final ApiRepository apiRepository;

  UserProfileBloc({required this.apiRepository}) : super(const UserProfileInitial()) {
    on<LoadUserProfileEvent>(_onLoadUserProfile);
    on<UpdateUserProfileEvent>(_onUpdateUserProfile);
    on<GetPaymentStatusEvent>(_onGetPaymentStatus);
  }

  Future<void> _onLoadUserProfile(LoadUserProfileEvent event, Emitter<UserProfileState> emit) async {
    emit(const UserProfileLoading());

    try {
      final response = await apiRepository.getUserProfile();
      emit(UserProfileLoaded(profileData: response));
    } on ApiException catch (e) {
      debugPrint('UserProfileBloc LoadProfile ApiException: ${e.message}');
      emit(UserProfileError(message: e.message));
    } catch (e) {
      debugPrint('UserProfileBloc LoadProfile Exception: $e');
      emit(const UserProfileError(message: 'Failed to load profile. Please try again.'));
    }
  }

  Future<void> _onUpdateUserProfile(UpdateUserProfileEvent event, Emitter<UserProfileState> emit) async {
    emit(const UserProfileLoading());

    try {
      final response = await apiRepository.updateUserProfile(event.profileData);
      
      if (response['status'] == true) {
        emit(UserProfileUpdateSuccess(
          message: response['message'] ?? 'Profile updated successfully',
          updatedProfileData: response,
        ));
        
        // Optionally, emit the loaded state with updated data
        emit(UserProfileLoaded(profileData: response));
      } else {
        emit(UserProfileError(
          message: response['message'] ?? 'Failed to update profile',
        ));
      }
    } on ApiException catch (e) {
      debugPrint('UserProfileBloc UpdateProfile ApiException: ${e.message}');
      emit(UserProfileError(message: e.message));
    } catch (e) {
      debugPrint('UserProfileBloc UpdateProfile Exception: $e');
      emit(const UserProfileError(message: 'Failed to update profile. Please try again.'));
    }
  }

  Future<void> _onGetPaymentStatus(GetPaymentStatusEvent event, Emitter<UserProfileState> emit) async {
    emit(const UserProfileLoading());

    try {
      final response = await apiRepository.getPaymentStatus();
      emit(PaymentStatusLoaded(paymentStatusData: response));
    } on ApiException catch (e) {
      debugPrint('UserProfileBloc PaymentStatus ApiException: ${e.message}');
      emit(UserProfileError(message: e.message));
    } catch (e) {
      debugPrint('UserProfileBloc PaymentStatus Exception: $e');
      emit(const UserProfileError(message: 'Failed to load payment status. Please try again.'));
    }
  }
}
