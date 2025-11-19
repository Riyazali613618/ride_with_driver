import '../../domain/model/booking.dart';
import '../../domain/repository/booking_repository.dart';

class MockRepository implements BookingRepository {
  final List<Booking> _items = List.generate(
    4,
    (i) => Booking(
      id: 'b\$i',
      date: DateTime.now().subtract(Duration(days: i)),
      pickupPoint: 'Noida UP',
      destination: i % 2 == 0 ? 'Simla HP' : 'Manali HP',
      clientName: 'Ramesh',
      status: i == 0 ? BookingStatus.ongoing : BookingStatus.pendingQuote,
    ),
  );

  @override
  Future<List<Booking>> getBookings() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _items;
  }

  @override
  Future<void> cancelBooking(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
// noop in mock
  }

  @override
  Future<void> sendQuotation(Map<String, dynamic> payload) async {
    await Future.delayed(const Duration(seconds: 1));
// pretend success
  }
}
