import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:r_w_r/booking/presentation/screens/makeBooking/make_booking_full_screen.dart';
import 'package:r_w_r/booking/presentation/widgets/add_value_popup.dart';
import 'package:r_w_r/booking/presentation/widgets/show_otp_popup.dart';
import 'package:r_w_r/components/common_parent_container.dart';

import '../../../../components/app_loader.dart';
import '../../../../utils/color.dart';
import '../../../utils/common_utils.dart';
import '../widgets/add_payment_dialog.dart';
import '../widgets/refund_form_popup.dart';
import '../widgets/vehicle_details_card.dart';

class ViewBookingDetailsScreen extends StatefulWidget {
  final List<String> selectedVehicle;
  final bool isMyBooking;
  final bool isQuoteRequest;
  final String type;

  const ViewBookingDetailsScreen(
      {required this.isMyBooking,
      required this.isQuoteRequest,
      required this.selectedVehicle,
      required this.type,
      super.key});

  @override
  State<ViewBookingDetailsScreen> createState() =>
      _ViewBookingDetailsScreenState();
}

class _ViewBookingDetailsScreenState extends State<ViewBookingDetailsScreen> {
  String bookingJourneyStatus = "";

  String bookingStartStatus = "";

  @override
  Widget build(BuildContext context) {
    print(widget.type);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CommonParentContainer(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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
                        "B-23456789",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
                if (widget.isQuoteRequest) const SizedBox(height: 10),

                if (!widget.isMyBooking && !widget.isQuoteRequest && widget.type != "History")
                  showEditCancelView(context),
                if((widget.isMyBooking && widget.type!="Pending Quotes" ))
                  showEditCancelView(context),
                const SizedBox(height: 10),
                if (!widget.isQuoteRequest &&
                    widget.type != "History" &&
                    (widget.isMyBooking && widget.type != "Pending Quotes"))
                  Row(
                    children: [
                      Expanded(
                          child: Column(
                        children: [
                          Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40641BB4),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 5, vertical: 10),
                            width: MediaQuery.of(context).size.width,
                            child: RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                    style: TextStyle(
                                        letterSpacing: 1, wordSpacing: 1),
                                    children: [
                                      TextSpan(
                                          text: "Total Amount",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white)),
                                      TextSpan(
                                        text: "\n30000.00",
                                        style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.white),
                                      ),
                                    ])),
                          ),
                          const SizedBox(height: 10),
                          Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: Color(0xFFB16449),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40641BB4),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      style: TextStyle(
                                          letterSpacing: 1, wordSpacing: 1),
                                      children: [
                                        TextSpan(
                                            text: "Outstanding",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        TextSpan(
                                            text: "\n30000.00",
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white)),
                                      ]))),
                        ],
                      )),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Column(
                        children: [
                          Container(
                              alignment: Alignment.center,
                              width: MediaQuery.of(context).size.width,
                              decoration: BoxDecoration(
                                color: AppColors.blue,
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40641BB4),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      style: TextStyle(
                                          letterSpacing: 1, wordSpacing: 1),
                                      children: [
                                        TextSpan(
                                            text: "Recieved",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        TextSpan(
                                            text: "\n30000.00",
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white)),
                                      ]))),
                          const SizedBox(height: 10),
                          Container(
                              width: MediaQuery.of(context).size.width,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xFFB16449),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x40641BB4),
                                    blurRadius: 4,
                                    offset: Offset(0, 4),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 10),
                              child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                      style: TextStyle(
                                          letterSpacing: 1, wordSpacing: 1),
                                      children: [
                                        TextSpan(
                                            text: "Value Addition",
                                            style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white)),
                                        TextSpan(
                                            text: "\n30000.00",
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w400,
                                                color: Colors.white)),
                                      ]))),
                        ],
                      )),
                      const SizedBox(width: 10),
                      if (widget.isMyBooking)
                        Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40641BB4),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Text("Code\n9999",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white)))
                      else
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AddPaymentRecordPopup(
                                    listener: (type) {
                                      setState(() {
                                        bookingJourneyStatus = "Upcoming";
                                        bookingStartStatus = "Start Journey";
                                      });
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: AppColors.blue,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x40641BB4),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  child: Text("+ Add Payment",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white))),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                showDialog(
                                  context: context,
                                  barrierDismissible: false,
                                  builder: (_) => AddValuePopup(
                                    listener: (type) {
                                      setState(() {
                                        bookingJourneyStatus = "Upcoming";
                                        bookingStartStatus = "Start Journey";
                                      });
                                    },
                                  ),
                                );
                              },
                              child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFB16449),
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color(0x40641BB4),
                                        blurRadius: 4,
                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  child: Text("  + Add Value  ",
                                      style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: Colors.white))),
                            ),
                          ],
                        ),
                    ],
                  ),
                if (!widget.isQuoteRequest && widget.type != "History")
                  const SizedBox(height: 20),
                if (bookingJourneyStatus.isNotEmpty)
                  Row(
                    children: [
                      SizedBox(
                        width: 20,
                        child: CircleAvatar(
                            radius: 4, backgroundColor: Colors.red),
                      ),
                      Text(
                        bookingJourneyStatus,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.black),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () {
                          if (bookingStartStatus == "End") {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => ShowCancelAlertPopup(
                                listener: (type) {
                                  if (type == "cancel") {
                                    showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (_) => RefundFormPopup(),
                                    );
                                  }
                                },
                              ),
                            );
                          } else {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => ShowOtpPopup(
                                listener: (type) {
                                  bookingJourneyStatus = "Ongoing";
                                  bookingStartStatus = "End";
                                  setState(() {});
                                },
                              ),
                            );
                          }
                        },
                        child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: AppColors.blue,
                              borderRadius: BorderRadius.circular(6),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x40641BB4),
                                  blurRadius: 4,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            child: Text(bookingStartStatus,
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white))),
                      ),
                    ],
                  ),
                if (bookingJourneyStatus.isNotEmpty) const SizedBox(height: 20),
