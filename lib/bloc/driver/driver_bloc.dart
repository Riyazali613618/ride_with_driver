import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/api/api_model/registrations/auto_rikshaw_registration_model.dart';
import 'package:r_w_r/api/api_model/rating_and_reviews_model/indicar_model.dart';
import 'package:r_w_r/api/api_service/api_repository.dart';
import 'package:r_w_r/api/api_service/registration_services/become_driver_registration_service.dart';
import 'package:r_w_r/api/api_service/registration_services/e_rekshaw_registration_service.dart';

import 'driver_event.dart';
import 'driver_state.dart';

class DriverBloc extends Bloc<DriverEvent, DriverState> {
  final ApiRepository apiRepository;

  DriverBloc({required this.apiRepository}) : super(const DriverInitial()) {
    on<LoadDriverProfileEvent>(_onLoadDriverProfile);
    on<UpdateDriverProfileEvent>(_onUpdateDriverProfile);
    on<DriverRegistrationEvent>(_onDriverRegistration);
    on<LoadDriverDetailsEvent>(_onLoadDriverDetails);
    on<BecomeDriverRegistrationEvent>(_onBecomeDriverRegistration);
    on<AutoRikshawRegistrationEvent>(_onAutoRikshawRegistration);
    on<ERikshawRegistrationEvent>(_onERikshawRegistration);
    on<TransporterRegistrationEvent>(_onTransporterRegistration);
  }

  Future<void> _onLoadDriverProfile(LoadDriverProfileEvent event, Emitter<DriverState> emit) async {
    emit(const DriverLoading());

    try {
      // This would need to be implemented in the ApiRepository
      // For now, using placeholder implementation
      emit(const DriverProfileLoaded(profileData: {}));
    } catch (e) {
      debugPrint('DriverBloc LoadDriverProfile Exception: $e');
      emit(const DriverError(message: 'Failed to load driver profile. Please try again.'));
    }
  }

  Future<void> _onUpdateDriverProfile(UpdateDriverProfileEvent event, Emitter<DriverState> emit) async {
    emit(const DriverLoading());

    try {
      // This would need to be implemented in the ApiRepository
      // For now, using placeholder implementation
      emit(DriverProfileUpdateSuccess(
        message: 'Driver profile updated successfully',
        updatedProfileData: event.profileData,
      ));
    } catch (e) {
      debugPrint('DriverBloc UpdateDriverProfile Exception: $e');
      emit(const DriverError(message: 'Failed to update driver profile. Please try again.'));
    }
  }

  Future<void> _onDriverRegistration(DriverRegistrationEvent event, Emitter<DriverState> emit) async {
    emit(const DriverLoading());

    try {
      // This would need to be implemented in the ApiRepository
      // For now, using placeholder implementation
      emit(DriverRegistrationSuccess(
        message: 'Driver registration completed successfully',
        registrationData: event.registrationData,
      ));
    } catch (e) {
      debugPrint('DriverBloc DriverRegistration Exception: $e');
      emit(const DriverError(message: 'Failed to complete driver registration. Please try again.'));
    }
  }

  Future<void> _onLoadDriverDetails(LoadDriverDetailsEvent event, Emitter<DriverState> emit) async {
    emit(const DriverLoading());

    try {
      // This would need to be implemented in the ApiRepository
      // For now, using placeholder implementation
      emit(const DriverDetailsLoaded(driverDetails: {}));
    } catch (e) {
      debugPrint('DriverBloc LoadDriverDetails Exception: $e');
      emit(const DriverError(message: 'Failed to load driver details. Please try again.'));
    }
  }

  Future<void> _onBecomeDriverRegistration(BecomeDriverRegistrationEvent event, Emitter<DriverState> emit) async {
    emit(const DriverLoading());

    try {
      Map<String, dynamic> response;
      
      // Handle different registration types
      if (event.type == 'E_RICKSHAW') {
        // Create E-Rickshaw model from the registration data
        final model = AutoRickshawModel.fromJson(event.data);
        
        // Call the E-Rickshaw API service
        response = await BecomeErickshawService().submitErickshawApplication(model);
      } else {
        // Default case - regular driver registration
        final model = BecomeDriverModel.fromJson(event.data);
        
        // Call the regular driver API service
        response = await BecomeDriverService().submitDriverApplication(model);
      }
      
      if (response['success'] == true) {
        emit(BecomeDriverRegistrationSuccess(
          message: 'Application submitted successfully!',
          registrationData: event.data,
        ));
      } else {
        emit(DriverError(
          message: response['message'] ?? 'Registration failed. Please try again.',
        ));
      }
    } catch (e) {
      debugPrint('DriverBloc BecomeDriverRegistration Exception: $e');
      emit(const DriverError(message: 'Failed to complete driver registration. Please try again.'));
    }
  }

  Future<void> _onAutoRikshawRegistration(AutoRikshawRegistrationEvent event, Emitter<DriverState> emit) async {
    emit(const DriverLoading());

    try {
      // This would need to be implemented in the ApiRepository
      // For now, using placeholder implementation
      emit(AutoRikshawRegistrationSuccess(
        message: 'Auto Rickshaw registration completed successfully',
        registrationData: event.registrationData,
      ));
    } catch (e) {
      debugPrint('DriverBloc AutoRikshawRegistration Exception: $e');
      emit(const DriverError(message: 'Failed to complete Auto Rickshaw registration. Please try again.'));
    }
  }

  Future<void> _onERikshawRegistration(ERikshawRegistrationEvent event, Emitter<DriverState> emit) async {
    emit(const DriverLoading());

    try {
      // Create model from the registration data
      final model = AutoRickshawModel.fromJson(event.registrationData);
      
      // Call the actual API service
      final response = await BecomeErickshawService().submitErickshawApplication(model);
      
      if (response['success'] == true) {
        emit(ERikshawRegistrationSuccess(
          message: 'E-Rickshaw registration completed successfully!',
          registrationData: event.registrationData,
        ));
      } else {
        emit(DriverError(
          message: response['message'] ?? 'E-Rickshaw registration failed. Please try again.',
        ));
      }
    } catch (e) {
      debugPrint('DriverBloc ERikshawRegistration Exception: $e');
      emit(const DriverError(message: 'Failed to complete E-Rickshaw registration. Please try again.'));
    }
  }

  Future<void> _onTransporterRegistration(TransporterRegistrationEvent event, Emitter<DriverState> emit) async {
    emit(const DriverLoading());

    try {
      // This would need to be implemented in the ApiRepository
      // For now, using placeholder implementation
      emit(TransporterRegistrationSuccess(
        message: 'Transporter registration completed successfully',
        registrationData: event.registrationData,
      ));
    } catch (e) {
      debugPrint('DriverBloc TransporterRegistration Exception: $e');
      emit(const DriverError(message: 'Failed to complete transporter registration. Please try again.'));
    }
  }
}
