import '../model/booking.dart';
import '../repository/booking_repository.dart';

class GetBookingsUseCase {
  final BookingRepository repo;

  GetBookingsUseCase(this.repo);

  Future<List<Booking>> call() => repo.getBookings();
}

class CancelBookingUseCase {
  final BookingRepository repo;

  CancelBookingUseCase(this.repo);

  Future<void> call(String id) => repo.cancelBooking(id);
}

class SendQuotationUseCase {
  final BookingRepository repo;

  SendQuotationUseCase(this.repo);

  Future<void> call(Map<String, dynamic> payload) =>
      repo.sendQuotation(payload);
}
