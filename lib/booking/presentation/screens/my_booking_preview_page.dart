import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../components/app_loader.dart';
import '../../../utils/color.dart';
import '../widgets/vehicle_details_card.dart';

class MyBookingPreviewPage extends StatelessWidget {
  final BuildContext parentContext;
  final List<String> selectedVehicle;

  MyBookingPreviewPage({required this.parentContext,required this.selectedVehicle, super.key});


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _profileAndQuotationCard(),
          const SizedBox(height: 24),

          // ---------------- Booking Details ----------------
          const Text("Booking Detail:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 12),

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
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 14),

          _paymentTerms(),
          const SizedBox(height: 26),

          // ---------------- Note ----------------
          const Text("Note :",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(height: 10),
          _bigNoteBox(),
          const SizedBox(height: 36),

          _sendQuotationBtn(),
          const SizedBox(height: 40),
        ],
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
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
              width: (MediaQuery.of(parentContext).size.width * .40) + 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Quotation",
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
                  )
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
        SizedBox(width:80,child: _smallPayBox("Advance– INR", "10000.00")),
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
        Text(label, style: TextStyle(
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
    return Center(
      child: Container(
        width: 110,
        height: 20,
        decoration: BoxDecoration(
          gradient:
               LinearGradient(colors: [gradientFirst, gradientSecond]),
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: const Text("Send Quotation",
            style: TextStyle(color: Colors.white, fontSize: 11,fontWeight: FontWeight.w400)),
      ),
    );
  }

}
