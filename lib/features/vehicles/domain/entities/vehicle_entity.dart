import 'package:equatable/equatable.dart';

class VehicleEntity extends Equatable {
  final String id;
  final String vehicleName;
  final String vehicleType;
  final String vehicleNumber;
  final int seatingCapacity;
  final String airConditioning;
  final String rcBookFrontPhoto;
  final String rcBookBackPhoto;
  final int minimumCharge;
  final bool isNegotiable;
  final List<String> images;
  final List<String> videos;
  final List<String> vehicleSpecifications;

  const VehicleEntity({
    required this.id,
    required this.vehicleName,
    required this.vehicleType,
    required this.vehicleNumber,
    required this.seatingCapacity,
    required this.airConditioning,
    required this.minimumCharge,
    required this.isNegotiable,
    required this.images,
    required this.rcBookFrontPhoto,
    required this.rcBookBackPhoto,
    required this.vehicleSpecifications,
    required this.videos,
  });

  @override
  List<Object?> get props => [id];
}
