import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/api/api_service/api_repository.dart';
import 'package:r_w_r/constants/token_manager.dart';

import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final ApiRepository apiRepository;

  AuthBloc({required this.apiRepository}) : super(const AuthInitial()) {
    on<SendOtpEvent>(_onSendOtp);
    on<VerifyOtpEvent>(_onVerifyOtp);
    on<LogoutEvent>(_onLogout);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
  }

  Future<void> _onSendOtp(SendOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final response = await apiRepository.sendOtp(number: event.phoneNumber);
      
      if (response['success'] == true) {
        emit(OtpSentSuccess(
          message: response['message'] ?? 'OTP sent successfully',
          phoneNumber: event.phoneNumber,
        ));
      } else {
        emit(AuthError(
          message: response['message'] ?? 'Failed to send OTP',
        ));
      }
    } on ApiException catch (e) {
      debugPrint('AuthBloc SendOtp ApiException: ${e.message}');
      emit(AuthError(message: e.message));
    } catch (e) {
      debugPrint('AuthBloc SendOtp Exception: $e');
      emit(const AuthError(message: 'Something went wrong. Please check your connection.'));
    }
  }

  Future<void> _onVerifyOtp(VerifyOtpEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    try {
      final response = await apiRepository.verifyOtp(
        number: event.phoneNumber,
        otp: event.otp,
      );

      if (response['status'] == true) {
        final token = response['data']?.toString() ?? '';
        
        // Save token
        if (token.isNotEmpty) {
          await TokenManager.saveToken(token);
        }

        emit(OtpVerificationSuccess(
          message: response['message'] ?? 'OTP verified successfully',
          token: token,
        ));
        
        // Immediately emit authenticated state
        emit(AuthenticatedState(token: token));
      } else {
        emit(AuthError(
          message: response['message'] ?? 'Failed to verify OTP',
        ));
      }
    } on ApiException catch (e) {
      debugPrint('AuthBloc VerifyOtp ApiException: ${e.message}');
      emit(AuthError(message: e.message));
    } catch (e) {
      debugPrint('AuthBloc VerifyOtp Exception: $e');
      emit(const AuthError(message: 'Something went wrong. Please check your connection.'));
    }
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    try {
      // Call logout API
      await apiRepository.logout();
    } catch (e) {
      debugPrint('AuthBloc Logout Exception: $e');
      // Continue with logout even if API call fails
    }

    // Clear token regardless of API response
    await TokenManager.clearToken();
    emit(const UnauthenticatedState());
  }

  Future<void> _onCheckAuthStatus(CheckAuthStatusEvent event, Emitter<AuthState> emit) async {
    final token = await TokenManager.getToken();
    
    if (token != null && token.isNotEmpty) {
      emit(AuthenticatedState(token: token));
    } else {
      emit(const UnauthenticatedState());
    }
  }
}
