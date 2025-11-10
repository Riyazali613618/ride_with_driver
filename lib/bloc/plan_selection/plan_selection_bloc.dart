import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/bloc/plan_selection/plan_selection_event.dart';
import 'package:r_w_r/bloc/plan_selection/plan_selection_state.dart';
import '../../api/api_model/payment/payment_model.dart';
import '../../api/api_model/user_model/plan_model.dart';
import '../../api/api_service/user_service/plan_service.dart';
import '../../api/api_service/user_service/PaymentStatusService.dart';


class PlanSelectionBloc extends Bloc<PlanSelectionEvent, PlanSelectionState> {
  PlanSelectionBloc() : super(PlanSelectionInitial()) {
    on<FetchPlans>(_onFetchPlans);
    on<SelectPlan>(_onSelectPlan);
    on<NavigateToLayout>(_onNavigateToLayout);
    on<NavigateToRegistration>(_onNavigateToRegistration);
    on<RetryFetchPlans>(_onRetryFetchPlans);
  }

  Future<void> _onFetchPlans(
      FetchPlans event,
      Emitter<PlanSelectionState> emit,
      ) async {
    emit(PlanSelectionLoading());
    try {
      final response = await PlanService.getPlans(event.planType);

      if (!response!.success || response.data == null) {
        emit(PlanSelectionError(
            response.message.isNotEmpty
                ? response.message
                : 'Failed to load plans'
        ));
        return;
      }
      // final plans = response.data!.;
      final plans=[];
      Plan? registrationPlan;
      List<Plan> subscriptionPlans = [];
      if (plans.isNotEmpty) {
        try {
          registrationPlan = plans.firstWhere(
                (plan) => plan.name.toLowerCase().contains('registration'),
          );
        }catch (e){
          registrationPlan = null;
        }
        // subscriptionPlans = plans
        //     .where((plan) => !plan.name.toLowerCase().contains('registration'))
        //     .toList();
      }
      final paymentPhase = PaymentStatusService
          .globalPaymentStatus?.data?.paymentPhase ?? '';
      emit(PlanSelectionLoaded(
        subscriptionPlans: subscriptionPlans,
        registrationPlan: registrationPlan,
        paymentPhase: paymentPhase,
      ));

      // Auto navigate if registration already done
      if (paymentPhase == 'POST_REGISTRATION') {
        add(NavigateToLayout());
      }
    } catch (e) {
      emit(PlanSelectionError('Error loading plans: $e'));
    }
  }

  void _onSelectPlan(
      SelectPlan event,
      Emitter<PlanSelectionState> emit,
      ) {
    // Handle plan selection logic here
  }

  void _onNavigateToLayout(
      NavigateToLayout event,
      Emitter<PlanSelectionState> emit,
      ) {
    emit(PlanSelectionNavigateToLayout());
  }

  void _onNavigateToRegistration(
      NavigateToRegistration event,
      Emitter<PlanSelectionState> emit,
      ) {
    emit(PlanSelectionNavigateToRegistration(event.planType));
  }

  void _onRetryFetchPlans(
      RetryFetchPlans event,
      Emitter<PlanSelectionState> emit,
      ) {
    add(FetchPlans(event.planType,event.planFor,event.countryId,event.stateId));
  }
}
