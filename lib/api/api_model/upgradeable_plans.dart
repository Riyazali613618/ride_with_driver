class UpgradeablePlans {
  bool? success;
  String? message;
  Data? data;

  UpgradeablePlans({this.success, this.message, this.data});

  UpgradeablePlans.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? currentCategory;
  int? currentHierarchyLevel;
  List<AvailableUpgrades>? availableUpgrades;
  int? totalUpgradeOptions;
  int? totalPlans;

  Data(
      {this.currentCategory,
        this.currentHierarchyLevel,
        this.availableUpgrades,
        this.totalUpgradeOptions,
        this.totalPlans});

  Data.fromJson(Map<String, dynamic> json) {
    currentCategory = json['currentCategory'];
    currentHierarchyLevel = json['currentHierarchyLevel'];
    if (json['availableUpgrades'] != null) {
      availableUpgrades = <AvailableUpgrades>[];
      json['availableUpgrades'].forEach((v) {
        availableUpgrades!.add(new AvailableUpgrades.fromJson(v));
      });
    }
    totalUpgradeOptions = json['totalUpgradeOptions'];
    totalPlans = json['totalPlans'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['currentCategory'] = this.currentCategory;
    data['currentHierarchyLevel'] = this.currentHierarchyLevel;
    if (this.availableUpgrades != null) {
      data['availableUpgrades'] =
          this.availableUpgrades!.map((v) => v.toJson()).toList();
    }
    data['totalUpgradeOptions'] = this.totalUpgradeOptions;
    data['totalPlans'] = this.totalPlans;
    return data;
  }
}

class AvailableUpgrades {
  String? upgradeCategory;
  int? hierarchyLevel;
  String? displayName;
  List<SubscriptionPlans>? subscriptionPlans;
  int? planCount;

  AvailableUpgrades(
      {this.upgradeCategory,
        this.hierarchyLevel,
        this.displayName,
        this.subscriptionPlans,
        this.planCount});

  AvailableUpgrades.fromJson(Map<String, dynamic> json) {
    upgradeCategory = json['upgradeCategory'];
    hierarchyLevel = json['hierarchyLevel'];
    displayName = json['displayName'];
    if (json['subscriptionPlans'] != null) {
      subscriptionPlans = <SubscriptionPlans>[];
      json['subscriptionPlans'].forEach((v) {
        subscriptionPlans!.add(new SubscriptionPlans.fromJson(v));
      });
    }
    planCount = json['planCount'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['upgradeCategory'] = this.upgradeCategory;
    data['hierarchyLevel'] = this.hierarchyLevel;
    data['displayName'] = this.displayName;
    if (this.subscriptionPlans != null) {
      data['subscriptionPlans'] =
          this.subscriptionPlans!.map((v) => v.toJson()).toList();
    }
    data['planCount'] = this.planCount;
    return data;
  }
}

class SubscriptionPlans {
  String? sId;
  String? name;
  String? planFor;
  String? countryId;
  String? stateId;
  String? locationLevel;
  int? pricePerMonth;
  int? durationInMonths;
  int? grossPrice;
  int? earlyBirdDiscountPercentage;
  int? earlyBirdDiscountPrice;
  int? finalPrice;
  int? maxVehicles;
  String? planType;
  int? freeSubscriptionMonths;
  List<String>? features;
  bool? isActive;
  int? iV;
  String? createdAt;
  String? updatedAt;

  SubscriptionPlans(
      {this.sId,
        this.name,
        this.planFor,
        this.countryId,
        this.stateId,
        this.locationLevel,
        this.pricePerMonth,
        this.durationInMonths,
        this.grossPrice,
        this.earlyBirdDiscountPercentage,
        this.earlyBirdDiscountPrice,
        this.finalPrice,
        this.maxVehicles,
        this.planType,
        this.freeSubscriptionMonths,
        this.features,
        this.isActive,
        this.iV,
        this.createdAt,
        this.updatedAt});

  SubscriptionPlans.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    planFor = json['planFor'];
    countryId = json['countryId'];
    stateId = json['stateId'];
    locationLevel = json['locationLevel'];
    pricePerMonth = json['pricePerMonth'];
    durationInMonths = json['durationInMonths'];
    grossPrice = json['grossPrice'];
    earlyBirdDiscountPercentage = json['earlyBirdDiscountPercentage'];
    earlyBirdDiscountPrice = json['earlyBirdDiscountPrice'];
    finalPrice = json['finalPrice'];
    maxVehicles = json['maxVehicles'];
    planType = json['planType'];
    freeSubscriptionMonths = json['freeSubscriptionMonths'];
    features = json['features'].cast<String>();
    isActive = json['isActive'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['planFor'] = this.planFor;
    data['countryId'] = this.countryId;
    data['stateId'] = this.stateId;
    data['locationLevel'] = this.locationLevel;
    data['pricePerMonth'] = this.pricePerMonth;
    data['durationInMonths'] = this.durationInMonths;
    data['grossPrice'] = this.grossPrice;
    data['earlyBirdDiscountPercentage'] = this.earlyBirdDiscountPercentage;
    data['earlyBirdDiscountPrice'] = this.earlyBirdDiscountPrice;
    data['finalPrice'] = this.finalPrice;
    data['maxVehicles'] = this.maxVehicles;
    data['planType'] = this.planType;
    data['freeSubscriptionMonths'] = this.freeSubscriptionMonths;
    data['features'] = this.features;
    data['isActive'] = this.isActive;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}