import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rwd/api/api_model/user_model/my_profile_model.dart';
import 'package:rwd/api/api_service/user_service/user_profile_service.dart';
import 'package:rwd/components/app_loader.dart';
import 'package:rwd/components/common_parent_container.dart';
import 'package:rwd/constants/api_constants.dart';
import 'package:rwd/screens/driver_screens/plans.dart';
import 'package:rwd/utils/common_utils.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../plan/presentation/screens/plan_selection_screen.dart' as planNew;

import '../../api/api_model/subscription/active_plan_model.dart';
import '../../api/api_service/countryStateProviderService.dart';
import '../../api/api_service/payment_service/payment_service.dart';
import '../../api/api_service/subscription/active_plan.dart';
import '../../bloc/payment/payment_bloc.dart';
import '../../components/app_invoice_viewer.dart';
import '../../components/custom_activity.dart' hide ApiException;
import '../../constants/color_constants.dart';
import '../../features/vehicles/presentation/addOns/add_on_vehicles_bottom_sheet.dart';
import '../../l10n/app_localizations.dart';
import '../../plan/data/models/plan_model.dart';
import '../../plan/data/repositories/plan_repository.dart';
import '../../plan/data/services/plan_service.dart' show PlanService;
import '../../plan/presentation/bloc/plan_bloc.dart';
import '../autoRikshawDriverRegistration.dart';
import '../block/provider/profile_provider.dart';
import '../driverRegistrationScreen.dart';
import '../eRickshawRegistration.dart';
import '../independentCarOwnerRegistration.dart';
import '../transporterRegistration.dart';
import '../user_screens/PartnerRegistrationWidget.dart';

class SubscriptionsScreen extends StatefulWidget {
  final String baseUrl;

