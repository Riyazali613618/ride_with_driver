import 'package:flutter/material.dart';
import 'package:r_w_r/screens/autoRikshawDriverRegistration.dart';
import 'package:r_w_r/screens/driverRegistrationScreen.dart';
import 'package:r_w_r/screens/eRickshawRegistration.dart';
import 'package:r_w_r/screens/registration_screens/become_driver_registration_screen.dart';
import 'package:r_w_r/screens/registration_screens/e_rikshaw_registration_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../api/api_model/language/language_model.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../transporterRegistration/presentation/pages/transporter_registration_page.dart';
import '../independentCarOwnerRegistration.dart';
import '../registration_screens/auto_rikshaw_registration_screenn.dart';
import '../registration_screens/indipendent_car_owner_registration_screen.dart';
import '../registration_screens/transporter_registration_screen.dart';
import '../transporterRegistration.dart' hide ApplicationStatus;

class AutoRickshawProgressCard extends StatefulWidget {
  const AutoRickshawProgressCard({Key? key}) : super(key: key);

  @override
  State<AutoRickshawProgressCard> createState() =>
      _AutoRickshawProgressCardState();
}

class _AutoRickshawProgressCardState extends State<AutoRickshawProgressCard> {
  ApplicationStatus _status = ApplicationStatus.notStarted;
  String? whoReg;

  @override
  void initState() {
    super.initState();
    _loadWhoReg();
  }

