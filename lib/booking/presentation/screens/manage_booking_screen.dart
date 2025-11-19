import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:r_w_r/components/app_loader.dart';

import '../../../components/custom_text_field.dart';
import '../../domain/model/booking.dart';
import '../bloc/manage_booking_bloc.dart';
import 'make_booking_full_screen.dart';

class ManageBookingScreen extends StatelessWidget {
  const ManageBookingScreen({super.key});

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
              controller: TextEditingController(),
              keyboardType: TextInputType.phone,
              prefixIcon: Icon(
                Icons.search,
                size: 15,
              ),
            )),
            SizedBox(width: 30),
            Container(
              margin: EdgeInsets.only(top: 10),
              alignment: Alignment.center,
              padding:
                  const EdgeInsets.symmetric(horizontal: 25.0, vertical: 10.0),
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
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
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
              borderRadius: BorderRadius.circular(12)),
          tabs: const [
            Tab(text: 'Booking'),
            Tab(text: 'Pending Quotes'),
            Tab(text: 'Quote Request'),
            Tab(text: 'History'),
          ],
        ),
      ),
      Expanded(
          child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        itemCount: widget.bookings.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final b = widget.bookings[i];
          return ListTile(
            leading: _statusDot(b.status),
            title: Text(DateFormat('dd/MM/yyyy').format(b.date) +
                ' - ' +
                b.pickupPoint),
            subtitle: Text('${b.destination} • ${b.clientName}'),
            trailing: _moreMenu(context, b),
          );
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
    return CircleAvatar(radius: 6, backgroundColor: c);
  }

  Widget _moreMenu(BuildContext context, Booking b) {
    return PopupMenuButton<String>(
      onSelected: (val) async {
        if (val == 'view') {
          Navigator.of(context).push(MaterialPageRoute(
              builder: (_) => MakeBookingFullScreen(initialBooking: b)));
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
      itemBuilder: (_) => const [
        PopupMenuItem(
            value: 'view',
            child:
                ListTile(leading: Icon(Icons.visibility), title: Text('View'))),
        PopupMenuItem(
            value: 'edit',
            child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
        PopupMenuItem(
            value: 'cancel',
            child:
                ListTile(leading: Icon(Icons.cancel), title: Text('Cancel'))),
        PopupMenuItem(
            value: 'delete',
            child: ListTile(
                leading: Icon(Icons.delete, color: Colors.red),
                title: Text('Delete'))),
      ],
    );
  }
}
