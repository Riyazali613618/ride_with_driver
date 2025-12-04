import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/utils/color.dart';
import 'package:r_w_r/utils/images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/payment/payment_bloc.dart';
import '../../bloc/plan_flow/plan_flow_cubit.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/presentation/bloc/plan_bloc.dart';
import '../../plan/presentation/bloc/plan_event.dart';
import '../../plan/presentation/bloc/plan_state.dart';
import '../../plan/presentation/screens/plan_selection_screen.dart' as planNew;

import '../driverRegistrationScreen.dart';
import '../driver_screens/driver_registration.dart';
import '../driver_screens/plans.dart';
import '../../screens/autoRikshawDriverRegistration.dart';
import '../../screens/transporterRegistration.dart';
import '../../screens/independentCarOwnerRegistration.dart';
import '../eRickshawRegistration.dart';
import '../block/provider/profile_provider.dart';

enum ApplicationStatus { notStarted, inProgress, completed, rejected }

class PartnerRegistrationWidget extends StatefulWidget {
  const PartnerRegistrationWidget({Key? key}) : super(key: key);

  @override
  State<PartnerRegistrationWidget> createState() =>
      _PartnerRegistrationWidgetState();
}

class _PartnerRegistrationWidgetState extends State<PartnerRegistrationWidget> {
  String? whoReg;
  bool isLoading = true;
  ApplicationStatus applicationStatus = ApplicationStatus.notStarted;

  // ---------------------------------------------------------------------
  // DATA MODEL FOR OPTIONS
  // ---------------------------------------------------------------------
  final List<Map<String, dynamic>> options = [
    {
      'title': 'Transport Driver',
      'icon': transporter,
      'key': "TRANSPORTER",
      'route': TransporterRegistrationFlow(),
      'colors': [Color(0xFFE8F5E8), Color(0xFFB8E6B8)]
    },
    {
      'title': 'Independent Taxi Owner',
      'icon': aloneDriver,
      'key': "INDEPENDENT_CAR_OWNER",
      'route': IndependentTaxiOwnerFlow(),
      'colors': [Color(0xFFE3F2FD), Color(0xFF90CAF9)]
    },
    {
      'title': 'Auto Rickshaw Driver',
      'icon': auto,
      'key': "RICKSHAW",
      'route': AutoRickshawDriverFlow(),
      'colors': [Color(0xFFF3E5F5), Color(0xFFCE93D8)]
    },
    {
      'title': 'E Rickshaw Driver',
      'icon': erickshaw,
      'key': "E_RICKSHAW",
      'route': ERickshawDriverFlow(),
      'colors': [Color(0xFFFFEBEE), Color(0xFFFFAB91)]
    },
    {
      'title': 'Stand Alone Driver',
      'icon': taxiDriver,
      'key': 'DRIVER',
      'route': DriverRegistrationFlow(),
      'colors': [Color(0xFFFFF8E1), Color(0xFFFFE082)]
    },
  ];

  // ---------------------------------------------------------------------
  // INIT LOGIC
  // ---------------------------------------------------------------------
  @override
  void initState() {
    super.initState();
    _loadStatus();
  }

  Future<void> _loadStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      whoReg = prefs.getString('who_reg');
    } catch (_) {}

    setState(() => isLoading = false);
  }

  // ---------------------------------------------------------------------
  // NAVIGATION HANDLER
  // ---------------------------------------------------------------------
  void _navigateAfterPlanCheck({
    required BuildContext context,
    required bool hasSubscription,
    required String category,
  }) {
    if (!hasSubscription) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                PaymentBloc(profileProvider: context.read<ProfileProvider>()),
            child: planNew.PlanSelectionScreen(category: category),
          ),
        ),
      );
    } else {
      _launchRegistrationFlow(category);
    }
  }

  void _launchRegistrationFlow(String type) {
    Widget target = DriverRegistrationFlow();

    final map = {
      "TRANSPORTER": TransporterRegistrationFlow(),
      "INDEPENDENT_CAR_OWNER": IndependentTaxiOwnerFlow(),
      "RICKSHAW": AutoRickshawDriverFlow(),
      "E_RICKSHAW": ERickshawDriverFlow(),
      "DRIVER": DriverRegistrationFlow(),
    };

    if (map.containsKey(type)) target = map[type]!;

    Navigator.push(context, MaterialPageRoute(builder: (_) => target));
  }

  // ---------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context);

    if (isLoading) return _loadingScreen();

    return CommonParentContainer(
      child: BlocListener<PlanBloc, PlanState>(
        listener: (context, state) {
          if (state.statusData != null) {
            final hasSub =
                state.statusData!['hasActiveSubscription'] ?? false;
            final type = state.statusData!['category'] ?? '';

            _navigateAfterPlanCheck(
              context: context,
              hasSubscription: hasSub,
              category: type,
            );
          }
        },
        child: Scaffold(
          backgroundColor: Colors.transparent,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            actionsPadding: EdgeInsets.zero,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: false,
            titleSpacing: 0,
            title: const Text(
              "Select your Partnership Type",
              style: TextStyle(fontSize: 18,color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          body: _buildScrollableContent(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // SEPARATED UI WIDGETS
  // ---------------------------------------------------------------------
  Widget _loadingScreen() {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientFirst, gradientSecond, gradientThird, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildScrollableContent() {
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.only(top: 130, left: 16, right: 16),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            delegate: SliverChildBuilderDelegate(
              childCount: options.length,
                  (context, index) => _buildOptionCard(options[index]),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> option) {
    return GestureDetector(
      onTap: () {
        context.read<PlanBloc>().add(FetchUserStatusEvent(option['key']));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: option['colors'],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(option['icon'], height: 60),
            const SizedBox(height: 10),
            Text(
              option['title'],
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
