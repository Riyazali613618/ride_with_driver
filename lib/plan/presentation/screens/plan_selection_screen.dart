import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/components/app_loader.dart';
import 'package:r_w_r/components/common_parent_container.dart';

import '../../../api/api_service/payment_service/payment_service.dart';
import '../../../bloc/payment/payment_bloc.dart';
import '../../../components/custom_activity.dart';
import '../../../screens/driver_screens/payment_bottom_sheet.dart';
import '../../data/models/plan_model.dart';
import '../bloc/plan_bloc.dart';
import '../bloc/plan_event.dart';
import '../bloc/plan_state.dart';

class PlanSelectionScreen extends StatefulWidget {
  final String currentCategory;
  final String category;
  final String title;

  const PlanSelectionScreen(
      {super.key, required this.title,required this.currentCategory, required this.category});

  @override
  State<PlanSelectionScreen> createState() => _PlanSelectionScreenState();
}

class _PlanSelectionScreenState extends State<PlanSelectionScreen> {
  final pageController = PageController(viewportFraction: 0.80, initialPage: 1);
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<PlanBloc>().add(FetchPlansEvent(
          widget.category,
          "68dabd590b3041213387d616",
          "68e7bd9c20a588293b4cbd0a",
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        bottom: true,
        child: CommonParentContainer(
          child: BlocBuilder<PlanBloc, PlanState>(
            builder: (context, state) {
              if (state.loading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state.error != null) {
                return Center(child: Text(state.error!));
              }

              if (state.plans == null) {
                return const Center(child: Text("No plans available"));
              }
              final plans = state.plans ?? [];
              return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 40,
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              Icons.arrow_back,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            widget.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: Text(
                        textAlign: TextAlign.center,
                        "Choose your subscription plan",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blue),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        textAlign: TextAlign.center,
                        "Select the best plan for your business type and enjoy full access to our platform features",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    CarouselSlider.builder(
                      itemCount: plans.length,
                      itemBuilder: (context, index, realIdx) {
                        final plan = state.plans![index];
                        return _planCard(plan, index == currentIndex, context,
                            widget.category,widget.currentCategory);
                      },
                      options: CarouselOptions(
                        height: 400,
                        enableInfiniteScroll: false,
                        enlargeFactor: 0.1,
                        enlargeCenterPage: true,
                        viewportFraction: 0.60,
                        onPageChanged: (index, reason) {
                          setState(() => currentIndex = index);
                        },
                      ),
                    ),
                  ]);
              /*PageView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: state.plans!.length,
                pageSnapping: true,
                clipBehavior: Clip.none,
                controller: pageController,
                itemBuilder: (context, index) {
                  final plan = state.plans![index];
                  return Center(
                    child: PlanCard(plan: plan,category:widget.category),
                  );
                },
              )*/
              ;
            },
          ),
        ),
      ),
    );
  }
}

