import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../domain/model/booking.dart';
import '../../../../domain/repository/booking_repository.dart';
import '../../../../domain/use_case/booking_use_cases.dart';


abstract class ManageEvent extends Equatable {}

class LoadBookings extends ManageEvent {
  @override
  // TODO: implement props
  List<Object?> get props => [];
}

class CancelBookingEvent extends ManageEvent {
  final String id;

  CancelBookingEvent(this.id);

  @override
  List<Object?> get props => [id];
}

abstract class ManageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ManageLoading extends ManageState {}

class ManageLoaded extends ManageState {
  final List<Booking> bookings;

  ManageLoaded(this.bookings);

  @override
  List<Object?> get props => [bookings];
}

class ManageError extends ManageState {
  final String message;

  ManageError(this.message);

  @override
  List<Object?> get props => [message];
}

class MyBookingBloc extends Bloc<ManageEvent, ManageState> {
  final BookingRepository repo;
  final GetBookingsUseCase _get;
  final CancelBookingUseCase _cancel;

  MyBookingBloc(this.repo)
      : _get = GetBookingsUseCase(repo),
        _cancel = CancelBookingUseCase(repo),
        super(ManageLoading()) {
    on<LoadBookings>((e, emit) async {
      emit(ManageLoading());
      try {
        final list = await _get();
        emit(ManageLoaded(list));
      } catch (ex) {
        emit(ManageError(ex.toString()));
      }
    });

    on<CancelBookingEvent>((e, emit) async {
      if (state is ManageLoaded) {
        try {
          await _cancel(e.id);
// refresh
          final list = await _get();
          emit(ManageLoaded(list));
        } catch (ex) {
          emit(ManageError(ex.toString()));
        }
      }
    });
  }
}