// ---- Step
                _profileAndQuotationCard(),
                const SizedBox(height: 5),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                      border: BoxBorder.fromBorderSide(
                          BorderSide(color: AppColors.blue, width: 0.5))),
                  child: Row(
                    children: [
                      Expanded(
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text("Mr Narendra Pratap Singh:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF595959))),
                          SizedBox(
                            height: 4,
                          ),
                          const Text("Mobile: +918787878787",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 11)),
                        ],
                      )),
                      SizedBox(
                        width: 10,
                      ),
                      Expanded(
                          child: Column(
                        children: [
                          const Text("Vehicle Booking For:",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Color(0xFF595959))),
                          SizedBox(
                            height: 4,
                          ),
                          const Text("{Pickup Point}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w400, fontSize: 11)),
                        ],
                      )),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- Booking Details ----------------
                const Text("Booking Detail:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 14),

                _labelInput("Total Passenger :", "7"),
                const SizedBox(height: 10),

                _labelInput("Pickup Point :", "Input Type"),
                const SizedBox(height: 10),

                _pickupDateTimeRow(),
                const SizedBox(height: 14),

                _destinationList(),
                const SizedBox(height: 12),

                _labelInput("Return point :", "Input Type"),
                const SizedBox(height: 10),
                _returnDate(),
                const SizedBox(height: 10),

                _labelInput("Total trip Days :", "4 Days"),
                const SizedBox(height: 18),

                // ---------------- Vehicle Details ----------------
                const Text("Vehicle Details :",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 12),

                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  scrollDirection: Axis.vertical,
                  padding: EdgeInsets.zero,
                  itemCount: widget.selectedVehicle.length,
                  itemBuilder: (context, index) {
                    return VehicleDetailsCard(
                      pos: index,
                      name: widget.selectedVehicle[index],
                    );
                  },
                ),

                _amountRow(),
                const SizedBox(height: 20),

                _totalAndHours(),
                const SizedBox(height: 16),

                const Divider(thickness: 1),
                const SizedBox(height: 16),

                // ---------------- Payment Terms ----------------
                const Text("Payment terms:",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 14),

                _paymentTerms(),
                const SizedBox(height: 26),

                // ---------------- Note ----------------
                const Text("Note :",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                _bigNoteBox(),
                const SizedBox(height: 36),

                if (widget.type != "Booking" && (!widget.isMyBooking)) ...[
                  _sendQuotationBtn(),
                  const SizedBox(height: 40),
                ],
                if(widget.isMyBooking && widget.type=="Pending Quotes" )...[
                  _acceptDeclineBtn(),
                  const SizedBox(height: 40),
                ]

              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _circle(bool done, String text) {
    return CircleAvatar(
      radius: 14,
      backgroundColor: done ? Colors.green : Colors.brown,
      child: Text(text, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _line() => Container(height: 2, width: 50, color: Colors.grey);

  // ------------------------ Profile + Quotation section ------------------------
  Widget _profileAndQuotationCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFFEDF7ED)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CircleAvatar(
                        radius: 32,
                        backgroundImage:
                            NetworkImage("https://via.placeholder.com/100")),
                    // sample profile
                    SizedBox(height: 6),
                    Text("Abc Travel Agency",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(
                      "501, 5th floor, trade complex\nNoida UP-190091, India",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    Text(
                      "Info@domain.com",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                    Text(
                      "Mobile- +91 9999999999",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: Colors.black),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            SizedBox(
              width: (MediaQuery.of(context).size.width * .40) + 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.isQuoteRequest ? "Quote Request" : "Quotation",
                    style: TextStyle(
                        color: Color(0xFFB66A53),
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Container(
                    color: Color(0xFFF8EDDA),
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Quote id:",
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                "Q-00012345",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Issued date:",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                "30-10-25",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                "Cancellation Deadline:",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                            ),
                            SizedBox(
                              width: 4,
                            ),
                            Expanded(
                              child: Text(
                                "31-10-25 – 11:59 PM",
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Radio<int>(
                        value: 1,
                        groupValue: 1,
                        onChanged: (value) {},
                        activeColor: Color(0xFF1FAF38),
                      ),
                      Text("Outstation",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 15))
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ],
    );
  }

  // -------------------- Default 40 height Input Box --------------------
  Widget _labelInput(String label, String value) {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: Text(label,
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w400,
                    color: Colors.black))),
        Expanded(
          flex: 3,
          child: SizedBox(
            height: 30,
            child: TextField(
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF9E9E9E)),
              readOnly: true,
              controller: TextEditingController(text: value),
              decoration: _inputDecoration(),
            ),
          ),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration() => InputDecoration(
        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.grey)),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: Colors.grey)),
      );

  Widget _pickupDateTimeRow() {
    return Row(
      children: [
        Expanded(
            flex: 2,
            child: const Text(
              "Pickup Date & Time :",
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            )),
        Expanded(
          flex: 3,
          child: Row(children: [
            Expanded(
              child: SizedBox(
                  height: 30,
                  child: TextField(
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9E9E)),
                      controller: TextEditingController(text: "30/10/2025"),
                      decoration: _inputDecoration())),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SizedBox(
                  height: 30,
                  child: TextField(
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF9E9E9E)),
                      controller: TextEditingController(text: "10:30 AM"),
                      decoration: _inputDecoration())),
            ),
          ]),
        ),
      ],
    );
  }

  // ---------------- Destinations preview list ----------------
  Widget _destinationList() {
    final destinations = [
      {"name": "Chamba", "date": "30/10/2025"},
      {"name": "Simla", "date": "31/10/2025"},
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
            flex: 2,
            child: const Text(
              "Destinations :",
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            )),
        Expanded(
            flex: 3,
            child: Column(
              children: [
                ...destinations.asMap().entries.map((e) {
                  return Container(
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
                                    child: Text(e.value["name"]!,
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
                      ],
                    ),
                  );
                }).toList()
              ],
            ))
      ],
    );
  }

  Widget _returnDate() {
    return _labelInput("Return date :", "30/10/2025");
  }

  // ---------------- Amount field ----------------
  Widget _amountRow() {
    return Row(
      children: [
        Spacer(),
        const Text(
          "Amount-",
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w400, color: Colors.black),
        ),
        const SizedBox(width: 10),
        SizedBox(
          height: 30,
          width: 100,
          child: TextField(
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w400, color: Colors.black),
            controller: TextEditingController(text: "20000.00"),
            decoration: _inputDecoration(),
          ),
        ),
      ],
    );
  }

  // ---------------- Total Amount + Hours ----------------
  Widget _totalAndHours() {
    return Column(
      children: [
        _labelInput("Total Amount :", "20000.00"),
        const SizedBox(height: 10),
        _labelInput("Daily driver working hours :", "10"),
      ],
    );
  }

  // ---------------- Payment Terms (4 fields) ----------------
  Widget _paymentTerms() {
    return Row(
      children: [
        SizedBox(width: 80, child: _smallPayBox("Advance– INR", "10000.00")),
        const SizedBox(width: 8),
        Expanded(child: _smallPayBox("Pay on Arrival– INR", "20000.00")),
        const SizedBox(width: 8),
        Expanded(child: _smallPayBox("Pay on completion– INR", "15000.00")),
      ],
    );
  }

  Widget _smallPayBox(String label, String value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black)),
        Container(
          width: double.infinity,
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey),
          ),
          height: 30,
          child: Text(
            value,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Color(0xFF595959)),
          ),
        )
      ],
    );
  }

  // ---------------- Note Box ----------------
  Widget _bigNoteBox() {
    return Container(
      height: 120,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.grey)),
      padding: const EdgeInsets.all(10),
      child: const TextField(
        maxLines: null,
        decoration: InputDecoration(border: InputBorder.none),
      ),
    );
  }

  // ---------------- Buttons ----------------
  Widget _sendQuotationBtn() {
    return Row(
      children: [
        if (widget.isQuoteRequest)
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: const Text("Decline",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w400)),
            ),
          ),
        Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MakeBookingFullScreen()));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                widget.isQuoteRequest ? Colors.green : gradientFirst,
                widget.isQuoteRequest ? Colors.green : gradientSecond
              ]),
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Text(
                widget.isQuoteRequest
                    ? "Accept & Send Quotation"
                    : "Send Quotation",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w400)),
          ),
        ),
      ],
    );
  }

  Widget _acceptDeclineBtn() {
    return Row(
      children: [
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(30),
              ),
              alignment: Alignment.center,
              child: const Text("Decline",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w400)),
            ),
          ),
        Spacer(),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => MakeBookingFullScreen()));
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            decoration: BoxDecoration(
             color: Colors.green,
              borderRadius: BorderRadius.circular(30),
            ),
            alignment: Alignment.center,
            child: Text("Accept",
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w400)),
          ),
        ),
      ],
    );
  }

  showEditCancelView(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.type != "Pending Quote")
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            color: Colors.red,
            child: Text(
              "Cancel Booking",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w400),
            ),
          ),
        Spacer(),
        if (!widget.isMyBooking)
          GestureDetector(
            onTap: () {
              CommonUtils.goToScreen(context, MakeBookingFullScreen());
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              color: AppColors.blue,
              child: Row(
                children: [
                  SvgPicture.asset(
                    "assets/svg/edit.svg",
                    width: 15,
                    height: 15,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Edit",
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white),
                  )
                ],
              ),
            ),
          ),
      ],
    );
  }
}
