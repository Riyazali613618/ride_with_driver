class TransporterDriverProfileModel {
  final bool status;
  final String message;
  final UserProfileData data;

  TransporterDriverProfileModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TransporterDriverProfileModel.fromJson(Map<String, dynamic> json) {
    return TransporterDriverProfileModel(
      status: json['success'] ?? false,
      message: json['message'] ?? '',
      data: UserProfileData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class UserProfileData {
  final String? id;
  final String? mobileNumber;
  final DateTime? otpExpiry;
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
  final CityInfo? city;
  final String? companyName;
  final CountryInfo? country;
  final FleetCounts? counts;
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
  final LanguageInfo? language;
  final List<String>? languageSpoken;
  final String? lastName;
  final double? lat;
  final double? lng;
  final int? minimumCharges;
  final bool? negotiable;
  final DateTime? planExpiredDate;
  final bool? preferencesChat;
  final bool? preferencesPhone;
  final bool? preferencesWhatsapp;
  final String? profilePhoto;
  final double? rating;
  final ServiceLocation? serviceLocation;
  final StateInfo? state;
  final int? totalRating;
  final int? totalRatingSum;
  final DateTime? upgradeDate;
  final String? upgradedFromCategory;
  final List<String>? vehicleType;
  final List<Vehicle>? vehicles;
  final String? transportationPermit;

  UserProfileData({
    this.id,
    this.mobileNumber,
    this.otpExpiry,
    this.isVerifiedByAdmin,
    this.isBlockedByAdmin,
    this.usertype,
    this.refreshTokenExpiry,
    this.refreshTokenVersion,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.userId,
    this.aadharCardNumber,
    this.address,
    this.bio,
    this.businessMobileNumber,
    this.city,
    this.companyName,
    this.country,
    this.counts,
    this.coverImage,
    this.dob,
    this.drivingLicenceNumber,
    this.email,
    this.experience,
    this.fcmToken,
    this.firstName,
    this.fleetSize,
    this.gender,
    this.gstin,
    this.independentCarOwnerFleetSize,
    this.isUpgradeAccount,
    this.language,
    this.languageSpoken,
    this.lastName,
    this.lat,
    this.lng,
    this.minimumCharges,
    this.negotiable,
    this.planExpiredDate,
    this.preferencesChat,
    this.preferencesPhone,
    this.preferencesWhatsapp,
    this.profilePhoto,
    this.rating,
    this.serviceLocation,
    this.state,
    this.totalRating,
    this.totalRatingSum,
    this.upgradeDate,
    this.upgradedFromCategory,
    this.vehicleType,
    this.vehicles,
    this.transportationPermit,
  });

  factory UserProfileData.fromJson(Map<String, dynamic> json) {
    return UserProfileData(
      id: json['_id'],
      mobileNumber: json['mobileNumber'],
      otpExpiry: json['otpExpiry'] != null
          ? DateTime.parse(json['otpExpiry'])
          : null,
      isVerifiedByAdmin: json['isVerifiedByAdmin'],
      isBlockedByAdmin: json['isBlockedByAdmin'],
      usertype: json['usertype'],
      refreshTokenExpiry: json['refreshTokenExpiry'] != null
          ? DateTime.parse(json['refreshTokenExpiry'])
          : null,
      refreshTokenVersion: json['refreshTokenVersion'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      v: json['__v'],
      userId: json['userId'] != null
          ? UserId.fromJson(json['userId'])
          : null,
      aadharCardNumber: json['aadharCardNumber'],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      bio: json['bio'],
      businessMobileNumber: json['businessMobileNumber'],
      city: json['city'] != null
          ? CityInfo.fromJson(json['city'])
          : null,
      companyName: json['companyName'],
      country: json['country'] != null
          ? CountryInfo.fromJson(json['country'])
          : null,
      counts: json['counts'] != null
          ? FleetCounts.fromJson(json['counts'])
          : null,
      coverImage: json['coverImage'],
      dob: json['dob'],
      drivingLicenceNumber: json['drivingLicenceNumber'],
      email: json['email'],
      experience: json['experience'],
      fcmToken: json['fcmToken'],
      firstName: json['firstName'],
      fleetSize: json['fleetSize'],
      gender: json['gender'],
      gstin: json['gstin'],
      independentCarOwnerFleetSize: json['independentCarOwnerFleetSize'] != null
          ? IndependentCarOwnerFleetSize.fromJson(json['independentCarOwnerFleetSize'])
          : null,
      isUpgradeAccount: json['isUpgradeAccount'],
      language: json['language'] != null
          ? LanguageInfo.fromJson(json['language'])
          : null,
      languageSpoken: json['languageSpoken'] != null
          ? List<String>.from(json['languageSpoken'])
          : null,
      lastName: json['lastName'],
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
      minimumCharges: json['minimumCharges'],
      negotiable: json['negotiable'],
      planExpiredDate: json['planExpiredDate'] != null
          ? DateTime.parse(json['planExpiredDate'])
          : null,
      preferencesChat: json['preferencesChat'],
      preferencesPhone: json['preferencesPhone'],
      preferencesWhatsapp: json['preferencesWhatsapp'],
      profilePhoto: json['profilePhoto'],
      rating: json['rating']?.toDouble(),
      serviceLocation: json['serviceLocation'] != null
          ? ServiceLocation.fromJson(json['serviceLocation'])
          : null,
      state: json['state'] != null
          ? StateInfo.fromJson(json['state'])
          : null,
      totalRating: json['totalRating'],
      totalRatingSum: json['totalRatingSum'],
      upgradeDate: json['upgradeDate'] != null
          ? DateTime.parse(json['upgradeDate'])
          : null,
      upgradedFromCategory: json['upgradedFromCategory'],
      vehicleType: json['vehicleType'] != null
          ? List<String>.from(json['vehicleType'])
          : null,
      vehicles: json['vehicles'] != null
          ? List<Vehicle>.from(json['vehicles'].map((x) => Vehicle.fromJson(x)))
          : null,
      transportationPermit: json['transportationPermit'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['_id'] = id;
    if (mobileNumber != null) data['mobileNumber'] = mobileNumber;
    if (otpExpiry != null) data['otpExpiry'] = otpExpiry!.toIso8601String();
    if (isVerifiedByAdmin != null) data['isVerifiedByAdmin'] = isVerifiedByAdmin;
    if (isBlockedByAdmin != null) data['isBlockedByAdmin'] = isBlockedByAdmin;
    if (usertype != null) data['usertype'] = usertype;
    if (refreshTokenExpiry != null) data['refreshTokenExpiry'] = refreshTokenExpiry!.toIso8601String();
    if (refreshTokenVersion != null) data['refreshTokenVersion'] = refreshTokenVersion;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    if (v != null) data['__v'] = v;
    if (userId != null) data['userId'] = userId!.toJson();
    if (aadharCardNumber != null) data['aadharCardNumber'] = aadharCardNumber;
    if (address != null) data['address'] = address!.toJson();
    if (bio != null) data['bio'] = bio;
    if (businessMobileNumber != null) data['businessMobileNumber'] = businessMobileNumber;
    if (city != null) data['city'] = city!.toJson();
    if (companyName != null) data['companyName'] = companyName;
    if (country != null) data['country'] = country!.toJson();
    if (counts != null) data['counts'] = counts!.toJson();
    if (coverImage != null) data['coverImage'] = coverImage;
    if (dob != null) data['dob'] = dob;
    if (drivingLicenceNumber != null) data['drivingLicenceNumber'] = drivingLicenceNumber;
    if (email != null) data['email'] = email;
    if (experience != null) data['experience'] = experience;
    if (fcmToken != null) data['fcmToken'] = fcmToken;
    if (firstName != null) data['firstName'] = firstName;
    if (fleetSize != null) data['fleetSize'] = fleetSize;
    if (gender != null) data['gender'] = gender;
    if (gstin != null) data['gstin'] = gstin;
    if (independentCarOwnerFleetSize != null) data['independentCarOwnerFleetSize'] = independentCarOwnerFleetSize!.toJson();
    if (isUpgradeAccount != null) data['isUpgradeAccount'] = isUpgradeAccount;
    if (language != null) data['language'] = language!.toJson();
    if (languageSpoken != null) data['languageSpoken'] = languageSpoken;
    if (lastName != null) data['lastName'] = lastName;
    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;
    if (minimumCharges != null) data['minimumCharges'] = minimumCharges;
    if (negotiable != null) data['negotiable'] = negotiable;
    if (planExpiredDate != null) data['planExpiredDate'] = planExpiredDate!.toIso8601String();
    if (preferencesChat != null) data['preferencesChat'] = preferencesChat;
    if (preferencesPhone != null) data['preferencesPhone'] = preferencesPhone;
    if (preferencesWhatsapp != null) data['preferencesWhatsapp'] = preferencesWhatsapp;
    if (profilePhoto != null) data['profilePhoto'] = profilePhoto;
    if (rating != null) data['rating'] = rating;
    if (serviceLocation != null) data['serviceLocation'] = serviceLocation!.toJson();
    if (state != null) data['state'] = state!.toJson();
    if (totalRating != null) data['totalRating'] = totalRating;
    if (totalRatingSum != null) data['totalRatingSum'] = totalRatingSum;
    if (upgradeDate != null) data['upgradeDate'] = upgradeDate!.toIso8601String();
    if (upgradedFromCategory != null) data['upgradedFromCategory'] = upgradedFromCategory;
    if (vehicleType != null) data['vehicleType'] = vehicleType;
    if (vehicles != null) data['vehicles'] = vehicles!.map((x) => x.toJson()).toList();
    if (transportationPermit != null) data['transportationPermit'] = transportationPermit;

    return data;
  }
}

class UserId {
  final String? id;
  final String? mobileNumber;
  final bool? isVerifiedByAdmin;
  final bool? isBlockedByAdmin;
  final String? usertype;

  UserId({
    this.id,
    this.mobileNumber,
    this.isVerifiedByAdmin,
    this.isBlockedByAdmin,
    this.usertype,
  });

  factory UserId.fromJson(Map<String, dynamic> json) {
    return UserId(
      id: json['_id'],
      mobileNumber: json['mobileNumber'],
      isVerifiedByAdmin: json['isVerifiedByAdmin'],
      isBlockedByAdmin: json['isBlockedByAdmin'],
      usertype: json['usertype'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['_id'] = id;
    if (mobileNumber != null) data['mobileNumber'] = mobileNumber;
    if (isVerifiedByAdmin != null) data['isVerifiedByAdmin'] = isVerifiedByAdmin;
    if (isBlockedByAdmin != null) data['isBlockedByAdmin'] = isBlockedByAdmin;
    if (usertype != null) data['usertype'] = usertype;

    return data;
  }
}

class CityInfo {
  final String? id;
  final String? name;

  CityInfo({
    this.id,
    this.name,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;

    return data;
  }
}

class CountryInfo {
  final String? id;
  final String? name;
  final String? countryFlag;
  final String? countryFooter;

  CountryInfo({
    this.id,
    this.name,
    this.countryFlag,
    this.countryFooter,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      id: json['id'],
      name: json['name'],
      countryFlag: json['country_flag'],
      countryFooter: json['country_footer'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;
    if (countryFlag != null) data['country_flag'] = countryFlag;
    if (countryFooter != null) data['country_footer'] = countryFooter;

    return data;
  }
}

class StateInfo {
  final String? id;
  final String? name;

  StateInfo({
    this.id,
    this.name,
  });

  factory StateInfo.fromJson(Map<String, dynamic> json) {
    return StateInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;

    return data;
  }
}

class LanguageInfo {
  final String? id;
  final String? name;

  LanguageInfo({
    this.id,
    this.name,
  });

  factory LanguageInfo.fromJson(Map<String, dynamic> json) {
    return LanguageInfo(
      id: json['id'],
      name: json['name'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['id'] = id;
    if (name != null) data['name'] = name;

    return data;
  }
}

class ServiceLocation {
  final double? lat;
  final double? lng;

  ServiceLocation({
    this.lat,
    this.lng,
  });

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      lat: json['lat']?.toDouble(),
      lng: json['lng']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (lat != null) data['lat'] = lat;
    if (lng != null) data['lng'] = lng;

    return data;
  }
}

class Address {
  final String? addressLine;
  final String? city;
  final String? state;
  final int? pincode;
  final String? country;

  Address({
    this.addressLine,
    this.city,
    this.state,
    this.pincode,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine: json['addressLine'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (addressLine != null) data['addressLine'] = addressLine;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (pincode != null) data['pincode'] = pincode;
    if (country != null) data['country'] = country;

    return data;
  }
}

class FleetCounts {
  final int? car;
  final int? bus;
  final int? minivan;

  FleetCounts({
    this.car,
    this.bus,
    this.minivan,
  });

  factory FleetCounts.fromJson(Map<String, dynamic> json) {
    return FleetCounts(
      car: json['car'],
      bus: json['bus'],
      minivan: json['minivan'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (car != null) data['car'] = car;
    if (bus != null) data['bus'] = bus;
    if (minivan != null) data['minivan'] = minivan;

    return data;
  }
}

class IndependentCarOwnerFleetSize {
  final int? cars;
  final int? minivans;

  IndependentCarOwnerFleetSize({
    this.cars,
    this.minivans,
  });

  factory IndependentCarOwnerFleetSize.fromJson(Map<String, dynamic> json) {
    return IndependentCarOwnerFleetSize(
      cars: json['cars'],
      minivans: json['minivans'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (cars != null) data['cars'] = cars;
    if (minivans != null) data['minivans'] = minivans;

    return data;
  }
}

class Vehicle {
  final String? id;
  final String? userId;
  final String? uuid;
  final String? vehicleOwnership;
  final String? vehicleName;
  final String? vehicleModelName;
  final String? manufacturing;
  final String? maxPower;
  final String? maxSpeed;
  final String? fuelType;
  final int? first2Km;
  final String? milage;
  final String? registrationDate;
  final String? airConditioning;
  final String? vehicleType;
  final int? seatingCapacity;
  final String? vehicleNumber;
  final List<String>? vehicleSpecifications;
  final List<String>? servedLocation;
  final int? minimumChargePerHour;
  final String? currency;
  final List<String>? images;
  final List<String>? videos;
  final bool? isPriceNegotiable;
  final String? rcBookFrontPhoto;
  final String? rcBookBackPhoto;
  final String? driverLicensePhoto;
  final String? driverLicenseNumber;
  final String? aadharCardPhoto;
  final String? aadharCardPhotoBack;
  final String? aadharCardNumber;
  final String? panCardPhoto;
  final String? panCardNumber;
  final VehicleDetails? details;
  final bool? isVerifiedByAdmin;
  final bool? isBlockedByAdmin;
  final bool? isDeleted;
  final bool? isDisabled;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? v;

  Vehicle({
    this.id,
    this.userId,
    this.uuid,
    this.vehicleOwnership,
    this.vehicleName,
    this.vehicleModelName,
    this.manufacturing,
    this.maxPower,
    this.maxSpeed,
    this.fuelType,
    this.first2Km,
    this.milage,
    this.registrationDate,
    this.airConditioning,
    this.vehicleType,
    this.seatingCapacity,
    this.vehicleNumber,
    this.vehicleSpecifications,
    this.servedLocation,
    this.minimumChargePerHour,
    this.currency,
    this.images,
    this.videos,
    this.isPriceNegotiable,
    this.rcBookFrontPhoto,
    this.rcBookBackPhoto,
    this.driverLicensePhoto,
    this.driverLicenseNumber,
    this.aadharCardPhoto,
    this.aadharCardPhotoBack,
    this.aadharCardNumber,
    this.panCardPhoto,
    this.panCardNumber,
    this.details,
    this.isVerifiedByAdmin,
    this.isBlockedByAdmin,
    this.isDeleted,
    this.isDisabled,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'],
      userId: json['userId'],
      uuid: json['uuid'],
      vehicleOwnership: json['vehicleOwnership'],
      vehicleName: json['vehicleName'],
      vehicleModelName: json['vehicleModelName'],
      manufacturing: json['manufacturing'],
      maxPower: json['maxPower'],
      maxSpeed: json['maxSpeed'],
      fuelType: json['fuelType'],
      first2Km: json['first2Km'],
      milage: json['milage'],
      registrationDate: json['registrationDate'],
      airConditioning: json['airConditioning'],
      vehicleType: json['vehicleType'],
      seatingCapacity: json['seatingCapacity'],
      vehicleNumber: json['vehicleNumber'],
      vehicleSpecifications: json['vehicleSpecifications'] != null
          ? List<String>.from(json['vehicleSpecifications'])
          : null,
      servedLocation: json['servedLocation'] != null
          ? List<String>.from(json['servedLocation'])
          : null,
      minimumChargePerHour: json['minimumChargePerHour'],
      currency: json['currency'],
      images: json['images'] != null
          ? List<String>.from(json['images'])
          : null,
      videos: json['videos'] != null
          ? List<String>.from(json['videos'])
          : null,
      isPriceNegotiable: json['isPriceNegotiable'],
      rcBookFrontPhoto: json['rcBookFrontPhoto'],
      rcBookBackPhoto: json['rcBookBackPhoto'],
      driverLicensePhoto: json['driverLicensePhoto'],
      driverLicenseNumber: json['driverLicenseNumber'],
      aadharCardPhoto: json['aadharCardPhoto'],
      aadharCardPhotoBack: json['aadharCardPhotoBack'],
      aadharCardNumber: json['aadharCardNumber'],
      panCardPhoto: json['panCardPhoto'],
      panCardNumber: json['panCardNumber'],
      details: json['details'] != null
          ? VehicleDetails.fromJson(json['details'])
          : null,
      isVerifiedByAdmin: json['isVerifiedByAdmin'],
      isBlockedByAdmin: json['isBlockedByAdmin'],
      isDeleted: json['isDeleted'],
      isDisabled: json['isDisabled'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      v: json['__v'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (id != null) data['_id'] = id;
    if (userId != null) data['userId'] = userId;
    if (uuid != null) data['uuid'] = uuid;
    if (vehicleOwnership != null) data['vehicleOwnership'] = vehicleOwnership;
    if (vehicleName != null) data['vehicleName'] = vehicleName;
    if (vehicleModelName != null) data['vehicleModelName'] = vehicleModelName;
    if (manufacturing != null) data['manufacturing'] = manufacturing;
    if (maxPower != null) data['maxPower'] = maxPower;
    if (maxSpeed != null) data['maxSpeed'] = maxSpeed;
    if (fuelType != null) data['fuelType'] = fuelType;
    if (first2Km != null) data['first2Km'] = first2Km;
    if (milage != null) data['milage'] = milage;
    if (registrationDate != null) data['registrationDate'] = registrationDate;
    if (airConditioning != null) data['airConditioning'] = airConditioning;
    if (vehicleType != null) data['vehicleType'] = vehicleType;
    if (seatingCapacity != null) data['seatingCapacity'] = seatingCapacity;
    if (vehicleNumber != null) data['vehicleNumber'] = vehicleNumber;
    if (vehicleSpecifications != null) data['vehicleSpecifications'] = vehicleSpecifications;
    if (servedLocation != null) data['servedLocation'] = servedLocation;
    if (minimumChargePerHour != null) data['minimumChargePerHour'] = minimumChargePerHour;
    if (currency != null) data['currency'] = currency;
    if (images != null) data['images'] = images;
    if (videos != null) data['videos'] = videos;
    if (isPriceNegotiable != null) data['isPriceNegotiable'] = isPriceNegotiable;
    if (rcBookFrontPhoto != null) data['rcBookFrontPhoto'] = rcBookFrontPhoto;
    if (rcBookBackPhoto != null) data['rcBookBackPhoto'] = rcBookBackPhoto;
    if (driverLicensePhoto != null) data['driverLicensePhoto'] = driverLicensePhoto;
    if (driverLicenseNumber != null) data['driverLicenseNumber'] = driverLicenseNumber;
    if (aadharCardPhoto != null) data['aadharCardPhoto'] = aadharCardPhoto;
    if (aadharCardPhotoBack != null) data['aadharCardPhotoBack'] = aadharCardPhotoBack;
    if (aadharCardNumber != null) data['aadharCardNumber'] = aadharCardNumber;
    if (panCardPhoto != null) data['panCardPhoto'] = panCardPhoto;
    if (panCardNumber != null) data['panCardNumber'] = panCardNumber;
    if (details != null) data['details'] = details!.toJson();
    if (isVerifiedByAdmin != null) data['isVerifiedByAdmin'] = isVerifiedByAdmin;
    if (isBlockedByAdmin != null) data['isBlockedByAdmin'] = isBlockedByAdmin;
    if (isDeleted != null) data['isDeleted'] = isDeleted;
    if (isDisabled != null) data['isDisabled'] = isDisabled;
    if (createdAt != null) data['createdAt'] = createdAt!.toIso8601String();
    if (updatedAt != null) data['updatedAt'] = updatedAt!.toIso8601String();
    if (v != null) data['__v'] = v;

    return data;
  }
}

class VehicleDetails {
  final String? fullName;
  final String? mobileNumber;
  final String? profilePhoto;
  final List<String>? languageSpoken;
  final String? bio;
  final int? experience;
  final Address? address;
  final DateTime? planExpiredDate;
  final double? rating;
  final int? totalRating;
  final int? totalRatingSum;

  VehicleDetails({
    this.fullName,
    this.mobileNumber,
    this.profilePhoto,
    this.languageSpoken,
    this.bio,
    this.experience,
    this.address,
    this.planExpiredDate,
    this.rating,
    this.totalRating,
    this.totalRatingSum,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      profilePhoto: json['profilePhoto'],
      languageSpoken: json['languageSpoken'] != null
          ? List<String>.from(json['languageSpoken'])
          : null,
      bio: json['bio'],
      experience: json['experience'],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : null,
      planExpiredDate: json['planExpiredDate'] != null
          ? DateTime.parse(json['planExpiredDate'])
          : null,
      rating: json['rating']?.toDouble(),
      totalRating: json['totalRating'],
      totalRatingSum: json['totalRatingSum'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};

    if (fullName != null) data['fullName'] = fullName;
    if (mobileNumber != null) data['mobileNumber'] = mobileNumber;
    if (profilePhoto != null) data['profilePhoto'] = profilePhoto;
    if (languageSpoken != null) data['languageSpoken'] = languageSpoken;
    if (bio != null) data['bio'] = bio;
    if (experience != null) data['experience'] = experience;
    if (address != null) data['address'] = address!.toJson();
    if (planExpiredDate != null) data['planExpiredDate'] = planExpiredDate!.toIso8601String();
    if (rating != null) data['rating'] = rating;
    if (totalRating != null) data['totalRating'] = totalRating;
    if (totalRatingSum != null) data['totalRatingSum'] = totalRatingSum;

    return data;
  }
}