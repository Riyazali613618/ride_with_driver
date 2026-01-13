import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_service/payment_service/payment_service.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_bloc.dart';
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_event.dart'
    show CheckVehicleLimitEvent;
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_state.dart';
import 'package:r_w_r/plan/data/models/plan_model.dart';
import 'package:r_w_r/plan/data/services/plan_service.dart';
import 'package:r_w_r/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../api/api_model/user_model/my_profile_model.dart';
import '../../../../api/api_model/user_model/user_eligibility_model.dart';
import '../../../../api/api_service/countryStateProviderService.dart';
import '../../../../api/api_service/user_service/user_profile_service.dart';
import '../../../../bloc/payment/payment_bloc.dart';
import '../../../../components/app_loader.dart';
import '../../../../constants/api_constants.dart';
import '../../../../plan/data/repositories/plan_repository.dart';
import '../../../../plan/presentation/bloc/plan_bloc.dart';
import '../../../../screens/driver_screens/payment_bottom_sheet.dart';
import '../../../../screens/user_screens/PartnerRegistrationWidget.dart';
import '../bloc/vehicle_list_bloc.dart';
import '../bloc/vehicle_list_event.dart';
import '../bloc/vehicle_list_state.dart';
import '../widgets/vehicle_card.dart';
import 'add_new_vehicle_screen.dart';

class VehiclesListingPage extends StatefulWidget {
  const VehiclesListingPage({super.key});

  @override
  State<VehiclesListingPage> createState() => _VehiclesListingPageState();
}

class _VehiclesListingPageState extends State<VehiclesListingPage> {
  SharedPreferences? pref;
  UserEligibilityModel? eligibilityModel;
  MyProfileData? profile;
  bool isCheckingLimit = false;
  int limit = 0;

  @override
  void initState() {
    super.initState();
    initPref();
    context.read<VehicleListBloc>().add(FetchVehicles());
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        eligibilityModel = await getEligibilityData();
        profile = await getProfileData();
        limit = profile?.vehicleLimit ?? 0;
        int totalVehicleAdded = profile!.vehicles.length;
        if ((profile?.addonVehicles ?? []).isNotEmpty) {
          limit = limit + (profile?.addonVehicles?[0].addOnVehicles ?? 0);

        }
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: false,
        child: CommonParentContainer(
          showLargeGradient: true,
          child: Column(
            children: [
              const SizedBox(height: 40),
              Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Icon(
                        Icons.arrow_back,
                        size: 24,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const Text(
                    "Manage Vehicles",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                ],
              ),
              Expanded(
                child: BlocBuilder<VehicleListBloc, VehicleListState>(
                  builder: (context, state) {
                    if (state is VehicleLoading) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (state is VehicleLoaded) {
                      return Column(
                        children: [
                          /// TITLE ROW
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 16,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Total Vehicles (${state.vehicles.length}/$limit)',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                BlocConsumer<ProfileBloc, ProfileState>(
                                  listener: (context, state) async {
                                    if (state is VehicleAllowedState) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => AddNewVehicleScreen(
                                            userType:
                                                "${pref?.getString('userType')}",
                                          ),
                                        ),
                                      );
                                    }

                                    if (state is VehicleLimitExceededState) {
                                      isCheckingLimit = false;
                                      if (mounted) {
                                        setState(() {});
                                      }
                                      int limit = profile?.vehicleLimit ?? 0;
                                      int totalVehicleAdded =
                                          profile?.vehicles.length ?? 0;
                                      if ((profile?.addonVehicles ?? [])
                                          .isNotEmpty) {
                                        limit = limit +
                                            (profile?.addonVehicles?[0]
                                                    .addOnVehicles ??
                                                0);
                                      }
                                      if (totalVehicleAdded >= limit) {
                                        showUpgradeDialog(
                                            context,
                                            profile?.usertype ?? "",
                                            profile?.activeSubscriptions ?? []);
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddNewVehicleScreen(
                                              userType:
                                                  "${pref?.getString('userType')}",
                                            ),
                                          ),
                                        );
                                      }
                                    }

                                    if (state is ProfileErrorState) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(content: Text(state.message)),
                                      );
                                    }
                                  },
                                  builder: (context, state) {
                                    return InkWell(
                                      onTap: state is ProfileLoading
                                          ? null
                                          : () async {
                                              if (isCheckingLimit) return;
                                              isCheckingLimit = true;
                                              setState(() {});
                                              if (eligibilityModel != null &&
                                                  eligibilityModel?.data !=
                                                      null &&
                                                  eligibilityModel
                                                          ?.data?.category
                                                          .toLowerCase() ==
                                                      "driver") {
                                                isCheckingLimit = false;
                                                setState(() {});
                                                showUpgradeDialog(
                                                    context,
                                                    "DRIVER",
                                                    profile?.activeSubscriptions ??
                                                        []);
                                              } else {
                                                context.read<ProfileBloc>().add(
                                                    CheckVehicleLimitEvent());
                                              }
                                            },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: gradientFirst,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: AppColors.blue,
                                            width: 0.5,
                                          ),
                                        ),
                                        child: isCheckingLimit
                                            ? SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  color: Colors.white,
                                                  strokeWidth: 1,
                                                ),
                                              )
                                            : Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.add,
                                                    color: Colors.white,
                                                    size: 15,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    "Add Vehicle",
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                ],
                                              ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),

                          /// LIST
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: state.vehicles.length,
                              itemBuilder: (_, i) => VehicleCard(
                                vehicle: state.vehicles[i],
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    if (state is VehicleError) {
                      return Center(child: Text(state.message));
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> initPref() async {
    pref = await SharedPreferences.getInstance();
  }

  void showUpgradeDialog(BuildContext context, String userType,
      List<Subscription> subscriptionList) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(userType == "DRIVER" ? "Upgrade User" : "Limit Exceeded"),
        content: Text(
          userType == "TRANSPORTER"
              ? "You have exceed your vehicle adding limit, please upgrade your transporter plan to add more vehicle."
              : userType == "DRIVER"
                  ? "Please upgrade to transporter or taxi owner to add vehicles."
                  : "You have exceed your vehicle adding limit, please upgrade to transporter to add more vehicle.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              if (userType == "TRANSPORTER") {
                getPlanData();
/*
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) => PaymentBloc(
                          profileProvider: context.read<ProfileProvider>()),
                      child: PlanSelectionScreen(
                          category: userType,
                          title: "Upgrade Add ons Vehicles",
                          count: 1,
                          currentCategory: "",
                          isAdOns: true),
                    ),
                  ),
                );
*/
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => PlanBloc(
                        RepositoryProvider.of<PlanRepository>(context),
                      ),
                      child: PartnerRegistrationWidget(),
                    ),
                  ),
                );
              }
            },
            child: const Text("Upgrade"),
          ),
        ],
      ),
    );
  }

  Future<MyProfileData> getProfileData() async {
    MyProfileData data = await UserProfileService().getUserProfile();
    return data;
  }

  Future<UserEligibilityModel> getEligibilityData() async {
    final data = await UserProfileService().getEligibility();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstants.planEligibilityKey, jsonEncode(data.data));
    return data;
  }

  Future<void> getPlanData() async {
    final langProvider = Provider.of<LocationProvider>(context, listen: false);

    final currentCountry =
        langProvider.selectedCountry ?? ApiConstants.defaultCountryCodeInd;
    final selectedState =
        langProvider.selectedState ?? ApiConstants.defaultStateCodeDel;
    if (selectedState.isEmpty) {
      await langProvider.fetchStates(currentCountry);
    }
    final response = await PlanService.getPlans(
        countryId: currentCountry,
        planFor: "TRANSPORTER",
        stateId: selectedState);
    if (response != null && response['success'] == true) {
      final List<dynamic> planList = response['data']['plans'];
      final list= planList.map((e) => PlanModel.fromJson(e)).toList();
      if(list.isNotEmpty){
        final data=list[0];
        final features = data.features;
        final discount = data.earlyBirdDiscountPercentage;
        final price = data.finalPrice;
        final price2 = data.grossPrice;
        final duration = data.durationInMonths;
        showAddVehicleQtyPopup(context, data, "TRANSPORTER", "TRANSPORTER", PaymentType.addOns, 1, true);
      }
    }
  }

  void showAddVehicleQtyPopup(BuildContext context, PlanModel plan,
      String category, String currentCategory, PaymentType planType, int count,bool isAdOns) {
    showDialog(
      context: context,
      builder: (_) => NumberOfVehiclesPopup(
        initialValue: count,
        plan: plan,
        isAdOns: isAdOns,
        onConfirm: (count) {
          showShortTermPlanBottomSheet(isAdOns,
              context, plan, category, currentCategory, planType, count);
        },
      ),
    );
  }
}

