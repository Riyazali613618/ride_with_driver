import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/payment/payment_bloc.dart';
import '../../bloc/payment_status/payment_status_bloc.dart';
import '../../bloc/payment_status/payment_status_event.dart';
import '../../bloc/plan_flow/plan_flow_cubit.dart';
import '../../bloc/plan_selection/plan_selection_bloc.dart';
import '../PlanSelectionView.dart';

class PlanSelectionScreen extends StatelessWidget {
  final String planType;
  final String planFor;
  final String countryId;
  final String stateId;

  const PlanSelectionScreen({
    super.key,
    required this.planType, required this.planFor, required this.countryId, required this.stateId,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PaymentStatusBloc>(
          create: (context) => PaymentStatusBloc()
            ..add(FetchPaymentStatus(planFor)),
        ),
        BlocProvider<PlanSelectionBloc>(
          create: (context) => PlanSelectionBloc(),
        ),
        BlocProvider<PaymentBloc>(
          create: (context) => PaymentBloc(),
        ),
        BlocProvider<PlanFlowCubit>(
          create: (context) => PlanFlowCubit(),
        ),
      ],
      child: PlanSelectionView(planType: planType, planFor: planFor, countryId: countryId, stateId: stateId,),
    );
  }
}
