class PlanEntity {
  final String id;
  final String name;
  final String planFor;
  final double pricePerMonth;
  final int durationInMonths;
  final double grossPrice;
  final double earlyBirdDiscountPercentage;
  final double earlyBirdDiscountPrice;
  final double finalPrice;
  final int maxVehicles;
  final String planType;
  final List<String> features;

  const PlanEntity({
    required this.id,
    required this.name,
    required this.planFor,
    required this.pricePerMonth,
    required this.durationInMonths,
    required this.grossPrice,
    required this.earlyBirdDiscountPercentage,
    required this.earlyBirdDiscountPrice,
    required this.finalPrice,
    required this.maxVehicles,
    required this.planType,
    required this.features,
  });
}
