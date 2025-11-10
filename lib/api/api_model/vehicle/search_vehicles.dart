class VehicleSearchResponse {
  final bool success;
  final String message;
  final VehicleSearchData data;

  VehicleSearchResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VehicleSearchResponse.fromJson(Map<String, dynamic> json) {
    return VehicleSearchResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: VehicleSearchData.fromJson(json['data'] ?? {}),
    );
  }
}

class VehicleSearchData {
  final List<VehicleOwner> results;
  final Pagination pagination;

  VehicleSearchData({
    required this.results,
    required this.pagination,
  });

  factory VehicleSearchData.fromJson(Map<String, dynamic> json) {
    return VehicleSearchData(
      results: (json['results'] as List<dynamic>?)
          ?.map((e) => VehicleOwner.fromJson(e))
          .toList() ??
          [],
      pagination: Pagination.fromJson(json['pagination'] ?? {}),
    );
  }
}

class VehicleOwner {
  final String id;
  final String userId;
  final String userType;
  final String firstName;
  final String lastName;
  final String profilePhoto;
  final String email;
  final String message;
  final bool isVerifiedByAdmin;
  final double rating;
  final String gstin;
  final String companyName;
  final String bio;
  final String fleetSize;
  final Counts counts;
  final Address address;
  final String businessMobileNumber;
  final String coverImage;
  final List<String> vehicleType;
  final Location serviceLocation;
  final List<String> languageSpoken;
  final int experience;
  final int minimumCharges;
  final bool negotiable;
  final String dob;
  final String gender;
  final int totalRating;
  final int totalRatingSum;
  final IndependentFleetSize independentCarOwnerFleetSize;
  final List<Vehicle> vehicles;
  final List<Review> reviews;
  final int reviewsTotal;
  final LanguageInfo? language;
  final CountryInfo? country;
  final StateInfo? state;
  final CityInfo? city;
  final String fcmToken;
  final bool preferencesWhatsapp;
  final bool preferencesPhone;
  final double lat;
  final double lng;

  VehicleOwner({
    required this.id,
    required this.userId,
    required this.userType,
    required this.firstName,
    required this.lastName,
    required this.profilePhoto,
    required this.email,
    required this.message,
    required this.isVerifiedByAdmin,
    required this.rating,
    required this.gstin,
    required this.companyName,
    required this.bio,
    required this.fleetSize,
    required this.counts,
    required this.address,
    required this.businessMobileNumber,
    required this.coverImage,
    required this.vehicleType,
    required this.serviceLocation,
    required this.languageSpoken,
    required this.experience,
    required this.minimumCharges,
    required this.negotiable,
    required this.dob,
    required this.gender,
    required this.totalRating,
    required this.totalRatingSum,
    required this.independentCarOwnerFleetSize,
    required this.vehicles,
    required this.reviews,
    required this.reviewsTotal,
    this.language,
    this.country,
    this.state,
    this.city,
    required this.fcmToken,
    required this.preferencesWhatsapp,
    required this.preferencesPhone,
    required this.lat,
    required this.lng,
  });

