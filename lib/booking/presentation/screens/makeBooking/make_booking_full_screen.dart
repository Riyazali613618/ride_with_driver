import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:r_w_r/components/app_loader.dart';
import 'package:r_w_r/components/common_parent_container.dart';

import '../../../../screens/multi_step_progress_bar.dart';
import '../../../../utils/color.dart';
import '../../../domain/model/booking.dart';
import '../../widgets/booking_details_form.dart';
import '../../widgets/quotation_terms_page.dart';
import 'make_booking_preview_page.dart';

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
  int? selectedBookingType = 1;
  final steps = [
    "Booking Type",
    "Booking Details",
    "Quotation & terms",
    "Preview"
  ];
  int step = 1;

  List<String> selectedVehicle = ['Tata SUV'];

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
      body: CommonParentContainer(
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
                  Expanded(
                    child: Text(
                      widget.initialBooking == null
                          ? "Make Booking"
                          : "Edit Booking",
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
                gradientColors: [Colors.green, Colors.green],
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
                    QuotationTermsPage(),
                    MyBookingPreviewPage(
                        parentContext: context,
                        selectedVehicle: selectedVehicle),
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
            SizedBox(
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll(
                    AppColors.blue,
                  ),
                  shape: WidgetStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(3.0))),
                ),
                onPressed: goToPreviousStep,
                child: const Text(
                  "Previous",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          const Spacer(),

          const SizedBox(width: 12),

          /// Continue / Submit Button
          SizedBox(
            child: ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStatePropertyAll(
                  AppColors.blue,
                ),
                shape: WidgetStateProperty.all(RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(3.0))),
              ),
              onPressed: () {
                if (selectedStep == 3) {
                  _showSuccessDialog();
                } else {
                  goToNextStep();
                }
              },
              child: Text(
                selectedStep == 3 ? "Submit" : "Next",
                style: TextStyle(color: Colors.white),
              ),
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
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 40),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                "assets/svg/booking_done.svg",
                width: 30,
                height: 30,
              ),
              const SizedBox(height: 16),
              const Text(
                "Quotation sent Successfully ",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: () {
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).pop();
                  }
                },
                child: Container(
                  width: 110,
                  height: 40,
                  decoration: BoxDecoration(
                    gradient:
                        LinearGradient(colors: [gradientFirst, gradientSecond]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text("Ok",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w400)),
                ),
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

  //TODO STEP2///////////////////////////////////////////////////////////////
  List<String> bookingDetails = [];
  int selectedBookingForm = 0;
  int day = 1;

  Widget stepMyBookingDetails() {
    if (selectedBookingType == 1) {
      selectedBookingForm = 0;
    }
    return SingleChildScrollView(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Booking Detail:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 12),
        if (selectedBookingType == 2)
          Row(
            children: [
              Expanded(
                  child: SizedBox(
                height: 30,
                child: ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemCount: bookingDetails.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        selectedBookingForm = index;
                        setState(() {});
                      },
                      child: Container(
                        height: 30,
                        margin: EdgeInsets.only(right: 6),
                        padding: EdgeInsets.symmetric(horizontal: 6),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: index == selectedBookingForm
                              ? AppColors.blue
                              : Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                          border: BoxBorder.fromBorderSide(
                              BorderSide(color: Colors.grey, width: 1)),
                        ),
                        child: Text(
                          bookingDetails[index],
                          style: TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 10,
                              color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),
              )),
              GestureDetector(
                onTap: () {
                  bookingDetails.insert(0, "${day++}-11-2025");
                  setState(() {});
                },
                child: Text(
                  "+ Add Day",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.blue),
                ),
              )
            ],
          ),
        SizedBox(
          height: 20,
        ),
        BookingDetailsForm(
            index: selectedBookingForm, bookingList: bookingDetails),
      ]),
    );
  }
}
