import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/components/common_parent_container.dart';
import 'package:r_w_r/components/custom_activity.dart';
import 'package:r_w_r/features/upgradeablePlans/upgradeable_plans_bloc.dart';
import 'package:r_w_r/features/upgradeablePlans/upgradeable_plans_event.dart';
import 'package:r_w_r/features/upgradeablePlans/upgradeable_plans_state.dart';
import 'package:r_w_r/utils/color.dart';
import 'package:r_w_r/utils/images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/payment/payment_bloc.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/presentation/bloc/plan_bloc.dart';
import '../../plan/presentation/bloc/plan_event.dart';
import '../../plan/presentation/bloc/plan_state.dart';
import '../../plan/presentation/screens/plan_selection_screen.dart' as planNew;
import '../../screens/autoRikshawDriverRegistration.dart';
import '../../screens/independentCarOwnerRegistration.dart'
    hide ProfileProvider;
import '../../screens/transporterRegistration.dart';
import '../block/provider/profile_provider.dart';
import '../driverRegistrationScreen.dart';
import '../eRickshawRegistration.dart';

enum ApplicationStatus { notStarted, inProgress, completed, rejected }

class PartnerRegistrationWidget extends StatefulWidget {
  const PartnerRegistrationWidget({Key? key}) : super(key: key);

  @override
  State<PartnerRegistrationWidget> createState() =>
      _PartnerRegistrationWidgetState();
}

class _PartnerRegistrationWidgetState extends State<PartnerRegistrationWidget> {
  String currentCategory="";
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
      'route': "TransporterRegistrationFlow",
      'colors': [Color(0xFFE8F5E8), Color(0xFFB8E6B8)]
    },
    {
      'title': 'Independent Taxi Owner',
      'icon': aloneDriver,
      'key': "INDEPENDENT_CAR_OWNER",
      'route': "IndependentTaxiOwnerFlow",
      'colors': [Color(0xFFE3F2FD), Color(0xFF90CAF9)]
    },
    {
      'title': 'Auto Rickshaw Driver',
      'icon': auto,
      'key': "RICKSHAW",
      'route': "AutoRickshawDriverFlow",
      'colors': [Color(0xFFF3E5F5), Color(0xFFCE93D8)]
    },
    {
      'title': 'E Rickshaw Driver',
      'icon': erickshaw,
      'key': "E_RICKSHAW",
      'route': "ERickshawDriverFlow",
      'colors': [Color(0xFFFFEBEE), Color(0xFFFFAB91)]
    },
    {
      'title': 'Stand Alone Driver',
      'icon': taxiDriver,
      'key': 'DRIVER',
      'route': "DriverRegistrationFlow",
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

  void _loadStatus() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final prefs = await SharedPreferences.getInstance();
        whoReg = prefs.getString('who_reg');
      } catch (_) {}
      context
          .read<UpgradeablePlansBloc>()
          .add(UpgradeablePlanLoad(whoReg ?? ""));
      setState(() => isLoading = false);
    });
  }

  // ---------------------------------------------------------------------
  // NAVIGATION HANDLER
  // ---------------------------------------------------------------------
  void _navigateAfterPlanCheck({
    required BuildContext context,
    required bool hasSubscription,
    required String category,
    required String currentCategory,
  }) {
    if (!hasSubscription) {
      String title = category == UserType.TRANSPORTER.name
          ? "Become a Transporter"
          : category == UserType.DRIVER.name
              ? "Become Independent Taxi Driver"
              : category == UserType.RICKSHAW.name
                  ? "Become a Rickshaw Driver"
                  : category == UserType.E_RICKSHAW.name
                      ? "Become a E-Rickshaw Driver"
                      : category == UserType.INDEPENDENT_CAR_OWNER.name
                          ? "Become a Stand Alone Driver"
                          : "";
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => BlocProvider(
            create: (_) =>
                PaymentBloc(profileProvider: context.read<ProfileProvider>()),
            child: planNew.PlanSelectionScreen(
              category: category,
              title: title,
              currentCategory: currentCategory,
            ),
          ),
        ),
      );
    } else {
      _launchRegistrationFlow(category);
    }
  }

  void _launchRegistrationFlow(String type) {
    switch (type) {
      case "TRANSPORTER":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => TransporterRegistrationFlow()));
        break;
      case "INDEPENDENT_CAR_OWNER":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => IndependentTaxiOwnerFlow()));
        break;
      case "RICKSHAW":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => AutoRickshawDriverFlow()));
        break;
      case "E_RICKSHAW":
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => ERickshawDriverFlow()));
        break;
      case "DRIVER":
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => DriverRegistrationFlow()));
        break;
    }
  }

  // ---------------------------------------------------------------------
  // MAIN BUILD
  // ---------------------------------------------------------------------
  bool handled = false;

  @override
  Widget build(BuildContext context) {
    if (whoReg == "TRANSPORTER") {
      return Center(
        child: Text(
          "You are already registered as Transporter",
          style: TextStyle(color: Colors.black),
        ),
      );
    }
    final local = AppLocalizations.of(context);

    if (isLoading) return _loadingScreen();

    return CommonParentContainer(
      child: BlocListener<PlanBloc, PlanState>(
        listenWhen: (previous, current) {
          return previous.statusData != current.statusData &&
              current.statusData != null &&
              !current.loading;
        },
        listener: (context, state) {
          final hasSub = state.statusData!['hasActiveSubscription'] ?? false;
          final type = state.statusData!['category'] ?? '';
          final currentCategory = state.statusData!['currentCategory'] ?? '';

          _navigateAfterPlanCheck(
            context: context,
            hasSubscription: hasSub,
            category: type,
            currentCategory: currentCategory,
          );
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
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
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
            colors: [
              gradientFirst,
              gradientSecond,
              gradientThird,
              Colors.white
            ],
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
    return BlocBuilder<UpgradeablePlansBloc, UpgradeablePlansState>(
      builder: (context, state) {
        final List<Map<String, dynamic>> filteredOptions;

        if (state is UpgradeablePlansLoaded &&
            state.data.data?.availableUpgrades?.isNotEmpty == true) {
          final allowedCategories = state.data.data!.availableUpgrades!
              .map((e) => e.upgradeCategory)
              .toSet();

          filteredOptions = options
              .where((option) => allowedCategories.contains(option['key']))
              .toList();
         currentCategory= state.data.data?.currentCategory??"";
        } else {
          filteredOptions = List<Map<String, dynamic>>.from(options);
        }

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
                  childCount: filteredOptions.length,
                  (context, index) => _buildOptionCard(filteredOptions[index]),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOptionCard(Map<String, dynamic> option) {
    return GestureDetector(
      onTap: () {
        context.read<PlanBloc>().add(FetchUserStatusEvent(option['key'],currentCategory));
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
