import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String id;
  final DateTime date;
  final String pickupPoint;
  final String destination;
  final String clientName;
  final BookingStatus status;


  const Booking({
    required this.id,
    required this.date,
    required this.pickupPoint,
    required this.destination,
    required this.clientName,
    this.status = BookingStatus.ongoing,
  });


  @override
  List<Object?> get props => [id, date, pickupPoint, destination, clientName, status];
}


enum BookingStatus { ongoing, upcoming, pendingQuote, completed, cancelled }