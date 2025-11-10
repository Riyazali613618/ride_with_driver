// lib/features/transporter_registration/presentation/cubit/transporter_form_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/transporterRegistration/presentation/transporter_form_state.dart';

import '../../api/api_model/registrations/transporter_model.dart';

class TransporterFormCubit extends Cubit<TransporterFormState> {
  TransporterFormCubit() : super(TransporterFormState.initial());

  void updateModel(TransporterModel updated) {
    emit(state.copyWith(model: updated));
  }

  void setStep(int step) {
    emit(state.copyWith(currentStep: step));
  }

  void nextStep() {
    if (state.currentStep < 3) emit(state.copyWith(currentStep: state.currentStep + 1));
  }

  void previousStep() {
    if (state.currentStep > 0) emit(state.copyWith(currentStep: state.currentStep - 1));
  }

  void setLoading(bool loading) => emit(state.copyWith(isLoading: loading));
}