void showShortTermPlanBottomSheet(bool isAdOns,BuildContext context, PlanModel plan,
    String category, String currentCategory, PaymentType planType, int count) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlocProvider.value(
      value: context.read<PaymentBloc>(),
      child: ShortTermPlanBottomSheet(
          context: context,
          isAdOns: isAdOns,
          plan: plan,
          category: category,
          currentCategory: currentCategory,
          planType: planType,
          count: count),
    ),
  );
}

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
                  (count * widget.plan.finalPrice).toStringAsFixed(2),
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
                  (count * widget.plan.earlyBirdDiscountPrice)
                      .toStringAsFixed(2),
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

class ShortTermPlanBottomSheet extends StatefulWidget {
  final PlanModel plan;
  final String currentCategory;
  final String category;
  final PaymentType planType;
  final int count;
  final bool isAdOns;
  final BuildContext context;

  const ShortTermPlanBottomSheet(
      {required this.plan,
        this.isAdOns=false,
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

              Text(
                widget.plan.name,
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
              _priceRow("Total Subscription Amount-",
                  "₹ ${widget.count * widget.plan.grossPrice}"),
              _priceRow(
                  "Discount (${widget.plan.earlyBirdDiscountPercentage}%)-",
                  "₹ ${widget.count * widget.plan.earlyBirdDiscountPrice}"),
              const Divider(),
              _priceRow("Payable Amount-",
                  "₹ ${widget.count * widget.plan.finalPrice}"),
              _priceRow("Tax (18%)", "₹ 0"),
              const SizedBox(height: 25),

              // Green Banner
              Center(
                child: Text(
                  "You have got ${widget.plan.earlyBirdDiscountPercentage}% discount",
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
                          isAdOns: widget.isAdOns,
                          plan: widget.plan,
                          finalPrice: widget.count * widget.plan.finalPrice,
                          planType: widget.category,
                          vehicleCount: ((widget.count ?? 0)).toString(),
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

