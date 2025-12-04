import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/api/api_model/payment/payment_model.dart';
import 'package:r_w_r/screens/transporterRegistration.dart';
import '../../api/api_model/user_model/plan_model.dart';
import '../../api/api_service/payment_service/payment_service.dart';
import '../../bloc/payment/payment_bloc.dart';
import '../../bloc/payment/payment_event.dart';
import '../../bloc/payment/payment_state.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/data/models/plan_model.dart';
import '../autoRikshawDriverRegistration.dart';
import '../driverRegistrationScreen.dart';
import '../eRickshawRegistration.dart';
import '../independentCarOwnerRegistration.dart';
import '../registration_screens/auto_rikshaw_registration_screenn.dart';
import '../registration_screens/become_driver_registration_screen.dart';
import '../registration_screens/e_rikshaw_registration_screen.dart';
import '../registration_screens/indipendent_car_owner_registration_screen.dart';
import '../registration_screens/transporter_registration_screen.dart';

class PaymentBottomSheetBlocView extends StatefulWidget {
  final PlanModel plan;
  final String planType;
  final PaymentType paymentType;
  final String? category;

  const PaymentBottomSheetBlocView({
    Key? key,
    required this.plan,
    required this.planType,
    this.paymentType = PaymentType.subscriptionRenewal,
    this.category,
  }) : super(key: key);

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
    context.read<PaymentBloc>().stream.listen((state) {
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
            context.read<PaymentBloc>().openRazorpayCheckout(state.orderData);
            print('[PaymentBottomSheet] Razorpay checkout call completed');
          } catch (e) {
            print('[PaymentBottomSheet] Error opening Razorpay: $e');
          }
        });
      } else if (state is PaymentCompleted) {
        print(
            '[PaymentBottomSheet] PaymentCompleted detected - navigating and closing');
        Navigator.pop(context);
        Navigator.pop(context);
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
                      _buildPlanCard(),
                      const SizedBox(height: 24),
                      // Payment type indicator
                      _buildPaymentTypeIndicator(),
                      const SizedBox(height: 24),
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

  Widget _buildPaymentTypeIndicator() {
    String paymentTypeText;
    Color indicatorColor;

    switch (widget.paymentType) {
      case PaymentType.subscriptionRenewal:
        paymentTypeText = 'Subscription Renewal';
        indicatorColor = Colors.blue;
        break;
      case PaymentType.registrationOnly:
        paymentTypeText = 'Registration Only';
        indicatorColor = Colors.green;
        break;
      case PaymentType.registrationWithSubscription:
        paymentTypeText = 'Registration + Subscription';
        indicatorColor = Colors.purple;
        break;
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: indicatorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: indicatorColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            paymentTypeText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: indicatorColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard() {
    bool isPro = true;
    final localizations = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isPro ? ColorConstants.primaryColor : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isPro ? null : Border.all(color: Colors.grey.shade200),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.plan.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isPro ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹ ${widget.plan.earlyBirdDiscountPrice.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: isPro ? Colors.white : Colors.black,
                ),
              ),
              const SizedBox(width: 8),
              if (widget.plan.earlyBirdDiscountPercentage > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPro
                        ? Colors.white.withOpacity(0.2)
                        : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    localizations.discount_percentage_off(
                        widget.plan.earlyBirdDiscountPercentage.toStringAsFixed(0)),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isPro ? Colors.white : Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            widget.plan.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isPro ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.plan.features
              .map((feature) => isPro
                  ? _buildProFeatureItem(feature)
                  : _buildFeatureItem(feature))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade200,
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.checkmark_alt,
                size: 12,
                color: Colors.grey,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: const Center(
              child: Icon(
                CupertinoIcons.checkmark_alt,
                size: 12,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ],
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
              Text(
                localizations.total,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Rs ${widget.plan.earlyBirdDiscountPrice.toStringAsFixed(2)}',
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
                                plan: widget.plan,
                                planType: widget.planType,
                                paymentType: widget.paymentType,
                                category: widget.category,
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
  if (planType == 'DRIVER') {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => DriverRegistrationFlow(),
      ),
    );
  } else if (planType == 'RICKSHAW') {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => AutoRickshawDriverFlow(),
      ),
    );
  } else if (planType == 'E_RICKSHAW') {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ERickshawDriverFlow(),
      ),
    );
  } else if (planType == 'TRANSPORTER') {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => TransporterRegistrationFlow(),
      ),
    );
  } else if (planType == 'INDEPENDENT_CAR_OWNER') {
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
