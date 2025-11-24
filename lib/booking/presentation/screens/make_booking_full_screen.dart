import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/app_loader.dart';
import '../../../screens/multi_step_progress_bar.dart';
import '../../../utils/color.dart';
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
  int? selectedBookingType = 0;
  final steps = [
    "Booking Type",
    "Booking Details",
    "Quotation & terms",
    "Preview"
  ];
  int step = 1;
  final _totalPassengers = TextEditingController(text: '7');
  final _clientNameController = TextEditingController(text: '');
  final _pickup = TextEditingController();
  final _pickupDate = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  final _pickupTime = TextEditingController(text: '10:30 AM');
  final _destinationCtr = TextEditingController();
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
      backgroundColor: Colors.transparent,
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              const SizedBox(height: 42),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      "Make Booking",
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
              // ---- Step Indicators ----
              MultiStepProgressBar(
                currentStep: selectedStep,
                stepTitles: steps,
                gradientColors: [gradientFirst, gradientSecond],
              ),
              const SizedBox(height: 12),

              /// ---- Tab Views ----
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    stepMyBookingType(),
                    stepMyBookingDetails(),
                    stepMyBookingQuotation(),
                    stepMyBookingPreview(),
                  ],
                ),
              ),

              /// ---- Navigation Buttons ----
              _buildBottomButtons(),
            ],
          ),
        ),
      ),
    );
  }

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

  //TODO STEP1///////////////////////////////////////////////////////////////
  Widget stepMyBookingType() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Row(
          children: [
            const Text('Booking Type :',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 8),
            Radio<int>(
              value: 1,
              groupValue: selectedBookingType,
              onChanged: (value) {
                setState(() {
                  selectedBookingType = value;
                });
              },
            ),
            Text("Outstation",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12))
          ],
        ),
        Row(
          children: [
            Radio<int>(
              value: 2,
              groupValue: selectedBookingType,
              onChanged: (value) {
                setState(() {
                  selectedBookingType = value;
                });
              },
            ),
            Text("City Break",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12))
          ],
        ),
      ]),
      const SizedBox(height: 16),
      const Text('Client:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      _clientTypeWidget(context),
      const SizedBox(height: 20),
      const Text('Mobile No:', style: TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
          decoration: InputDecoration(
              constraints: BoxConstraints(
                maxHeight: 40,
              ),
              contentPadding: EdgeInsets.only(left: 15, right: 10),
              hintText: '+91',
              hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8)))),
    ]);
  }

  Widget _clientTypeWidget(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(50, 50),
      constraints: BoxConstraints.expand(height: 180),
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      onSelected: (val) async {},
      itemBuilder: (_) => const [
        PopupMenuItem(
            value: 'Type 1',
            child: ListTile(
                title: Text(
              'Type 1',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
        PopupMenuItem(
            value: 'Type 2',
            child: ListTile(
                title: Text(
              'Type 2',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
        PopupMenuItem(
            value: 'Type 1',
            child: ListTile(
                title: Text(
              'Type 3',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
      ],
      child: Container(
          alignment: Alignment.centerLeft,
          height: 40,
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: BoxBorder.fromBorderSide(
                  BorderSide(color: Colors.grey, width: 1))
              /*suffixIcon: IconButton(
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                onPressed: () {},
              ),
              hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),*/
              ),
          child: Text(
            "Select Type",
            style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
            /*decoration: InputDecoration(
                  constraints: BoxConstraints(
                    maxHeight: 40,
                  ),
                  contentPadding: EdgeInsets.only(left: 10, right: 10),
                  hintText: 'Select Type',
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.grey,
                    ),
                    onPressed: () {},
                  ),
                  hintStyle:
                      TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)))*/
          )),
    );
  }

  //TODO STEP2///////////////////////////////////////////////////////////////
  Widget stepMyBookingDetails() {
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Booking Detail:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: SizedBox(
            height: 40,
            child: _commonTextFields(
                controller: _pickup, labelText: "Pickup Point"),
          )),
          const SizedBox(width: 30),
          SizedBox(
            width: 110,
            height: 40,
            child: _commonTextFields(
                controller: _totalPassengers, labelText: 'Passengers'),
          ),
        ]),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
                child: SizedBox(
              height: 40,
              child: _commonTextFields(
                  readOnly: true,
                  callback: () {},
                  controller: _pickupDate,
                  labelText: "Pickup Date"),
            )),
            const SizedBox(width: 12),
            SizedBox(
              height: 40,
              width: 110,
              child: _commonTextFields(
                  callback: () {},
                  controller: _pickupTime,
                  labelText: "Pickup Time"),
            )
          ],
        ),
        const SizedBox(height: 12),
        const Text('Destinations :'),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
                child: SizedBox(
              height: 40,
              child: _destinationTypeTextFields(
                  controller: _destinationCtr, labelText: "Input Type"),
            )),
            const SizedBox(width: 10),
            GestureDetector(
                onTap: () {
                  if (_destinationCtr.text.isNotEmpty) {
                    setState(() {
                      _destinations.add(_destinationCtr.text);
                      _destinationCtr.clear();
                    });
                  }
                },
                child: const Text('+ Add',
                    style: TextStyle(
                        color: AppColors.blue,
                        fontSize: 16,
                        fontWeight: FontWeight.bold)))
          ],
        ),
        const SizedBox(height: 15),
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
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                      labelStyle:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                      hintStyle:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      labelText: 'Return point',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8))))),
          const SizedBox(width: 12),
          Expanded(
              child: TextField(
                  controller: _returnDate,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                  decoration: InputDecoration(
                      labelStyle:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                      hintStyle:
                          TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                      labelText: 'Return date',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)))))
        ]),
        const SizedBox(height: 12),
        TextField(
            controller: _totalDays,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            decoration: InputDecoration(
                labelStyle:
                    TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                hintStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                labelText: 'Total trip Days',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8)))),
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
      ]),
    );
  }

  Widget stepMyBookingQuotation() {
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

  Widget stepMyBookingPreview() {
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

  _commonTextFields(
      {required TextEditingController controller,
      required String labelText,
      GestureTapCallback? callback,
      bool readOnly = false}) {
    return TextField(
        readOnly: readOnly,
        onTap: callback,
        controller: controller,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
            hintStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8))));
  }

  _destinationTypeTextFields(
      {required TextEditingController controller,
      required String labelText,
      GestureTapCallback? callback,
      bool readOnly = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      height: 40,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey),
      ),
      child: Row(
        children: [
          Expanded(
              child: Container(
            height: 40,
            alignment: Alignment.centerLeft,
            child: Text(
              textAlign: TextAlign.left,
              "Enter Destination",
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            ),
          )),
          Container(
            width: 1,
            height: 38,
            color: AppColors.blue,
          ),
          SizedBox(
            width: 100,
            child: Container(
              height: 40,
              width: 100,
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Select Date',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 11,
                          fontWeight: FontWeight.w400)),
                  SizedBox(width: 4),
                  Icon(Icons.calendar_month, color: AppColors.blue, size: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