  factory VehicleOwner.fromJson(Map<String, dynamic> json) {
    return VehicleOwner(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      userType: json['userType'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      email: json['email'] ?? '',
      message: json['message'] ?? '',
      isVerifiedByAdmin: json['isVerifiedByAdmin'] ?? false,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      gstin: json['gstin'] ?? '',
      companyName: json['companyName'] ?? '',
      bio: json['bio'] ?? '',
      fleetSize: json['fleetSize'] ?? '',
      counts: Counts.fromJson(json['counts'] ?? {}),
      address: Address.fromJson(json['address'] ?? {}),
      businessMobileNumber: json['businessMobileNumber'] ?? '',
      coverImage: json['coverImage'] ?? '',
      vehicleType:
      (json['vehicleType'] as List<dynamic>?)?.cast<String>() ?? [],
      serviceLocation: Location.fromJson(json['serviceLocation'] ?? {}),
      languageSpoken:
      (json['languageSpoken'] as List<dynamic>?)?.cast<String>() ?? [],
      experience: json['experience'] ?? 0,
      minimumCharges: json['minimumCharges'] ?? 0,
      negotiable: json['negotiable'] ?? false,
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      totalRating: json['totalRating'] ?? 0,
      totalRatingSum: json['totalRatingSum'] ?? 0,
      independentCarOwnerFleetSize: IndependentFleetSize.fromJson(
          json['independentCarOwnerFleetSize'] ?? {}),
      vehicles: (json['vehicles'] as List<dynamic>?)
          ?.map((e) => Vehicle.fromJson(e))
          .toList() ??
          [],
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => Review.fromJson(e))
          .toList() ??
          [],
      reviewsTotal: json['reviewsTotal'] ?? 0,
      language: json['language'] != null
          ? LanguageInfo.fromJson(json['language'])
          : null,
      country:
      json['country'] != null ? CountryInfo.fromJson(json['country']) : null,
      state: json['state'] != null ? StateInfo.fromJson(json['state']) : null,
      city: json['city'] != null ? CityInfo.fromJson(json['city']) : null,
      fcmToken: json['fcmToken'] ?? '',
      preferencesWhatsapp: json['preferencesWhatsapp'] ?? false,
      preferencesPhone: json['preferencesPhone'] ?? false,
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LanguageInfo {
  final String id;
  final String? name;

  LanguageInfo({required this.id, this.name});

  factory LanguageInfo.fromJson(Map<String, dynamic> json) {
    return LanguageInfo(
      id: json['id'] ?? '',
      name: json['name'],
    );
  }
}

class CountryInfo {
  final String id;
  final String? name;
  final String? countryFlag;
  final String? countryFooter;

  CountryInfo({
    required this.id,
    this.name,
    this.countryFlag,
    this.countryFooter,
  });

  factory CountryInfo.fromJson(Map<String, dynamic> json) {
    return CountryInfo(
      id: json['id'] ?? '',
      name: json['name'],
      countryFlag: json['country_flag'],
      countryFooter: json['country_footer'],
    );
  }
}

class StateInfo {
  final String id;
  final String? name;

  StateInfo({required this.id, this.name});

  factory StateInfo.fromJson(Map<String, dynamic> json) {
    return StateInfo(
      id: json['id'] ?? '',
      name: json['name'],
    );
  }
}

class CityInfo {
  final String id;
  final String? name;

  CityInfo({required this.id, this.name});

  factory CityInfo.fromJson(Map<String, dynamic> json) {
    return CityInfo(
      id: json['id'] ?? '',
      name: json['name'],
    );
  }
}

class Counts {
  final int car;
  final int bus;
  final int minivan;

  Counts({required this.car, required this.bus, required this.minivan});

  factory Counts.fromJson(Map<String, dynamic> json) {
    return Counts(
      car: json['car'] ?? 0,
      bus: json['bus'] ?? 0,
      minivan: json['minivan'] ?? 0,
    );
  }
}

class Address {
  final String addressLine;
  final String state;
  final String city;
  final int? pincode;

  Address({
    required this.addressLine,
    required this.state,
    required this.city,
    this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine: json['addressLine'] ?? '',
      state: json['state'] ?? '',
      city: json['city'] ?? '',
      pincode: json['pincode'],
    );
  }
}

class Location {
  final double lat;
  final double lng;
  final String? name;

  Location({required this.lat, required this.lng, this.name});

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      name: json['name'],
    );
  }
}

class IndependentFleetSize {
  final int cars;
  final int minivans;

  IndependentFleetSize({required this.cars, required this.minivans});

