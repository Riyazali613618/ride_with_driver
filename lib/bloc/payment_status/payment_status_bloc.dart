import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:r_w_r/bloc/payment_status/payment_status_event.dart';
import 'package:r_w_r/bloc/payment_status/payment_status_state.dart';
import '../../api/api_service/user_service/PaymentStatusService.dart';

class PaymentStatusBloc extends Bloc<PaymentStatusEvent, PaymentStatusState> {
  PaymentStatusBloc() : super(PaymentStatusInitial()) {
    on<FetchPaymentStatus>(_onFetchPaymentStatus);
    on<ResetPaymentStatus>(_onResetPaymentStatus);
  }

  Future<void> _onFetchPaymentStatus(FetchPaymentStatus event, Emitter<PaymentStatusState> emit,) async {
    emit(PaymentStatusLoading());
    try {
      await PaymentStatusService.fetchPaymentStatus(event.category);

      if (PaymentStatusService.globalPaymentStatus != null) {
        emit(PaymentStatusLoaded(PaymentStatusService.globalPaymentStatus!));
      } else {
        emit(PaymentStatusError('Failed to load payment status'));
      }
    } catch (e) {
      emit(PaymentStatusError('Error: $e'));
    }
  }

  void _onResetPaymentStatus(
      ResetPaymentStatus event,
      Emitter<PaymentStatusState> emit,
      ) {
    emit(PaymentStatusInitial());
  }
}
