import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../domain/model/booking.dart';
import '../bloc/make_booking_bloc.dart';
import '../widgets/gradient_header.dart';

class MakeBookingFullScreen extends StatefulWidget {
  final Booking? initialBooking;
  const MakeBookingFullScreen({this.initialBooking, super.key});

  @override
  State<MakeBookingFullScreen> createState() => _MakeBookingFullScreenState();
}

class _MakeBookingFullScreenState extends State<MakeBookingFullScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int selectedStep = 0;
  int step = 1;
  final _totalPassengers = TextEditingController(text: '7');
  final _pickup = TextEditingController();
  final _pickupDate = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  final _pickupTime = TextEditingController(text: '10:30 AM');
  final _destinations = <String>['Chamba', 'Simla'];
  final _returnPoint = TextEditingController();
  final _returnDate = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  final _totalDays = TextEditingController(text: '4');
  final _amount = TextEditingController(text: '20000.00');
  final _advance = TextEditingController(text: '10000.00');
  final _onArrival = TextEditingController(text: '20000.00');
  final _onCompletion = TextEditingController(text: '15000.00');
  final _note = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          selectedStep = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void goToNextStep() {
    if (selectedStep < 3) {
      setState(() {
        selectedStep++;
      });
      _tabController.animateTo(selectedStep);
    }
  }

  void goToPreviousStep() {
    if (selectedStep > 0) {
      setState(() {
        selectedStep--;
      });
      _tabController.animateTo(selectedStep);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF7F7F7),
      appBar: AppBar(
        title: const Text("Make a Booking"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),

          /// ---- Step Indicators ----
          _buildStepHeader(),

          const SizedBox(height: 12),

          /// ---- Tab Views ----
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                step1ServiceSelection(),
                step2ChooseSlot(),
                step3EnterDetails(),
                step4BookingSummary(),
              ],
            ),
          ),

          /// ---- Navigation Buttons ----
          _buildBottomButtons(),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// STEP HEADER
  /// --------------------------------------------------------------------------
  Widget _buildStepHeader() {
    final steps = ["Services", "Slot", "Details", "Summary"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == selectedStep;
          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor:
                      isActive ? Colors.blue : Colors.grey.shade400,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// BOTTOM NAVIGATION BUTTONS
  /// --------------------------------------------------------------------------
  Widget _buildBottomButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          /// Back Button
          if (selectedStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: goToPreviousStep,
                child: const Text("Back"),
              ),
            )
          else
            const Spacer(),

          const SizedBox(width: 12),

          /// Continue / Submit Button
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (selectedStep == 3) {
                  _showSuccessDialog();
                } else {
                  goToNextStep();
                }
              },
              child: Text(selectedStep == 3 ? "Submit" : "Continue"),
            ),
          ),
        ],
      ),
    );
  }

  /// --------------------------------------------------------------------------
  /// SUCCESS DIALOG
  /// --------------------------------------------------------------------------
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 60),
              const SizedBox(height: 16),
              const Text(
                "Booking Successful!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                "Your booking has been confirmed.",
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget step1ServiceSelection() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Booking Type :',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [
        Flexible(
            child: RadioListTile(
                value: 'out',
                groupValue: 'out',
                onChanged: (_) {},
                title: const Text('Outstation'))),
        Flexible(
            child: RadioListTile(
                value: 'city',
                groupValue: null,
                onChanged: (_) {},
                title: const Text('City Break')))
      ]),
      const SizedBox(height: 16),
      const Text('Client Name :',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
          decoration: InputDecoration(
              hintText: 'Select Type',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
      const SizedBox(height: 12),
      TextField(
          decoration: InputDecoration(
              hintText: '+91 9999999999',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
    ]);
  }

  Widget step2ChooseSlot() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Booking Detail:',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: TextField(
                controller: _totalPassengers,
                decoration: InputDecoration(
                    labelText: 'Total Passenger',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8))))),
        const SizedBox(width: 12),
        Expanded(
            child: TextField(
                controller: _pickup,
                decoration: InputDecoration(
                    labelText: 'Pickup point',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)))))
      ]),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
              child: TextField(
                  controller: _pickupDate,
                  decoration: InputDecoration(
                      labelText: 'Pickup Date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 12),
          Expanded(
              child: TextField(
                  controller: _pickupTime,
                  decoration: InputDecoration(
                      labelText: 'Pickup Time',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))))
        ],
      ),
      const SizedBox(height: 12),
      const Text('Destinations :'),
      const SizedBox(height: 8),
      Column(
          children: _destinations
              .asMap()
              .entries
              .map((e) => Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(8),
                  color: Colors.grey.shade300,
                  child: Row(children: [
                    Container(
                        width: 28,
                        height: 28,
                        alignment: Alignment.center,
                        color: Colors.grey,
                        child: Text('${e.key + 1}')),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.value)),
                    Text(DateFormat('dd/MM/yyyy').format(DateTime.now()))
                  ])))
              .toList()),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: TextField(
                controller: _returnPoint,
                decoration: InputDecoration(
                    labelText: 'Return point',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8))))),
        const SizedBox(width: 12),
        Expanded(
            child: TextField(
                controller: _returnDate,
                decoration: InputDecoration(
                    labelText: 'Return date',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)))))
      ]),
      const SizedBox(height: 12),
      TextField(
          controller: _totalDays,
          decoration: InputDecoration(
              labelText: 'Total trip Days',
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
      const SizedBox(height: 16),
      const Text('Vehicle Details :',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Container(
          height: 120,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300)),
          child: Row(children: [
            Expanded(
                child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Tata SUV',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          SizedBox(height: 6),
                          Text(
                              'RE Compact • 7 SeatsVehicle Number - CH 01 HG 5687',
                              style: TextStyle(fontSize: 12))
                        ]))),
            SizedBox(
                width: 120,
                child: Image.network('https://via.placeholder.com/120',
                    fit: BoxFit.cover))
          ])),
    ]);
  }

  Widget step3EnterDetails() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Quotation Amount:',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
              child: TextField(
                  controller: _amount,
                  decoration: InputDecoration(
                      labelText: 'Amount',
                      prefixText: 'INR- ',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 12),
          Expanded(
              child: TextField(
                  controller: _totalDays,
                  decoration: InputDecoration(
                      labelText: 'Daily driver working hours',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))))
        ],
      ),
      const SizedBox(height: 12),
      const Divider(),
      const SizedBox(height: 12),
      const Text('Payment terms:',
          style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Row(children: [
        Expanded(
            child: TextField(
                controller: _advance,
                decoration: InputDecoration(
                    labelText: 'Advance- INR',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8))))),
        const SizedBox(width: 8),
        Expanded(
            child: TextField(
                controller: _onArrival,
                decoration: InputDecoration(
                    labelText: 'Pay on Arrival- INR',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8))))),
        const SizedBox(width: 8),
        Expanded(
            child: TextField(
                controller: _onCompletion,
                decoration: InputDecoration(
                    labelText: 'Pay on completion- INR',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)))))
      ]),
      const SizedBox(height: 12),
      const Text('Note :', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
          controller: _note,
          maxLines: 4,
          decoration: InputDecoration(
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8))))
    ]);
  }

  Widget step4BookingSummary() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Preview',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      const SizedBox(height: 12),
      Card(
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quotation',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text('Amount: INR- \${_amount.text}'),
                    Text('Days: \${_totalDays.text}')
                  ])))
    ]);
  }
}
