class DriverModel {
  final String id;
  final String userId;
  final String firstName;
  final String lastName;
  final String profilePhoto;
  final String email;
  final String bio;
  final double minimumCharges;
  final ServiceLocation serviceLocation;
  final List<String> languageSpoken;
  final Address address;
  final double rating;
  final int experience;
  final String businessMobileNumber;
  final List<String> vehicleType;
  final bool isVerifiedByAdmin;
  final double lat;
  final double lng;
  final int totalRating;
  final int totalRatingSum;
  final bool negotiable;
  final String dob;
  final String gender;
  final String gstin;
  final String companyName;
  final String fleetSize;
  final VehicleCounts counts;
  final String coverImage;
  final bool preferencesWhatsapp;
  final bool preferencesPhone;
  final String fcmToken;
  final String message;
  final Language language;
  final Country country;
  final State state;
  final dynamic city; // Can be null
  final IndependentCarOwnerFleetSize independentCarOwnerFleetSize;
  final List<dynamic> vehicles;

  DriverModel({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.profilePhoto,
    required this.email,
    required this.bio,
    required this.minimumCharges,
    required this.serviceLocation,
    required this.languageSpoken,
    required this.address,
    required this.rating,
    required this.experience,
    required this.businessMobileNumber,
    required this.vehicleType,
    required this.isVerifiedByAdmin,
    required this.lat,
    required this.lng,
    required this.totalRating,
    required this.totalRatingSum,
    required this.negotiable,
    required this.dob,
    required this.gender,
    required this.gstin,
    required this.companyName,
    required this.fleetSize,
    required this.counts,
    required this.coverImage,
    required this.preferencesWhatsapp,
    required this.preferencesPhone,
    required this.fcmToken,
    required this.message,
    required this.language,
    required this.country,
    required this.state,
    required this.city,
    required this.independentCarOwnerFleetSize,
    required this.vehicles,
  });

  // Helper getter for full name
  String get fullName => '$firstName $lastName';

  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      email: json['email'] ?? '',
      bio: json['bio'] ?? '',
      minimumCharges: (json['minimumCharges'] ?? 0).toDouble(),
      serviceLocation: ServiceLocation.fromJson(json['serviceLocation'] ?? {}),
      languageSpoken: List<String>.from(json['languageSpoken'] ?? []),
      address: Address.fromJson(json['address'] ?? {}),
      rating: (json['rating'] ?? 0).toDouble(),
      experience: json['experience'] ?? 0,
      businessMobileNumber: json['businessMobileNumber'] ?? '',
      vehicleType: List<String>.from(json['vehicleType'] ?? []),
      isVerifiedByAdmin: json['isVerifiedByAdmin'] ?? false,
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
      totalRating: json['totalRating'] ?? 0,
      totalRatingSum: json['totalRatingSum'] ?? 0,
      negotiable: json['negotiable'] ?? false,
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      gstin: json['gstin'] ?? '',
      companyName: json['companyName'] ?? '',
      fleetSize: json['fleetSize'] ?? '',
      counts: VehicleCounts.fromJson(json['counts'] ?? {}),
      coverImage: json['coverImage'] ?? '',
      preferencesWhatsapp: json['preferencesWhatsapp'] ?? false,
      preferencesPhone: json['preferencesPhone'] ?? false,
      fcmToken: json['fcmToken'] ?? '',
      message: json['message'] ?? '',
      language: Language.fromJson(json['language'] ?? {}),
      country: Country.fromJson(json['country'] ?? {}),
      state: State.fromJson(json['state'] ?? {}),
      city: json['city'], // Can be null
      independentCarOwnerFleetSize: IndependentCarOwnerFleetSize.fromJson(json['independentCarOwnerFleetSize'] ?? {}),
      vehicles: List<dynamic>.from(json['vehicles'] ?? []),
    );
  }
}

class ServiceLocation {
  final double lat;
  final double lng;

  ServiceLocation({
    required this.lat,
    required this.lng,
  });

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      lat: (json['lat'] ?? 0).toDouble(),
      lng: (json['lng'] ?? 0).toDouble(),
    );
  }
}

class Address {
  final String addressLine;
  final String city;
  final String state;
  final int? pincode; // Made nullable to match JSON

  Address({
    required this.addressLine,
    required this.city,
    required this.state,
    this.pincode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'], // Can be null
    );
  }
}

class VehicleCounts {
  final int car;
  final int bus;
  final int minivan;

  VehicleCounts({
    required this.car,
    required this.bus,
    required this.minivan,
  });

  factory VehicleCounts.fromJson(Map<String, dynamic> json) {
    return VehicleCounts(
      car: json['car'] ?? 0,
      bus: json['bus'] ?? 0,
      minivan: json['minivan'] ?? 0,
    );
  }
}

class Language {
  final String id;
  final String? name; // Nullable as shown in JSON

  Language({
    required this.id,
    this.name,
  });

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'] ?? '',
      name: json['name'],
    );
  }
}

class Country {
  final String id;
  final String name;
  final String countryFlag;
  final String countryFooter;

  Country({
    required this.id,
    required this.name,
    required this.countryFlag,
    required this.countryFooter,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      countryFlag: json['country_flag'] ?? '',
      countryFooter: json['country_footer'] ?? '',
    );
  }
}

class State {
  final String id;
  final String name;

  State({
    required this.id,
    required this.name,
  });

  factory State.fromJson(Map<String, dynamic> json) {
    return State(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }
}

class IndependentCarOwnerFleetSize {
  final int cars;
  final int minivans;

  IndependentCarOwnerFleetSize({
    required this.cars,
    required this.minivans,
  });

  factory IndependentCarOwnerFleetSize.fromJson(Map<String, dynamic> json) {
    return IndependentCarOwnerFleetSize(
      cars: json['cars'] ?? 0,
      minivans: json['minivans'] ?? 0,
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

class DriverResponse {
  final bool success;
  final String message;
  final List<DriverModel> results;
  final Pagination pagination;

  DriverResponse({
    required this.success,
    required this.message,
    required this.results,
    required this.pagination,
  });

  factory DriverResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DriverResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      results: (data['results'] as List?)
          ?.map((e) => DriverModel.fromJson(e))
          .toList() ??
          [],
      pagination: Pagination.fromJson(data['pagination'] ?? {}),
    );
  }
}