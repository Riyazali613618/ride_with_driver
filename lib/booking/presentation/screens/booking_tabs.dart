import 'package:flutter/material.dart';

import '../../../screens/widgets/gradient_button.dart';
import '../../../utils/color.dart';
import 'makeBooking/make_booking_full_screen.dart';
import 'manageBooking/manage_booking_page.dart';
import 'myBookings/my_booking_page.dart';

class BookingTabs extends StatefulWidget {
  final bool isManageBooking;

  const BookingTabs({this.isManageBooking = false, super.key});

  @override
  State<BookingTabs> createState() => _BookingTabsState();
}

class _BookingTabsState extends State<BookingTabs>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: true, // Prevents default pop behavior
        onPopInvokedWithResult: (didPop, result) {
          // previousStep(context);
        },
        child: Scaffold(
          // Use cream background color from design
          backgroundColor: Color(0xFFFFFFFF),
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
                      child: Text(
                        widget.isManageBooking
                            ? "Manage Bookings"
                            : "My Bookings",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.only(right: 20, top: 20),
                      width: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        // Apply gradient only when enabled
                        gradient: LinearGradient(
                          colors: [gradientFirst, gradientSecond],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        // Fallback to a solid grey color when disabled
                        color: Colors.white,
                      ),
                      // Use Material/InkWell to handle taps and ripple effect over the gradient
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MakeBookingFullScreen()));
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 6),
                            child: Center(
                              child: Text(
                                "+ Make Booking",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: widget.isManageBooking
                        ? ManageBookingPage()
                        : MyBookingPage(),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
