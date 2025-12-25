import '../entities/vehicle_entity.dart';

abstract class VehicleRepository {
  Future<List<VehicleEntity>> getVehicles();
}
