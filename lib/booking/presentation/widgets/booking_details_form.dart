import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:rwd/booking/presentation/widgets/vehicle_details_card.dart';
import 'package:rwd/placeSearch/google_place_search_widget_booking.dart';
import 'package:rwd/utils/common_utils.dart';

import '../../../components/app_loader.dart';
import '../../../constants/api_constants.dart';

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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Expanded(
              child: GooglePlaceSearchWidgetBooking(
                  onSelected: (value) async {
                    final data = await getLatLngForSelectedLoc(value.placeId);
                    if (data['latitude'] != null) {}
                  },
                  controller: _pickup,
                  type: "Pickup Point")),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            height: 40,
            child: _commonTextFields(
                controller: _totalPassengers,
                labelText: 'Total Passengers',
                textInputType: TextInputType.number,
                maxLength: 2,
                inputFormatter: [
                  FilteringTextInputFormatter.digitsOnly,
                ]),
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
                  callback: () {
                    _selectDatePicker(context, "PICKUP");
                  },
                  controller: _pickupDate,
                  labelText: "Pickup Date"),
            )),
            const SizedBox(width: 12),
            SizedBox(
              height: 40,
              width: 110,
              child: _commonTextFields(
                  readOnly: true,
                  callback: () {
                    _selectTimePicker(context, "PICKUP");
                  },
                  controller: _pickupTime,
                  labelText: "Pickup Time"),
            )
          ],
        ),
        const SizedBox(height: 12),
        Text(
          'Destinations :',
          style: CommonUtils.commonTitleStyle(
              fontSize: 14, weight: FontWeight.w400, color: Colors.black),
        ),
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
                child: Text('+ Add',
                    style: TextStyle(
                        fontFamily: AppConstants.ptSansFont,
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
              child: GooglePlaceSearchWidgetBooking(
            onSelected: (value) async {
              final data = await getLatLngForSelectedLoc(value.placeId);
              if (data['latitude'] != null) {}
            },
            controller: _returnPoint,
            type: "Return Point",
          )),
          const SizedBox(width: 10),
          SizedBox(
            height: 40,
            width: 110,
            child: _commonTextFields(
                readOnly: true,
                callback: () {
                  _selectDatePicker(context, "RETURN");
                },
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
      TextInputType? textInputType,
      List<TextInputFormatter>? inputFormatter,
      GestureTapCallback? callback,
      Widget? suffix,
      int? maxLength,
      bool readOnly = false}) {
    return TextField(
        readOnly: readOnly,
        onTap: callback,
        maxLength: maxLength,
        keyboardType: textInputType,
        inputFormatters: inputFormatter,
        controller: controller,
        buildCounter: (
          context, {
          required int currentLength,
          required bool isFocused,
          required int? maxLength,
        }) {
          return null; // 👈 hides the counter
        },
        style: TextStyle(
            fontFamily: AppConstants.ptSansFont,
            fontSize: 11,
            fontWeight: FontWeight.w400),
        decoration: InputDecoration(
            suffixIcon: suffix,
            hintStyle: TextStyle(
                fontFamily: AppConstants.ptSansFont,
                fontSize: 14,
                fontWeight: FontWeight.w400),
            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
            labelText: labelText,
            labelStyle: TextStyle(
                fontFamily: AppConstants.ptSansFont,
                fontSize: 11,
                fontWeight: FontWeight.w400),
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

  Widget _totalPassengerDropdown(BuildContext context) {
    return PopupMenuButton<String>(
      offset: Offset(50, 50),
      constraints: BoxConstraints.expand(height: 180),
      padding: EdgeInsets.zero,
      menuPadding: EdgeInsets.zero,
      onSelected: (val) async {},
      itemBuilder: (_) => const [
        PopupMenuItem(
            value: '1',
            child: ListTile(
                title: Text(
              '1',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
        PopupMenuItem(
            value: '2',
            child: ListTile(
                title: Text(
              '2',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
        PopupMenuItem(
            value: '3',
            child: ListTile(
                title: Text(
              '3',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
        PopupMenuItem(
            value: '4',
            child: ListTile(
                title: Text(
              '4',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
        PopupMenuItem(
            value: '5',
            child: ListTile(
                title: Text(
              '5',
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 11,
                  fontWeight: FontWeight.w400),
            ))),
        PopupMenuItem(
            value: '6',
            child: ListTile(
                title: Text(
              '6',
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
                "Select Type",
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

  final DateFormat _uiFormat = DateFormat('dd/MM/yyyy');
  final DateFormat _serverFormat = DateFormat('yyyy-MM-dd');
  String pickupDateServer = "";
  String returnDateServer = "";
  String pickupTimeServer = "";
  String returnTimeServer = "";

  String pickupDateLocal = "";
  String returnDateLocal = "";
  String pickupTimeLocal = "";
  String returnTimeLocal = "";

  Future<void> _selectDatePicker(BuildContext context, String type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      if (type == "PICKUP") {
        pickupDateServer = _serverFormat.format(picked);
        pickupDateLocal = _uiFormat.format(picked);
        _pickupDate.text = pickupDateLocal;
      } else {
        returnDateServer = _serverFormat.format(picked);
        returnDateLocal = _uiFormat.format(picked);
        _returnDate.text = returnDateLocal;
      }
      updateState();
    }
  }

  Future<void> _selectTimePicker(BuildContext context, String type) async {
    final TimeOfDay? picked =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());

    if (picked != null) {
      if (type == "PICKUP") {
        pickupTimeServer = picked.format(context);
        pickupTimeLocal = DateFormat('hh:mm a').format(
            DateFormat('HH:mm').parse("${picked.hour}:${picked.minute}"));
        _pickupTime.text = pickupTimeLocal;
      } else {
        returnTimeLocal = picked.format(context);
        returnTimeServer = picked.format(context);
      }
      updateState();
    }
  }

  void updateState() {
    if (mounted) {
      setState(() {});
    }
  }
}
