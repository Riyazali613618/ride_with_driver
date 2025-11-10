import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:r_w_r/screens/driver_screens/plans.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../api/api_model/subscription/active_plan_model.dart';
import '../../api/api_service/subscription/active_plan.dart';
import '../../components/app_invoice_viewer.dart';
import '../../constants/color_constants.dart';
import '../../l10n/app_localizations.dart';

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
  SubscriptionData? _subscriptionData;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
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
      final service = SubscriptionService(baseUrl: widget.baseUrl);
      final response = await service.getSubscriptionDetails();

      if (response.status) {
        setState(() {
          _subscriptionData = response.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response.message;
          _isLoading = false;
        });
      }
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
      // backgroundColor: Colors.white,
      // appBar: AppBar(
      //   backgroundColor: ColorConstants.primaryColor,
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   title: Column(
      //     crossAxisAlignment: CrossAxisAlignment.start,
      //     children: [
      //       Text(
      //         localizations.active_subscriptions,
      //         style: TextStyle(
      //           color: ColorConstants.white,
      //           fontSize: 18,
      //           fontWeight: FontWeight.w600,
      //         ),
      //       ),
      //       Text(
      //         localizations.manage_subscriptions,
      //         style: TextStyle(
      //           color: Colors.grey,
      //           fontSize: 14,
      //           fontWeight: FontWeight.normal,
      //         ),
      //       ),
      //     ],
      //   ),
      //   titleSpacing: 0,
      // ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ColorConstants.primaryColorNew,
              ColorConstants.redColorNew,
              ColorConstants.whiteNew,
            ],
            stops: [
              0.0,
              0.20,
              0.80,
            ],
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
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
                              color: ColorConstants.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            localizations.manage_subscriptions,
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: _buildBody(),
              ),
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
    final hasActivePlan = _subscriptionData?.activePlan != null;
    final hasActiveTransactions = _subscriptionData?.transactions.any(
        (transaction) => transaction.status.toLowerCase() == 'active') ?? false;
    
    if (_subscriptionData == null || (!hasActivePlan && !hasActiveTransactions)) {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.active_plan,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),
        if (_subscriptionData!.activePlan != null) 
          _buildActivePlanCard(
            _subscriptionData!.activePlan!,
            _subscriptionData!.transactions.isNotEmpty ? _subscriptionData!.transactions.first : null,
          ),
          if (_subscriptionData!.transactions.isNotEmpty) ...[
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
            ..._subscriptionData!.transactions
                .map(
                  (transaction) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildTransactionItem(transaction),
              ),
            )
                .toList(),
          ],
          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildActivePlanCard(ActivePlan activePlan, TransactionModel? tran) {
    final localizations = AppLocalizations.of(context)!;

    final bool isPro = true;
    final Color cardColor = ColorConstants.primaryColor;
    final Color textColor = Colors.white;
    final Color featureIconBorderColor = Colors.white;
    final Color featureIconBackgroundColor = Colors.transparent;

    final double priceInStandardUnit = activePlan.price / 1;

    // Safe date handling
    final expiryDate = activePlan.validity;
    // final purchaseDate = activePlan.validity;

    // String formattedEndDate = expiryDate != null
    //     ? DateFormat('MMMM d, yyyy').format(expiryDate)
    //     : 'Invalid date';
    //
    // // Calculate days remaining safely
    // int daysRemaining = 0;
    // if (expiryDate != null) {
    //   daysRemaining = expiryDate.difference(DateTime.now()).inDays;
    //   if (daysRemaining < 0) daysRemaining = 0;
    // }
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha(25),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 16,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      tran?.status.capitalize() ?? 'Active',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(50),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star,
                  size: 18,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '${activePlan.name} ',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '₹$priceInStandardUnit',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 16,
                  color: textColor.withAlpha(200),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                     localizations.expiryNotAvailable,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor.withAlpha(200),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            activePlan.featureTitle.isNotEmpty
                ? activePlan.featureTitle
                : localizations.planIncludes,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
          const SizedBox(height: 12),
          ...activePlan.features
              .map((feature) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: featureIconBackgroundColor,
                    border: Border.all(
                        color: featureIconBorderColor, width: 2),
                  ),
                  child: Center(
                    child: Icon(
                      CupertinoIcons.checkmark_alt,
                      size: 12,
                      color: textColor,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    feature,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: textColor,
                    ),
                  ),
                ),
              ],
            ),
          ))
              .toList(),
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

  Widget _buildTransactionItem(TransactionModel transaction) {
    final localizations = AppLocalizations.of(context)!;

    final double amountInStandardUnit = transaction.amount / 1;

    final transactionDate = DateTime.now();
    String formattedDate = transactionDate != null
        ? DateFormat('MMM d, yyyy').format(transactionDate)
        : 'Invalid date';
    return GestureDetector(
      onTap: () {
        _showInvoiceBottomSheet(context, transaction.amount.toString());

        print(
            "this is the invoice pdf in html🔫🔫🔫🔫🔫🔫🔫🔫 ${transaction.amount}");
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.file_download_outlined,
                color: ColorConstants.primaryColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.planName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    transactionDate != null
                        ? '${localizations.paymentOn}$formattedDate'
                        : ' ',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '₹$amountInStandardUnit',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: transaction.status.toLowerCase() == 'active'
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    transaction.status.capitalize(),
                    style: TextStyle(
                      fontSize: 12,
                      color: transaction.status.toLowerCase() == 'active'
                          ? Colors.green.shade700
                          : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 50,
          margin: const EdgeInsets.only(bottom: 12),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  CupertinoPageRoute(
                      builder: (context) =>
                          PlanSelectionScreen(planType: "UPGRADE", planFor: '',countryId: '', stateId: '',)));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: Text(
              localizations.upgrade_plan,
              style: TextStyle(
                fontSize: 16,
                color: ColorConstants.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Extension to capitalize strings
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}