  const SubscriptionsScreen({
    super.key,
    required this.baseUrl,
  });

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  bool _isLoading = true;
  String _errorMessage = '';
  List<Subscription> _subscriptionData = [];
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) {
        getPlans();
      },
    );
    // Don't call _fetchSubscriptionData here
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Call _fetchSubscriptionData here instead, after the widget is fully initialized
    if (!_isInitialized) {
      _isInitialized = true;
      _fetchSubscriptionData();
    }
  }

  Future<void> viewOrDownloadInvoice(String pdfUrl) async {
    final localizations = AppLocalizations.of(context)!;

    try {
      if (await canLaunch(pdfUrl)) {
        await launch(pdfUrl);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(localizations.could_not_open_pdf)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(' ${e.toString()}')),
      );
    }
  }

  Future<void> _fetchSubscriptionData() async {
    final localizations = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final data = await UserProfileService().getUserProfile();
      _subscriptionData = data.subscriptions;
      setState(() {
        _isLoading = false;
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e is ApiException ? e.message : localizations.retry;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      body: CommonParentContainer(
        showLargeGradient: true,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 40,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: ColorConstants.white,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            localizations.active_subscriptions,
                            style: TextStyle(
                              fontFamily: AppConstants.ptSansFont,
                              color: ColorConstants.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          /*  Text(
                            localizations.manage_subscriptions,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),*/
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              _buildBody(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    final localizations = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              localizations.error,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _fetchSubscriptionData,
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(localizations.retry),
            ),
          ],
        ),
      );
    }

    // Check if there are no plans and no active transactions
    List<Subscription> activeSubscriptions =
        _subscriptionData.where((s) => s.status == 'active').toList();
    List<Subscription> expiredSubscription =
        _subscriptionData.where((s) => s.status != 'active').toList();

    if (_subscriptionData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.subscriptions_outlined,
              size: 60,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              localizations.no_active_subscriptions,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              localizations.no_active_subscriptions,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeSubscriptions.isNotEmpty)
            _buildActivePlanCard(
              activeSubscriptions,
            ),
          const SizedBox(height: 10),

          _buildActionButtons(activeSubscriptions),

          if (expiredSubscription.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              localizations.transaction_history,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            /*  ...expiredSubscription
                .map(
                  (transaction) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildTransactionItem(transaction),
                  ),
                )
                .toList(),*/
            SizedBox(
                height: 110,
                child: ListView.builder(
                  itemCount: expiredSubscription.length,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    return _buildTransactionItem(expiredSubscription[index]);
                  },
                ))
          ],
          const SizedBox(height: 24),
          // _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard(List<Subscription> activePlan) {
    final localizations = AppLocalizations.of(context)!;

    final data = activePlan[0];
    if (data == null) {
      return SizedBox.shrink();
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0x291FAF38),
        borderRadius: BorderRadius.circular(27),
        border: Border.all(color: Color(0xFF1FAF38)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 30,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            data.planName ?? "",
            style: CommonUtils.commonTitleStyle(
                weight: FontWeight.w700, fontSize: 14),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                  child: Align(
                alignment: Alignment.centerLeft,
                child: IntrinsicWidth(
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 1),
                    decoration: BoxDecoration(
                        color: Color(0x1F641BB4),
                        border: Border.all(color: AppColors.blue, width: 0.5),
                        borderRadius: BorderRadius.all(Radius.circular(12))),
                    child: Text(
                      "Validity: ${getDuration(data)} months | Expires On: ${DateFormat('dd MMM yyyy').format(activePlan[0].endDate!)}",
                      style: TextStyle(
                        fontFamily: AppConstants.ptSansFont,
                        fontSize: 10,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              )),
              const SizedBox(width: 8),
              const Icon(Icons.info_outline, size: 20),
            ],
          ),

          const SizedBox(height: 10),

          /// PRICE
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "₹ ${(data.totalAmount ?? 0).toStringAsFixed(0)}",
                  style: TextStyle(
                    fontFamily: AppConstants.ptSansFont,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.blue,
                  ),
                ),
                TextSpan(
                  text: " (Vehicle-${data.maxVehicles})",
                  style: TextStyle(
                    fontFamily: AppConstants.ptSansFont,
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 5),

          /// BENEFITS TITLE
          const Text(
            "Benefits:",
            style: TextStyle(
              fontFamily: AppConstants.ptSansFont,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 5),

          /// BENEFITS GRID
          if ((data.benefits ?? []).isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: (data.benefits ?? []).length > 5
                  ? 5
                  : data.benefits?.length ?? 0,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 2,
                mainAxisSpacing: 5,
                childAspectRatio: 5,
              ),
              itemBuilder: (context, index) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      size: 18,
                      color: Color(0xFF1FAF38),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        data.benefits![index],
                        style: const TextStyle(
                          fontFamily: AppConstants.ptSansFont,
                          fontSize: 11,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
        ],
      ),
    );
  }

  void _showInvoiceBottomSheet(BuildContext context, String invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DynamicInvoiceBottomSheet(
          htmlContent: invoice,
        );
      },
    );
  }

  Widget _buildTransactionItem(Subscription transaction) {
    return GestureDetector(
      onTap: () {
        _showInvoiceBottomSheet(
          context,
          transaction.subscriptionAmount.toString(),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.60,
        // ✅ FIXED WIDTH (REQUIRED)
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: const Color(0x57D9D9D9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD9D9D9)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x1F000000),
              blurRadius: 25.04,
              offset: Offset(0, 3.34),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            Row(
              children: [
                Expanded(
                  child: Text(
                    maxLines: 2,
                    transaction.planName ?? "",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ),
                const Icon(Icons.info_outline, size: 20),
              ],
            ),

            const SizedBox(height: 2),

            /// PRICE + VALIDITY
            Row(
              children: [
                Text(
                  "₹ ${(transaction.totalAmount ?? 0).toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF666666),
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  "Validity: ${getDuration(transaction)} months",
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.black,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 2),

            /// VALIDITY CHIP (WRAP WIDTH)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                border: Border.all(color: const Color(0xFFD9D9D9)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Validity: ${getDuration(transaction)} months | "
                "Expires On: ${DateFormat('dd MMM yyyy').format(transaction.endDate!)}",
                style: const TextStyle(
                  fontSize: 8,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(List<Subscription> activeSubscriptions) {
    final localizations = AppLocalizations.of(context)!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
            child: GestureDetector(
          onTap: () {
            if (activeSubscriptions.isNotEmpty &&
                activeSubscriptions[0].pdfUrl != null &&
                activeSubscriptions[0].pdfUrl!.isNotEmpty)
              viewOrDownloadInvoice(activeSubscriptions[0].pdfUrl!);
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/download.svg",
                width: 20,
                height: 20,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "Invoice",
                style: CommonUtils.commonTitleStyle(
                    fontSize: 12, color: AppColors.blue),
              )
            ],
          ),
        )),
        Expanded(
            child: Container(
          width: double.infinity,
          height: 35,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(
              color: Color(0xFF0064E0),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: GestureDetector(
            onTap: () async {
             /* final profile = await UserProfileService().getUserProfile();
              String title = profile.usertype == UserType.TRANSPORTER.name
                  ? "Renew Transporter Plan"
                  : profile.usertype == UserType.DRIVER.name
                      ? "Renew Independent Taxi Driver Plan"
                      : profile.usertype == UserType.RICKSHAW.name
                          ? "Renew Rickshaw Driver Plan"
                          : profile.usertype == UserType.E_RICKSHAW.name
                              ? "Renew E-Rickshaw Driver Plan"
                              : profile.usertype ==
                                      UserType.INDEPENDENT_CAR_OWNER.name
                                  ? "Renew Stand Alone Driver Plan"
                                  : "";
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BlocProvider(
                    create: (_) => PaymentBloc(
                        profileProvider: context.read<ProfileProvider>()),
                    child: planNew.PlanSelectionScreen(
                      category: profile.usertype ?? "",
                      title: title,
                      count: 1,
                      currentCategory: "",
                    ),
                  ),
                ),
              );*/
            },
            child: Text(
              "Renew Plan",
              style: TextStyle(
                fontFamily: AppConstants.ptSansFont,
                fontSize: 12,
                color: ColorConstants.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )),
        SizedBox(
          width: 20,
        ),
        Expanded(
            child: Container(
          width: double.infinity,
          height: 35,
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 0),
          decoration: BoxDecoration(
              color: Color(0xFF0064E0),
              borderRadius: BorderRadius.all(Radius.circular(10))),
          child: GestureDetector(
            onTap: () async {
              final eligibleData = await UserProfileService().getEligibility();
              if (eligibleData.data?.paymentPhase == "PRE_REGISTRATION") {
                _navigateToApplication(eligibleData.data?.category ?? "");
              } else if (activeSubscriptions[0].category == "TRANSPORTER") {
                getPlanData(activeSubscriptions[0].category);
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => PlanBloc(
                        RepositoryProvider.of<PlanRepository>(context),
                      ),
                      child: PartnerRegistrationWidget(),
                    ),
                  ),
                );
              }
            },
            child: Text(
              "Upgrade Plan",
              style: TextStyle(
                fontFamily: AppConstants.ptSansFont,
                fontSize: 12,
                color: ColorConstants.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Future<void> _navigateToApplication(String type) async {
    Widget? destination;

    String userType = type;
    if (userType == "RICKSHAW") {
      destination = AutoRickshawDriverFlow();
    } else if (userType == "DRIVER") {
      destination = DriverRegistrationFlow();
    } else if (userType == "E_RICKSHAW") {
      destination = ERickshawDriverFlow();
    } else if (userType == "TRANSPORTER") {
      destination = TransporterRegistrationFlow();
    } else if (userType == "INDEPENDENT_CAR_OWNER") {
      destination = IndependentTaxiOwnerFlow();
    }

    if (destination != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => destination!),
      ).then((_) {});
    }
  }

  List<PlanModel> subscriptionPlanList = [];
  MyProfileData? profileData;

  Future<void> getPlans() async {
    final langProvider = Provider.of<LocationProvider>(context, listen: false);

    final currentCountry =
        langProvider.selectedCountry ?? ApiConstants.defaultCountryCodeInd;
    final selectedState =
        langProvider.selectedState ?? ApiConstants.defaultStateCodeDel;
    if (selectedState.isEmpty) {
      await langProvider.fetchStates(currentCountry);
    }
    profileData = await UserProfileService().getUserProfile();
    final response = await PlanService.getPlans(
        countryId: currentCountry,
        planFor: profileData?.usertype ?? "",
        stateId: selectedState);
    if (response != null && response['success'] == true) {
      final List<dynamic> planList = response['data']['plans'];
      final list = planList.map((e) => PlanModel.fromJson(e)).toList();
      if (list.isNotEmpty) {
        subscriptionPlanList = list;
        setState(() {});
      }
    }
  }

  PlanModel? getActivePlanData(String planId) {
    if (subscriptionPlanList.isEmpty) {
      return null;
    }
    for (var data in subscriptionPlanList) {
      if (data.id == planId) {
        return data;
      }
    }
    return null;
  }

  Future<void> getPlanData(String? category) async {
    final langProvider = Provider.of<LocationProvider>(context, listen: false);

    final currentCountry =
        langProvider.selectedCountry ?? ApiConstants.defaultCountryCodeInd;
    final selectedState =
        langProvider.selectedState ?? ApiConstants.defaultStateCodeDel;
    if (selectedState.isEmpty) {
      await langProvider.fetchStates(currentCountry);
    }
    final response = await PlanService.getPlans(
        countryId: currentCountry,
        planFor: "TRANSPORTER",
        stateId: selectedState);
    if (response != null && response['success'] == true) {
      final List<dynamic> planList = response['data']['plans'];
      final list = planList.map((e) => PlanModel.fromJson(e)).toList();
      if (list.isNotEmpty) {
        final data = list[0];
        final features = data.features;
        final discount = data.earlyBirdDiscountPercentage;
        final price = data.finalPrice;
        final price2 = data.grossPrice;
        final duration = data.durationInMonths;
        final rwdBalance = profileData?.rwdBalance ?? 0;
        showAddVehicleQtyPopup(rwdBalance, context, data, "TRANSPORTER",
            "TRANSPORTER", PaymentType.addOns, 1, true);
      }
    }
  }

  void showAddVehicleQtyPopup(
      double rwdBalance,
      BuildContext context,
      PlanModel plan,
      String category,
      String currentCategory,
      PaymentType planType,
      int count,
      bool isAdOns) {
    showDialog(
      context: context,
      builder: (_) => NumberOfVehiclesPopup(
        initialValue: count,
        plan: plan,
        isAdOns: isAdOns,
        onConfirm: (count) {
          showAddOnPlanBottomSheet(rwdBalance, isAdOns, context, plan, category,
              currentCategory, planType, count);
        },
      ),
    );
  }

  getDuration(Subscription data) {
    DateTime? startDate = data.startDate;
    DateTime? endDate = data.endDate;
    if (endDate == null || startDate == null) {
      return 1;
    }
    if (startDate.isAfter(endDate)) {
      final temp = startDate;
      startDate = endDate;
      endDate = temp;
    }

    int yearDiff = endDate.year - startDate.year;
    int monthDiff = endDate.month - startDate.month;
    if (yearDiff == 0) {
      return monthDiff;
    }

    int totalMonths = yearDiff * 12 + monthDiff;

    // Adjust if end day is before start day
    if (endDate.day < startDate.day) {
      totalMonths--;
    }

    return totalMonths;
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

void showAddOnPlanBottomSheet(
    double rwdBalance,
    bool isAdOns,
    BuildContext context,
    PlanModel plan,
    String category,
    String currentCategory,
    PaymentType planType,
    int count) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => BlocProvider.value(
      value: context.read<PaymentBloc>(),
      child: AddOnPlanBottomSheet(
          context: context,
          isAdOns: isAdOns,
          plan: plan,
          rwdBalance: rwdBalance,
          category: category,
          currentCategory: currentCategory,
          planType: planType,
          count: count),
    ),
  );
}
