import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_service/payment_service/payment_service.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/constants/token_manager.dart';
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
import '../../../../screens/autoRikshawDriverRegistration.dart';
import '../../../../screens/driverRegistrationScreen.dart';
import '../../../../screens/driver_screens/payment_bottom_sheet.dart';
import '../../../../screens/eRickshawRegistration.dart';
import '../../../../screens/independentCarOwnerRegistration.dart';
import '../../../../screens/transporterRegistration.dart';
import '../../../../screens/user_screens/PartnerRegistrationWidget.dart';
import '../../../../utils/common_utils.dart';
import '../addOns/add_on_vehicles_bottom_sheet.dart';
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
    getVehicleLimit();
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
                                      fontFamily: AppConstants.ptSansFont,
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
                                            userType: profile?.usertype ?? "",
                                          ),
                                        ),
                                      );
                                    }

                                    if (state is VehicleLimitExceededState) {
                                      isCheckingLimit = false;
                                      if (mounted) {
                                        setState(() {});
                                      }
                                      int vLimit = profile?.vehicleLimit ?? 0;
                                      int addOnsLimit =
                                          profile?.addOnVehicleLimit ?? 0;
                                      if (addOnsLimit > 0) {
                                        vLimit = addOnsLimit;
                                      }
                                      int totalVehicleAdded =
                                          profile?.vehicles.length ?? 0;
                                      if (vLimit != limit) {
                                        limit = vLimit;
                                        updateState();
                                      }
                                      /*if ((profile?.addonVehicles ?? [])
                                          .isNotEmpty) {
                                        vLimit = vLimit +
                                            (profile?.addonVehicles?[0]
                                                    .addOnVehicles ??
                                                0);
                                      }*/
                                      if (totalVehicleAdded >= vLimit) {
                                        showUpgradeDialog(
                                            context,
                                            profile?.usertype ?? "",
                                            profile?.activeSubscriptions ?? []);
                                      } else {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => AddNewVehicleScreen(
                                              userType: profile?.usertype ?? "",
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
                                              if (eligibilityModel
                                                      ?.data?.paymentPhase ==
                                                  AppConstants
                                                      .preRegistration) {
                                                showCompleteYourRegistrationDialog(
                                                    context,
                                                    eligibilityModel?.data?.category ?? "");
                                                return;
                                              }
                                              if (isCheckingLimit) return;
                                              isCheckingLimit = true;
                                              setState(() {});
                                              profile =
                                                  await UserProfileService()
                                                      .getUserProfile();
                                              if (profile != null &&
                                                  (profile?.usertype ?? "")
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
                                                      fontFamily: AppConstants
                                                          .ptSansFont,
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
                                SizedBox(
                                  width: 15,
                                )
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

  void showCompleteYourRegistrationDialog(
      BuildContext context, String userType) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Complete Your Registration"),
        content: Text(
            "It seems you haven't completed you upgrade partner registration. Please complete your registration in order to ${userType == "TRANSPORTER" ? "add new vehicle" : "upgrade your user type."}"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToApplication(userType);
            },
            child: const Text("Complete Registration"),
          ),
        ],
      ),
    );
  }

  MyProfileData? myProfileData;

  Future<MyProfileData?> getProfileData() async {
    myProfileData = await UserProfileService().getUserProfile();
    return myProfileData;
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
      final list = planList.map((e) => PlanModel.fromJson(e)).toList();
      if (list.isNotEmpty) {
        final data = list[0];
        final features = data.features;
        final discount = data.earlyBirdDiscountPercentage;
        final price = data.finalPrice;
        final price2 = data.grossPrice;
        final duration = data.durationInMonths;
        final rwdBalance = myProfileData?.rwdBalance ?? 0;
        showAddVehicleQtyPopup(rwdBalance, context, data, "TRANSPORTER",
            "TRANSPORTER", PaymentType.addOns, 1, true);
      }
    }
  }

  void showAddVehicleQtyPopup(
      double rwdBalance,
      BuildContext context,
      PlanModel plan,
      String category,
      String currentCategory,
      PaymentType planType,
      int count,
      bool isAdOns) {
    showDialog(
      context: context,
      builder: (_) => NumberOfVehiclesPopup(
        initialValue: count,
        plan: plan,
        isAdOns: isAdOns,
        onConfirm: (count) {
          showAddOnPlanBottomSheet(rwdBalance, isAdOns, context, plan, category,
              currentCategory, planType, count);
        },
      ),
    );
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }

  void hghdsg() {}

  Future<void> _navigateToApplication(String type) async {
    Widget? destination;

    String userType = type;
    if (userType == "RICKSHAW") {
      destination = AutoRickshawDriverFlow();
    } else if (userType == "DRIVER") {
      destination = DriverRegistrationFlow();
    } else if (userType == "E_RICKSHAW") {
      destination = ERickshawDriverFlow();
    } else if (userType == "TRANSPORTER") {
      destination = TransporterRegistrationFlow();
    } else if (userType == "INDEPENDENT_CAR_OWNER") {
      destination = IndependentTaxiOwnerFlow();
    }

    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination!),
      ).then((_) {
        getVehicleLimit();
      });
    }
  }

  void getVehicleLimit() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        eligibilityModel = await getEligibilityData();
        profile = await getProfileData();
        limit = profile?.vehicleLimit ?? 0;
        int addOnsLimit = profile?.addOnVehicleLimit ?? 0;
        if (addOnsLimit > 0) {
          limit = addOnsLimit;
        }
        updateState();
      },
    );
  }
}

void showAddOnPlanBottomSheet(
    double rwdBalance,
    bool isAdOns,
    BuildContext context,
    PlanModel plan,
    String category,
    String currentCategory,
    PaymentType planType,
    int count) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlocProvider.value(
      value: context.read<PaymentBloc>(),
      child: AddOnPlanBottomSheet(
          context: context,
          isAdOns: isAdOns,
          plan: plan,
          rwdBalance: rwdBalance,
          category: category,
          currentCategory: currentCategory,
          planType: planType,
          count: count),
    ),
  );
}
