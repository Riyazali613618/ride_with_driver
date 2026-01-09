class MyProfileModel {
  MyProfileModel({
    required this.success,
    required this.message,
    required this.data,
  });

  final bool? success;
  final String? message;
  final MyProfileData? data;

  MyProfileModel copyWith({
    bool? success,
    String? message,
    MyProfileData? data,
  }) {
    return MyProfileModel(
      success: success ?? this.success,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  factory MyProfileModel.fromJson(Map<String, dynamic> json) {
    return MyProfileModel(
      success: json["success"],
      message: json["message"],
      data: json["data"] == null ? null : MyProfileData.fromJson(json["data"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": data?.toJson(),
      };

  @override
  String toString() {
    return "$success, $message, $data, ";
  }
}

class MyProfileData {
  MyProfileData({
    required this.id,
    required this.mobileNumber,
    required this.otpExpiry,
    required this.isVerifiedByAdmin,
    required this.isBlockedByAdmin,
    required this.usertype,
    required this.refreshTokenExpiry,
    required this.refreshTokenVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    required this.userId,
    required this.aadharCardNumber,
    required this.address,
    required this.bio,
    required this.businessMobileNumber,
    required this.city,
    required this.companyName,
    required this.country,
    required this.counts,
    required this.coverImage,
    required this.dob,
    required this.drivingLicenceNumber,
    required this.email,
    required this.experience,
    required this.fcmToken,
    required this.firstName,
    required this.fleetSize,
    required this.gender,
    required this.gstin,
    required this.independentCarOwnerFleetSize,
    required this.isUpgradeAccount,
    required this.language,
    required this.languageSpoken,
    required this.lastName,
    required this.lat,
    required this.lng,
    required this.minimumCharges,
    required this.negotiable,
    required this.preferencesChat,
    required this.preferencesPhone,
    required this.preferencesWhatsapp,
    required this.profilePhoto,
    required this.rating,
    required this.serviceLocation,
    required this.state,
    required this.totalRating,
    required this.totalRatingSum,
    required this.upgradeDate,
    required this.upgradedFromCategory,
    required this.vehicleType,
    required this.upgradeId,
    required this.upgradeSubscriptionId,
    required this.vehicles,
    required this.transportationPermit,
    required this.aadharCardFront,
    required this.aadharCardBack,
    required this.subscriptions,
    required this.activeSubscriptions,
    required this.expiredSubscriptions,
    required this.renewalSubscriptions,
    required this.addonVehicles,
    required this.vehicleLimit,
  });

  final String? id;
  final String? mobileNumber;
  final dynamic otpExpiry;
  final bool? isVerifiedByAdmin;
  final bool? isBlockedByAdmin;
  final String? usertype;
  final DateTime? refreshTokenExpiry;
  final int? refreshTokenVersion;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;
  final UserId? userId;
  final String? aadharCardNumber;
  final Address? address;
  final String? bio;
  final String? businessMobileNumber;
  final MyCity? city;
  final String? companyName;
  final Country? country;
  final Counts? counts;
  final String? coverImage;
  final String? dob;
  final String? drivingLicenceNumber;
  final String? email;
  final int? experience;
  final String? fcmToken;
  final String? firstName;
  final String? fleetSize;
  final String? gender;
  final String? gstin;
  final IndependentCarOwnerFleetSize? independentCarOwnerFleetSize;
  final bool? isUpgradeAccount;
  final Language? language;
  final List<dynamic> languageSpoken;
  final String? lastName;
  final dynamic lat;
  final dynamic lng;
  final int? minimumCharges;
  final bool? negotiable;
  final bool? preferencesChat;
  final bool? preferencesPhone;
  final bool? preferencesWhatsapp;
  final String? profilePhoto;
  final int? rating;
  final ServiceLocation? serviceLocation;
  final MyState? state;
  final int? totalRating;
  final int? totalRatingSum;
  final DateTime? upgradeDate;
  final String? upgradedFromCategory;
  final List<dynamic> vehicleType;
  final dynamic upgradeId;
  final dynamic upgradeSubscriptionId;
  final List<Vehicle> vehicles;
  final String? transportationPermit;
  final String? aadharCardFront;
  final String? aadharCardBack;
  final List<Subscription> subscriptions;
  final List<Subscription> activeSubscriptions;
  final List<Subscription> expiredSubscriptions;
  final List<dynamic> renewalSubscriptions;
  final List<AddOnVehicles>? addonVehicles;
  final int? vehicleLimit;

  MyProfileData copyWith({
    String? id,
    String? mobileNumber,
    dynamic? otpExpiry,
    bool? isVerifiedByAdmin,
    bool? isBlockedByAdmin,
    String? usertype,
    DateTime? refreshTokenExpiry,
    int? refreshTokenVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
    UserId? userId,
    String? aadharCardNumber,
    Address? address,
    String? bio,
    String? businessMobileNumber,
    MyCity? city,
    String? companyName,
    Country? country,
    Counts? counts,
    String? coverImage,
    String? dob,
    String? drivingLicenceNumber,
    String? email,
    int? experience,
    String? fcmToken,
    String? firstName,
    String? fleetSize,
    String? gender,
    String? gstin,
    IndependentCarOwnerFleetSize? independentCarOwnerFleetSize,
    bool? isUpgradeAccount,
    Language? language,
    List<dynamic>? languageSpoken,
    String? lastName,
    dynamic? lat,
    dynamic? lng,
    int? minimumCharges,
    bool? negotiable,
    bool? preferencesChat,
    bool? preferencesPhone,
    bool? preferencesWhatsapp,
    String? profilePhoto,
    int? rating,
    ServiceLocation? serviceLocation,
    MyState? state,
    int? totalRating,
    int? totalRatingSum,
    DateTime? upgradeDate,
    String? upgradedFromCategory,
    List<dynamic>? vehicleType,
    dynamic? upgradeId,
    dynamic? upgradeSubscriptionId,
    List<Vehicle>? vehicles,
    String? transportationPermit,
    String? aadharCardFront,
    String? aadharCardBack,
    List<Subscription>? subscriptions,
    List<Subscription>? activeSubscriptions,
    List<Subscription>? expiredSubscriptions,
    List<dynamic>? renewalSubscriptions,
    List<AddOnVehicles>? addonVehicles,
    int? vehicleLimit,
  }) {
    return MyProfileData(
      id: id ?? this.id,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      otpExpiry: otpExpiry ?? this.otpExpiry,
      isVerifiedByAdmin: isVerifiedByAdmin ?? this.isVerifiedByAdmin,
      isBlockedByAdmin: isBlockedByAdmin ?? this.isBlockedByAdmin,
      usertype: usertype ?? this.usertype,
      refreshTokenExpiry: refreshTokenExpiry ?? this.refreshTokenExpiry,
      refreshTokenVersion: refreshTokenVersion ?? this.refreshTokenVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
      userId: userId ?? this.userId,
      aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
      address: address ?? this.address,
      bio: bio ?? this.bio,
      businessMobileNumber: businessMobileNumber ?? this.businessMobileNumber,
      city: city ?? this.city,
      companyName: companyName ?? this.companyName,
      country: country ?? this.country,
      counts: counts ?? this.counts,
      coverImage: coverImage ?? this.coverImage,
      dob: dob ?? this.dob,
      drivingLicenceNumber: drivingLicenceNumber ?? this.drivingLicenceNumber,
      email: email ?? this.email,
      experience: experience ?? this.experience,
      fcmToken: fcmToken ?? this.fcmToken,
      firstName: firstName ?? this.firstName,
      fleetSize: fleetSize ?? this.fleetSize,
      gender: gender ?? this.gender,
      gstin: gstin ?? this.gstin,
      independentCarOwnerFleetSize:
          independentCarOwnerFleetSize ?? this.independentCarOwnerFleetSize,
      isUpgradeAccount: isUpgradeAccount ?? this.isUpgradeAccount,
      language: language ?? this.language,
      languageSpoken: languageSpoken ?? this.languageSpoken,
      lastName: lastName ?? this.lastName,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      minimumCharges: minimumCharges ?? this.minimumCharges,
      negotiable: negotiable ?? this.negotiable,
      preferencesChat: preferencesChat ?? this.preferencesChat,
      preferencesPhone: preferencesPhone ?? this.preferencesPhone,
      preferencesWhatsapp: preferencesWhatsapp ?? this.preferencesWhatsapp,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      rating: rating ?? this.rating,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      state: state ?? this.state,
      totalRating: totalRating ?? this.totalRating,
      totalRatingSum: totalRatingSum ?? this.totalRatingSum,
      upgradeDate: upgradeDate ?? this.upgradeDate,
      upgradedFromCategory: upgradedFromCategory ?? this.upgradedFromCategory,
      vehicleType: vehicleType ?? this.vehicleType,
      upgradeId: upgradeId ?? this.upgradeId,
      upgradeSubscriptionId:
          upgradeSubscriptionId ?? this.upgradeSubscriptionId,
      vehicles: vehicles ?? this.vehicles,
      transportationPermit: transportationPermit ?? this.transportationPermit,
      aadharCardFront: aadharCardFront ?? this.aadharCardFront,
      aadharCardBack: aadharCardBack ?? this.aadharCardBack,
      subscriptions: subscriptions ?? this.subscriptions,
      activeSubscriptions: activeSubscriptions ?? this.activeSubscriptions,
      expiredSubscriptions: expiredSubscriptions ?? this.expiredSubscriptions,
      renewalSubscriptions: renewalSubscriptions ?? this.renewalSubscriptions,
      addonVehicles: addonVehicles ?? this.addonVehicles,
      vehicleLimit: vehicleLimit ?? this.vehicleLimit,
    );
  }

  factory MyProfileData.fromJson(Map<String, dynamic> json) {
    return MyProfileData(
      id: json["_id"],
      mobileNumber: json["mobileNumber"],
      otpExpiry: json["otpExpiry"],
      isVerifiedByAdmin: json["isVerifiedByAdmin"],
      isBlockedByAdmin: json["isBlockedByAdmin"],
      usertype: json["usertype"],
      refreshTokenExpiry: DateTime.tryParse(json["refreshTokenExpiry"] ?? ""),
      refreshTokenVersion: json["refreshTokenVersion"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
      userId: json["userId"] == null ? null : UserId.fromJson(json["userId"]),
      aadharCardNumber: json["aadharCardNumber"],
      address:
          json["address"] == null ? null : Address.fromJson(json["address"]),
      bio: json["bio"],
      businessMobileNumber: json["businessMobileNumber"],
      city: json["city"] == null ? null : MyCity.fromJson(json["city"]),
      companyName: json["companyName"],
      country:
          json["country"] == null ? null : Country.fromJson(json["country"]),
      counts: json["counts"] == null ? null : Counts.fromJson(json["counts"]),
      coverImage: json["coverImage"],
      dob: json["dob"],
      drivingLicenceNumber: json["drivingLicenceNumber"],
      email: json["email"],
      experience: json["experience"],
      fcmToken: json["fcmToken"],
      firstName: json["firstName"],
      fleetSize: json["fleetSize"],
      gender: json["gender"],
      gstin: json["gstin"],
      independentCarOwnerFleetSize: json["independentCarOwnerFleetSize"] == null
          ? null
          : IndependentCarOwnerFleetSize.fromJson(
              json["independentCarOwnerFleetSize"]),
      isUpgradeAccount: json["isUpgradeAccount"],
      language:
          json["language"] == null ? null : Language.fromJson(json["language"]),
      languageSpoken: json["languageSpoken"] == null
          ? []
          : List<dynamic>.from(json["languageSpoken"]!.map((x) => x)),
      lastName: json["lastName"],
      lat: json["lat"],
      lng: json["lng"],
      minimumCharges: json["minimumCharges"],
      negotiable: json["negotiable"],
      preferencesChat: json["preferencesChat"],
      preferencesPhone: json["preferencesPhone"],
      preferencesWhatsapp: json["preferencesWhatsapp"],
      profilePhoto: json["profilePhoto"],
      rating: json["rating"],
      serviceLocation: json["serviceLocation"] == null
          ? null
          : ServiceLocation.fromJson(json["serviceLocation"]),
      state: json["state"] == null ? null : MyState.fromJson(json["state"]),
      totalRating: json["totalRating"],
      totalRatingSum: json["totalRatingSum"],
      upgradeDate: DateTime.tryParse(json["upgradeDate"] ?? ""),
      upgradedFromCategory: json["upgradedFromCategory"],
      vehicleType: json["vehicleType"] == null
          ? []
          : List<dynamic>.from(json["vehicleType"]!.map((x) => x)),
      upgradeId: json["upgradeId"],
      upgradeSubscriptionId: json["upgradeSubscriptionId"],
      vehicles: json["vehicles"] == null
          ? []
          : List<Vehicle>.from(
              json["vehicles"]!.map((x) => Vehicle.fromJson(x))),
      transportationPermit: json["transportationPermit"],
      aadharCardFront: json["aadharCardFront"],
      aadharCardBack: json["aadharCardBack"],
      subscriptions: json["subscriptions"] == null
          ? []
          : List<Subscription>.from(
              json["subscriptions"]!.map((x) => Subscription.fromJson(x))),
      activeSubscriptions: json["active_subscriptions"] == null
          ? []
          : List<Subscription>.from(json["active_subscriptions"]!
              .map((x) => Subscription.fromJson(x))),
      expiredSubscriptions: json["expired_subscriptions"] == null
          ? []
          : List<Subscription>.from(json["expired_subscriptions"]!
              .map((x) => Subscription.fromJson(x))),
      renewalSubscriptions: json["renewal_subscriptions"] == null
          ? []
          : List<dynamic>.from(json["renewal_subscriptions"]!.map((x) => x)),
      addonVehicles: json["addonVehicles"] == null
          ? []
          : List<AddOnVehicles>.from(json["addonVehicles"]!.map((x) => AddOnVehicles.fromJson(x))),
      vehicleLimit: json["vehicleLimit"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "mobileNumber": mobileNumber,
        "otpExpiry": otpExpiry,
        "isVerifiedByAdmin": isVerifiedByAdmin,
        "isBlockedByAdmin": isBlockedByAdmin,
        "usertype": usertype,
        "refreshTokenExpiry": refreshTokenExpiry?.toIso8601String(),
        "refreshTokenVersion": refreshTokenVersion,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
        "userId": userId?.toJson(),
        "aadharCardNumber": aadharCardNumber,
        "address": address?.toJson(),
        "bio": bio,
        "businessMobileNumber": businessMobileNumber,
        "city": city?.toJson(),
        "companyName": companyName,
        "country": country?.toJson(),
        "counts": counts?.toJson(),
        "coverImage": coverImage,
        "dob": dob,
        "drivingLicenceNumber": drivingLicenceNumber,
        "email": email,
        "experience": experience,
        "fcmToken": fcmToken,
        "firstName": firstName,
        "fleetSize": fleetSize,
        "gender": gender,
        "gstin": gstin,
        "independentCarOwnerFleetSize": independentCarOwnerFleetSize?.toJson(),
        "isUpgradeAccount": isUpgradeAccount,
        "language": language?.toJson(),
        "languageSpoken": languageSpoken.map((x) => x).toList(),
        "lastName": lastName,
        "lat": lat,
        "lng": lng,
        "minimumCharges": minimumCharges,
        "negotiable": negotiable,
        "preferencesChat": preferencesChat,
        "preferencesPhone": preferencesPhone,
        "preferencesWhatsapp": preferencesWhatsapp,
        "profilePhoto": profilePhoto,
        "rating": rating,
        "serviceLocation": serviceLocation?.toJson(),
        "state": state?.toJson(),
        "totalRating": totalRating,
        "totalRatingSum": totalRatingSum,
        "upgradeDate": upgradeDate?.toIso8601String(),
        "upgradedFromCategory": upgradedFromCategory,
        "vehicleType": vehicleType.map((x) => x).toList(),
        "upgradeId": upgradeId,
        "upgradeSubscriptionId": upgradeSubscriptionId,
        "vehicles": vehicles.map((x) => x?.toJson()).toList(),
        "transportationPermit": transportationPermit,
        "aadharCardFront": aadharCardFront,
        "aadharCardBack": aadharCardBack,
        "subscriptions": subscriptions.map((x) => x?.toJson()).toList(),
        "active_subscriptions":
            activeSubscriptions.map((x) => x?.toJson()).toList(),
        "expired_subscriptions":
            expiredSubscriptions.map((x) => x?.toJson()).toList(),
        "renewal_subscriptions": renewalSubscriptions.map((x) => x).toList(),
        "addonVehicles": addonVehicles?.map((x) => x).toList()??[],
        "vehicleLimit": vehicleLimit,
      };

  @override
  String toString() {
    return "$id, $mobileNumber, $otpExpiry, $isVerifiedByAdmin, $isBlockedByAdmin, $usertype, $refreshTokenExpiry, $refreshTokenVersion, $createdAt, $updatedAt, $v, $userId, $aadharCardNumber, $address, $bio, $businessMobileNumber, $city, $companyName, $country, $counts, $coverImage, $dob, $drivingLicenceNumber, $email, $experience, $fcmToken, $firstName, $fleetSize, $gender, $gstin, $independentCarOwnerFleetSize, $isUpgradeAccount, $language, $languageSpoken, $lastName, $lat, $lng, $minimumCharges, $negotiable, $preferencesChat, $preferencesPhone, $preferencesWhatsapp, $profilePhoto, $rating, $serviceLocation, $state, $totalRating, $totalRatingSum, $upgradeDate, $upgradedFromCategory, $vehicleType, $upgradeId, $upgradeSubscriptionId, $vehicles, $transportationPermit, $aadharCardFront, $aadharCardBack, $subscriptions, $activeSubscriptions, $expiredSubscriptions, $renewalSubscriptions, $addonVehicles, $vehicleLimit, ";
  }
}

class Subscription {
  Subscription({
    required this.id,
    required this.plan,
    required this.maxVehicles,
    required this.category,
    required this.status,
    required this.orderId,
    required this.startDate,
    required this.endDate,
    required this.subscriptionType,
    required this.subscriptionAmount,
    required this.totalAmount,
    required this.isUpgrade,
    required this.upgradeFromCategory,
    required this.upgradeId,
    required this.upgradeSubscriptionId,
    required this.createdAt,
    required this.updatedAt,
  });

  final String? id;
  final String? plan;
  final int? maxVehicles;
  final String? category;
  final String? status;
  final String? orderId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? subscriptionType;
  final int? subscriptionAmount;
  final int? totalAmount;
  final bool? isUpgrade;
  final String? upgradeFromCategory;
  final String? upgradeId;
  final dynamic upgradeSubscriptionId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Subscription copyWith({
    String? id,
    String? plan,
    int? maxVehicles,
    String? category,
    String? status,
    String? orderId,
    DateTime? startDate,
    DateTime? endDate,
    String? subscriptionType,
    int? subscriptionAmount,
    int? totalAmount,
    bool? isUpgrade,
    String? upgradeFromCategory,
    String? upgradeId,
    dynamic? upgradeSubscriptionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Subscription(
      id: id ?? this.id,
      plan: plan ?? this.plan,
      maxVehicles: maxVehicles ?? this.maxVehicles,
      category: category ?? this.category,
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      subscriptionType: subscriptionType ?? this.subscriptionType,
      subscriptionAmount: subscriptionAmount ?? this.subscriptionAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      isUpgrade: isUpgrade ?? this.isUpgrade,
      upgradeFromCategory: upgradeFromCategory ?? this.upgradeFromCategory,
      upgradeId: upgradeId ?? this.upgradeId,
      upgradeSubscriptionId:
          upgradeSubscriptionId ?? this.upgradeSubscriptionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Subscription.fromJson(Map<String, dynamic> json) {
    return Subscription(
      id: json["_id"],
      plan: json["plan"],
      maxVehicles: json["max_vehicles"],
      category: json["category"],
      status: json["status"],
      orderId: json["orderId"],
      startDate: DateTime.tryParse(json["startDate"] ?? ""),
      endDate: DateTime.tryParse(json["endDate"] ?? ""),
      subscriptionType: json["subscriptionType"],
      subscriptionAmount: json["subscriptionAmount"],
      totalAmount: json["totalAmount"],
      isUpgrade: json["isUpgrade"],
      upgradeFromCategory: json["upgradeFromCategory"],
      upgradeId: json["upgradeId"],
      upgradeSubscriptionId: json["upgradeSubscriptionId"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "plan": plan,
        "max_vehicles": maxVehicles,
        "category": category,
        "status": status,
        "orderId": orderId,
        "startDate": startDate?.toIso8601String(),
        "endDate": endDate?.toIso8601String(),
        "subscriptionType": subscriptionType,
        "subscriptionAmount": subscriptionAmount,
        "totalAmount": totalAmount,
        "isUpgrade": isUpgrade,
        "upgradeFromCategory": upgradeFromCategory,
        "upgradeId": upgradeId,
        "upgradeSubscriptionId": upgradeSubscriptionId,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };

  @override
  String toString() {
    return "$id, $plan, $maxVehicles, $category, $status, $orderId, $startDate, $endDate, $subscriptionType, $subscriptionAmount, $totalAmount, $isUpgrade, $upgradeFromCategory, $upgradeId, $upgradeSubscriptionId, $createdAt, $updatedAt, ";
  }
}

class Address {
  Address({
    required this.addressLine,
    required this.pincode,
    required this.city,
    required this.state,
  });

  final String? addressLine;
  final int? pincode;
  final String? city;
  final String? state;

  Address copyWith({
    String? addressLine,
    int? pincode,
    String? city,
    String? state,
  }) {
    return Address(
      addressLine: addressLine ?? this.addressLine,
      pincode: pincode ?? this.pincode,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine: json["addressLine"],
      pincode: json["pincode"],
      city: json["city"],
      state: json["state"],
    );
  }

  Map<String, dynamic> toJson() => {
        "addressLine": addressLine,
        "pincode": pincode,
        "city": city,
        "state": state,
      };

  @override
  String toString() {
    return "$addressLine, $pincode, $city, $state, ";
  }
}

class AddOnVehicles {
  AddOnVehicles({
    required this.addOnVehicles,
  });

  final int? addOnVehicles;

  AddOnVehicles copyWith({
    int? addOnVehicles,
  }) {
    return AddOnVehicles(
      addOnVehicles: addOnVehicles ?? this.addOnVehicles,
    );
  }

  factory AddOnVehicles.fromJson(Map<String, dynamic> json) {
    return AddOnVehicles(
      addOnVehicles: json["addOnVehicles"],
    );
  }

  Map<String, dynamic> toJson() => {
        "addOnVehicles": addOnVehicles,
      };

  @override
  String toString() {
    return "$addOnVehicles, ";
  }
}

class MyCity {
  MyCity({
    required this.id,
    required this.name,
  });

  final String? id;
  final String? name;

  MyCity copyWith({
    String? id,
    String? name,
  }) {
    return MyCity(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory MyCity.fromJson(Map<String, dynamic> json) {
    return MyCity(
      id: json["id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };

  @override
  String toString() {
    return "$id, $name, ";
  }
}

class MyState {
  MyState({
    required this.id,
    required this.name,
  });

  final String? id;
  final String? name;

  MyState copyWith({
    String? id,
    String? name,
  }) {
    return MyState(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory MyState.fromJson(Map<String, dynamic> json) {
    return MyState(
      id: json["id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };

  @override
  String toString() {
    return "$id, $name, ";
  }
}

class Language {
  Language({
    required this.id,
    required this.name,
  });

  final String? id;
  final String? name;

  Language copyWith({
    String? id,
    String? name,
  }) {
    return Language(
      id: id ?? this.id,
      name: name ?? this.name,
    );
  }

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json["id"],
      name: json["name"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };

  @override
  String toString() {
    return "$id, $name, ";
  }
}

class Country {
  Country({
    required this.id,
    required this.name,
    required this.countryFlag,
    required this.countryFooter,
  });

  final String? id;
  final String? name;
  final dynamic countryFlag;
  final dynamic countryFooter;

  Country copyWith({
    String? id,
    String? name,
    dynamic? countryFlag,
    dynamic? countryFooter,
  }) {
    return Country(
      id: id ?? this.id,
      name: name ?? this.name,
      countryFlag: countryFlag ?? this.countryFlag,
      countryFooter: countryFooter ?? this.countryFooter,
    );
  }

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json["id"],
      name: json["name"],
      countryFlag: json["country_flag"],
      countryFooter: json["country_footer"],
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country_flag": countryFlag,
        "country_footer": countryFooter,
      };

  @override
  String toString() {
    return "$id, $name, $countryFlag, $countryFooter, ";
  }
}

class Counts {
  Counts({required this.json});

  final Map<String, dynamic> json;

  factory Counts.fromJson(Map<String, dynamic> json) {
    return Counts(json: json);
  }

  Map<String, dynamic> toJson() => {};

  @override
  String toString() {
    return "";
  }
}

class IndependentCarOwnerFleetSize {
  IndependentCarOwnerFleetSize({
    required this.cars,
    required this.minivans,
  });

  final int? cars;
  final int? minivans;

  IndependentCarOwnerFleetSize copyWith({
    int? cars,
    int? minivans,
  }) {
    return IndependentCarOwnerFleetSize(
      cars: cars ?? this.cars,
      minivans: minivans ?? this.minivans,
    );
  }

  factory IndependentCarOwnerFleetSize.fromJson(Map<String, dynamic> json) {
    return IndependentCarOwnerFleetSize(
      cars: json["cars"],
      minivans: json["minivans"],
    );
  }

  Map<String, dynamic> toJson() => {
        "cars": cars,
        "minivans": minivans,
      };

  @override
  String toString() {
    return "$cars, $minivans, ";
  }
}

class ServiceLocation {
  ServiceLocation({
    required this.lat,
    required this.lng,
  });

  final double? lat;
  final double? lng;

  ServiceLocation copyWith({
    double? lat,
    double? lng,
  }) {
    return ServiceLocation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
    );
  }

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      lat: json["lat"],
      lng: json["lng"],
    );
  }

  Map<String, dynamic> toJson() => {
        "lat": lat,
        "lng": lng,
      };

  @override
  String toString() {
    return "$lat, $lng, ";
  }
}

class UserId {
  UserId({
    required this.id,
    required this.mobileNumber,
    required this.isVerifiedByAdmin,
    required this.isBlockedByAdmin,
    required this.usertype,
  });

  final String? id;
  final String? mobileNumber;
  final bool? isVerifiedByAdmin;
  final bool? isBlockedByAdmin;
  final String? usertype;

  UserId copyWith({
    String? id,
    String? mobileNumber,
    bool? isVerifiedByAdmin,
    bool? isBlockedByAdmin,
    String? usertype,
  }) {
    return UserId(
      id: id ?? this.id,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      isVerifiedByAdmin: isVerifiedByAdmin ?? this.isVerifiedByAdmin,
      isBlockedByAdmin: isBlockedByAdmin ?? this.isBlockedByAdmin,
      usertype: usertype ?? this.usertype,
    );
  }

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      id: json["_id"],
      mobileNumber: json["mobileNumber"],
      isVerifiedByAdmin: json["isVerifiedByAdmin"],
      isBlockedByAdmin: json["isBlockedByAdmin"],
      usertype: json["usertype"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "mobileNumber": mobileNumber,
        "isVerifiedByAdmin": isVerifiedByAdmin,
        "isBlockedByAdmin": isBlockedByAdmin,
        "usertype": usertype,
      };

  @override
  String toString() {
    return "$id, $mobileNumber, $isVerifiedByAdmin, $isBlockedByAdmin, $usertype, ";
  }
}

class Vehicle {
  Vehicle({
    required this.id,
    required this.userId,
    required this.vehicleType,
    required this.vehicleName,
    required this.brandName,
    required this.vehicleNumber,
    required this.seatingCapacity,
    required this.airConditioning,
    required this.vehicleSpecifications,
    required this.serviceLocation,
    required this.minimumChargePerHour,
    required this.isPriceNegotiable,
    required this.images,
    required this.videos,
    required this.rcBookFrontPhoto,
    required this.rcBookBackPhoto,
    required this.isVerifiedByAdmin,
    required this.isBlockedByAdmin,
    required this.isDisabled,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  final String? id;
  final String? userId;
  final String? vehicleType;
  final String? vehicleName;
  final String? brandName;
  final String? vehicleNumber;
  final int? seatingCapacity;
  final String? airConditioning;
  final List<String> vehicleSpecifications;
  final ServiceLocation? serviceLocation;
  final int? minimumChargePerHour;
  final bool? isPriceNegotiable;
  final List<String> images;
  final List<dynamic> videos;
  final String? rcBookFrontPhoto;
  final String? rcBookBackPhoto;
  final bool? isVerifiedByAdmin;
  final bool? isBlockedByAdmin;
  final bool? isDisabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Vehicle copyWith({
    String? id,
    String? userId,
    String? vehicleType,
    String? vehicleName,
    String? brandName,
    String? vehicleNumber,
    int? seatingCapacity,
    String? airConditioning,
    List<String>? vehicleSpecifications,
    ServiceLocation? serviceLocation,
    int? minimumChargePerHour,
    bool? isPriceNegotiable,
    List<String>? images,
    List<dynamic>? videos,
    String? rcBookFrontPhoto,
    String? rcBookBackPhoto,
    bool? isVerifiedByAdmin,
    bool? isBlockedByAdmin,
    bool? isDisabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? v,
  }) {
    return Vehicle(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleName: vehicleName ?? this.vehicleName,
      brandName: brandName ?? this.brandName,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
      airConditioning: airConditioning ?? this.airConditioning,
      vehicleSpecifications:
          vehicleSpecifications ?? this.vehicleSpecifications,
      serviceLocation: serviceLocation ?? this.serviceLocation,
      minimumChargePerHour: minimumChargePerHour ?? this.minimumChargePerHour,
      isPriceNegotiable: isPriceNegotiable ?? this.isPriceNegotiable,
      images: images ?? this.images,
      videos: videos ?? this.videos,
      rcBookFrontPhoto: rcBookFrontPhoto ?? this.rcBookFrontPhoto,
      rcBookBackPhoto: rcBookBackPhoto ?? this.rcBookBackPhoto,
      isVerifiedByAdmin: isVerifiedByAdmin ?? this.isVerifiedByAdmin,
      isBlockedByAdmin: isBlockedByAdmin ?? this.isBlockedByAdmin,
      isDisabled: isDisabled ?? this.isDisabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      v: v ?? this.v,
    );
  }

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json["_id"],
      userId: json["userId"],
      vehicleType: json["vehicleType"],
      vehicleName: json["vehicleName"],
      brandName: json["brandName"],
      vehicleNumber: json["vehicleNumber"],
      seatingCapacity: json["seatingCapacity"],
      airConditioning: json["airConditioning"],
      vehicleSpecifications: json["vehicleSpecifications"] == null
          ? []
          : List<String>.from(json["vehicleSpecifications"]!.map((x) => x)),
      serviceLocation: json["serviceLocation"] == null
          ? null
          : ServiceLocation.fromJson(json["serviceLocation"]),
      minimumChargePerHour: json["minimumChargePerHour"],
      isPriceNegotiable: json["isPriceNegotiable"],
      images: json["images"] == null
          ? []
          : List<String>.from(json["images"]!.map((x) => x)),
      videos: json["videos"] == null
          ? []
          : List<dynamic>.from(json["videos"]!.map((x) => x)),
      rcBookFrontPhoto: json["rcBookFrontPhoto"],
      rcBookBackPhoto: json["rcBookBackPhoto"],
      isVerifiedByAdmin: json["isVerifiedByAdmin"],
      isBlockedByAdmin: json["isBlockedByAdmin"],
      isDisabled: json["isDisabled"],
      createdAt: DateTime.tryParse(json["createdAt"] ?? ""),
      updatedAt: DateTime.tryParse(json["updatedAt"] ?? ""),
      v: json["__v"],
    );
  }

  Map<String, dynamic> toJson() => {
        "_id": id,
        "userId": userId,
        "vehicleType": vehicleType,
        "vehicleName": vehicleName,
        "brandName": brandName,
        "vehicleNumber": vehicleNumber,
        "seatingCapacity": seatingCapacity,
        "airConditioning": airConditioning,
        "vehicleSpecifications": vehicleSpecifications.map((x) => x).toList(),
        "serviceLocation": serviceLocation?.toJson(),
        "minimumChargePerHour": minimumChargePerHour,
        "isPriceNegotiable": isPriceNegotiable,
        "images": images.map((x) => x).toList(),
        "videos": videos.map((x) => x).toList(),
        "rcBookFrontPhoto": rcBookFrontPhoto,
        "rcBookBackPhoto": rcBookBackPhoto,
        "isVerifiedByAdmin": isVerifiedByAdmin,
        "isBlockedByAdmin": isBlockedByAdmin,
        "isDisabled": isDisabled,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "__v": v,
      };

  @override
  String toString() {
    return "$id, $userId, $vehicleType, $vehicleName, $brandName, $vehicleNumber, $seatingCapacity, $airConditioning, $vehicleSpecifications, $serviceLocation, $minimumChargePerHour, $isPriceNegotiable, $images, $videos, $rcBookFrontPhoto, $rcBookBackPhoto, $isVerifiedByAdmin, $isBlockedByAdmin, $isDisabled, $createdAt, $updatedAt, $v, ";
  }
}
