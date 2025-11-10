import 'package:equatable/equatable.dart';

abstract class DriverEvent extends Equatable {
  const DriverEvent();

  @override
  List<Object?> get props => [];
}

class LoadDriverProfileEvent extends DriverEvent {
  const LoadDriverProfileEvent();
}

class UpdateDriverProfileEvent extends DriverEvent {
  final Map<String, dynamic> profileData;

  const UpdateDriverProfileEvent({required this.profileData});

  @override
  List<Object?> get props => [profileData];
}

class DriverRegistrationEvent extends DriverEvent {
  final Map<String, dynamic> registrationData;

  const DriverRegistrationEvent({required this.registrationData});

  @override
  List<Object?> get props => [registrationData];
}

class LoadDriverDetailsEvent extends DriverEvent {
  final String driverId;

  const LoadDriverDetailsEvent({required this.driverId});

  @override
  List<Object?> get props => [driverId];
}

class BecomeDriverRegistrationEvent extends DriverEvent {
  final String type;
  final Map<String, dynamic> data;
  final Map<String, dynamic> registrationData; // Keep for backward compatibility

  const BecomeDriverRegistrationEvent({
    this.type = 'DRIVER',
    required this.data,
    this.registrationData = const {},
  });

  @override
  List<Object?> get props => [type, data, registrationData];
}

class AutoRikshawRegistrationEvent extends DriverEvent {
  final Map<String, dynamic> registrationData;

  const AutoRikshawRegistrationEvent({required this.registrationData});

  @override
  List<Object?> get props => [registrationData];
}

class ERikshawRegistrationEvent extends DriverEvent {
  final Map<String, dynamic> registrationData;

  const ERikshawRegistrationEvent({required this.registrationData});

  @override
  List<Object?> get props => [registrationData];
}

class TransporterRegistrationEvent extends DriverEvent {
  final Map<String, dynamic> registrationData;

  const TransporterRegistrationEvent({required this.registrationData});

  @override
  List<Object?> get props => [registrationData];
}
