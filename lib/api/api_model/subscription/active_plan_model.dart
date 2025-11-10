class SubscriptionResponse {
  final bool status;
  final String message;
  final SubscriptionData data;

  SubscriptionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory SubscriptionResponse.fromJson(Map<String, dynamic> json) {
    return SubscriptionResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: SubscriptionData.fromJson(json['data'] ?? {}),
    );
  }
}

class SubscriptionData {
  final ActivePlan? activePlan;
  final List<TransactionModel> transactions;

  SubscriptionData({
    required this.activePlan,
    required this.transactions,
  });

  factory SubscriptionData.fromJson(Map<String, dynamic> json) {
    final transactions = (json['transactions'] as List<dynamic>? ?? [])
        .map((transaction) => TransactionModel.fromJson(transaction))
        .toList();
    
    ActivePlan? activePlan;
    
    // First try to get activePlan from the API response
    if (json['activePlan'] != null) {
      activePlan = ActivePlan.fromJson(json['activePlan']);
    } else {
      // If activePlan is null, try to create it from active transactions
      TransactionModel? activeTransaction;
      try {
        activeTransaction = transactions.firstWhere(
          (transaction) => transaction.status.toLowerCase() == 'active',
        );
      } catch (e) {
        // If no active transaction found, use the first transaction if available
        activeTransaction = transactions.isNotEmpty ? transactions.first : null;
      }
      
      if (activeTransaction != null && activeTransaction.plan != null) {
        // Create ActivePlan from the transaction's plan data
        activePlan = ActivePlan(
          id: activeTransaction.plan!.id,
          name: activeTransaction.plan!.name,
          planFor: activeTransaction.plan!.planFor,
          subscriptionGrossPricePerMonth: activeTransaction.plan!.subscriptionGrossPricePerMonth,
          durationInMonths: activeTransaction.plan!.durationInMonths,
          subscriptionGrossPriceTotal: activeTransaction.plan!.subscriptionGrossPriceTotal,
          earlyBirdDiscountPercentage: activeTransaction.plan!.earlyBirdDiscountPercentage,
          earlyBirdDiscountPrice: activeTransaction.plan!.earlyBirdDiscountPrice,
          subscriptionFinalPrice: activeTransaction.plan!.subscriptionFinalPrice,
          mrp: activeTransaction.plan!.mrp,
          price: activeTransaction.plan!.price,
          validity: activeTransaction.plan!.validity,
          featureTitle: activeTransaction.plan!.featureTitle,
          features: activeTransaction.plan!.features,
        );
      }
    }
    
    return SubscriptionData(
      activePlan: activePlan,
      transactions: transactions,
    );
  }
}

/// Active Plan (if present)
class ActivePlan {
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

  ActivePlan({
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
  });

  factory ActivePlan.fromJson(Map<String, dynamic> json) {
    return ActivePlan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      planFor: json['planFor'] ?? '',
      subscriptionGrossPricePerMonth:
      json['subscriptionGrossPricePerMonth'] ?? 0,
      durationInMonths: json['durationInMonths'] ?? 0,
      subscriptionGrossPriceTotal: json['subscriptionGrossPriceTotal'] ?? 0,
      earlyBirdDiscountPercentage: json['earlyBirdDiscountPercentage'] ?? 0,
      earlyBirdDiscountPrice: json['earlyBirdDiscountPrice'] ?? 0,
      subscriptionFinalPrice: json['subscriptionFinalPrice'] ?? 0,
      mrp: json['mrp'] ?? 0,
      price: json['price'] ?? 0,
      validity: json['validity'] ?? 0,
      featureTitle: json['featureTitle'] ?? '',
      features: (json['features'] as List<dynamic>? ?? [])
          .map((f) => f.toString())
          .toList(),
    );
  }
}

/// Transaction model with embedded plan
class TransactionModel {
  final String planName;
  final int amount;
  final String currency;
  final String status;
  final String id;
  final String userId;
  final String planId;
  final Plan? plan;

  TransactionModel({
    required this.planName,
    required this.amount,
    required this.currency,
    required this.status,
    required this.id,
    required this.userId,
    required this.planId,
    required this.plan,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      planName: json['planName'] ?? '',
      amount: json['amount'] ?? 0,
      currency: json['currency'] ?? '',
      status: json['status'] ?? '',
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      planId: json['planId'] ?? '',
      plan: json['plan'] != null ? Plan.fromJson(json['plan']) : null,
    );
  }
}

/// Plan inside Transaction
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
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      planFor: json['planFor'] ?? '',
      subscriptionGrossPricePerMonth:
      json['subscriptionGrossPricePerMonth'] ?? 0,
      durationInMonths: json['durationInMonths'] ?? 0,
      subscriptionGrossPriceTotal: json['subscriptionGrossPriceTotal'] ?? 0,
      earlyBirdDiscountPercentage: json['earlyBirdDiscountPercentage'] ?? 0,
      earlyBirdDiscountPrice: json['earlyBirdDiscountPrice'] ?? 0,
      subscriptionFinalPrice: json['subscriptionFinalPrice'] ?? 0,
      mrp: json['mrp'] ?? 0,
      price: json['price'] ?? 0,
      validity: json['validity'] ?? 0,
      featureTitle: json['featureTitle'] ?? '',
      features: (json['features'] as List<dynamic>? ?? [])
          .map((f) => f.toString())
          .toList(),
    );
  }
}
