import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:rwd/components/app_loader.dart';
import 'package:rwd/components/common_parent_container.dart';
import 'package:rwd/components/custom_activity.dart';
import 'package:rwd/constants/color_constants.dart';
import 'package:rwd/features/upgradeablePlans/upgradeable_plans_bloc.dart';
import 'package:rwd/features/upgradeablePlans/upgradeable_plans_event.dart';
import 'package:rwd/features/upgradeablePlans/upgradeable_plans_state.dart';
import 'package:rwd/screens/layout.dart';
import 'package:rwd/utils/color.dart';
import 'package:rwd/utils/images.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../bloc/payment/payment_bloc.dart';
import '../../constants/api_constants.dart';
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
  String currentCategory = "";
  String? whoReg;
  bool isLoading = true;
  ApplicationStatus applicationStatus = ApplicationStatus.notStarted;

  // ---------------------------------------------------------------------
  // DATA MODEL FOR OPTIONS
  // ---------------------------------------------------------------------
  final List<Map<String, dynamic>> options = [
    {
      'title': 'Transport Owner',
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
      'title': 'Auto Rickshaw',
      'icon': auto,
      'key': "RICKSHAW",
      'route': "AutoRickshawDriverFlow",
      'colors': [Color(0xFFF3E5F5), Color(0xFFCE93D8)]
    },
    {
      'title': 'E Rickshaw',
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
        setState(() {});
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
              count: 1,
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
    if (whoReg == "Transporter") {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(),
        body: Center(
          child: Text(
            "You are already registered as Transporter",
            style: TextStyle(color: Colors.black),
          ),
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
            leading: InkWell(
              onTap: () {
                if (Navigator.canPop(context)) {
                  Navigator.of(context).pop();
                } else {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) {
                        return Layout();
                      },
                    ),
                    (route) => false,
                  );
                }
              },
              child: Icon(
                Icons.arrow_back,
                size: 24,
                color: Colors.white,
              ),
            ),
            actionsPadding: EdgeInsets.zero,
            iconTheme: const IconThemeData(color: Colors.white),
            centerTitle: false,
            titleSpacing: 0,
          ),
          body: Column(
              children: [
            const SizedBox(
              height: 100,
            ),
            Text(
              "Choose & Start Earning As",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.black),
            ),
            Text(
              "Select how you want to work and earn",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Colors.black),
            ),
            Expanded(child: _buildScrollableContent()),
            SizedBox(
              height: 20,
            ),
            RichText(
                text: TextSpan(children: [
                  TextSpan(
                      text: "No commission • No middleman ",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          fontFamily: AppConstants.ptSansFont,
                          color: Color(0xFF595959))),
                  TextSpan(
                      text: " • Direct contact",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          fontFamily: AppConstants.ptSansFont,
                          color: Color(0xFF595959))),
                ]))
          ]),
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
          currentCategory = state.data.data?.currentCategory ?? "";
        }else if(state is UpgradeablePlansLoading){
          return Center(
            child: SizedBox(width: 50,height: 50,
            child: CircularProgressIndicator(color: AppColors.blue,strokeWidth: 2,),),
          );
        } else {
          filteredOptions = List<Map<String, dynamic>>.from(options);
        }

        return CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.only(top: 20, left: 10, right: 10),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1 / 0.8,
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
        context
            .read<PlanBloc>()
            .add(FetchUserStatusEvent(option['key'], currentCategory));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: option['colors'],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(option['icon'], height: 40),
                const SizedBox(height: 5),
                Text(
                  option['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppConstants.ptSansFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: ColorConstants.black2,
                  ),
                ),
                Text(
                  getDescription(option['key']),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: AppConstants.ptSansFont,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.black2,
                  ),
                ),

              ],
            ),
            Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    showInfoPopup(option['key']);
                  },
                  child: SvgPicture.asset(
                    "assets/svg/info.svg",
                    width: 20,
                    height: 20,
                  ),
                ))
          ],
        ),
      ),
    );
  }

  String getDescription(String category) {
    String desc = "";
    if (category == "RICKSHAW") {
      desc = "City Rides";
    } else if (category == "DRIVER") {
      desc = "Direct booking";
    } else if (category == "E_RICKSHAW") {
      desc = "Local & daily trips";
    } else if (category == "TRANSPORTER") {
      desc = "Outstation & city Or Fleet Bookings";
    } else if (category == "INDEPENDENT_CAR_OWNER") {
      desc = "Outstation & city";
    }

    return desc;
  }

  void showInfoPopup(String category) {
    String desc = "";
    String title = "";
    if (category == "RICKSHAW") {
      desc =
          "1. Valid driving licence\n2. Aadhaar Card ID verification\n3. Vehicle details with photos and videos";
      title = "Drivers who owned, rented or operate an Auto Rickshaw.";
    } else if (category == "DRIVER") {
      desc = "1. Valid driving licence\n2. Adhaar Card ID verification";
      title = "Drivers who do not own a vehicle.";
    } else if (category == "E_RICKSHAW") {
      desc =
          "1. Valid driving licence (as applicable)\n2. Aadhaar Card ID verification\n3. Vehicle details with photos and videos";
      title = "Drivers who owned, rented or operate an E-Rickshaw.";
    } else if (category == "TRANSPORTER") {
      desc =
          "1. Business ID verification or valid Transport Permit (if applicable)\n2. Company details (legal name, address, contact person, contact number)\n3. GST Certificate (mandatory)\n4. Vehicle details with photos and videos";
      title =
          "Owners managing more than two vehicles or those who want to register as a Transport Agency. ";
    } else if (category == "INDEPENDENT_CAR_OWNER") {
      desc =
          "1. Valid driving licence\n2. Aadhaar Card ID verification\n3. Active vehicle insurance\n4. Vehicle details with photos and videos";
      title =
          "Drivers who operate their own or rented car (Limited to one or two vehicles).";
    }

    showStandAloneDriverDialog(title, desc, category);
  }

  void showStandAloneDriverDialog(String title, String desc, String category) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                category,
                style: TextStyle(
                  fontFamily: AppConstants.ptSansFont,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 10),

              // Subtitle
              Text(
                title,
                style: TextStyle(
                    fontFamily: AppConstants.ptSansFont,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),

              const SizedBox(height: 20),

              // Section title
              const Text(
                'Mandatory Requirements',
                style: TextStyle(
                  fontFamily: AppConstants.ptSansFont,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 12),
              Text(
                desc,
                style: const TextStyle(
                    fontSize: 12,
                    fontFamily: AppConstants.ptSansFont,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(height: 10),

              // Optional action button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Reusable list item widget
