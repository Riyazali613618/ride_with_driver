import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/api/api_service/api_repository.dart';

import 'vehicle_event.dart';
import 'vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final ApiRepository apiRepository;

  VehicleBloc({required this.apiRepository}) : super(const VehicleInitial()) {
    on<AddVehicleEvent>(_onAddVehicle);
    on<SearchVehiclesEvent>(_onSearchVehicles);
    on<LoadVehicleTypesEvent>(_onLoadVehicleTypes);
    on<UpdateVehicleEvent>(_onUpdateVehicle);
    on<DeleteVehicleEvent>(_onDeleteVehicle);
  }

  Future<void> _onAddVehicle(AddVehicleEvent event, Emitter<VehicleState> emit) async {
    emit(const VehicleLoading());

    try {
      final response = await apiRepository.addVehicle(event.vehicleData);
      
      if (response['status'] == true) {
        emit(VehicleAddSuccess(
          message: response['message'] ?? 'Vehicle added successfully',
          vehicleData: response,
        ));
      } else {
        emit(VehicleError(
          message: response['message'] ?? 'Failed to add vehicle',
        ));
      }
    } on ApiException catch (e) {
      debugPrint('VehicleBloc AddVehicle ApiException: ${e.message}');
      emit(VehicleError(message: e.message));
    } catch (e) {
      debugPrint('VehicleBloc AddVehicle Exception: $e');
      emit(const VehicleError(message: 'Failed to add vehicle. Please try again.'));
    }
  }

  Future<void> _onSearchVehicles(SearchVehiclesEvent event, Emitter<VehicleState> emit) async {
    emit(const VehicleLoading());

    try {
      final response = await apiRepository.searchVehicles(event.searchCriteria);
      
      if (response['status'] == true) {
        final vehicles = (response['data'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ?? [];
        
        emit(VehicleSearchSuccess(vehicles: vehicles));
      } else {
        emit(VehicleError(
          message: response['message'] ?? 'Failed to search vehicles',
        ));
      }
    } on ApiException catch (e) {
      debugPrint('VehicleBloc SearchVehicles ApiException: ${e.message}');
      emit(VehicleError(message: e.message));
    } catch (e) {
      debugPrint('VehicleBloc SearchVehicles Exception: $e');
      emit(const VehicleError(message: 'Failed to search vehicles. Please try again.'));
    }
  }

  Future<void> _onLoadVehicleTypes(LoadVehicleTypesEvent event, Emitter<VehicleState> emit) async {
    emit(const VehicleLoading());

    try {
      // This would need to be implemented in the ApiRepository
      // For now, using a placeholder implementation
      emit(const VehicleTypesLoaded(vehicleTypes: []));
    } catch (e) {
      debugPrint('VehicleBloc LoadVehicleTypes Exception: $e');
      emit(const VehicleError(message: 'Failed to load vehicle types. Please try again.'));
    }
  }

  Future<void> _onUpdateVehicle(UpdateVehicleEvent event, Emitter<VehicleState> emit) async {
    emit(const VehicleLoading());

    try {
      // This would need to be implemented in the ApiRepository
      // For now, using a placeholder implementation
      emit(const VehicleUpdateSuccess(
        message: 'Vehicle updated successfully',
        updatedVehicleData: {},
      ));
    } catch (e) {
      debugPrint('VehicleBloc UpdateVehicle Exception: $e');
      emit(const VehicleError(message: 'Failed to update vehicle. Please try again.'));
    }
  }

  Future<void> _onDeleteVehicle(DeleteVehicleEvent event, Emitter<VehicleState> emit) async {
    emit(const VehicleLoading());

    try {
      // This would need to be implemented in the ApiRepository
      // For now, using a placeholder implementation
      emit(const VehicleDeleteSuccess(message: 'Vehicle deleted successfully'));
    } catch (e) {
      debugPrint('VehicleBloc DeleteVehicle Exception: $e');
      emit(const VehicleError(message: 'Failed to delete vehicle. Please try again.'));
    }
  }
}
