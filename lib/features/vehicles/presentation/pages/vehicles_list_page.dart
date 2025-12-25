import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/components/booking_container.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/utils/color.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../components/app_loader.dart';
import '../../../../screens/vehicle/add_vehicle_screen.dart';
import '../../../../screens/vehicle/vehicleRegistrationScreen.dart';
import '../bloc/vehicle_list_bloc.dart';
import '../bloc/vehicle_list_event.dart';
import '../bloc/vehicle_list_state.dart';
import '../widgets/vehicle_card.dart';
import 'add_vehicle_screen.dart';

class VehiclesListingPage extends StatefulWidget {
  const VehiclesListingPage({super.key});

  @override
  State<VehiclesListingPage> createState() => _VehiclesListingPageState();
}

class _VehiclesListingPageState extends State<VehiclesListingPage> {
  SharedPreferences? pref;

  @override
  void initState()  {
    super.initState();
    initPref();
    context.read<VehicleListBloc>().add(FetchVehicles());
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
                                if (pref?.getString('who_reg') == "Transporter")
                                  TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  AddNewVehicleScreen(
                                                    userType: "Taxi Owner",
                                                  )));
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: gradientFirst,
                                        borderRadius: BorderRadius.circular(20),
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
}
