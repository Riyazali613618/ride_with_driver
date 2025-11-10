import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/screens/transporterRegistration.dart';

import '../api/api_model/payment/payment_model.dart';
import '../bloc/payment/payment_bloc.dart';
import '../bloc/payment/payment_state.dart';
import '../bloc/payment_status/payment_status_bloc.dart';
import '../bloc/payment_status/payment_status_event.dart';
import '../bloc/payment_status/payment_status_state.dart';
import '../bloc/plan_flow/plan_flow_cubit.dart';
import '../bloc/plan_selection/plan_selection_bloc.dart';
import '../bloc/plan_selection/plan_selection_event.dart';
import '../bloc/plan_selection/plan_selection_state.dart';
import '../constants/color_constants.dart';
import '../l10n/app_localizations.dart';
import '../utils/color.dart';
import 'layout.dart';

class PlanSelectionView extends StatefulWidget {
  final String planType;
  final String planFor;
  final String countryId;
  final String stateId;

  const PlanSelectionView(
      {super.key,
      required this.planType,
      required this.planFor,
      required this.countryId,
      required this.stateId});

  @override
  State<PlanSelectionView> createState() => _PlanSelectionViewState();
}

class _PlanSelectionViewState extends State<PlanSelectionView> {
  @override
  void initState() {
    super.initState();
    _initData();
  }

