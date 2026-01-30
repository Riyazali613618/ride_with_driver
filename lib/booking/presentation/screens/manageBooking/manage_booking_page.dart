import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rwd/components/booking_container.dart';
import 'package:rwd/components/common_parent_container.dart';
import 'package:rwd/constants/color_constants.dart';

import '../../../../components/custom_text_field.dart';
import '../../../../screens/layout.dart';
import '../../../../utils/color.dart';
import '../../../domain/model/booking.dart';
import '../../bloc/manage_booking_bloc.dart';
import '../makeBooking/make_booking_full_screen.dart';
import '../view_booking_details_screen.dart';

class ManageBookingPage extends StatelessWidget {
  const ManageBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CommonParentContainer(
        showLargeGradient: false,
        child: BlocBuilder<ManageBookingBloc, ManageState>(
          builder: (context, state) {
            if (state is ManageLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ManageError) {
              return Center(child: Text(state.message));
            }

            if (state is ManageLoaded) {
              return _BookingList(bookings: state.bookings);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );  }
}

class _BookingList extends StatefulWidget {
  final List<Booking> bookings;

  const _BookingList({required this.bookings});

  @override
  State<_BookingList> createState() => _BookingListState();
}

class _BookingListState extends State<_BookingList>
    with SingleTickerProviderStateMixin {
  late TabController _tc;
  String currentType = SelectedTab.booking.name;

  @override
  void initState() {
    _tc = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(children: [
        BookingContainer(child: Column(
          children: [
            const SizedBox(
              height: 40,
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(width: 8),
                Text(
                  "Manage Bookings",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: TabBar(
                onTap: (value) {
                  switch (value) {
                    case 0:
                      currentType = SelectedTab.booking.name;
                      break;
                    case 1:
                      currentType = SelectedTab.pendingQuotes.name;
                      break;
                    case 2:
                      currentType = SelectedTab.quoteRequest.name;
                      break;
                    case 3:
                      currentType = SelectedTab.history.name;
                      break;
                  }
                  setState(() {});
                },
                indicatorWeight: 0.001,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                indicatorSize: TabBarIndicatorSize.label,
                padding: EdgeInsets.zero,
                indicatorPadding: EdgeInsets.zero,
                dividerHeight: 0,
                labelPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                indicatorColor: Colors.white,
                controller: _tc,
                labelColor: Colors.white,
                unselectedLabelStyle:
                TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                unselectedLabelColor: Colors.white,
                labelStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                tabs: const [
                  Tab(text: 'Booking'),
                  Tab(text: 'Pending Quotes'),
                  Tab(text: 'Quote Request'),
                  Tab(text: 'History'),
                ],
              ),
            ),
          ],
      
        )),
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                  child: CustomTextField(
                    borderRadius: 8,
                    label: '',
                    fillColor: Color(0xFFE8E7E7),
                    controller: TextEditingController(),
                    keyboardType: TextInputType.phone,
                    prefixIcon: Icon(
                      Icons.search,
                      size: 15,
                    ),
                  )),
               SizedBox(width: 30),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  margin: EdgeInsets.only(right: 0, top: 10),
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
      
              //_allMenu(context),
            ],
          ),
        ),
        Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.separated(
                separatorBuilder: (context, index) =>
                    SizedBox(
                      height: 5,
                    ),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                itemCount: widget.bookings.length,
                itemBuilder: (context, i) {
                  final b = widget.bookings[i];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return ViewBookingDetailsScreen(
                            selectedVehicle: ["Tata SUV"],
                            userType: UserTypes.partner.name,
                            type: getType(),
                            isQuoteRequest: currentType == SelectedTab.quoteRequest.name,
                            isMyBooking: false);
                      },));
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 5),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0x1AB16449), // brown/orange shade
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top row: Quote ID & Date time
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Quote ID  ",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: ColorConstants.black2,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "Q-9872348",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: ColorConstants.black2,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                ],
                              ),
                              Text(
                                "Pending",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
      
                          const SizedBox(height: 4),
      
                          // Avatar + Name
                          Row(
                            children: [
                              Expanded(
                                child: Row(children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.person,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Flexible(
                                    flex: 1,
                                    child: Text(
                                      b.clientName,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                              Text(
                                "30/11/2025   10:30 AM",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: ColorConstants.black2,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
      
                          const SizedBox(height: 8),
      
                          // Pickup & Destination
                          Row(
                            children: const [
                              Expanded(
                                child: _InfoColumn(
                                  title: "Pickup point",
                                  value: "CP, New Delhi",
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _InfoColumn(
                                  title: "Destination",
                                  value: "Simla, +5 others",
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )),
      ]),
    );
  }

  String getType() {
    return currentType;
  }
}

enum SelectedTab {
  booking,
  pendingQuotes,
  quoteRequest,
  history,
}

class _InfoColumn extends StatelessWidget {
  final String title;
  final String value;

  const _InfoColumn({
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 11,
            color: ColorConstants.black2,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
