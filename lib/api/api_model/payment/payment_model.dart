// lib/api/api_model/payment_model.dart

class CreateOrderResponse {
  final bool success;
  final bool status;
  final String message;
  final OrderData? data;

  CreateOrderResponse({
    required this.success,
    required this.status,
    required this.message,
    this.data,
  });

  factory CreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return CreateOrderResponse(
      success: json['success'] ?? false,
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? OrderData.fromJson(json['data']) : null,
    );
  }
}

class OrderData {
  final String razorpayKey;
  final String orderId;
  final int amount;
  final String currency;
  final OrderMetadata? orderMetadata;
  final Breakdown? breakdown;

  OrderData({
    required this.razorpayKey,
    required this.orderId,
    required this.amount,
    required this.currency,
    this.orderMetadata,
    this.breakdown,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    return OrderData(
      razorpayKey: json['razorpayKey'] ?? '',
      orderId: json['orderId'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? 'INR',
      orderMetadata: json['orderMetadata'] != null
          ? OrderMetadata.fromJson(json['orderMetadata'])
          : null,
      breakdown: json['breakdown'] != null
          ? Breakdown.fromJson(json['breakdown'])
          : null,
    );
  }
}

class OrderMetadata {
  final String userId;
  final String paymentType;
  final String category;
  final String planId;
  final String subscriptionType;
  final Plan? plan;
  final RegistrationFee? registrationFee;
  final int subscriptionAmount;
  final int registrationAmount;
  final int totalAmount;
  final String description;

  OrderMetadata({
    required this.userId,
    required this.paymentType,
    required this.category,
    required this.planId,
    required this.subscriptionType,
    this.plan,
    this.registrationFee,
    required this.subscriptionAmount,
    required this.registrationAmount,
    required this.totalAmount,
    required this.description,
  });

  factory OrderMetadata.fromJson(Map<String, dynamic> json) {
    return OrderMetadata(
      userId: json['userId'] ?? '',
      paymentType: json['paymentType'] ?? '',
      category: json['category'] ?? '',
      planId: json['planId'] ?? '',
      subscriptionType: json['subscriptionType'] ?? '',
      plan: json['plan'] != null ? Plan.fromJson(json['plan']) : null,
      registrationFee: json['registrationFee'] != null
          ? RegistrationFee.fromJson(json['registrationFee'])
          : null,
      subscriptionAmount: json['subscriptionAmount'] ?? 0,
      registrationAmount: json['registrationAmount'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
      description: json['description'] ?? '',
    );
  }
}

class Plan {
  final String id;
  final String name;
  final String planFor;
  final int subscriptionGrossPricePerMonth;
  final int durationInMonths;
  final int subscriptionGrossPriceTotal;
  final int earlyBirdDiscountPercentage;
  final int earlyBirdDiscountPrice;
  final int subscriptionFinalPrice;
  final int mrp;
  final int price;
  final int validity;
  final String featureTitle;
  final List<String> features;
  final int maxVehicles;
  final String planType;
  final bool isDeleted;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  Plan({
    required this.id,
    required this.name,
    required this.planFor,
    required this.subscriptionGrossPricePerMonth,
    required this.durationInMonths,
    required this.subscriptionGrossPriceTotal,
    required this.earlyBirdDiscountPercentage,
    required this.earlyBirdDiscountPrice,
    required this.subscriptionFinalPrice,
    required this.mrp,
    required this.price,
    required this.validity,
    required this.featureTitle,
    required this.features,
    required this.maxVehicles,
    required this.planType,
    required this.isDeleted,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      planFor: json['planFor'] ?? '',
      subscriptionGrossPricePerMonth: json['subscriptionGrossPricePerMonth'] ?? 0,
      durationInMonths: json['durationInMonths'] ?? 0,
      subscriptionGrossPriceTotal: json['subscriptionGrossPriceTotal'] ?? 0,
      earlyBirdDiscountPercentage: json['earlyBirdDiscountPercentage'] ?? 0,
      earlyBirdDiscountPrice: json['earlyBirdDiscountPrice'] ?? 0,
      subscriptionFinalPrice: json['subscriptionFinalPrice'] ?? 0,
      mrp: json['mrp'] ?? 0,
      price: json['price'] ?? 0,
      validity: json['validity'] ?? 0,
      featureTitle: json['featureTitle'] ?? '',
      features: (json['features'] as List<dynamic>?)
          ?.map((f) => f.toString())
          .toList() ??
          [],
      maxVehicles: json['maxVehicles'] ?? 0,
      planType: json['planType'] ?? '',
      isDeleted: json['isDeleted'] ?? false,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class RegistrationFee {
  final String id;
  final String category;
  final int grossPrice;
  final int earlyBirdDiscountPercentage;
  final int earlyBirdDiscountPrice;
  final int finalPrice;
  final bool isActive;
  final bool isDeleted;
  final String createdAt;
  final String updatedAt;

  RegistrationFee({
    required this.id,
    required this.category,
    required this.grossPrice,
    required this.earlyBirdDiscountPercentage,
    required this.earlyBirdDiscountPrice,
    required this.finalPrice,
    required this.isActive,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
  });

  factory RegistrationFee.fromJson(Map<String, dynamic> json) {
    return RegistrationFee(
      id: json['_id'] ?? '',
      category: json['category'] ?? '',
      grossPrice: json['grossPrice'] ?? 0,
      earlyBirdDiscountPercentage: json['earlyBirdDiscountPercentage'] ?? 0,
      earlyBirdDiscountPrice: json['earlyBirdDiscountPrice'] ?? 0,
      finalPrice: json['finalPrice'] ?? 0,
      isActive: json['isActive'] ?? false,
      isDeleted: json['isDeleted'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }
}

class Breakdown {
  final int registrationFee;
  final int subscriptionFee;
  final int totalAmount;
  final int discountApplied;

  Breakdown({
    required this.registrationFee,
    required this.subscriptionFee,
    required this.totalAmount,
    required this.discountApplied,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) {
    return Breakdown(
      registrationFee: json['registrationFee'] ?? 0,
      subscriptionFee: json['subscriptionFee'] ?? 0,
      totalAmount: json['totalAmount'] ?? 0,
      discountApplied: json['discountApplied'] ?? 0,
    );
  }
}


class SaveOrderRequest {
  final String razorpayOrderId;
  final String razorpayPaymentId;
  final String razorpaySignature;

  SaveOrderRequest({
    required this.razorpayOrderId,
    required this.razorpayPaymentId,
    required this.razorpaySignature,
  });

  Map<String, dynamic> toJson() {
    return {
      'razorpay_order_id': razorpayOrderId,
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_signature': razorpaySignature,
    };
  }
}