  Future<void> _loadApplicationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('auto_rickshaw_status');
    if (statusString != null) {
      setState(() {
        _status = ApplicationStatus.values.firstWhere(
          (e) => e.toString() == statusString,
          orElse: () => ApplicationStatus.notStarted,
        );
      });
    }
  }

  Future<void> _loadApplicationStatusDriver() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('driver_status');
    if (statusString != null) {
      setState(() {
        _status = ApplicationStatus.values.firstWhere(
          (e) => e.toString() == statusString,
          orElse: () => ApplicationStatus.notStarted,
        );
      });
    }
  }

  Future<void> _loadApplicationStatusER() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('er_status');
    if (statusString != null) {
      setState(() {
        _status = ApplicationStatus.values.firstWhere(
          (e) => e.toString() == statusString,
          orElse: () => ApplicationStatus.notStarted,
        );
      });
    }
  }

  Future<void> _loadApplicationStatusTrans() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('transporter_status');
    if (statusString != null) {
      setState(() {
        _status = ApplicationStatus.values.firstWhere(
          (e) => e.toString() == statusString,
          orElse: () => ApplicationStatus.notStarted,
        );
      });
    }
  }

  Future<void> _loadApplicationStatusIndi() async {
    final prefs = await SharedPreferences.getInstance();
    final statusString = prefs.getString('indi_status');
    if (statusString != null) {
      setState(() {
        _status = ApplicationStatus.values.firstWhere(
          (e) => e.toString() == statusString,
          orElse: () => ApplicationStatus.notStarted,
        );
      });
    }
  }

  Future<void> _loadWhoReg() async {
    final prefs = await SharedPreferences.getInstance();
    whoReg = prefs.getString('who_reg');
    print("here we got:${whoReg}");
    if (whoReg == "Auto") {
      _loadApplicationStatus();
    } else if (whoReg == "Driver") {
      _loadApplicationStatusDriver();
    } else if (whoReg == "ER") {
      _loadApplicationStatusER();
    } else if (whoReg == "Transporter") {
      _loadApplicationStatusTrans();
    } else if (whoReg == "Indi") {
      _loadApplicationStatusIndi();
    }
  }

  // Add this method to check if card should be visible
  bool get _shouldShowCard {
    return _status != ApplicationStatus.notStarted &&
        _status != ApplicationStatus.submitted &&
        _status != ApplicationStatus.approved &&
        _status != ApplicationStatus.rejected;
  }

  @override
  Widget build(BuildContext context) {
    // Return empty container if card shouldn't be shown
    if (!_shouldShowCard) {
      return SizedBox.shrink();
    }

    final localization = AppLocalizations.of(context)!;

    return Card(
      color: Colors.white,
      margin: EdgeInsets.all(10),
      elevation: 0,
      child: Padding(
        padding: EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /*Row(
              children: [
                Icon(Icons.auto_awesome, color: ColorConstants.primaryColor),
                SizedBox(width: 8),
                Text(
                  whoReg == "Auto"
                      ? localization.autoRickshaw
                      : whoReg == "Driver"
                      ? localization.become_driver
                      : whoReg == "ER"
                      ? localization.become_auto_rickshaw_driver
                      : whoReg == "Transporter"
                      ? localization.become_driver_transporter
                      : localization.become_driver_transporter, // default case (Indi)
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

              ],
            ),
            SizedBox(height: 16),
            _buildProgressIndicator(),
            SizedBox(height: 16),*/
            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final steps = [
      'Personal Info',
      'Documents',
      'Vehicle Info',
      'Fare & Cities',
      'Review'
    ];

    int completedSteps = 0;
    switch (_status) {
      case ApplicationStatus.personalInfoComplete:
        completedSteps = 1;
        break;
      case ApplicationStatus.documentsComplete:
        completedSteps = 2;
        break;
      case ApplicationStatus.vehicleInfoComplete:
        completedSteps = 3;
        break;
      case ApplicationStatus.fareAndCitiesComplete:
        completedSteps = 4;
        break;
      case ApplicationStatus.submitted:
        completedSteps = 5;
        break;
      default:
        completedSteps = 0;
    }

    return Column(
      children: [
        LinearProgressIndicator(
          value: completedSteps / steps.length,
          backgroundColor: Colors.grey[300],
          valueColor:
              AlwaysStoppedAnimation<Color>(ColorConstants.primaryColor),
        ),
        SizedBox(height: 8),
        Text(
          'Progress: $completedSteps/${steps.length} steps completed',
          style: TextStyle(color: Colors.grey[600]),
        ),
        if (completedSteps < steps.length)
          Text(
            'Next: ${steps[completedSteps]}',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
      ],
    );
  }

  Widget _buildActionButton() {
    String buttonText;
    Color buttonColor;
    VoidCallback? onPressed;

    switch (_status) {
      case ApplicationStatus.notStarted:
        buttonText = 'Start Application';
        buttonColor = ColorConstants.primaryColor;
        onPressed = () => _navigateToApplication();
        break;
      case ApplicationStatus.submitted:
        buttonText = 'Application Submitted';
        buttonColor = Colors.green;
        onPressed = null;
        break;
      default:
        buttonText = 'Complete your Application';
        buttonColor = ColorConstants.primaryColorNew;
        onPressed = () => _navigateToApplication();
    }

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12), // ✅ works fine
              ),
              elevation: 0,
              backgroundColor: Color(0xff0064E0)),
          onPressed: onPressed,
          child: Text(
            buttonText,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
          )),
    );
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          padding: EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          buttonText,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  void _navigateToApplication() {
    Widget? destination;

    print("_navigateToApplication:${whoReg}");
    if (whoReg == 'Auto') {
      destination = AutoRickshawDriverFlow();
    } else if (whoReg == 'Driver') {
      destination = DriverRegistrationFlow();
    } else if (whoReg == 'ER') {
      destination = ERickshawDriverFlow();
    } else if (whoReg == 'Transporter') {
      destination = TransporterRegistrationFlow();
    } else if (whoReg == 'Indi') {
      destination = IndependentTaxiOwnerFlow();
    }

    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination!),
      ).then((_) {
        // Load status based on whoReg
        if (whoReg == "Auto") {
          _loadApplicationStatus();
        } else if (whoReg == "Driver") {
          _loadApplicationStatusDriver();
        } else if (whoReg == "ER") {
          _loadApplicationStatusER();
        } else if (whoReg == "Transporter") {
          _loadApplicationStatusTrans();
        } else if (whoReg == "Indi") {
          _loadApplicationStatusIndi();
        }
      });
    }
  }
}
