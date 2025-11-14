import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../data/models/plan_model.dart';

class PlanPaymentScreen extends StatefulWidget {
  final PlanModel selectedPlan;

  const PlanPaymentScreen({super.key, required this.selectedPlan});

  @override
  State<PlanPaymentScreen> createState() => _PlanPaymentScreenState();
}

class _PlanPaymentScreenState extends State<PlanPaymentScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();

    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    _startPayment();
  }

  void _startPayment() {
    final amount =
        (widget.selectedPlan.finalPrice * 100).toInt(); // convert to paise

    var options = {
      'key': 'rzp_test_xxxxxx', // replace with your Razorpay key
      'amount': amount, // in paise
      'name': 'RideWithDriver',
      'description': widget.selectedPlan.name,
      'prefill': {
        'contact': '9999999999', // optional
        'email': 'user@example.com', // optional
      },
      'theme': {'color': '#6A1B9A'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    debugPrint('✅ Payment Success: ${response.paymentId}');
    debugPrint('Order ID: ${response.orderId}');
    debugPrint('Signature: ${response.signature}');

    final paymentData = {
      "razorpay_order_id": response.orderId,
      "razorpay_payment_id": response.paymentId,
      "razorpay_signature": response.signature,
      "registrationPlanId": widget.selectedPlan.id,
      "subscriptionPlanId": /*widget.selectedPlan.subscriptionPlanId ??*/ "",
    };

    // TODO: send `paymentData` to your backend for verification
    Navigator.pop(context, paymentData);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    debugPrint('❌ Payment failed: ${response.code} | ${response.message}');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('⚡ External Wallet selected: ${response.walletName}');
  }

  @override
  void dispose() {
    _razorpay.clear(); // always clear to prevent memory leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
