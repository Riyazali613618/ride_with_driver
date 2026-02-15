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
import '../../../constants/token_manager.dart';
import '../../../screens/driver_screens/payment_bottom_sheet.dart';
import '../../../utils/common_utils.dart';
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
    /*  double price = data.perVehiclePrice * (myProfileData?.addOnVehicleLimit ?? 2);
    price = price + (price * ((double.parse(taxRate)) / 100));*/
    double price = data.finalPrice;
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
                    child: RenewPlanPriceDetailsBottomSheet(
                        myProfileData: myProfileData,
                        context: context,
                        plan: data),
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

class RenewPlanPriceDetailsBottomSheet extends StatefulWidget {
  final PlanModel plan;
  final BuildContext context;
  final MyProfileData? myProfileData;

  const RenewPlanPriceDetailsBottomSheet(
      {required this.plan,
      required this.context,
      required this.myProfileData,
      super.key});

  @override
  State<RenewPlanPriceDetailsBottomSheet> createState() =>
      _RenewPlanPriceDetailsBottomSheetState();
}

class _RenewPlanPriceDetailsBottomSheetState
    extends State<RenewPlanPriceDetailsBottomSheet> {
  bool showBenefits = false;
  bool showContact = false;
  String phoneNumber = "";
  String email = "";
  double refundableAmount = 0;
  double amountToPay = 0;

  //TODO Wallet Amount and rwdBalance both are same, we are just using walletAmount
  //TODO for calculation so that we can send how much amount used from wallet and
  //TODO rwdAmount is using to show how much are are there in wallet
  double rwdBalance = 0;
  double walletAmount = 0;
  MyProfileData? myProfileData;
  String taxRate = "18";
  double taxAmount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        myProfileData = widget.myProfileData;
        phoneNumber = myProfileData?.mobileNumber ?? "";
        email = myProfileData?.email ?? "";
        rwdBalance = myProfileData?.rwdBalance ?? 0;
        walletAmount = myProfileData?.rwdBalance ?? 0;
        taxRate = widget.plan.taxRate;
        if (taxRate.isEmpty) {
          taxRate = "18";
        }
        int vLimit=(myProfileData?.addOnVehicleLimit ?? 2);
        if((myProfileData?.addOnVehicleLimit??0)>0){
          vLimit=myProfileData!.addOnVehicleLimit!;
        }
        double price =
            widget.plan.perVehiclePrice * vLimit;
        taxAmount = (price * ((double.parse(taxRate)) / 100));
        amountToPay = price + taxAmount;
        if (amountToPay > rwdBalance) {
          amountToPay = amountToPay - walletAmount;
          walletAmount = 0;
        } else {
          walletAmount = walletAmount - amountToPay;
          amountToPay = 0;
        }
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    int vLimit=(myProfileData?.addOnVehicleLimit ?? 2);
    if((myProfileData?.addOnVehicleLimit??0)>0){
      vLimit=myProfileData!.addOnVehicleLimit!;
    }
    double totalRenewalAmount =
        widget.plan.perVehiclePrice * vLimit;


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

              Text(
                widget.plan.name,
                style: CommonUtils.commonTitleStyle(),
              ),
              const SizedBox(height: 20),

              _infoRow("Validity", "${widget.plan.durationInMonths} Months"),
              const SizedBox(height: 12),

              // Number of Vehicles
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Number of Vehicles",
                    style: CommonUtils.commonTitleStyle(fontSize: 14),
                  ),
                  Row(
                    children: [
                      Text(
                        (vLimit)
                            .toString()
                            .padLeft(2, '0'),
                        style: CommonUtils.commonTitleStyle(
                            fontSize: 14, weight: FontWeight.w400),
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
                  children: widget.plan.features
                      .map(
                        (e) => Text("• $e"),
                      )
                      .toList() /*const [
                    Text("• Unlimited calls"),
                    Text("• Listing support"),
                    Text("• Instant booking service"),
                  ]*/
                  ,
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
                  children: [
                    if (email.isNotEmpty) Text("Support Email: $email"),
                    if (email.isNotEmpty) Text("Phone: $phoneNumber"),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Pricing Summary
              _priceRow("Renewal Amount-",
                  "₹ ${totalRenewalAmount.toStringAsFixed(2)}"),
              _priceRow(
                  "Discount (${widget.plan.earlyBirdDiscountPercentage}%) -",
                  "- ₹ ${widget.plan.earlyBirdDiscountPrice}"),
              /* if (refundableAmount > 0)
                _priceRow("Refund From Previous Plan -",
                    "- ₹ ${refundableAmount.toStringAsFixed(2)}"),*/
              if (rwdBalance > 0)
                _priceRow("Current RWD Wallet Balance -",
                    "₹ ${rwdBalance.toStringAsFixed(2)}"),
              if (walletAmount > 0)
                _priceRow("Remaining Wallet Balance after payment-",
                    "₹ ${((walletAmount - rwdBalance).abs()).toStringAsFixed(2)}"),
              const Divider(),
              _priceRow(
                  "Payable Amount after Tax: ", "₹ ${(amountToPay).toStringAsFixed(2)}",
                  weight: FontWeight.w700),
              _priceRow("Tax (${widget.plan.taxRate}%)",
                  "+ ₹ ${taxAmount.toStringAsFixed(2)}"),

              const SizedBox(height: 25),

              // Green Banner
              Center(
                child: Text(
                  "You have got ${widget.plan.earlyBirdDiscountPercentage}% discount",
                  style: CommonUtils.commonTitleStyle(
                      weight: FontWeight.w400, fontSize: 12),
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
                          isAdOns: false,
                          isRenewal: true,
                          plan: widget.plan,
                          benefits: widget.plan.features,
                          planName: widget.plan.name,
                          finalPrice: amountToPay,
                          rwdBalance: myProfileData?.rwdBalance ?? 0,
                          planType: "TRANSPORTER",
                          vehicleCount: "0",
                          currentCategory: "TRANSPORTER",
                          paymentType: PaymentType.subscriptionRenewal,
                          category: "TRANSPORTER",
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
                  child: Text(
                    "Make Payment",
                    style: CommonUtils.commonTitleStyle(
                        fontSize: 14,
                        weight: FontWeight.w400,
                        color: Colors.white),
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
        Text(
          title,
          style: CommonUtils.commonTitleStyle(
              weight: FontWeight.w700, fontSize: 14),
        ),
        Text(
          value,
          style: CommonUtils.commonTitleStyle(
              weight: FontWeight.w400, fontSize: 14),
        ),
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
              Text(
                title,
                style: CommonUtils.commonTitleStyle(fontSize: 14),
              ),
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

  Widget _priceRow(String title, String value, {FontWeight? weight}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: CommonUtils.commonTitleStyle(
                fontSize: 12, weight: weight ?? FontWeight.w400),
          ),
          Text(value,
              style: CommonUtils.commonTitleStyle(
                  fontSize: 12, weight: weight ?? FontWeight.w400)),
        ],
      ),
    );
  }

  String getSubscriptionAmount(PlanModel plan) {
    return "+ ₹ ${plan.grossPrice.toStringAsFixed(2)}";
  }

  String getSubscriptionDiscount(PlanModel plan) {
    return "- ₹ ${plan.earlyBirdDiscountPrice.toStringAsFixed(2)}";
  }

  String getSubscriptionFinalAmount(PlanModel plan) {
    return "";
  }

  double getTaxValue(String taxRate, double finalPrice) {
    double tax = double.parse(taxRate.isNotEmpty ? taxRate : "18");
    final finalTaxValue = ((tax * finalPrice) / 100);
    return finalTaxValue;
  }
}
