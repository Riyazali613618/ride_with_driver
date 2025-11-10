
import '../../api/api_model/registrations/transporter_model.dart';

class TransporterFormState {
  final int currentStep;
  final TransporterModel model;
  final bool isLoading;

  TransporterFormState({
    required this.currentStep,
    required this.model,
    required this.isLoading,
  });

  factory TransporterFormState.initial() => TransporterFormState(
    currentStep: 0,
    model: TransporterModel.empty(),
    isLoading: false,
  );

  TransporterFormState copyWith({
    int? currentStep,
    TransporterModel? model,
    bool? isLoading,
  }) {
    return TransporterFormState(
      currentStep: currentStep ?? this.currentStep,
      model: model ?? this.model,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
