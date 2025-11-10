import 'package:equatable/equatable.dart';

abstract class DriverState extends Equatable {
  const DriverState();

  @override
  List<Object?> get props => [];
}

class DriverInitial extends DriverState {
  const DriverInitial();
}

class DriverLoading extends DriverState {
  const DriverLoading();
}

// Add this new loading state for registration
class DriverRegistrationLoading extends DriverState {
  const DriverRegistrationLoading();
}

class DriverProfileLoaded extends DriverState {
  final Map<String, dynamic> profileData;

  const DriverProfileLoaded({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

class DriverProfileUpdateSuccess extends DriverState {
  final String message;
  final Map<String, dynamic> updatedProfileData;

  const DriverProfileUpdateSuccess({
    required this.message,
    required this.updatedProfileData,
  });

  @override
  List<Object?> get props => [message, updatedProfileData];
}

class DriverRegistrationSuccess extends DriverState {
  final String message;
  final Map<String, dynamic> registrationData;

  const DriverRegistrationSuccess({
    required this.message,
    required this.registrationData,
  });

  @override
  List<Object?> get props => [message, registrationData];
}

class DriverDetailsLoaded extends DriverState {
  final Map<String, dynamic> driverDetails;

  const DriverDetailsLoaded({required this.driverDetails});

  @override
  List<Object?> get props => [driverDetails];
}

class BecomeDriverRegistrationSuccess extends DriverState {
  final String message;
  final Map<String, dynamic> registrationData;

  const BecomeDriverRegistrationSuccess({
    required this.message,
    required this.registrationData,
  });

  @override
  List<Object?> get props => [message, registrationData];
}

class AutoRikshawRegistrationSuccess extends DriverState {
  final String message;
  final Map<String, dynamic> registrationData;

  const AutoRikshawRegistrationSuccess({
    required this.message,
    required this.registrationData,
  });

  @override
  List<Object?> get props => [message, registrationData];
}

class ERikshawRegistrationSuccess extends DriverState {
  final String message;
  final Map<String, dynamic> registrationData;

  const ERikshawRegistrationSuccess({
    required this.message,
    required this.registrationData,
  });

  @override
  List<Object?> get props => [message, registrationData];
}

class TransporterRegistrationSuccess extends DriverState {
  final String message;
  final Map<String, dynamic> registrationData;

  const TransporterRegistrationSuccess({
    required this.message,
    required this.registrationData,
  });

  @override
  List<Object?> get props => [message, registrationData];
}

class DriverError extends DriverState {
  final String message;

  const DriverError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Add this new error state for registration
class DriverRegistrationError extends DriverState {
  final String message;
  final String? errorCode;

  const DriverRegistrationError({
    required this.message,
    this.errorCode,
  });

  @override
  List<Object?> get props => [message, errorCode];
}