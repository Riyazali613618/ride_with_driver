import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rwd/screens/profileScreens/carOwnerProfile/bloc/car_owner_profile_state.dart';
import 'package:rwd/screens/profileScreens/carOwnerProfile/car_owner_profile_repository.dart';

import '../../../../features/vehicles/presentation/bloc/profile_state.dart' hide ProfileLoading;
import 'car_owner_profile_event.dart';

class CarOwnerProfileBloc extends Bloc<CarOwnerEvent, CarOwnerProfileState> {
  final CarOwnerProfileRepository repository;

  CarOwnerProfileBloc(this.repository) : super(ProfileLoading()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      try {
        final profile = await repository.getProfile();
        emit(ProfileLoaded(profile));
      } catch (e) {
        emit(ProfileError(e.toString()));
      }
    });

    on<CarOwnerProfileEvent>((event, emit) async {
      await repository.updateProfile(event.body);
      add(LoadProfile());
    });
  }
}