  factory IndependentFleetSize.fromJson(Map<String, dynamic> json) {
    return IndependentFleetSize(
      cars: json['cars'] ?? 0,
      minivans: json['minivans'] ?? 0,
    );
  }
}

class Vehicle {
  final String id;
  final String userId;
  final String vehicleType;
  final String vehicleName;
  final String vehicleNumber;
  final int seatingCapacity;
  final String airConditioning;
  final List<String> vehicleSpecifications;
  final Location serviceLocation;
  final int minimumChargePerHour;
  final bool isPriceNegotiable;
  final List<String> images;
  final List<String> videos;
  final String rcBookFrontPhoto;
  final String rcBookBackPhoto;
  final bool isVerifiedByAdmin;
  final bool isBlockedByAdmin;
  final bool isDisabled;
  final String? createdAt;
  final String? updatedAt;

  Vehicle({
    required this.id,
    required this.userId,
    required this.vehicleType,
    required this.vehicleName,
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
    this.createdAt,
    this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      vehicleName: json['vehicleName'] ?? '',
      vehicleNumber: json['vehicleNumber'] ?? '',
      seatingCapacity: json['seatingCapacity'] ?? 0,
      airConditioning: json['airConditioning'] ?? '',
      vehicleSpecifications: (json['vehicleSpecifications'] as List<dynamic>?)
          ?.cast<String>() ??
          [],
      serviceLocation: Location.fromJson(json['serviceLocation'] ?? {}),
      minimumChargePerHour: json['minimumChargePerHour'] ?? 0,
      isPriceNegotiable: json['isPriceNegotiable'] ?? false,
      images: (json['images'] as List<dynamic>?)?.cast<String>() ?? [],
      videos: (json['videos'] as List<dynamic>?)?.cast<String>() ?? [],
      rcBookFrontPhoto: json['rcBookFrontPhoto'] ?? '',
      rcBookBackPhoto: json['rcBookBackPhoto'] ?? '',
      isVerifiedByAdmin: json['isVerifiedByAdmin'] ?? false,
      isBlockedByAdmin: json['isBlockedByAdmin'] ?? false,
      isDisabled: json['isDisabled'] ?? false,
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class Review {
  final String id;
  final ReviewUserId? userId;
  final String partnerId;
  final String serviceType;
  final String review;
  final double rating;
  final Reviewer reviewer;
  final String? createdAt;
  final String? updatedAt;

  Review({
    required this.id,
    this.userId,
    required this.partnerId,
    required this.serviceType,
    required this.review,
    required this.rating,
    required this.reviewer,
    this.createdAt,
    this.updatedAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? '',
      userId: json['userId'] != null
          ? ReviewUserId.fromJson(json['userId'])
          : null,
      partnerId: json['partnerId'] ?? '',
      serviceType: json['serviceType'] ?? '',
      review: json['review'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      reviewer: Reviewer.fromJson(json['reviewer'] ?? {}),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
    );
  }
}

class ReviewUserId {
  final String id;
  final String mobileNumber;

  ReviewUserId({required this.id, required this.mobileNumber});

  factory ReviewUserId.fromJson(Map<String, dynamic> json) {
    return ReviewUserId(
      id: json['_id'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
    );
  }
}

class Reviewer {
  final String name;
  final String mobileNumber;
  final String userType;
  final String profilePhoto;

  Reviewer({
    required this.name,
    required this.mobileNumber,
    required this.userType,
    required this.profilePhoto,
  });

  factory Reviewer.fromJson(Map<String, dynamic> json) {
    return Reviewer(
      name: json['name'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      userType: json['usertype'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
    );
  }
}

class Pagination {
  final int total;
  final int page;
  final int pages;
  final int limit;
  final bool hasNext;
  final bool hasPrev;

  Pagination({
    required this.total,
    required this.page,
    required this.pages,
    required this.limit,
    required this.hasNext,
    required this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'] ?? 0,
      page: json['page'] ?? 0,
      pages: json['pages'] ?? 0,
      limit: json['limit'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}