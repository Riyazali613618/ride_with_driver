class EligibilityModel {
  bool? success;
  String? message;
  Data? data;

  EligibilityModel({this.success, this.message, this.data});

  EligibilityModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? subscriptionId;
  String? orderId;
  String? paymentRestrictionId;
  String? paymentPhase;
  String? category;
  String? subscriptionType;
  String? subcrptionStartDate;
  String? subcriptionEndDate;
  String? planFor;
  String? planType;
  bool? isFormSubmitted;
  String? subcriptionStatus;
  bool? canUpgrade;

  Data(
      {this.id,
        this.subscriptionId,
        this.orderId,
        this.paymentRestrictionId,
        this.paymentPhase,
        this.category,
        this.subscriptionType,
        this.subcrptionStartDate,
        this.subcriptionEndDate,
        this.planFor,
        this.planType,
        this.isFormSubmitted,
        this.subcriptionStatus,
        this.canUpgrade});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    subscriptionId = json['subscriptionId'];
    orderId = json['orderId'];
    paymentRestrictionId = json['paymentRestrictionId'];
    paymentPhase = json['paymentPhase'];
    category = json['category'];
    subscriptionType = json['subscriptionType'];
    subcrptionStartDate = json['subcrption_start_date'];
    subcriptionEndDate = json['subcription_end_date'];
    planFor = json['planFor'];
    planType = json['planType'];
    isFormSubmitted = json['isFormSubmitted'];
    subcriptionStatus = json['subcription_status'];
    canUpgrade = json['canUpgrade'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['subscriptionId'] = this.subscriptionId;
    data['orderId'] = this.orderId;
    data['paymentRestrictionId'] = this.paymentRestrictionId;
    data['paymentPhase'] = this.paymentPhase;
    data['category'] = this.category;
    data['subscriptionType'] = this.subscriptionType;
    data['subcrption_start_date'] = this.subcrptionStartDate;
    data['subcription_end_date'] = this.subcriptionEndDate;
    data['planFor'] = this.planFor;
    data['planType'] = this.planType;
    data['isFormSubmitted'] = this.isFormSubmitted;
    data['subcription_status'] = this.subcriptionStatus;
    data['canUpgrade'] = this.canUpgrade;
    return data;
  }
}