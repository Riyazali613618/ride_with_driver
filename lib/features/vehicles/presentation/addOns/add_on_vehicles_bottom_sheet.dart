import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../api/api_model/user_model/my_profile_model.dart';
import '../../../../api/api_service/payment_service/payment_service.dart';
import '../../../../api/api_service/user_service/user_profile_service.dart';
import '../../../../bloc/payment/payment_bloc.dart';
import '../../../../plan/data/models/plan_model.dart';
import '../../../../screens/driver_screens/payment_bottom_sheet.dart';
import '../../../../utils/common_utils.dart';

class NumberOfVehiclesPopup extends StatefulWidget {
  final bool isAdOns;
  final int initialValue;
  final PlanModel plan;
  final Function(int) onConfirm;

  const NumberOfVehiclesPopup({
    super.key,
    this.isAdOns = false,
    this.initialValue = 1,
    required this.plan,
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
                    if (count < 10) {
                      setState(() => count++);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "Maximum ${widget.plan.maxVehicles} vehicles allowed for this plan",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Colors.red,
                      ));
                    } /* if (count < widget.plan.maxVehicles) {
                      setState(() => count++);
                    }else{
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Maximum ${widget.plan.maxVehicles} vehicles allowed for this plan",style: TextStyle(color: Colors.white),),backgroundColor: Colors.red,));
                    }*/
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Text(
                  "Total: ",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                ),
                Spacer(),
                Text(
                  (count *
                      (widget.isAdOns
                          ? widget.plan.perVehiclePrice
                          : widget.plan.finalPrice))
                      .toStringAsFixed(2),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                )
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  "Discount Applied: ",
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                ),
                Spacer(),
                Text(
                  (widget.plan.earlyBirdDiscountPrice).toStringAsFixed(2),
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      fontSize: 12),
                )
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

class AddOnPlanBottomSheet extends StatefulWidget {
  final PlanModel plan;
  final String currentCategory;
  final String category;
  final PaymentType planType;
  final double rwdBalance;
  final int count;
  final bool isAdOns;
  final BuildContext context;

  const AddOnPlanBottomSheet(
      {required this.plan,
        this.isAdOns = false,
        required this.rwdBalance,
        required this.context,
        required this.currentCategory,
        required this.category,
        required this.planType,
        required this.count,
        super.key});

  @override
  State<AddOnPlanBottomSheet> createState() => _AddOnPlanBottomSheetState();
}

class _AddOnPlanBottomSheetState extends State<AddOnPlanBottomSheet> {
  bool showBenefits = false;
  bool showContact = false;
  String phoneNumber = "";
  String email = "";
  double refundableAmount = 0;
  double amountToPay = 0;
  double totalTax = 0;

  //TODO Wallet Amount and rwdBalance both are same, we are just using walletAmount
  //TODO for calculation so that we can send how much amount used from wallet and
  //TODO rwdAmount is using to show how much are are there in wallet
  double rwdBalance = 0;
  double walletAmount = 0;
  MyProfileData? myProfileData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
          (timeStamp) async {
        myProfileData = await UserProfileService().getUserProfile();
        email = myProfileData?.email ?? "";
        phoneNumber = myProfileData?.mobileNumber ?? "";
        rwdBalance = myProfileData?.rwdBalance ?? 0;
        walletAmount = myProfileData?.rwdBalance ?? 0;
        amountToPay = widget.count * widget.plan.perVehiclePrice;
        if (walletAmount > 0) {
          if (walletAmount > amountToPay) {
            rwdBalance = walletAmount - amountToPay;
            amountToPay = 0;
          } else {
            amountToPay = (amountToPay - walletAmount).abs();
            rwdBalance = 0;
          }
        }
        setState(() {});
      },
    );
  }

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
                        widget.count.toString().padLeft(2, '0'),
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
              _priceRow("Total Add ons Amount-",
                  "₹ ${(widget.count * widget.plan.perVehiclePrice).toStringAsFixed(2)}"),
              _priceRow(
                  "Discount (${widget.plan.earlyBirdDiscountPercentage}%) -",
                  widget.category == "TRANSPORTER"
                      ? getSubscriptionDiscount(widget.plan)
                      : "- ₹ ${widget.plan.earlyBirdDiscountPrice}"),
              if (refundableAmount > 0)
                _priceRow("Refund From Previous Plan -",
                    "- ₹ ${refundableAmount.toStringAsFixed(2)}"),
              if (rwdBalance > 0)
                _priceRow("Current RWD Wallet Balance -",
                    "₹ ${walletAmount.toStringAsFixed(2)}"),
              if (rwdBalance > 0)
                _priceRow("Remaining Wallet Balance after payment-",
                    "₹ ${((rwdBalance).abs()).toStringAsFixed(2)}"),
              const Divider(),
              _priceRow(
                  "Payable Amount: ", "₹ ${(amountToPay).toStringAsFixed(2)}",
                  weight: FontWeight.w700),
              _priceRow("Tax (${widget.plan.taxRate}%)",
                  "+ ₹ ${getTaxValue(widget.plan.taxRate,amountToPay).toStringAsFixed(2)}"),

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
                          isAdOns: widget.isAdOns,
                          plan: widget.plan,
                          finalPrice: amountToPay,
                          rwdBalance: rwdBalance,
                          planType: widget.category,
                          vehicleCount:
                          ((widget.plan.maxVehicles ?? 0)).toString(),
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
    if(finalPrice<=0){
      return 0;
    }
    double tax = double.parse(taxRate.isNotEmpty ? taxRate : "18");
    final finalTaxValue = ((tax * finalPrice) / 100);
    return finalTaxValue;
  }
}
