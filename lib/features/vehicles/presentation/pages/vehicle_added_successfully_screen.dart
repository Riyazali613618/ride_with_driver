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
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/features/vehicles/domain/entities/vehicle_entity.dart';
import 'package:r_w_r/features/vehicles/presentation/bloc/profile_state.dart';
import 'package:r_w_r/features/vehicles/presentation/pages/add_new_vehicle_screen.dart';
import 'package:r_w_r/screens/vehicle/add_vehicle_screen.dart';
import 'package:r_w_r/utils/common_utils.dart';

import '../../../../constants/token_manager.dart';
import '../../../../plan/data/repositories/plan_repository.dart';
import '../../../../plan/presentation/bloc/plan_bloc.dart';
import '../../../../screens/layout.dart';
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
                        listener: (context, state) {
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
                            showUpgradeDialog(context);
                          }

                          if (state is ProfileErrorState) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.message)),
                            );
                          }
                        },
                        builder: (context, state) {
                          return InkWell(
                            onTap: state is ProfileLoading
                                ? null
                                : () {
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
                                      "Add more vehicles",
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

  void showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Limit Exceeded"),
        content: const Text(
          "You have exceed your vehicle adding limit, please upgrade to transporter to add more vehicle.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
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
            },
            child: const Text("Upgrade"),
          ),
        ],
      ),
    );
  }
}
