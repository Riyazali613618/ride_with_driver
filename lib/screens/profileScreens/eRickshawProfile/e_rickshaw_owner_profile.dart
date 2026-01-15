import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/screens/profileScreens/carOwnerProfile/bloc/car_owner_profile_bloc.dart';
import 'package:r_w_r/screens/profileScreens/carOwnerProfile/bloc/car_owner_profile_state.dart';
import 'package:r_w_r/screens/profileScreens/carOwnerProfile/car_owner_profile_api_service.dart';
import 'package:r_w_r/screens/profileScreens/carOwnerProfile/car_owner_profile_repository.dart';
import 'package:r_w_r/screens/profileScreens/carOwnerProfile/views/profile_form.dart';
import 'package:r_w_r/screens/profileScreens/eRickshawProfile/rickshaw_profile_form.dart';
import 'package:r_w_r/utils/common_utils.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

import '../carOwnerProfile/bloc/car_owner_profile_event.dart';
import '../carOwnerProfile/views/edit_profile_header.dart';

class ERickshawOwnerProfile extends StatefulWidget {
  final String userType;
  const ERickshawOwnerProfile({this.userType="",super.key});

  @override
  State<ERickshawOwnerProfile> createState() => _ERickshawOwnerProfileState();
}

class _ERickshawOwnerProfileState extends State<ERickshawOwnerProfile> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CarOwnerProfileBloc(
        CarOwnerProfileRepository(CarOwnerProfileApiService()),
      )..add(LoadProfile()),
      child: Scaffold(
        body: CommonParentContainer(
          child: BlocBuilder<CarOwnerProfileBloc, CarOwnerProfileState>(
            builder: (context, state) {
              if (state is ProfileLoading) {
                return Shimmer(
                  duration: Duration(seconds: 3),
                  //Default value
                  interval: Duration(seconds: 5),
                  //Default value: Duration(seconds: 0)
                  color: Colors.white,
                  //Default value
                  colorOpacity: 0,
                  //Default value
                  enabled: true,
                  //Default value
                  direction: ShimmerDirection.fromLTRB(),
                  //Default Value
                  child: Container(
                    color: Color(0x1A000000),
                  ),
                );
              }

              if (state is ProfileLoaded) {
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                      ),
                      Row(
                        children: [
                          BackButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            color: Colors.white,
                          ),
                          Expanded(
                              child: Text(
                            "Profile",
                            style: CommonUtils.commonTitleStyle(
                                color: Colors.white),
                          ))
                        ],
                      ),
                      EditProfileHeader(
                          profile: state.profile,
                          coverImage: (value) {
                            if (value.isNotEmpty) {}
                          },
                          profileImage: (value) {
                            if (value.isNotEmpty) {}
                          }),
                      const SizedBox(height: 60),
                      RickshawProfileForm(
                        profile: state.profile.data,
                        onUpdate: () {
                          context.read<CarOwnerProfileBloc>().add(
                                CarOwnerProfileEvent({
                                  "name": state.profile.data?.firstName ?? "",
                                }),
                              );
                        },
                      ),
                    ],
                  ),
                );
              }

              return const Center(child: Text("Something went wrong"));
            },
          ),
        ),
      ),
    );
  }
}
