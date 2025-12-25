import '../../domain/entities/vehicle_entity.dart';
import '../../domain/repositories/vehicle_repository.dart';
import '../datasources/vehicle_remote_datasource.dart';

class VehicleRepositoryImpl implements VehicleRepository {
  final VehicleRemoteDatasource remote;

  VehicleRepositoryImpl(this.remote);

  @override
  Future<List<VehicleEntity>> getVehicles() {
    return remote.getVehicles();
  }
}
