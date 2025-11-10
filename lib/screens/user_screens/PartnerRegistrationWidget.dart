import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:r_w_r/screens/autoRikshawDriverRegistration.dart';
import 'package:r_w_r/screens/driverRegistrationScreen.dart';
import 'package:r_w_r/screens/independentCarOwnerRegistration.dart';
import 'package:r_w_r/screens/transporterRegistration.dart';
import 'package:r_w_r/utils/color.dart';
import 'package:r_w_r/utils/images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../transporterRegistration/presentation/pages/transporter_registration_page.dart';
import '../driver_screens/plans.dart';
import '../eRickshawRegistration.dart';

enum ApplicationStatus { notStarted, inProgress, completed, rejected }

class PartnerRegistrationWidget extends StatefulWidget {
  @override
  _PartnerRegistrationWidgetState createState() =>
      _PartnerRegistrationWidgetState();
}

class _PartnerRegistrationWidgetState extends State<PartnerRegistrationWidget> {
  final bool _currentSubscriptionVisibility = true;
  String? whoReg;
  ApplicationStatus applicationStatus = ApplicationStatus.notStarted;
  bool isLoading = true;

  final List<Map<String, dynamic>> allOptions = [
    {
      'titleKey': 'transporterOwner',
      'displayTitle': 'Transport Driver',
      'icon': transporter,
      'key': "TRANSPORTER",
      'whoRegValue': 'Transporter',
      'colors': [Color(0xFFE8F5E8), Color(0xFFB8E6B8)]
    },
    {
      'titleKey': 'independentCarOwner',
      'displayTitle': 'Independent Taxi Owner',
      'icon': aloneDriver,
      'key': "INDEPENDENT_CAR_OWNER",
      'whoRegValue': 'Indi',
      'colors': [Color(0xFFE3F2FD), Color(0xFF90CAF9)]
    },
    {
      'titleKey': 'autoRickshawOwner',
      'displayTitle': 'Auto Rickshaw Driver',
      'icon': auto,
      'key': "RICKSHAW",
      'whoRegValue': 'Auto',
      'colors': [Color(0xFFF3E5F5), Color(0xFFCE93D8)]
    },
    {
      'titleKey': 'eRickshawOwner',
      'displayTitle': 'E Rickshaw Driver',
      'icon': erickshaw,
      'key': "E_RICKSHAW",
      'whoRegValue': 'ER',
      'colors': [Color(0xFFFFEBEE), Color(0xFFFFAB91)]
    },
    {
      'titleKey': 'standAloneDriver',
      'displayTitle': 'Stand Alone Driver',
      'icon': taxiDriver,
      'key': 'DRIVER',
      'whoRegValue': 'Driver',
      'colors': [Color(0xFFFFF8E1), Color(0xFFFFE082)]
    },
  ];

  final List<Map<String, String>> benefits = [
    {'icon': '💰', 'titleKey': 'earnMore', 'descriptionKey': 'earnMoreDesc'},
    {
      'icon': '📱',
      'titleKey': 'easyManagement',
      'descriptionKey': 'easyManagementDesc'
    },
    {
      'icon': '🤝',
      'titleKey': 'trustedPlatform',
      'descriptionKey': 'trustedPlatformDesc'
    },
    {
      'icon': '🎯',
      'titleKey': 'flexibleWork',
      'descriptionKey': 'flexibleWorkDesc'
    },
  ];

  List<Map<String, dynamic>> get filteredOptions {
    if (whoReg == null || whoReg!.isEmpty) {
      return allOptions;
    } else {
      return allOptions
          .where((option) => option['whoRegValue'] == whoReg)
          .toList();
    }
  }

  @override
  void initState() {
    super.initState();
    _loadWhoRegAndStatus();
  }

  Future<ApplicationStatus> _loadWhoRegAndStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      whoReg = prefs.getString('who_reg');

      ApplicationStatus status = ApplicationStatus.notStarted;

      if (whoReg == "Auto") {
        status = await _loadApplicationStatus('auto_rickshaw_status');
      } else if (whoReg == "Driver") {
        status = await _loadApplicationStatus('driver_status');
      } else if (whoReg == "ER") {
        status = await _loadApplicationStatus('er_status');
      } else if (whoReg == "Transporter") {
        status = await _loadApplicationStatus('transporter_status');
      } else if (whoReg == "Indi") {
        status = await _loadApplicationStatus('indi_status');
      }

      setState(() {
        applicationStatus = status;
        isLoading = false;
      });

      return status;
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      return ApplicationStatus.notStarted;
    }
  }

  Future<ApplicationStatus> _loadApplicationStatus(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final statusString = prefs.getString(key);

      switch (statusString) {
        case 'in_progress':
          return ApplicationStatus.inProgress;
        case 'completed':
          return ApplicationStatus.completed;
        case 'rejected':
          return ApplicationStatus.rejected;
        default:
          return ApplicationStatus.notStarted;
      }
    } catch (e) {
      return ApplicationStatus.notStarted;
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    if (isLoading) {
      return Scaffold(
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
              stops: [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          "Select your Partnership Type",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
          textAlign: TextAlign.start,
        ),
      ),
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
        child: Column(
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * .13),
            Container(
              margin: EdgeInsets.only(left: 5, right: 5),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  SingleChildScrollView(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(height: 10),
                        _buildPartnershipList(localizations),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPartnershipList(AppLocalizations localizations) {
    final options = filteredOptions;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 18,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: options.length,
      itemBuilder: (context, index) {
        final option = options[index];

        return GestureDetector(
          onTap: () {
            if(option['displayTitle']=='Transport Driver'){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder:(context) {
                     return PlanSelectionScreen(
                        planType: 'REGISTRATION', planFor: option['key']!, countryId: '', stateId: '',
                      );
                    },/* (context) =>TransporterRegistrationFlow()

                  //     PlanSelectionScreen(
                  //   planType: 'REGISTRATION', planFor: option['key']!, countryId: '', stateId: '',
                  // ),*/
                ),
              );
            }else if(option['displayTitle']=='Independent Taxi Owner'){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>IndependentTaxiOwnerFlow()

                  //     PlanSelectionScreen(
                  //   planType: 'REGISTRATION', planFor: option['key']!, countryId: '', stateId: '',
                  // ),
                ),
              );
            }else if(option['displayTitle']=='Auto Rickshaw Driver'){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>AutoRickshawDriverFlow()

                  //     PlanSelectionScreen(
                  //   planType: 'REGISTRATION', planFor: option['key']!, countryId: '', stateId: '',
                  // ),
                ),
              );
            }else if(option['displayTitle']=='E Rickshaw Driver'){
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>ERickshawDriverFlow()

                  //     PlanSelectionScreen(
                  //   planType: 'REGISTRATION', planFor: option['key']!, countryId: '', stateId: '',
                  // ),
                ),
              );
            }else{
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>DriverRegistrationFlow()

                  //     PlanSelectionScreen(
                  //   planType: 'REGISTRATION', planFor: option['key']!, countryId: '', stateId: '',
                  // ),
                ),
              );
            }

          },
          child: Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: option['colors'],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      CupertinoIcons.exclamationmark,
                      size: 14,
                      color: Colors.black54,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        option['icon']!,
                        height: 56,
                        width: 62,
                      ),
                      SizedBox(height: 12),
                      Text(
                        option['displayTitle'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
