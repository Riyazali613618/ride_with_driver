import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rwd/screens/layout.dart';

import '../../api/api_model/user_model/my_profile_model.dart';
import '../../api/api_service/payment_service/payment_service.dart';
import '../../bloc/payment/payment_bloc.dart';
import '../../bloc/payment/payment_event.dart';
import '../../bloc/payment/payment_state.dart';
import '../../constants/color_constants.dart';
import '../../constants/token_manager.dart';
import '../../features/vehicles/presentation/pages/add_new_vehicle_screen.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/data/models/plan_model.dart';
import '../Eligibility/bloc/eligibility_bloc.dart';
import '../Eligibility/bloc/eligibility_event.dart';
import '../autoRikshawDriverRegistration.dart';
import '../driverRegistrationScreen.dart';
import '../eRickshawRegistration.dart';
import '../independentCarOwnerRegistration.dart';
import '../transporterRegistration.dart';

class PaymentBottomSheetBlocView extends StatefulWidget {
  final PlanModel plan;
  final String planType;
  final double rwdBalance;
  final double finalPrice;
  final PaymentType paymentType;
  final String? category;
  final String? currentCategory;
  final String vehicleCount;
  final List<String>? benefits;
  final String planName;
  final bool isAdOns;
  final bool isRenewal;

  const PaymentBottomSheetBlocView({
    super.key,
    required this.plan,
    required this.planType,
    required this.rwdBalance,
    required this.finalPrice,
    required this.currentCategory,
    this.vehicleCount = "",
    this.benefits,
    this.planName = "",
    this.isAdOns = false,
    this.isRenewal = false,
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
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocListener<PaymentBloc, PaymentState>(
      listener: (context, state) async {
        /// 🔹 Order created → open Razorpay
        if (state is PaymentOrderCreated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            context.read<PaymentBloc>().openRazorpayCheckout(
                  state.orderData,
                  isAdOns: widget.isAdOns,
                  isRenewal: state.orderData['description'] ==
                      PaymentType.subscriptionRenewal.name,
                );
          });
        }

        /// 🔹 Payment success
        if (state is PaymentCompleted) {
          if (!mounted) return;

          Navigator.of(context).pop(); // close bottom sheet
          if (widget.isRenewal) {
            Navigator.pushAndRemoveUntil(
              context,
              CupertinoPageRoute(
                builder: (context) => Layout(),
              ),
              (route) => false,
            );
            return;
          } else if (widget.isAdOns) {
            MyProfileData? profile = await TokenManager.getProfile();
            if (!mounted) return;

            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => AddNewVehicleScreen(
                  userType: profile?.usertype ?? "",
                  isFromRegistration: false,
                ),
              ),
            );
          } else {
            navigateBasedOnPlanType(context, widget.planType);
          }
        }

        /// 🔹 Payment error
        if (state is PaymentError) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: BlocBuilder<PaymentBloc, PaymentState>(
          builder: (context, state) {
            final isLoading =
                state is PaymentLoading || state is PaymentProcessing;

            if (isLoading) {
              return const Padding(
                padding: EdgeInsets.all(50),
                child: Center(child: CircularProgressIndicator()),
              );
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  _dragIndicator(),
                  const SizedBox(height: 24),
                  Text(
                    localizations.add_payment,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildTotalAndPaymentButton(context),
                  const SizedBox(height: 16),
                  _dragIndicator(width: 140),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _dragIndicator({double width = 40}) {
    return Container(
      width: width,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildTotalAndPaymentButton(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    double rwdBalance = widget.rwdBalance;
    double payablePrice = widget.finalPrice;
    if (rwdBalance > payablePrice) {
      payablePrice = 0;
      rwdBalance = rwdBalance - payablePrice;
    } else {
      payablePrice = payablePrice - rwdBalance;
      rwdBalance = 0;
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${localizations.total} Pay",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '₹ ${(payablePrice).toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                context.read<PaymentBloc>().add(
                      InitiatePayment(
                        isAdOns: widget.isAdOns,
                        isRenewal: widget.isRenewal,
                        finalPrice: payablePrice,
                        duration: widget.plan.durationInMonths,
                        earlyBirdDiscountPrice:
                            widget.plan.earlyBirdDiscountPrice,
                        plan: widget.plan,
                        planName: widget.planName,
                        benefits: widget.benefits ?? [],
                        maxvehicles: widget.vehicleCount.isNotEmpty
                            ? int.parse(widget.vehicleCount)
                            : widget.plan.maxVehicles,
                        planType: widget.planType,
                        rwdBalance: rwdBalance,
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
              ),
              child: Text(
                localizations.make_payment,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 🔥 SAFE navigation helper
void navigateBasedOnPlanType(BuildContext context, String planType) {
  context.read<EligibilityBloc>().add(RefreshEligibilityEvent());

  Widget screen;
  switch (planType) {
    case 'DRIVER':
      screen = DriverRegistrationFlow();
      break;
    case 'RICKSHAW':
      screen = AutoRickshawDriverFlow();
      break;
    case 'E_RICKSHAW':
      screen = ERickshawDriverFlow();
      break;
    case 'TRANSPORTER':
      screen = TransporterRegistrationFlow();
      break;
    case 'INDEPENDENT_CAR_OWNER':
      screen = IndependentTaxiOwnerFlow();
      break;
    default:
      return;
  }

  Navigator.push(
    context,
    CupertinoPageRoute(builder: (_) => screen),
  );
}
