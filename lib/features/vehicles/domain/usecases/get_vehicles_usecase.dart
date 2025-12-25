import '../repositories/vehicle_repository.dart';
import '../entities/vehicle_entity.dart';

class GetVehiclesUseCase {
  final VehicleRepository repository;

  GetVehiclesUseCase(this.repository);

  Future<List<VehicleEntity>> call() {
    return repository.getVehicles();
  }
}
