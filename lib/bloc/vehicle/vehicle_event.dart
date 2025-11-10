import 'package:equatable/equatable.dart';

abstract class VehicleEvent extends Equatable {
  const VehicleEvent();

  @override
  List<Object?> get props => [];
}

class AddVehicleEvent extends VehicleEvent {
  final Map<String, dynamic> vehicleData;

  const AddVehicleEvent({required this.vehicleData});

  @override
  List<Object?> get props => [vehicleData];
}

class SearchVehiclesEvent extends VehicleEvent {
  final Map<String, dynamic> searchCriteria;

  const SearchVehiclesEvent({required this.searchCriteria});

  @override
  List<Object?> get props => [searchCriteria];
}

class LoadVehicleTypesEvent extends VehicleEvent {
  const LoadVehicleTypesEvent();
}

class UpdateVehicleEvent extends VehicleEvent {
  final String vehicleId;
  final Map<String, dynamic> updateData;

  const UpdateVehicleEvent({required this.vehicleId, required this.updateData});

  @override
  List<Object?> get props => [vehicleId, updateData];
}

class DeleteVehicleEvent extends VehicleEvent {
  final String vehicleId;

  const DeleteVehicleEvent({required this.vehicleId});

  @override
  List<Object?> get props => [vehicleId];
}
