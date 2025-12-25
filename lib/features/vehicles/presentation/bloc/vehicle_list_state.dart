import '../../domain/entities/vehicle_entity.dart';

abstract class VehicleListState {}

class VehicleInitial extends VehicleListState {}
class VehicleLoading extends VehicleListState {}

class VehicleLoaded extends VehicleListState {
  final List<VehicleEntity> vehicles;
  VehicleLoaded(this.vehicles);
}

class VehicleError extends VehicleListState {
  final String message;
  VehicleError(this.message);
}
