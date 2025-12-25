import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/bloc/payment/payment_event.dart';
import 'package:r_w_r/bloc/payment/payment_state.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../api/api_service/payment_service/payment_service.dart';
import '../../api/api_model/payment/payment_model.dart';
import '../../screens/block/provider/profile_provider.dart';

class PaymentBloc extends Bloc<PaymentEvent, PaymentState> {
  late Razorpay _razorpay;
  String? _currentRegistrationFeeId;
  final ProfileProvider? profileProvider;
  InitiatePayment? _currentInitiatePaymentEvent;

  PaymentBloc({this.profileProvider}) : super(PaymentInitial()) {
    print('[PaymentBloc] Constructor called');
    print('[PaymentBloc] ProfileProvider injected: ${profileProvider != null}');
    if (profileProvider != null) {
      print('[PaymentBloc] ProfileProvider phone: ${profileProvider?.phoneNumber}');
      print('[PaymentBloc] ProfileProvider email: ${profileProvider?.email}');
    }

    _initializeRazorpay();
    on<InitiatePayment>(_onInitiatePayment);
    on<PaymentSuccess>(_onPaymentSuccess);
    on<PaymentFailed>(_onPaymentFailed);
    on<ResetPayment>(_onResetPayment);
  }

  void _initializeRazorpay() {
    try {
      print('[PaymentBloc] Initializing Razorpay...');
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
      print('[PaymentBloc] Razorpay initialized successfully');
    } catch (e) {
      print('[PaymentBloc] Error initializing Razorpay: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('[PaymentBloc] Razorpay payment success: ${response.paymentId}');
    // Trigger payment success event with stored payment info
    if (_currentInitiatePaymentEvent != null) {
      print('[PaymentBloc] Processing payment success for plan: ${_currentInitiatePaymentEvent!.plan.name}');
      add(PaymentSuccess(
        response: response,
        currentCategory: _currentInitiatePaymentEvent!.currentCategory,
        plan: _currentInitiatePaymentEvent!.plan,
        planType: _currentInitiatePaymentEvent!.planType,
        paymentType: _currentInitiatePaymentEvent!.paymentType,
        category: _currentInitiatePaymentEvent!.category,
        registrationFeeId: _currentRegistrationFeeId,
      ));
    } else {
      print('[PaymentBloc] Error: No current initiate payment event found');
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('[PaymentBloc] Razorpay payment error: ${response.message}');
    add(PaymentFailed(response.message ?? 'Payment failed'));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handle external wallet
  }

  Future<void> _onInitiatePayment(InitiatePayment event, Emitter<PaymentState> emit,) async {
    print('[PaymentBloc] Initiating payment for plan: ${event.plan.name}');
    emit(PaymentLoading());

    try {
      // Create order for Razorpay payment
      late Map<String, dynamic> orderResponse;

      switch (event.paymentType) {
        case PaymentType.subscriptionRenewal:
          orderResponse = await PaymentService.createOrderForSubscriptionRenewal(
            planId: event.plan.id,
          );
          break;
        case PaymentType.registrationOnly:
          orderResponse = await PaymentService.createOrderForRegistrationOnly(
            category: event.category ?? event.planType,
            currentCategory: event.currentCategory??"",
            planId: event.plan.id,
          );
          break;
        case PaymentType.registrationWithSubscription:
          orderResponse = await PaymentService.createOrderForRegistrationWithSubscription(
            category: event.category ?? event.planType,
            currentCategory: event.currentCategory??"",
            planId: event.plan.id,
          );
          break;
      }

      final createOrderResponse = CreateOrderResponse.fromJson(orderResponse);

      if (createOrderResponse.success && createOrderResponse.data != null) {
        print(createOrderResponse);
        final orderData = createOrderResponse.data!;
        String? regID = orderData.orderMetadata?.registrationFee?.id.toString();
        emit(PaymentError("Error: ${createOrderResponse.data}"));

        if (regID != null) {
          _currentRegistrationFeeId = regID;
        }

        if (orderData.razorpayKey.isEmpty) {
          emit(PaymentError("Invalid merchant key received"));
          return;
        }

        var options = {
          'key': orderData.razorpayKey,
          'amount': orderData.amount,
          'name': 'Ride with Driver',
          'description': _getPaymentDescription(event.paymentType),
          'order_id': orderData.orderId,
          'prefill': {
            'contact': profileProvider?.phoneNumber ?? '',
            'email': profileProvider?.email ?? '',
          },
          'external': {
            'wallets': ['paytm']
          }
        };
        
        print('[PaymentBloc] Created payment options: ${options.toString()}');
        print('[PaymentBloc] Order ID: ${orderData.orderId}');
        print('[PaymentBloc] Amount: ${orderData.amount}');
        print('[PaymentBloc] Razorpay Key: ${orderData.razorpayKey}');

        // Store the event for later use when payment succeeds
        _currentInitiatePaymentEvent = event;
        
        print('[PaymentBloc] Emitting PaymentOrderCreated state');
        emit(PaymentOrderCreated(
          orderData: options,
          registrationFeeId: _currentRegistrationFeeId,
        ));
      } else {
        emit(PaymentError("Failed to create order: ${createOrderResponse.message}"));
      }
    } catch (e) {
      emit(PaymentError("Error: Please complete another process or they have bought plan"));
    }
  }

  Future<void> _onPaymentSuccess(
      PaymentSuccess event,
      Emitter<PaymentState> emit,
      ) async {
    emit(PaymentProcessing());

    try {
      switch (event.paymentType) {
        case PaymentType.subscriptionRenewal:
          await PaymentService.saveOrderForSubscriptionRenewal(
            razorpayOrderId: event.response.orderId ?? '',
            razorpayPaymentId: event.response.paymentId ?? '',
            razorpaySignature: event.response.signature ?? '',
            planId: event.plan.id,
            currentCategory: event.currentCategory??"",
          );
          break;
        case PaymentType.registrationOnly:
          await PaymentService.saveOrderForRegistrationOnly(
            razorpayOrderId: event.response.orderId ?? '',
            razorpayPaymentId: event.response.paymentId ?? '',
            razorpaySignature: event.response.signature ?? '',
            category: event.category ?? event.planType,
            currentCategory: event.currentCategory??"",
            registrationFeeId: event.registrationFeeId ?? '',
          );
          break;
        case PaymentType.registrationWithSubscription:
          await PaymentService.saveOrderForRegistrationWithSubscription(
            razorpayOrderId: event.response.orderId ?? '',
            razorpayPaymentId: event.response.paymentId ?? '',
            razorpaySignature: event.response.signature ?? '',
            category: event.category ?? event.planType,
            currentCategory: event.currentCategory??"",
            planId: event.plan.id,
            registrationFeeId: event.registrationFeeId ?? '',
          );
          break;
      }

      emit(PaymentCompleted(event.planType));
    } catch (e) {
      emit(PaymentError("Error: $e"));
    }
  }

  void _onPaymentFailed(
      PaymentFailed event,
      Emitter<PaymentState> emit,
      ) {
    emit(PaymentError(event.error));
  }

  void _onResetPayment(
      ResetPayment event,
      Emitter<PaymentState> emit,
      ) {
    emit(PaymentInitial());
  }

  String _getPaymentDescription(PaymentType paymentType) {
    switch (paymentType) {
      case PaymentType.subscriptionRenewal:
        return 'Subscription Renewal';
      case PaymentType.registrationOnly:
        return 'Registration Fee';
      case PaymentType.registrationWithSubscription:
        return 'Registration + Subscription';
    }
  }

  void openRazorpayCheckout(Map<String, dynamic> options) {
    try {
      print('[PaymentBloc] Opening Razorpay checkout with options: $options');
      print('[PaymentBloc] Razorpay instance status: ${_razorpay != null ? "initialized" : "null"}');
      
      // Validate essential options
      if (options['key'] == null || options['key'].toString().isEmpty) {
        print('[PaymentBloc] ERROR: Razorpay key is missing or empty');
        add(PaymentFailed('Invalid Razorpay key'));
        return;
      }
      
      if (options['amount'] == null) {
        print('[PaymentBloc] ERROR: Amount is missing');
        add(PaymentFailed('Invalid payment amount'));
        return;
      }
      
      if (options['order_id'] == null || options['order_id'].toString().isEmpty) {
        print('[PaymentBloc] ERROR: Order ID is missing or empty');
        add(PaymentFailed('Invalid order ID'));
        return;
      }
      
      print('[PaymentBloc] All required options are present:');
      print('[PaymentBloc] - Key: ${options['key']}');
      print('[PaymentBloc] - Amount: ${options['amount']}');
      print('[PaymentBloc] - Order ID: ${options['order_id']}');
      print('[PaymentBloc] - Contact: ${options['prefill']?['contact']}');
      print('[PaymentBloc] - Email: ${options['prefill']?['email']}');
      
      // Try opening Razorpay immediately first
      print('[PaymentBloc] About to call _razorpay.open() immediately');
      try {
        _razorpay.open(options);
        print('[PaymentBloc] _razorpay.open() called successfully, waiting for callbacks');
      } catch (immediateError) {
        print('[PaymentBloc] Immediate call failed: $immediateError, trying with delay');
        
        // If immediate call fails, try with a small delay
        Future.delayed(const Duration(milliseconds: 300), () {
          try {
            print('[PaymentBloc] About to call _razorpay.open() after delay');
            _razorpay.open(options);
            print('[PaymentBloc] Delayed _razorpay.open() called successfully');
          } catch (delayedError, delayedStackTrace) {
            print('[PaymentBloc] Error in delayed Razorpay open: $delayedError');
            print('[PaymentBloc] Delayed stack trace: $delayedStackTrace');
            add(PaymentFailed('Failed to open payment gateway: $delayedError'));
          }
        });
      }
      
    } catch (e, stackTrace) {
      print('[PaymentBloc] Error opening Razorpay checkout: $e');
      print('[PaymentBloc] Stack trace: $stackTrace');
      add(PaymentFailed('Payment gateway error: $e'));
    }
  }

  @override
  Future<void> close() {
    _razorpay.clear();
    return super.close();
  }
}
