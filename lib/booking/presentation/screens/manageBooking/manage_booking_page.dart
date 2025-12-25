import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:r_w_r/components/app_loader.dart';
import 'package:r_w_r/components/booking_container.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/constants/color_constants.dart';
import 'package:r_w_r/utils/common_utils.dart';

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
    return BlocListener<ManageBookingBloc, ManageState>(
      listener: (context, state) {},
      child: Scaffold(
        backgroundColor: Colors.white,
        body: BlocBuilder<ManageBookingBloc, ManageState>(
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
    );
  }
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
    return Column(children: [
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
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: 20,
                          child: _statusDot(b.status),
                        ),
                        Expanded(
                          child: Text(
                            DateFormat('dd/MM/yy').format(b.date),
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.start,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            b.pickupPoint,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            b.destination,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Expanded(
                          child: Text(
                            b.clientName,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontSize: 10,
                                color: Colors.black,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        if (currentType == SelectedTab.quoteRequest.name)
                          GestureDetector(
                            onTap: () {
                              CommonUtils.goToScreen(
                                  context,
                                  ViewBookingDetailsScreen(
                                      userType: UserTypes.partner.name,
                                      selectedVehicle: ["Tata SUV"],
                                      isQuoteRequest: true,
                                      type: getType(),
                                      isMyBooking: false));
                            },
                            child: Container(
                              padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              child: Icon(
                                Icons.visibility,
                                size: 20,
                              ),
                            ),
                          )
                        else
                          _moreMenu(context, b, i),
                      ],
                    ),
                  ],
                );
              },
            ),
          )),
    ]);
  }

  Widget _statusDot(BookingStatus s) {
    Color c = Colors.green;
    switch (s) {
      case BookingStatus.ongoing:
        c = Colors.green;
        break;
      case BookingStatus.upcoming:
        c = Colors.orange;
        break;
      case BookingStatus.pendingQuote:
        c = Colors.brown;
        break;
      case BookingStatus.completed:
        c = Colors.grey;
        break;
      case BookingStatus.cancelled:
        c = Colors.red;
        break;
    }
    return CircleAvatar(radius: 4, backgroundColor: c);
  }

  Widget _moreMenu(BuildContext context, Booking b, int index) {
    return PopupMenuButton<String>(
      offset: Offset(-10, 15),
      onSelected: (val) async {
        if (val == 'view') {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) =>
                  ViewBookingDetailsScreen(
                      selectedVehicle: ["Tata SUV"],
                      userType: UserTypes.partner.name,
                      type: getType(),
                      isQuoteRequest: getType() == "Quote Request",
                      isMyBooking: false)));
        } else if (val == 'cancel') {
          final bloc = context.read<ManageBookingBloc>();
          await showDialog(
              context: context,
              builder: (c) =>
                  AlertDialog(
                      title: const Text('Cancel'),
                      content: const Text('Are you sure?'),
                      actions: [
                        TextButton(
                            onPressed: () => Navigator.pop(c),
                            child: const Text('No')),
                        TextButton(
                            onPressed: () {
                              bloc.add(CancelBookingEvent(b.id));
                              Navigator.pop(c);
                            },
                            child: const Text('Yes'))
                      ]));
        } else if (val == 'edit') {
// navigate to edit - in demo we open make booking
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MakeBookingFullScreen(initialBooking: b)));
        } else if (val == 'delete') {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Deleted (mock)')));
        }
      },
      itemBuilder: (_) =>
      [
        PopupMenuItem(
            value: 'view',
            child: ListTile(
                leading: Icon(
                  Icons.visibility,
                  size: 20,
                ),
                title: Text(
                  'View',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                ))),
        if (currentType == SelectedTab.pendingQuotes.name)
          PopupMenuItem(
              value: 'edit',
              child: ListTile(
                  leading: Icon(
                    Icons.edit,
                    size: 20,
                  ),
                  title: Text(
                    'Edit',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w400),
                  ))),
        if (currentType == SelectedTab.booking.name)
          PopupMenuItem(
              value: 'cancel',
              child: ListTile(
                  leading: Icon(
                    Icons.cancel,
                    size: 20,
                  ),
                  title: Text(
                    'Cancel',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w400),
                  ))),
        if (currentType == SelectedTab.history.name)
          PopupMenuItem(
              value: 'delete',
              child: ListTile(
                  leading: Icon(
                    Icons.delete,
                    color: Colors.red,
                    size: 20,
                  ),
                  title: Text(
                    'Delete',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 11,
                        fontWeight: FontWeight.w400),
                  ))),
      ],
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: SvgPicture.asset(
            "assets/svg/more_hori.svg",
            width: 5,
            height: 5,
          )),
    );
  }

  Widget _allMenu(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(0, 50),
      onSelected: (val) async {},
      itemBuilder: (_) =>
      const [
        PopupMenuItem(
            value: 'all',
            child: ListTile(
                title: Text(
                  'All',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                ))),
        PopupMenuItem(
            value: 'Pending',
            child: ListTile(
                title: Text(
                  'Pending',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                ))),
        PopupMenuItem(
            value: 'completed',
            child: ListTile(
                title: Text(
                  'Completed',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 11,
                      fontWeight: FontWeight.w400),
                ))),
      ],
      child: Container(
        margin: EdgeInsets.only(top: 10),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
        color: AppColors.blue,
        child: Row(
          children: [
            Text(
              "All",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Colors.white),
            ),
            SizedBox(width: 10),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white,
              size: 20,
            )
          ],
        ),
      ),
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
