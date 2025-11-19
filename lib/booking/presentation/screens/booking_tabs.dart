import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../utils/color.dart';
import '../bloc/manage_booking_bloc.dart';
import '../widgets/gradient_header.dart';
import 'make_booking_full_screen.dart';
import 'manage_booking_screen.dart';

class BookingTabs extends StatefulWidget {
  const BookingTabs({super.key});

  @override
  State<BookingTabs> createState() => _BookingTabsState();
}

class _BookingTabsState extends State<BookingTabs>
    with SingleTickerProviderStateMixin {
  late TabController _tc;

  @override
  void initState() {
    _tc = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false, // Prevents default pop behavior
        onPopInvokedWithResult: (didPop, result) {
          // previousStep(context);
        },
        child: Scaffold(
          // Use cream background color from design
          backgroundColor: Color(0xFFFFFBF3),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  gradientFirst,
                  gradientSecond,
                  gradientThird,
                  Colors.white
                ],
                stops: [0.0, 0.15, 0.30, .90],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    padding: EdgeInsets.all(1.5),
                    height: 40,
                    margin: EdgeInsets.only(left: 10, right: 10, top: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          gradientFirst,
                          gradientSecond,
                        ],
                      ),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white),
                      child: TabBar(
                        indicatorWeight: 2,
                        indicatorSize: TabBarIndicatorSize.tab,
                        padding: EdgeInsets.zero,
                        dividerHeight: 0,
                        controller: _tc,
                        labelColor: Colors.purple.shade800,
                        unselectedLabelColor: Colors.grey,
                        indicator: BoxDecoration(
                            color: Color(0x1F641BB4),
                            borderRadius: BorderRadius.only(
                                topLeft:
                                    Radius.circular(_tc.index == 0 ? 12 : 0),
                                bottomLeft:
                                    Radius.circular(_tc.index == 0 ? 12 : 0),
                                topRight:
                                    Radius.circular(_tc.index == 0 ? 12 : 0),
                                bottomRight:
                                    Radius.circular(_tc.index == 0 ? 12 : 0))),
                        tabs: [
                          Tab(
                            child: Text(
                              "Manage Booking",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.black),
                            ),
                          ),
                          Tab(
                            child: Text(
                              "My Booking",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                  color: Colors.black),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(controller: _tc, children: const [
                      ManageBookingScreen(),
                      MakeBookingFullScreen()
                    ]),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
