import 'package:flutter_bloc/flutter_bloc.dart';
import 'vehicle_list_event.dart';
import 'vehicle_list_state.dart';
import '../../domain/usecases/get_vehicles_usecase.dart';

class VehicleListBloc extends Bloc<VehicleListEvent, VehicleListState> {
  final GetVehiclesUseCase getVehicles;

  VehicleListBloc(this.getVehicles) : super(VehicleInitial()) {
    on<FetchVehicles>((event, emit) async {
      emit(VehicleLoading());
      try {
        final vehicles = await getVehicles();
        emit(VehicleLoaded(vehicles));
      } catch (e) {
        emit(VehicleError(e.toString()));
      }
    });
  }
}
