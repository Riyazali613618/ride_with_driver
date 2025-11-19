import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repository/booking_repository.dart';
import '../../domain/use_case/booking_use_cases.dart';

abstract class MakeEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartMakeBooking extends MakeEvent {}

class UpdateBookingDetail extends MakeEvent {
  final Map<String, dynamic> data;

  UpdateBookingDetail(this.data);

  @override
  List<Object?> get props => [data];
}

class SubmitQuotation extends MakeEvent {}

abstract class MakeState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MakeInitial extends MakeState {}

class MakeInProgress extends MakeState {
  final Map<String, dynamic> data;

  MakeInProgress(this.data);

  @override
  List<Object?> get props => [data];
}

class MakeSuccess extends MakeState {}

class MakeFailure extends MakeState {
  final String message;

  MakeFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class MakeBookingBloc extends Bloc<MakeEvent, MakeState> {
  final BookingRepository repo;
  final SendQuotationUseCase _send;
  Map<String, dynamic> _form = {};

  MakeBookingBloc(this.repo)
      : _send = SendQuotationUseCase(repo),
        super(MakeInitial()) {
    on<StartMakeBooking>((e, emit) => emit(MakeInitial()));
    on<UpdateBookingDetail>((e, emit) {
      _form.addAll(e.data);
      emit(MakeInProgress(Map.from(_form)));
    });
    on<SubmitQuotation>((e, emit) async {
      emit(MakeInProgress(_form));
      try {
        await _send(_form);
        emit(MakeSuccess());
      } catch (ex) {
        emit(MakeFailure(ex.toString()));
      }
    });
  }
}
