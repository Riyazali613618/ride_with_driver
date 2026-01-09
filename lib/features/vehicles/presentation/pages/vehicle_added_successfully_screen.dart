// vehicle_registration_provider.dart
import 'dart:io';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:r_w_r/api/api_service/media_service.dart';
import 'package:r_w_r/api/api_service/user_service/user_profile_service.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_state.dart';
import 'package:r_w_r/features/vehicles/presentation/pages/add_new_vehicle_screen.dart';
import 'package:r_w_r/screens/vehicle/add_vehicle_screen.dart';
import 'package:r_w_r/utils/common_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../api/api_model/user_model/my_profile_model.dart';
import '../../../../bloc/payment/payment_bloc.dart';
import '../../../../constants/token_manager.dart';
import '../../../../plan/data/repositories/plan_repository.dart';
import '../../../../plan/presentation/bloc/plan_bloc.dart';
import '../../../../plan/presentation/bloc/plan_event.dart';
import '../../../../plan/presentation/screens/plan_selection_screen.dart' show PlanSelectionScreen;
import '../../../../screens/block/provider/profile_provider.dart';
import '../../../../screens/layout.dart';
import '../../../../screens/transporterRegistration.dart';
import '../../../../screens/user_screens/PartnerRegistrationWidget.dart';
import '../../../../screens/widgets/gradient_button.dart';
import '../../../../utils/color.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_event.dart';

class VehicleAddedSuccessfullyScreen extends StatefulWidget {
  final String userType;

  const VehicleAddedSuccessfullyScreen({required this.userType, super.key});

  @override
  State<VehicleAddedSuccessfullyScreen> createState() =>
      _VehicleAddedSuccessfullyScreenState();
}

class _VehicleAddedSuccessfullyScreenState
    extends State<VehicleAddedSuccessfullyScreen> {
  bool isCheckingLimit = false;
  SharedPreferences? pref;
  Future<void> initPref() async {
    pref = await SharedPreferences.getInstance();

  }
  @override
  void initState() {
    super.initState();
    initPref();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonParentContainer(
        showLargeGradient: true,
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/svg/successfull.svg",
                    width: 40,
                    height: 40,
                  ),
                  Text(
                    "Vehicle Added Successfully",
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
                  ),
                ],
              )),
              Flexible(
                  flex: 1,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                      ),
                      BlocConsumer<ProfileBloc, ProfileState>(
                        listener: (context, state) async {
                          if (state is VehicleAllowedState) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddNewVehicleScreen(
                                  userType: widget.userType,
                                ),
                              ),
                            );
                          }

                          if (state is VehicleLimitExceededState) {
                           /* final userType = await getProfileData();
                            showUpgradeDialog(context, userType);*/
                            final profile = await getProfileData();
                            isCheckingLimit = false;
                            if (mounted) {
                              setState(() {});
                            }
                            int limit = profile.vehicleLimit ?? 0;
                            int totalVehicleAdded =
                                profile.vehicles.length;
                            if ((profile.addonVehicles ?? [])
                                .isNotEmpty) {
                              limit = limit +
                                  (profile.addonVehicles?[0].addOnVehicles??0);
                            }
                            if (totalVehicleAdded >= limit) {
                              showUpgradeDialog(
                                  context, profile.usertype ?? "");
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
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (context, state) {
                          return  isCheckingLimit
                              ? SizedBox(
                            width: 16,
                            height: 16,
                            child:
                            CircularProgressIndicator(
                              color: Colors.purple,
                              strokeWidth: 1,
                            ),
                          )
                              : InkWell(
                            onTap: state is ProfileLoading
                                ? null
                                : () {
                              if (isCheckingLimit) return;
                              isCheckingLimit = true;
                                    context
                                        .read<ProfileBloc>()
                                        .add(CheckVehicleLimitEvent());
                                  },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [gradientFirst, gradientSecond],
                                ),
                              ),
                              child: state is ProfileLoading
                                  ? const SizedBox(
                                      height: 14,
                                      width: 14,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      "Add more vehicle",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                            ),
                          );
                        },
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const Layout()),
                            (route) => false,
                          );
                        },
                        child: Text(
                          "Skip",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                        ),
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                    ],
                  ))
            ],
          ),
        ),
      ),
    );
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

  Future<MyProfileData> getProfileData() async {
    MyProfileData data = await UserProfileService().getUserProfile();
    return data;
  }
}
