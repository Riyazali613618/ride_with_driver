import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:r_w_r/booking/presentation/widgets/vehicle_details_card.dart';

import '../../../components/app_loader.dart';

class BookingDetailsForm extends StatefulWidget {
  final int index;
  final List<String> bookingList;

  const BookingDetailsForm(
      {required this.index, required this.bookingList, super.key});

  @override
  State<BookingDetailsForm> createState() => _BookingDetailsFormState();
}

class _BookingDetailsFormState extends State<BookingDetailsForm> {
  int selectedStep = 0;
  int? selectedBookingType = 0;
  final steps = [
    "Booking Type",
    "Booking Details",
    "Quotation & terms",
    "Preview"
  ];
  final _totalPassengers = TextEditingController(text: '7');
  final _pickup = TextEditingController();
  final _pickupDate = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  final _pickupTime = TextEditingController(text: '10:30 AM');
  final _destinationCtr = TextEditingController();
  final _destinations = <String>['Chamba', 'Simla'];
  final _returnPoint = TextEditingController();
  final _returnDate = TextEditingController(
      text: DateFormat('dd/MM/yyyy').format(DateTime.now()));
  List<String> selectedVehicle = ['Tata SUV'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(children: [
          Expanded(
              child: SizedBox(
            height: 40,
            child: _commonTextFields(
                controller: _pickup, labelText: "Pickup Point"),
          )),
          const SizedBox(width: 10),
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
                  readOnly: true,
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
                      margin: EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Container(
                              alignment: Alignment.center,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              color: AppColors.darkGrey,
                              child: Text(
                                '${e.key + 1}',
                                style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 10,
                                    color: Colors.white),
                              )),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                                padding: const EdgeInsets.all(8),
                                color: AppColors.darkGrey,
                                child: Row(children: [
                                  Expanded(
                                      child: Text(e.value,
                                          style: TextStyle(
                                              fontWeight: FontWeight.w400,
                                              fontSize: 10,
                                              color: Colors.white))),
                                  Text(
                                      DateFormat('dd/MM/yyyy')
                                          .format(DateTime.now()),
                                      style: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 10,
                                          color: Colors.white))
                                ])),
                          ),
                          const SizedBox(width: 10),
                          GestureDetector(
                              onTap: () {
                                setState(() {
                                  _destinations.removeAt(e.key);
                                });
                              },
                              child: SvgPicture.asset(
                                "assets/svg/cross.svg",
                                width: 16,
                                height: 16,
                              )),
                          const SizedBox(width: 40),
                        ],
                      ),
                    ))
                .toList()),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(
              child: SizedBox(
            height: 40,
            child: _commonTextFields(
                controller: _returnPoint, labelText: "Input Type"),
          )),
          const SizedBox(width: 10),
          SizedBox(
            height: 40,
            width: 110,
            child: _commonTextFields(
                readOnly: true,
                callback: () {},
                controller: _returnDate,
                labelText: "Return Date"),
          )
        ]),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              text: "Trip booking duration is for ",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 10,
                  fontWeight: FontWeight.w400),
              children: [
                TextSpan(
                    text: '5 days',
                    style: const TextStyle(
                        color: Colors.blue,
                        fontSize: 10,
                        fontWeight: FontWeight.w400)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        _chooseVehicleTypeWidget(context),
        const SizedBox(height: 8),
        const Text('Vehicle Details :',
            style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          padding: EdgeInsets.zero,
          itemCount: selectedVehicle.length,
          itemBuilder: (context, index) {
            return VehicleDetailsCard(
                pos: index,
                name: selectedVehicle[index],
                onTap: (pos) {
                  setState(() {
                    selectedVehicle.removeAt(index);
                    setState(() {});
                  });
                });
          },
        ),
      ],
    );
  }

  _commonTextFields(
      {required TextEditingController controller,
      required String labelText,
      GestureTapCallback? callback,
      Widget? suffix,
      bool readOnly = false}) {
    return TextField(
        readOnly: readOnly,
        onTap: callback,
        controller: controller,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        decoration: InputDecoration(
            suffixIcon: suffix,
            hintStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            labelText: labelText,
            labelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
            border:
                OutlineInputBorder(borderRadius: BorderRadius.circular(8))));
  }

  Widget _chooseVehicleTypeWidget(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(50, 50),
      constraints: BoxConstraints.expand(height: 180),
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      onSelected: (val) async {
        if (!selectedVehicle.contains(val)) {
          selectedVehicle.add(val);
          setState(() {
            ;
          });
        }
      },
      itemBuilder: (_) => const [
        PopupMenuItem(
            value: 'Tata SUV',
            child: ListTile(
                title: Text(
              'Tata SUV',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
        PopupMenuItem(
            value: 'Tata Curve',
            child: ListTile(
                title: Text(
              'Tata Curve',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
        PopupMenuItem(
            value: 'Tata Punch',
            child: ListTile(
                title: Text(
              'Tata Punch',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
      ],
      child: Container(
          alignment: Alignment.centerLeft,
          height: 40,
          width: MediaQuery.of(context).size.width * .80,
          padding: EdgeInsets.only(left: 10, right: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: BoxBorder.fromBorderSide(
                BorderSide(color: Colors.grey, width: 1)),
            /*suffixIcon: IconButton(
                icon: const Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey,
                ),
                onPressed: () {},
              ),
              hintStyle: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),*/
          ),
          child: Row(
            children: [
              Expanded(
                  child: Text(
                "Select Type Multiple",
                style: TextStyle(fontWeight: FontWeight.w400, fontSize: 12),
              )),
              const Icon(
                Icons.arrow_drop_down,
                color: Colors.grey,
              )
            ],
          )),
    );
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
