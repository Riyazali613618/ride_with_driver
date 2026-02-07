import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:rwd/api/api_model/user_model/my_profile_model.dart';
import 'package:rwd/api/api_service/user_service/user_profile_service.dart';
import 'package:rwd/components/app_loader.dart';
import 'package:rwd/components/common_parent_container.dart';

import '../../../api/api_service/countryStateProviderService.dart';
import '../../../api/api_service/payment_service/payment_service.dart';
import '../../../bloc/payment/payment_bloc.dart';
import '../../../constants/api_constants.dart';
import '../../../screens/driver_screens/payment_bottom_sheet.dart';
import '../../data/models/plan_model.dart';
import '../bloc/plan_bloc.dart';
import '../bloc/plan_event.dart';
import '../bloc/plan_state.dart';

class RenewTransporterPlan extends StatefulWidget {
  final String category;
  final String title;
  final int count;
  final bool isRenewal;

  const RenewTransporterPlan(
      {super.key,
      this.isRenewal = false,
      required this.title,
      required this.count,
      required this.category});

  @override
  State<RenewTransporterPlan> createState() => _RenewTransporterPlanState();
}

class _RenewTransporterPlanState extends State<RenewTransporterPlan> {
  final pageController = PageController(viewportFraction: 0.80, initialPage: 1);
  int currentIndex = 0;
  MyProfileData? myProfileData;

  @override
  void initState() {
    super.initState();
    fetchPlansList();
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
                        return _planCard(
                            myProfileData?.activeSubscriptions ?? [],
                            false,
                            widget.count,
                            plan,
                            index == currentIndex,
                            context);
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
            },
          ),
        ),
      ),
    );
  }

  void fetchPlansList() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final langProvider =
          Provider.of<LocationProvider>(context, listen: false);
      final currentCountry =
          langProvider.selectedCountry ?? ApiConstants.defaultCountryCodeInd;
      final selectedState =
          langProvider.selectedState ?? ApiConstants.defaultStateCodeDel;
      if (selectedState.isEmpty) {
        await langProvider.fetchStates(currentCountry);
      }
      myProfileData = await UserProfileService().getUserProfile();
      if (!mounted) return;

      context.read<PlanBloc>().add(FetchPlansEvent(
            widget.category,
            currentCountry,
            selectedState,
          ));
    }); // context.read<PlanBloc>().add(FetchPlansEvent(widget.category));
  }

  Widget _planCard(List<Subscription> activeSubscriptions, bool isAdOns,
      int count, PlanModel data, bool isActive, BuildContext context) {
    final features = data.features;
    final discount = data.earlyBirdDiscountPercentage;
    String taxRate = data.taxRate;
    if (taxRate.isEmpty) {
      taxRate = "18";
    }
    double price = data.perVehiclePrice * (myProfileData?.vehicleLimit ?? 2);
    price = price + (price * ((double.parse(taxRate)) / 100));
    final price2 = data.grossPrice;
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
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text("Validity $duration Month",
              style: const TextStyle(fontSize: 11, color: Colors.black87)),
          const SizedBox(height: 16),
          Row(
            children: [
              Text("₹ ${price.toStringAsFixed(0)}",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Text("₹ ${price2.toStringAsFixed(0)}",
                  style: const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      fontSize: 11,
                      fontWeight: FontWeight.bold)),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => BlocProvider.value(
                    value: context.read<PaymentBloc>(),
                    child: PaymentBottomSheetBlocView(
                      isAdOns: false,
                      isRenewal: true,
                      plan: data,
                      benefits: data.features,
                      planName: data.name,
                      finalPrice: price,
                      rwdBalance: myProfileData?.rwdBalance ?? 0,
                      planType: widget.category,
                      vehicleCount: "2",
                      currentCategory: "TRANSPORTER",
                      paymentType: PaymentType.subscriptionRenewal,
                      category: "TRANSPORTER",
                    ),
                  ),
                );
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
}
