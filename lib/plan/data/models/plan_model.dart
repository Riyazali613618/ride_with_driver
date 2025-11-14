import '../../domain/entities/plan_entity.dart';

class PlanModel extends PlanEntity {
  const PlanModel({
    required super.id,
    required super.name,
    required super.planFor,
    required super.pricePerMonth,
    required super.durationInMonths,
    required super.grossPrice,
    required super.earlyBirdDiscountPercentage,
    required super.earlyBirdDiscountPrice,
    required super.finalPrice,
    required super.maxVehicles,
    required super.planType,
    required super.features,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      planFor: json['planFor'] ?? '',
      pricePerMonth: (json['pricePerMonth'] ?? 0).toDouble(),
      durationInMonths: json['durationInMonths'] ?? 0,
      grossPrice: (json['grossPrice'] ?? 0).toDouble(),
      earlyBirdDiscountPercentage:
      (json['earlyBirdDiscountPercentage'] ?? 0).toDouble(),
      earlyBirdDiscountPrice:
      (json['earlyBirdDiscountPrice'] ?? 0).toDouble(),
      finalPrice: (json['finalPrice'] ?? 0).toDouble(),
      maxVehicles: json['maxVehicles'] ?? 0,
      planType: json['planType'] ?? '',
      features:
      List<String>.from(json['features']?.map((f) => f.toString()) ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'planFor': planFor,
      'pricePerMonth': pricePerMonth,
      'durationInMonths': durationInMonths,
      'grossPrice': grossPrice,
      'earlyBirdDiscountPercentage': earlyBirdDiscountPercentage,
      'earlyBirdDiscountPrice': earlyBirdDiscountPrice,
      'finalPrice': finalPrice,
      'maxVehicles': maxVehicles,
      'planType': planType,
      'features': features,
    };
  }
}
