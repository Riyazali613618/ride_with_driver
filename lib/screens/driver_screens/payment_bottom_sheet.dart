import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/features/vehicles/presentation/pages/add_new_vehicle_screen.dart';
import 'package:r_w_r/screens/transporterRegistration.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_service/payment_service/payment_service.dart';
import '../../bloc/payment/payment_bloc.dart';
import '../../bloc/payment/payment_event.dart';
import '../../bloc/payment/payment_state.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/data/models/plan_model.dart';
import '../Eligibility/bloc/eligibility_bloc.dart';
import '../Eligibility/bloc/eligibility_event.dart';
import '../autoRikshawDriverRegistration.dart';
import '../driverRegistrationScreen.dart';
import '../eRickshawRegistration.dart';
import '../independentCarOwnerRegistration.dart';

class PaymentBottomSheetBlocView extends StatefulWidget {
  final PlanModel plan;
  final String planType;
  final double finalPrice;
  final PaymentType paymentType;
  final String? category;
  final String? currentCategory;
  final String vehicleCount;
  final bool isAdOns;

  const PaymentBottomSheetBlocView({
    super.key,
    required this.finalPrice,
    this.isAdOns = false,
    required this.plan,
    required this.currentCategory,
    this.vehicleCount = "",
    required this.planType,
    this.paymentType = PaymentType.subscriptionRenewal,
    this.category,
  });

  @override
  State<PaymentBottomSheetBlocView> createState() =>
      _PaymentBottomSheetBlocViewState();
}

class _PaymentBottomSheetBlocViewState
    extends State<PaymentBottomSheetBlocView> {
  @override
  void initState() {
    super.initState();
    // Listen to Razorpay events through BLoC
    _setupPaymentListeners();
  }

  void _setupPaymentListeners() {
    // The PaymentBloc handles Razorpay events internally
    context.read<PaymentBloc>().stream.listen((state) async {
      print('[PaymentBottomSheet] Payment state changed: ${state.runtimeType}');
      if (state is PaymentOrderCreated) {
        print(
            '[PaymentBottomSheet] PaymentOrderCreated detected - Opening Razorpay checkout');
        print('[PaymentBottomSheet] Order data: ${state.orderData}');

        // Open Razorpay checkout using post-frame callback to ensure UI is ready
        WidgetsBinding.instance.addPostFrameCallback((_) {
          try {
            print(
                '[PaymentBottomSheet] Opening Razorpay in post-frame callback');
            context
                .read<PaymentBloc>()
                .openRazorpayCheckout(state.orderData, isAdOns: widget.isAdOns);
            print('[PaymentBottomSheet] Razorpay checkout call completed');
          } catch (e) {
            print('[PaymentBottomSheet] Error opening Razorpay: $e');
          }
        });
      } else if (state is PaymentCompleted) {
        print(
            '[PaymentBottomSheet] PaymentCompleted detected - navigating and closing');
        if (context.mounted) Navigator.pop(context);
        if (context.mounted) Navigator.pop(context);
        if (widget.isAdOns) {
          SharedPreferences? pref = await SharedPreferences.getInstance();

          Navigator.of(context).pop();
          Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => AddNewVehicleScreen(
                  userType: "${pref.getString('userType')}"),
            ),
          );
        } else
          navigateBasedOnPlanType(context, widget.planType);
      } else if (state is PaymentError) {
        print('[PaymentBottomSheet] PaymentError detected: ${state.message}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ),
      ),
      child: BlocBuilder<PaymentBloc, PaymentState>(
        builder: (context, state) {
          final isLoading =
              state is PaymentLoading || state is PaymentProcessing;

          return isLoading
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                )
              : SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      // Top indicator bar
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        localizations.add_payment,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Plan card
/*
                      _buildPlanCard(),

                      const SizedBox(height: 24),
                      // Payment type indicator
                      _buildPaymentTypeIndicator(),
                      const SizedBox(height: 24),*/
                      _buildTotalAndPaymentButton(),
                      const SizedBox(height: 16),
                      // Bottom indicator bar
                      Container(
                        width: 140,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
        },
      ),
    );
  }

  Widget _buildTotalAndPaymentButton() {
    final localizations = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(widget.finalPrice<=0)
                Text(
                localizations.total+" Pay",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rs ${widget.finalPrice<=0?0:widget.finalPrice.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if(widget.finalPrice<=0)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if(widget.finalPrice<0)
                Text(
                "Return in RWD wallet",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rs ${(widget.finalPrice.abs()).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          BlocBuilder<PaymentBloc, PaymentState>(
            builder: (context, state) {
              final isPaymentInProgress =
                  state is PaymentLoading || state is PaymentProcessing;

              return ElevatedButton(
                onPressed: isPaymentInProgress
                    ? null
                    : () {
                        context.read<PaymentBloc>().add(
                              InitiatePayment(
                                isAdOns: widget.isAdOns,
                                finalPrice: widget.finalPrice,
                                duration: widget.plan.durationInMonths,
                                earlyBirdDiscountPrice:
                                    widget.plan.earlyBirdDiscountPrice,
                                plan: widget.plan,
                                maxvehicles: widget.vehicleCount.isNotEmpty
                                    ? int.parse(widget.vehicleCount)
                                    : widget.plan.maxVehicles,
                                planType: widget.planType,
                                paymentType: widget.paymentType,
                                category: widget.category,
                                currentCategory: widget.currentCategory,
                              ),
                            );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  minimumSize: const Size(double.infinity, 54),
                  elevation: 0,
                ),
                child: isPaymentInProgress
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        localizations.make_payment,
                        style: const TextStyle(
                          fontSize: 16,
                          color: ColorConstants.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// Navigation utility function (remains the same)
void navigateBasedOnPlanType(BuildContext context, String planType) {
  context.read<EligibilityBloc>().add(RefreshEligibilityEvent());
  if (planType == 'DRIVER') {
    Navigator.of(context).pop();
   // Navigator.of(context).pop();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => DriverRegistrationFlow(),
      ),
    );
  } else if (planType == 'RICKSHAW') {
    Navigator.of(context).pop();
   // Navigator.of(context).pop();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AutoRickshawDriverFlow(),
      ),
    );
  } else if (planType == 'E_RICKSHAW') {
    Navigator.of(context).pop();
   // Navigator.of(context).pop();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ERickshawDriverFlow(),
      ),
    );
  } else if (planType == 'TRANSPORTER') {
    Navigator.of(context).pop();
   // Navigator.of(context).pop();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => TransporterRegistrationFlow(),
      ),
    );
  } else if (planType == 'INDEPENDENT_CAR_OWNER') {
    Navigator.of(context).pop();
   // Navigator.of(context).pop();
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => IndependentTaxiOwnerFlow(),
      ),
    );
  } else {
    print("Invalid plan type selected");
  }
}