  void _initData() {
    // Listen to payment status first
    context.read<PaymentStatusBloc>().stream.listen((state) {
      if (state is PaymentStatusLoaded) {
        final paymentPhase = state.paymentStatus.data?.paymentPhase;

        if (paymentPhase != 'PRE_REGISTRATION') {
          // Fetch plans only if not in pre-registration phase
          context.read<PlanSelectionBloc>().add(FetchPlans(widget.planType,
              widget.planFor, widget.countryId, widget.stateId));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              gradientFirst,
              gradientSecond,
              gradientThird,
              Colors.white
            ],
            stops: [0.0, 0.15, 0.30, .90],
          ),
        ),
        child: MultiBlocListener(
          listeners: [
            // Payment Status Listener
            BlocListener<PaymentStatusBloc, PaymentStatusState>(
              listener: (context, state) {
                if (state is PaymentStatusError) {
                  context.read<PlanFlowCubit>().setError(state.message);
                } else if (state is PaymentStatusLoaded) {
                  final paymentPhase = state.paymentStatus.data?.paymentPhase;
                  print("22222222222222222222222222222222222222222222");
                  if (paymentPhase == 'PRE_REGISTRATION') {
                    // Fetch plans only if not in pre-registration phase
                    context.read<PlanSelectionBloc>().add(FetchPlans(
                        widget.planType,
                        widget.planFor,
                        widget.countryId,
                        widget.stateId));
                  }
                }
              },
            ),
            // Plan Selection Listener
            BlocListener<PlanSelectionBloc, PlanSelectionState>(
              listener: (context, state) {
                if (state is PlanSelectionNavigateToLayout) {
                  print("""""" """""" """""" """""2""" """""" """""" """""" "");
                  _navigateToLayout(context);
                } else if (state is PlanSelectionNavigateToRegistration) {
                  print("""""" """""" """""" """""3""" """""" """""" """""" "");
                  _navigateToRegistration(context, state.planType);
                } else if (state is PlanSelectionError) {
                  print("""""" """""" """""" """""4""" """""" """""" """""" "");
                  context.read<PlanFlowCubit>().setError(state.message);
                }
              },
            ),
            // Payment Listener
            BlocListener<PaymentBloc, PaymentState>(
              listener: (context, state) {
                print(
                    '[PlanSelectionView] Payment state changed: ${state.runtimeType}');
                if (state is PaymentOrderCreated) {
                  print("""""" """""" """""" """""5""" """""" """""" """""" "");
                  print(
                      '[PlanSelectionView] PaymentOrderCreated detected, opening Razorpay checkout');
                  print('[PlanSelectionView] Order data: ${state.orderData}');
                  // Call both immediate and delayed checkout to ensure it opens
                  try {
                    context
                        .read<PaymentBloc>()
                        .openRazorpayCheckout(state.orderData);
                    print(
                        '[PlanSelectionView] Immediate Razorpay checkout call completed');
                  } catch (e) {
                    print(
                        '[PlanSelectionView] Error in immediate Razorpay call: $e');
                  }
                } else if (state is PaymentCompleted) {
                  print(
                      '[PlanSelectionView] PaymentCompleted detected, navigating to registration');
                  print("""""" """""" """""" """""6""" """""" """""" """""" "");
                  _navigateToRegistration(context, state.planType);
                } else if (state is PaymentError) {
                  print("""""" """""" """""" """""7""" """""" """""" """""" "");
                  print(
                      '[PlanSelectionView] PaymentError detected: ${state.message}');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is PaymentLoading) {
                  print("""""" """""" """""" """""8""" """""" """""" """""" "");
                  print('[PlanSelectionView] PaymentLoading detected');
                } else if (state is PaymentProcessing) {
                  print("""""" """""" """""" """""9""" """""" """""" """""" "");
                  print('[PlanSelectionView] PaymentProcessing detected');
                }
              },
            ),
          ],
          child: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(context),
                SafeArea(child: _buildBody(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: ColorConstants.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.choose_right_plan,
                  style: const TextStyle(
                    color: ColorConstants.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  localizations.choose_plan_description,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return BlocBuilder<PlanFlowCubit, PlanFlowState>(
      builder: (context, flowState) {
        if (flowState.error != null) {
          return _buildErrorCard(context, flowState.error!);
        }

        return BlocBuilder<PaymentStatusBloc, PaymentStatusState>(
          builder: (context, paymentState) {
            if (paymentState is PaymentStatusLoading) {
              return _buildLoadingWidget(context);
            }

            if (paymentState is PaymentStatusLoaded) {
              final paymentPhase =
                  paymentState.paymentStatus.data?.paymentPhase;

              /*if (paymentPhase == 'PRE_REGISTRATION') {
                return _buildPaymentSuccessCard(context);
              }*/

              return BlocBuilder<PlanSelectionBloc, PlanSelectionState>(
                builder: (context, planState) {
                  if (planState is PlanSelectionLoading) {
                    return _buildLoadingWidget(context);
                  }

                  if (planState is PlanSelectionLoaded) {
                    /*if (planState.subscriptionPlans.isEmpty) {
                      return _buildEmptyPlansCard(context);
                    }*/

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (planState.registrationPlan != null) ...[
                            _buildRegistrationFeesContainer(
                                context, planState.registrationPlan!),
                            const SizedBox(height: 24),
                          ],
                          _buildPlansContainer(
                              context, planState.subscriptionPlans),
                        ],
                      ),
                    );
                  }

                  return _buildEmptyPlansCard(context);
                },
              );
            }

            return _buildLoadingWidget(context);
          },
        );
      },
    );
  }

  Widget _buildLoadingWidget(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            localizations.loading_plans,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRegistrationFeesContainer(
      BuildContext context, Plan registrationPlan) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: ColorConstants.primaryColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      registrationPlan.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      registrationPlan.featureTitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withAlpha(10),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: ColorConstants.primaryColor.withAlpha(30),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        registrationPlan.featureTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      if (registrationPlan.features.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        ...registrationPlan.features.map(
                          (feature) => Text(
                            '• $feature',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 8),
                      Text(
                        '₹${registrationPlan.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // BlocBuilder<PaymentBloc, PaymentState>(
          //   builder: (context, state) {
          //     final isLoading = state is PaymentLoading;
          //
          //     return GestureDetector(
          //       onTap: (){
          //         Navigator.push(context, MaterialPageRoute<void>(
          //           builder: (BuildContext context) => BecomeTransporterScreen(),
          //         ),);
          //       },
          //
          //       // isLoading ? null : () {
          //       //   context.read<PaymentBloc>().add(
          //       //     InitiatePayment(
          //       //       plan: registrationPlan,
          //       //       planType: widget.planType,
          //       //       paymentType: PaymentType.registrationOnly,
          //       //       category: widget.planType,
          //       //     ),
          //       //   );
          //       // },
          //       child: Container(
          //         padding: const EdgeInsets.symmetric(
          //             horizontal: 20, vertical: 10),
          //         decoration: BoxDecoration(
          //           color: ColorConstants.primaryColor,
          //           borderRadius: BorderRadius.circular(8),
          //         ),
          //         child: isLoading
          //             ? const SizedBox(
          //           height: 20,
          //           width: 20,
          //           child: CircularProgressIndicator(
          //             strokeWidth: 2,
          //             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          //           ),
          //         )
          //             : Text(
          //           localizations.apply_now,
          //           style: const TextStyle(
          //             fontSize: 14,
          //             fontWeight: FontWeight.w600,
          //             color: Colors.white,
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildPlansContainer(
      BuildContext context, List<Plan> subscriptionPlans) {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star,
                  color: Colors.orange,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.chooseYourPlan,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      localizations.chooseYourPlanDesc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 450,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: subscriptionPlans.length,
            itemBuilder: (context, index) {
              final plan = subscriptionPlans[index];
              bool isPro = index == 0; // First card will have pro styling
              return Container(
                width: 280,
                margin: const EdgeInsets.only(right: 16),
                child: _buildPlanCard(context, plan, isPro, subscriptionPlans),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPlanCard(BuildContext context, Plan plan, bool isPro,
      List<Plan> subscriptionPlans) {
    final localizations = AppLocalizations.of(context)!;
    final bool hasDiscount = plan.mrp != null && plan.mrp! > plan.price;
    final double? discountPercentage =
        hasDiscount ? ((plan.mrp! - plan.price) / plan.mrp! * 100) : null;

    return GestureDetector(
      onTap: () {
        if (subscriptionPlans.isNotEmpty) {
          _showPaymentBottomSheet(
              context, plan); // Pass the selected plan instead of first plan
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: isPro
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    ColorConstants.primaryColor,
                    ColorConstants.primaryColor.withOpacity(0.8),
                  ],
                )
              : LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: isPro
                  ? ColorConstants.primaryColor.withOpacity(0.3)
                  : Colors.black.withOpacity(0.1),
              blurRadius: isPro ? 20 : 15,
              offset: const Offset(0, 8),
              spreadRadius: isPro ? 2 : 0,
            ),
          ],
          border: Border.all(
            color: isPro ? Colors.white.withOpacity(0.3) : Colors.grey.shade200,
            width: isPro ? 1.5 : 1,
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isPro ? Colors.white : Colors.black87,
                          letterSpacing: -0.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isPro) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'RECOMMENDED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Price section with MRP
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '₹${plan.price.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isPro ? Colors.white : Colors.black87,
                        height: 1,
                      ),
                    ),
                    if (hasDiscount) ...[
                      const SizedBox(width: 8),
                      Text(
                        '₹${plan.mrp!.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isPro ? Colors.white70 : Colors.grey.shade600,
                          decoration: TextDecoration.lineThrough,
                          decorationColor:
                              isPro ? Colors.white70 : Colors.grey.shade600,
                          decorationThickness: 2,
                        ),
                      ),
                    ],
                  ],
                ),
                if (hasDiscount) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isPro
                            ? [Colors.white, Colors.white.withOpacity(0.9)]
                            : [Colors.green.shade400, Colors.green.shade500],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: isPro
                              ? Colors.white.withOpacity(0.3)
                              : Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_offer,
                          size: 14,
                          color: isPro
                              ? ColorConstants.primaryColor
                              : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${discountPercentage!.toStringAsFixed(0)}% OFF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPro
                                ? ColorConstants.primaryColor
                                : Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 10),

            // Feature title with icon
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isPro
                        ? Colors.white.withOpacity(0.2)
                        : ColorConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.star_rounded,
                    size: 16,
                    color: isPro ? Colors.white : ColorConstants.primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    plan.featureTitle,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPro ? Colors.white : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Features list with enhanced styling
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: plan.features
                      .take(5)
                      .map((feature) => Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isPro
                                  ? Colors.white.withOpacity(0.1)
                                  : Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isPro
                                    ? Colors.white.withOpacity(0.2)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: isPro
                                        ? Colors.white.withOpacity(0.2)
                                        : ColorConstants.primaryColor
                                            .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    Icons.check_circle_rounded,
                                    size: 12,
                                    color: isPro
                                        ? Colors.white
                                        : ColorConstants.primaryColor,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: isPro
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.black87,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              ),
            ),
            _buildApplyButton(context,
                isPro: isPro, plan: plan, subscriptionPlans: subscriptionPlans),
          ],
        ),
      ),
    );
  }

  Widget _buildApplyButton(BuildContext context,
      {required bool isPro,
      required Plan plan,
      required List<Plan> subscriptionPlans}) {
    final localizations = AppLocalizations.of(context)!;

    return BlocBuilder<PaymentBloc, PaymentState>(
      builder: (context, state) {
        final isLoading = state is PaymentLoading;

        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (BuildContext context) =>
                    TransporterRegistrationFlow(),
              ),
            );
          },

          // (isLoading || subscriptionPlans.isEmpty) ? null : () {
          //   _showPaymentBottomSheet(context, plan); // Pass the selected plan directly
          // },
          child: Container(
            height: 40,
            width: 300,
            decoration: BoxDecoration(
              color: isPro ? Colors.white : ColorConstants.primaryColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isPro ? ColorConstants.primaryColor : Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      localizations.apply_now,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color:
                            isPro ? ColorConstants.primaryColor : Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.error_outline,
                    size: 40,
                    color: Colors.red.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.oops_something_wrong,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  error,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PlanFlowCubit>().reset();
                    context
                        .read<PaymentStatusBloc>()
                        .add(FetchPaymentStatus(widget.planType));
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(localizations.retry),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentSuccessCard(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 12,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorConstants.primaryColor,
                  ColorConstants.primaryColor.withAlpha(200),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      size: 60,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    localizations.payment_successful_title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    localizations.payment_success_message,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<PlanFlowCubit, PlanFlowState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.isNavigating
                              ? null
                              : () {
                                  context
                                      .read<PlanFlowCubit>()
                                      .setNavigating(true);
                                  context.read<PlanSelectionBloc>().add(
                                      NavigateToRegistration(
                                          widget.planType,
                                          widget.planFor,
                                          widget.countryId,
                                          widget.stateId));
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: ColorConstants.primaryColor,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 4,
                          ),
                          child: state.isNavigating
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      ColorConstants.primaryColor,
                                    ),
                                  ),
                                )
                              : Text(
                                  localizations.complete_registration,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyPlansCard(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.inbox_outlined,
                    size: 40,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  localizations.no_plans_available,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  localizations.no_plans_message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<PlanSelectionBloc>().add(RetryFetchPlans(
                        widget.planType,
                        widget.planFor,
                        widget.countryId,
                        widget.stateId));
                  },
                  icon: const Icon(Icons.refresh),
                  label: Text(localizations.refresh),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ColorConstants.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Navigation methods
  void _navigateToLayout(BuildContext context) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => Layout(initialIndex: 1),
      ),
    );
  }

  void _navigateToRegistration(BuildContext context, String planType) {
    Navigator.of(context).pop();
    // navigateBasedOnPlanType(context, planType);
  }

  // void _showLoadingDialog(BuildContext context) {
  //   final localizations = AppLocalizations.of(context)!;
  //
  //   showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         child: Padding(
  //           padding: const EdgeInsets.all(20.0),
  //           child: Row(
  //             mainAxisSize: MainAxisSize.min,
  //             children: [
  //               const CircularProgressIndicator(),
  //               const SizedBox(width: 20),
  //               Text(localizations.processing_payment),
  //             ],
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  void _showPaymentBottomSheet(BuildContext context, Plan plan) {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (context) => BlocProvider.value(
    //     value: context.read<PaymentBloc>(),
    //     child: PaymentBottomSheetBlocView(
    //       plan: plan,
    //       planType: widget.planType,
    //       paymentType: PaymentType.registrationWithSubscription,
    //       category: widget.planType,
    //     ),
    //   ),
    // );
  }
}
