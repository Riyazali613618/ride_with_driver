import 'package:equatable/equatable.dart';

abstract class VehicleState extends Equatable {
  const VehicleState();

  @override
  List<Object?> get props => [];
}

class VehicleInitial extends VehicleState {
  const VehicleInitial();
}

class VehicleLoading extends VehicleState {
  const VehicleLoading();
}

class VehicleAddSuccess extends VehicleState {
  final String message;
  final Map<String, dynamic> vehicleData;

  const VehicleAddSuccess({required this.message, required this.vehicleData});

  @override
  List<Object?> get props => [message, vehicleData];
}

class VehicleSearchSuccess extends VehicleState {
  final List<Map<String, dynamic>> vehicles;

  const VehicleSearchSuccess({required this.vehicles});

  @override
  List<Object?> get props => [vehicles];
}

class VehicleTypesLoaded extends VehicleState {
  final List<Map<String, dynamic>> vehicleTypes;

  const VehicleTypesLoaded({required this.vehicleTypes});

  @override
  List<Object?> get props => [vehicleTypes];
}

class VehicleUpdateSuccess extends VehicleState {
  final String message;
  final Map<String, dynamic> updatedVehicleData;

  const VehicleUpdateSuccess({required this.message, required this.updatedVehicleData});

  @override
  List<Object?> get props => [message, updatedVehicleData];
}

class VehicleDeleteSuccess extends VehicleState {
  final String message;

  const VehicleDeleteSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class VehicleError extends VehicleState {
  final String message;

  const VehicleError({required this.message});

  @override
  List<Object?> get props => [message];
}
