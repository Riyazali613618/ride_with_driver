import 'package:equatable/equatable.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class OtpSentSuccess extends AuthState {
  final String message;
  final String phoneNumber;

  const OtpSentSuccess({required this.message, required this.phoneNumber});

  @override
  List<Object?> get props => [message, phoneNumber];
}

class OtpVerificationSuccess extends AuthState {
  final String message;
  final String token;

  const OtpVerificationSuccess({required this.message, required this.token});

  @override
  List<Object?> get props => [message, token];
}

class AuthenticatedState extends AuthState {
  final String token;

  const AuthenticatedState({required this.token});

  @override
  List<Object?> get props => [token];
}

class UnauthenticatedState extends AuthState {
  const UnauthenticatedState();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}
