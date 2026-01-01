/*
// models/user_profile_model.dart

class UserProfileModel {
  final bool status;
  final String message;
  final UserData? data;

  UserProfileModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class UserData {
  final String firstName;
  final String lastName;
  final String? number;
  final String email;
  final String language;
  final String languageID;
  final String userType;
  final int vehicleLimit;
  final List<Subscriptions>? subscriptions;

  UserData({
    required this.vehicleLimit,
    required this.firstName,
    required this.userType,
    required this.subscriptions,
    required this.lastName,
    required this.languageID,
    this.number,
    required this.email,
    required this.language,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    List<Subscriptions>? subscriptionsList=[];
    var content = json['subscriptions']==null?[]:json['subscriptions'] as List;
    subscriptionsList = content.map((item) => Subscriptions.fromJson(item)).toList();
    return UserData(
        vehicleLimit: json['vehicleLimit'] ?? 1,
        firstName: json['firstName'] ?? '',
        subscriptions: subscriptionsList,
        lastName: json['lastName'] ?? '',
        number: json['number'],
        userType: json['usertype'] ?? '',
        email: json['email'] ?? '',
        language:
            json['language'] != null ? json['language'] is Map?(json['language']["name"] ?? ''):json['language'] : "",
        languageID:
            json['language'] != null ? json['language'] is Map?( json['language']["id"] ?? '' ): json['language']: "");
  }

  Map<String, dynamic> toJson() {
    return {
      'vehicleLimit': vehicleLimit,
      'firstName': firstName,
      'userType': userType,
      'subscriptions': subscriptions,
      'lastName': lastName,
      if (number != null) 'number': number,
      'email': email,
      'language': language,
    };
  }

  UserData copyWith({
    String? firstName,
    String? lastName,
    String? number,
    String? email,
    String? userType,
    String? language,
    String? languageID,
    int? vehicleLimit,
    List<Subscriptions>? subscriptions,
  }) {
    return UserData(
      vehicleLimit: vehicleLimit ?? this.vehicleLimit,
      subscriptions: subscriptions ?? this.subscriptions,
      userType: userType ?? this.userType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      number: number ?? this.number,
      email: email ?? this.email,
      languageID: languageID ?? this.languageID,
      language: language ?? this.language,
    );
  }
}

class Subscriptions {
  String? sId;
  String? plan;
  String? category;
  String? status;
  String? startDate;
  String? endDate;
  String? subscriptionType;
  int? subscriptionAmount;
  int? totalAmount;
  bool? isUpgrade;
  String? upgradeFromCategory;
  String? upgradeId;
  Null? upgradeSubscriptionId;
  String? createdAt;
  String? updatedAt;

  Subscriptions({this.sId, this.plan, this.category, this.status, this.startDate, this.endDate, this.subscriptionType, this.subscriptionAmount, this.totalAmount, this.isUpgrade, this.upgradeFromCategory, this.upgradeId, this.upgradeSubscriptionId, this.createdAt, this.updatedAt});

  Subscriptions.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    plan = json['plan'];
    category = json['category'];
    status = json['status'];
    startDate = json['startDate'];
    endDate = json['endDate'];
    subscriptionType = json['subscriptionType'];
    subscriptionAmount = json['subscriptionAmount'];
    totalAmount = json['totalAmount'];
    isUpgrade = json['isUpgrade'];
    upgradeFromCategory = json['upgradeFromCategory'];
    upgradeId = json['upgradeId'];
    upgradeSubscriptionId = json['upgradeSubscriptionId'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['plan'] = this.plan;
    data['category'] = this.category;
    data['status'] = this.status;
    data['startDate'] = this.startDate;
    data['endDate'] = this.endDate;
    data['subscriptionType'] = this.subscriptionType;
    data['subscriptionAmount'] = this.subscriptionAmount;
    data['totalAmount'] = this.totalAmount;
    data['isUpgrade'] = this.isUpgrade;
    data['upgradeFromCategory'] = this.upgradeFromCategory;
    data['upgradeId'] = this.upgradeId;
    data['upgradeSubscriptionId'] = this.upgradeSubscriptionId;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}



class UpdateProfileResponse {
  final bool status;
  final String message;

  UpdateProfileResponse({
    required this.status,
    required this.message,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
*/
