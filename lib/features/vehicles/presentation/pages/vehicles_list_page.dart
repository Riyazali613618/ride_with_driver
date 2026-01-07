import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/components/booking_container.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_bloc.dart';
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_event.dart'
    show CheckVehicleLimitEvent;
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_state.dart';
import 'package:r_w_r/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../api/api_model/user_model/my_profile_model.dart';
import '../../../../api/api_model/user_model/user_eligibility_model.dart';
import '../../../../api/api_service/user_service/user_profile_service.dart';
import '../../../../bloc/payment/payment_bloc.dart';
import '../../../../components/app_loader.dart';
import '../../../../constants/api_constants.dart';
import '../../../../plan/data/repositories/plan_repository.dart';
import '../../../../plan/presentation/bloc/plan_bloc.dart';
import '../../../../plan/presentation/screens/plan_selection_screen.dart';
import '../../../../screens/block/provider/profile_provider.dart';
import '../../../../screens/user_screens/PartnerRegistrationWidget.dart';
import '../../../../screens/vehicle/add_vehicle_screen.dart';
import '../../../../screens/vehicle/vehicleRegistrationScreen.dart';
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

  @override
  void initState() {
    super.initState();
    initPref();
    context.read<VehicleListBloc>().add(FetchVehicles());
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) async {
        eligibilityModel = await getEligibilityData();
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
                                    'Total Vehicles (${state.vehicles.length})',
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
                                      final userType = await getProfileData();
                                      showUpgradeDialog(context, userType);
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
                                              final profile =
                                                  await getEligibilityData();
                                              if (eligibilityModel != null &&
                                                  eligibilityModel?.data !=
                                                      null &&
                                                  eligibilityModel
                                                          ?.data?.category
                                                          .toLowerCase() ==
                                                      "driver") {
                                                showUpgradeDialog(
                                                    context, "DRIVER");
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
                                        child: Row(
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
                                                fontWeight: FontWeight.w500,
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

  void showUpgradeDialog(BuildContext context, String userType) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Limit Exceeded"),
        content: Text(
          userType == "TRANSPORTER"
              ? "You have exceed your vehicle adding limit, please upgrade your transporter plan to add more vehicle."
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (_) =>
                          PaymentBloc(profileProvider: context.read<ProfileProvider>()),
                      child: PlanSelectionScreen(
                        category: userType,
                        title: "Upgrade Add ons Vehicles",
                        count: 1,
                        currentCategory: "",
                        isAdOns:true
                      ),
                    ),
                  ),
                );
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

  Future<String> getProfileData() async {
    MyProfileData data = await UserProfileService().getUserProfile();
    if (data.usertype != null) {
      return data.usertype ?? "";
    } else {
      return "";
    }
  }

  Future<UserEligibilityModel> getEligibilityData() async {
    final data = await UserProfileService().getEligibility();
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(AppConstants.planEligibilityKey, jsonEncode(data.data));
    return data;
  }
}
