import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/screens/dashboard/performance_section.dart';
import 'package:r_w_r/screens/dashboard/revenue_chart.dart';
import 'package:r_w_r/screens/dashboard/summary_cards.dart';

import '../../features/newDashboard/dashboard_api_service.dart';
import '../../features/newDashboard/dashboard_repository.dart';
import 'dashboard_bloc.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardScreenNew extends StatefulWidget {
  const DashboardScreenNew({super.key});

  @override
  State<DashboardScreenNew> createState() => _DashboardScreenNewState();
}

class _DashboardScreenNewState extends State<DashboardScreenNew> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(LoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        top: false,
        child: CommonParentContainer(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              _header(),
              Expanded(
                child: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                    if (state is DashboardLoaded) {
                      final dashboard = state.data.data;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SummaryCards(data: dashboard),
                            SizedBox(height: 20),
                            RevenueChart(data: dashboard),
                            SizedBox(height: 0),
                            PerformanceSection(data: dashboard),
                          ],
                        ),
                      );
                    } else if (state is DashboardLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else {
                      return const Center(child: Text("Something went wrong!"));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text(
            "Dashboard",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
                onTap: () {
                  context.read<DashboardBloc>().add(LoadDashboard());
                },
                child: const Icon(Icons.refresh, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _bottomNav() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: const Color(0xFF7B3FE4),
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: "Favorite"),
        BottomNavigationBarItem(
            icon: Icon(Icons.dashboard), label: "Dashboard"),
        BottomNavigationBarItem(icon: Icon(Icons.message), label: "Message"),
        BottomNavigationBarItem(
            icon: Icon(Icons.directions_car), label: "Booking"),
      ],
    );
  }
}