Widget _planCard(
    PlanModel data, bool isActive, BuildContext context, String category,String currentCategory) {
  final features = data.features;
  final discount = data.earlyBirdDiscountPercentage;
  final price = data.finalPrice;
  final duration = data.durationInMonths;
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    margin: const EdgeInsets.all(6),
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(18),
      border: Border.all(
        color: isActive ? Colors.purple : Colors.grey.shade300,
      ),
      boxShadow: isActive
          ? [
              BoxShadow(
                  color: Colors.purple.withOpacity(0.15),
                  blurRadius: 15,
                  spreadRadius: 3)
            ]
          : [],
      gradient: isActive
          ? LinearGradient(
              colors: [Colors.purple.shade50, Colors.white],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            )
          : null,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(data.name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text("Validity $duration Month",
            style: const TextStyle(fontSize: 11, color: Colors.black87)),
        const SizedBox(height: 16),
        Row(
          children: [
            Text("₹ ${price.toStringAsFixed(0)}",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.purple),
              ),
              child: Text(
                "${discount.toStringAsFixed(0)} % Off",
                style: const TextStyle(
                    fontSize: 11,
                    color: Colors.purple,
                    fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        const Text("Benefits:",
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        ...List.generate(
          features.length > 5 ? 5 : features.length,
          (i) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    features[i],
                    maxLines: 2,
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
        const Spacer(),
        Center(
          child: GestureDetector(
            onTap: () {
              if (category == UserType.TRANSPORTER.name) {
                showAddVehicleQtyPopup(context, data, category,currentCategory,
                    PaymentType.registrationWithSubscription, 2);
              } else {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => BlocProvider.value(
                    value: context.read<PaymentBloc>(),
                    child: PaymentBottomSheetBlocView(
                      plan: data,
                      planType: category,
                      currentCategory: currentCategory,
                      paymentType: PaymentType.registrationWithSubscription,
                      category: category,
                    ),
                  ),
                );
              }
            },
            child: Container(
              width: 160,
              height: 38,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(25),
                gradient: const LinearGradient(
                  colors: [Colors.purple, Colors.orange],
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                "Continue",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    ),
  );
}

void showAddVehicleQtyPopup(BuildContext context, PlanModel plan,
    String category,String currentCategory, PaymentType planType, int count) {
  showDialog(
    context: context,
    builder: (_) => NumberOfVehiclesPopup(
      initialValue: count,
      onConfirm: (count) {
        showShortTermPlanBottomSheet(context, plan, category,currentCategory, planType, count);
      },
    ),
  );
}

void showShortTermPlanBottomSheet(BuildContext context, PlanModel plan,
    String category,String currentCategory, PaymentType planType, int count) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlocProvider.value(
      value: context.read<PaymentBloc>(),
      child: ShortTermPlanBottomSheet(
          context: context,
          plan: plan,
          category: category,
          currentCategory: currentCategory,
          planType: planType,
          count: count),
    ),
  );
}

class NumberOfVehiclesPopup extends StatefulWidget {
  final int initialValue;
  final Function(int) onConfirm;

  const NumberOfVehiclesPopup({
    super.key,
    this.initialValue = 1,
    required this.onConfirm,
  });

  @override
  State<NumberOfVehiclesPopup> createState() => _NumberOfVehiclesPopupState();
}

class _NumberOfVehiclesPopupState extends State<NumberOfVehiclesPopup> {
  late int count;

  @override
  void initState() {
    super.initState();
    count = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Number of Vehicles",
              style: TextStyle(
                fontSize: 25,
                color: Colors.black,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Give the vehicle detail you want to list on platform, Number of vehicles affect subscription Amount.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
            const SizedBox(height: 25),

            // Counter Box
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _circleButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (count > 1) {
                      setState(() => count--);
                    }
                  },
                ),
                Container(
                  width: 80,
                  height: 40,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: Text(
                    count.toString(),
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.w600),
                  ),
                ),
                _circleButton(
                  icon: Icons.add,
                  onTap: () {
                    setState(() => count++);
                  },
                ),
              ],
            ),

            const SizedBox(height: 30),

            // Confirm Button
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  widget.onConfirm(count ?? 2);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text(
                  "Confirm",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: CircleAvatar(
        radius: 18,
        backgroundColor: Colors.grey.shade200,
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}

class ShortTermPlanBottomSheet extends StatefulWidget {
  final PlanModel plan;
  final String currentCategory;
  final String category;
  final PaymentType planType;
  final int count;
  final BuildContext context;

  const ShortTermPlanBottomSheet(
      {required this.plan,
      required this.context,
      required this.currentCategory,
      required this.category,
      required this.planType,
      required this.count,
      super.key});

  @override
  State<ShortTermPlanBottomSheet> createState() =>
      _ShortTermPlanBottomSheetState();
}

class _ShortTermPlanBottomSheetState extends State<ShortTermPlanBottomSheet> {
  bool showBenefits = false;
  bool showContact = false;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.70,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, controller) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.all(20),
            children: [
              // Close line indicator
              Center(
                child: Container(
                  width: 45,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              const Text(
                "Short Term Plan",
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              _infoRow("Validity", "3 Months"),
              const SizedBox(height: 12),

              // Number of Vehicles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Number of Vehicles",
                    style: TextStyle(fontSize: 16, color: AppColors.appBlack),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.count.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  )
                ],
              ),

              const SizedBox(height: 20),

              // Benefits Section
              _expansionTile(
                title: "Benefits",
                expanded: showBenefits,
                onTap: () => setState(() => showBenefits = !showBenefits),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("• Unlimited calls"),
                    Text("• Listing support"),
                    Text("• Instant booking service"),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Contact details section
              _expansionTile(
                title: "Contact details",
                expanded: showContact,
                onTap: () => setState(() => showContact = !showContact),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Support Email: support@rwd.com"),
                    Text("Phone: +91 9876543210"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Pricing Summary
              _priceRow("Total Subscription Amount-", "₹ 3000.00"),
              _priceRow("Discount (80%)-", "₹ 2400.00"),
              const Divider(),
              _priceRow("Payable Amount-", "₹ 600.00"),
              _priceRow("Tax (18%)", "₹ 108.00"),
              const SizedBox(height: 25),

              // Green Banner
              const Center(
                child: Text(
                  "You have got 80% discount",
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              const SizedBox(height: 5),

              // Payment button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => BlocProvider.value(
                        value: context.read<PaymentBloc>(),
                        child: PaymentBottomSheetBlocView(
                          plan: widget.plan,
                          planType: widget.category,
                          currentCategory: widget.currentCategory,
                          paymentType: PaymentType.registrationWithSubscription,
                          category: widget.category,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    "Make Payment",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 16)),
        Text(value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _expansionTile({
    required String title,
    required bool expanded,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.appBlack)),
              Icon(
                expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                size: 24,
              )
            ],
          ),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: child,
          ),
      ],
    );
  }

  Widget _priceRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
