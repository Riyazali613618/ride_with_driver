import '../model/booking.dart';

abstract class BookingRepository {
  Future<List<Booking>> getBookings();
  Future<void> cancelBooking(String id);
  Future<void> sendQuotation(Map<String, dynamic> payload);
}