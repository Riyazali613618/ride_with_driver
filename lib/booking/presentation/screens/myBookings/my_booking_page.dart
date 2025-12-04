import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:r_w_r/components/app_loader.dart';

import '../../../../components/custom_text_field.dart';
import '../../../domain/model/booking.dart';
import '../../bloc/manage_booking_bloc.dart';
import '../makeBooking/make_booking_full_screen.dart';
import '../makeBooking/make_booking_preview_page.dart';
import '../view_booking_details_screen.dart';

class MyBookingPage extends StatelessWidget {
  const MyBookingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<ManageBookingBloc, ManageState>(
      listener: (context, state) {},
      child: PopScope(
          canPop: false, // Prevents default pop behavior
          onPopInvokedWithResult: (didPop, result) {
            // previousStep(context);
          },
          child: Scaffold(
            // Use cream background color from design
            backgroundColor: Colors.transparent,
            body: Column(
              children: [
                Expanded(child: BlocBuilder<ManageBookingBloc, ManageState>(
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
                })),
              ],
            ),
          )),
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

  var searchCtr = TextEditingController();
  var focusNode = FocusNode();

  @override
  void initState() {
    _tc = TabController(length: 4, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
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
              controller: searchCtr,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              prefixIcon: Icon(
                Icons.search,
                size: 15,
              ),
            )),
            SizedBox(width: 30),
            _allMenu(context),
          ],
        ),
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
          indicatorColor: AppColors.blue,
          controller: _tc,
          labelColor: Colors.purple.shade800,
          unselectedLabelColor: Colors.grey,
          labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'My Booking'),
            Tab(text: 'Pending Quotes'),
            Tab(text: 'Sent Quote Request'),
            Tab(text: 'History'),
          ],
        ),
      ),
      Expanded(
          child: ListView.separated(
        separatorBuilder: (context, index) => SizedBox(
          height: 5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        itemCount: widget.bookings.length,
        itemBuilder: (context, i) {
          final b = widget.bookings[i];
          return Column(
            children: [
              if (i == 0)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  color: AppColors.blue,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          maxLines: 1,
                          "Date",
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                          textAlign: TextAlign.start,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          maxLines: 1,
                          "Pickup Point",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          maxLines: 1,
                          "Destination",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          "Client Name",
                          maxLines: 1,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "Action",
                        maxLines: 1,
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.w500),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                ),
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
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ViewBookingDetailsScreen(
                                selectedVehicle: ["Tata SUV"],
                                type: getType(),
                                isQuoteRequest: false,
                                isMyBooking: true)));
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
                    _moreMenu(context, b,i),
                ],
              ),
            ],
          ) /*ListTile(
            leading: _statusDot(b.status),
            title: Text(DateFormat('dd/MM/yyyy').format(b.date) +
                ' - ' +
                b.pickupPoint),
            subtitle: Text('${b.destination} • ${b.clientName}'),
            trailing: _moreMenu(context, b),
          )*/
              ;
        },
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

  Widget _moreMenu(BuildContext context, Booking b,int index) {
    focusNode.unfocus();
    return PopupMenuButton<String>(
      offset: Offset(-10, 15),
      onSelected: (val) async {
        if (val == 'view') {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => ViewBookingDetailsScreen(
                  isQuoteRequest: false,
                  type: getType(),
                  selectedVehicle: ["Tata SUV"],
                  isMyBooking: true)));
        } else if (val == 'cancel') {
          final bloc = context.read<ManageBookingBloc>();
          await showDialog(
              context: context,
              builder: (c) => AlertDialog(
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
      itemBuilder: (_) => [
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
    focusNode.unfocus();
    return PopupMenuButton<String>(
      offset: Offset(0, 50),
      onSelected: (val) async {},
      itemBuilder: (_) => const [
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
    if (currentType == SelectedTab.booking.name) {
      return "My Booking";
    } else if (currentType == SelectedTab.pendingQuotes.name) {
      return "Pending Quotes";
    } else if (currentType == SelectedTab.quoteRequest.name) {
      return "Sent Quote Request";
    } else if (currentType == SelectedTab.history.name) {
      return "History";
    } else {
      return "";
    }
  }
}

enum SelectedTab {
  booking,
  pendingQuotes,
  quoteRequest,
  history,
}
