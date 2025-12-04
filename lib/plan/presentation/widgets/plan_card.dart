import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/api/api_model/payment/payment_model.dart';
import 'package:r_w_r/screens/widgets/gradient_button.dart';
import '../../../api/api_service/payment_service/payment_service.dart';
import '../../../bloc/payment/payment_bloc.dart';
import '../../../bloc/payment/payment_event.dart';
import '../../../bloc/payment/payment_state.dart';
import '../../../utils/color.dart';
import '../../data/models/plan_model.dart';

class PlanCard extends StatelessWidget {
  final PlanModel plan;
  final String category;

  const PlanCard({super.key, required this.plan, required this.category});

  @override
  Widget build(BuildContext context) {
    final features = plan.features;
    final discount = plan.earlyBirdDiscountPercentage;
    final price = plan.finalPrice;

    return BlocConsumer<PaymentBloc, PaymentState>(
      listener: (context, state) {
        if (state is PaymentOrderCreated) {
          /// ✅ Open Razorpay checkout
          context.read<PaymentBloc>().openRazorpayCheckout(state.orderData);
        }

        if (state is PaymentCompleted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Payment Completed Successfully!')),
          );

          // You can navigate to a success or next screen
          Navigator.pop(context, true);
        }

        if (state is PaymentError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is PaymentLoading || state is PaymentProcessing;
        return Container(
          width: 225,
          alignment: Alignment.topCenter,
          height: 381,
          padding: const EdgeInsets.all(0.5),
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFF641BB4), Color(0xFFB66A53)]),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(),
            ),
            child: ListView(
              // ✅ ensures container wraps content
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("₹ $price", style: const TextStyle(fontSize: 20)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Colors.purple, Colors.orange],
                        ),
                      ),
                      child: Text(
                        "$discount% Off",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  "Benefits:",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),

                // ✅ Remove Expanded & use Column for wrapping content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: features
                      .map(
                        (feature) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                color: Colors.green,
                                width: 18,
                                height: 18,
                                child: const Icon(Icons.check,
                                    color: Colors.white, size: 15),
                              ),
                              const SizedBox(width: 6),
                              Expanded(child: Text(feature)),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),

                const SizedBox(height: 12),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 50),
                  child: GradientButton(
                      text: "Continue",
                      onPressed: () {
                        //  context.read<PaymentBloc>().add(event)
                     /*   context.read<PaymentBloc>().add(
                              InitiatePayment(
                                plan: Plan(
                                    id: plan.id,
                                    name: plan.name,
                                    planFor: plan.planFor,
                                    subscriptionGrossPricePerMonth:
                                        plan.pricePerMonth.toInt() ?? 0,
                                    durationInMonths: plan.durationInMonths,
                                    subscriptionGrossPriceTotal:
                                        plan.grossPrice.toInt(),
                                    earlyBirdDiscountPercentage: plan
                                        .earlyBirdDiscountPercentage
                                        .toInt(),
                                    earlyBirdDiscountPrice:
                                        plan.earlyBirdDiscountPrice.toInt(),
                                    subscriptionFinalPrice:
                                        plan.finalPrice.toInt(),
                                    mrp: 0,
                                    price: plan.pricePerMonth.toInt(),
                                    validity: plan.durationInMonths,
                                    featureTitle: "",
                                    features: features,
                                    maxVehicles: plan.maxVehicles,
                                    planType: plan.planType,
                                    isDeleted: false,
                                    isActive: false,
                                    createdAt: "",
                                    updatedAt: ""),
                                planType: plan.planType,
                                paymentType: PaymentType.registrationOnly,
                                category: category,
                              ),
                            );*/
                      },
                      gradientColors: [gradientFirst, gradientSecond]),
                )
              ],
            ),
          ),
        );
      },
    ); /**/
  }
}
