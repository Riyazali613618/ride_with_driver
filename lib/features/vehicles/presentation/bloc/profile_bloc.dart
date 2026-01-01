import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_repository.dart';

import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc(this.repository) : super(ProfileInitial()) {
    on<CheckVehicleLimitEvent>(_onCheckVehicleLimit);
  }

  Future<void> _onCheckVehicleLimit(
    CheckVehicleLimitEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final profile = await repository.fetchUserProfile();
      Map<String, dynamic> map = profile['data'];
      final int vehicleLimit = map['vehicleLimit'];
      final List vehicles = map['vehicles'];

      if (vehicles.length < vehicleLimit) {
        emit(VehicleAllowedState());
      } else {
        emit(VehicleLimitExceededState());
      }
    } catch (e) {
      emit(ProfileErrorState(e.toString()));
    }
  }
}
