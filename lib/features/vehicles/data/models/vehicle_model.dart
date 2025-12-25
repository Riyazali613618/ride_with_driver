import '../../domain/entities/vehicle_entity.dart';

class VehicleModel extends VehicleEntity {
  const VehicleModel({
    required super.id,
    required super.vehicleName,
    required super.vehicleType,
    required super.vehicleNumber,
    required super.seatingCapacity,
    required super.airConditioning,
    required super.minimumCharge,
    required super.isNegotiable,
    required super.images,
    required super.videos,
    required super.vehicleSpecifications,
    required super.rcBookBackPhoto,
    required super.rcBookFrontPhoto,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['_id'],
      vehicleName: json['vehicleName'],
      vehicleType: json['vehicleType'],
      vehicleNumber: json['vehicleNumber'],
      seatingCapacity: json['seatingCapacity'],
      airConditioning: json['airConditioning'],
      minimumCharge: json['minimumChargePerHour'],
      isNegotiable: json['isPriceNegotiable'],
      rcBookFrontPhoto: json['rcBookFrontPhoto'],
      rcBookBackPhoto: json['rcBookBackPhoto'],
      images: List<String>.from(json['images']),
      videos: List<String>.from(json['videos']),
      vehicleSpecifications: List<String>.from(json['vehicleSpecifications']),
    );
  }
}
