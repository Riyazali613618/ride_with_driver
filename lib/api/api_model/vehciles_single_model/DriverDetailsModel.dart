class DriverDetailsModel {
  final bool success;
  final String message;
  final DriverProvider? provider;
  final String? profileType;

  DriverDetailsModel({
    required this.success,
    required this.message,
    this.provider,
    this.profileType,
  });

  factory DriverDetailsModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;

    return DriverDetailsModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      provider: data != null && data['provider'] != null
          ? DriverProvider.fromJson(data['provider'])
          : null,
      profileType: data?['profileType'],
    );
  }
}
class DriverProvider {
  final String? userType;
  final bool? isVerifiedByAdmin;
  final String? id;
  final String? userId;
  final String? firstName;
  final String? lastName;
  final String? profilePhoto;
  final String? coverImage;
  final String? email;
  final String? message;
  final BasicField? language;
  final BasicField? country;
  final BasicField? state;
  final BasicField? city;
  final String? fcmToken;
  final bool? preferencesWhatsapp;
  final bool? preferencesPhone;
  final double? lat;
  final double? lng;
  final double? rating;
  final String? gstin;
  final String? companyName;
  final String? bio;
  final String? fleetSize;
  final Counts? counts;
  final Address? address;
  final String? businessMobileNumber;
  final List<String>? vehicleType;
  final ServiceLocation? serviceLocation;
  final List<String>? languageSpoken;
  final int? experience;
  final double? minimumCharges;
  final bool? negotiable;
  final String? dob;
  final String? gender;
  final int? totalRating;
  final int? totalRatingSum;
  final FleetSize? independentCarOwnerFleetSize;
  final List<Vehicle>? vehicles;

  DriverProvider({
    this.userType,
    this.isVerifiedByAdmin,
    this.id,
    this.userId,
    this.firstName,
    this.lastName,
    this.profilePhoto,
    this.coverImage,
    this.email,
    this.message,
    this.language,
    this.country,
    this.state,
    this.city,
    this.fcmToken,
    this.preferencesWhatsapp,
    this.preferencesPhone,
    this.lat,
    this.lng,
    this.rating,
    this.gstin,
    this.companyName,
    this.bio,
    this.fleetSize,
    this.counts,
    this.address,
    this.businessMobileNumber,
    this.vehicleType,
    this.serviceLocation,
    this.languageSpoken,
    this.experience,
    this.minimumCharges,
    this.negotiable,
    this.dob,
    this.gender,
    this.totalRating,
    this.totalRatingSum,
    this.independentCarOwnerFleetSize,
    this.vehicles,
  });

  factory DriverProvider.fromJson(Map<String, dynamic> json) {
    return DriverProvider(
      userType: json['userType'],
      isVerifiedByAdmin: json['isVerifiedByAdmin'],
      id: json['id'],
      userId: json['userId'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePhoto: json['profilePhoto'],
      coverImage: json['coverImage'],
      email: json['email'],
      message: json['message'],
      language: json['language'] != null ? BasicField.fromJson(json['language']) : null,
      country: json['country'] != null ? BasicField.fromJson(json['country']) : null,
      state: json['state'] != null ? BasicField.fromJson(json['state']) : null,
      city: json['city'] != null ? BasicField.fromJson(json['city']) : null,
      fcmToken: json['fcmToken'],
      preferencesWhatsapp: json['preferencesWhatsapp'],
      preferencesPhone: json['preferencesPhone'],
      lat: json['lat'] != null ? double.tryParse(json['lat'].toString()) : null,
      lng: json['lng'] != null ? double.tryParse(json['lng'].toString()) : null,
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
      gstin: json['gstin'],
      companyName: json['companyName'],
      bio: json['bio'],
      fleetSize: json['fleetSize'],
      counts: json['counts'] != null ? Counts.fromJson(json['counts']) : null,
      address: json['address'] != null ? Address.fromJson(json['address']) : null,
      businessMobileNumber: json['businessMobileNumber'],
      vehicleType: json['vehicleType'] != null ? List<String>.from(json['vehicleType']) : [],
        serviceLocation: json['serviceLocation'] != null
            ? ServiceLocation.fromJson(json['serviceLocation'])
            : null,
      languageSpoken: json['languageSpoken'] != null ? List<String>.from(json['languageSpoken']) : [],
      experience: json['experience'] != null ? json['experience'] as int : null,
      minimumCharges: json['minimumCharges'] != null
          ? double.tryParse(json['minimumCharges'].toString())
          : null,
      negotiable: json['negotiable'],
      dob: json['dob'],
      gender: json['gender'],
      totalRating: json['totalRating'],
      totalRatingSum: json['totalRatingSum'],
      independentCarOwnerFleetSize: json['independentCarOwnerFleetSize'] != null
          ? FleetSize.fromJson(json['independentCarOwnerFleetSize'])
          : null,
      vehicles: json['vehicles'] != null
          ? (json['vehicles'] as List).map((e) => Vehicle.fromJson(e)).toList()
          : [],
    );
  }
}

class Language {
  final String? id;
  final String? name;

  Language({this.id, this.name});

  factory Language.fromJson(Map<String, dynamic> json) {
    return Language(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Country {
  final String? id;
  final String? name;

  Country({this.id, this.name});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
    );
  }
}

class StateModel {
  final String? id;
  final String? name;

  StateModel({this.id, this.name});

  factory StateModel.fromJson(Map<String, dynamic> json) {
    return StateModel(
      id: json['id'],
      name: json['name'],
    );
  }
}

class City {
  final String? id;
  final String? name;

  City({this.id, this.name});

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Counts {
  final int? car;
  final int? bus;
  final int? minivan;

  Counts({this.car, this.bus, this.minivan});

  factory Counts.fromJson(Map<String, dynamic> json) {
    return Counts(
      car: json['car'],
      bus: json['bus'],
      minivan: json['minivan'],
    );
  }
}

class Address {
  final String? addressLine;
  final dynamic? pincode;
  final String? city;
  final String? state;

  Address({this.city, this.state, this.addressLine, this.pincode});

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine: json['addressLine'],
      pincode: json['pincode'].toString(),
      city:json['city'],
      state:json['state']
    );
  }
}


class Vehicle {
  final String? id;
  final String? userId;
  final String? vehicleType;
  final String? vehicleName;
  final String? vehicleNumber;
  final int? seatingCapacity;
  final String? airConditioning;
  final List<String>? vehicleSpecifications;
  final Map<String,dynamic>? serviceLocation;
  final double? minimumChargePerHour;
  final bool? isPriceNegotiable;
  final List<String>? images;   // ✅ handled
  final List<String>? videos;   // ✅ handled
  final String? rcBookFrontPhoto;
  final String? rcBookBackPhoto;
  final bool? isVerifiedByAdmin;
  final bool? isBlockedByAdmin;
  final bool? isDisabled;
  final String? createdAt;
  final String? updatedAt;
  final int? v;

  Vehicle({
    this.id,
    this.userId,
    this.vehicleType,
    this.vehicleName,
    this.vehicleNumber,
    this.seatingCapacity,
    this.airConditioning,
    this.vehicleSpecifications,
    this.serviceLocation,
    this.minimumChargePerHour,
    this.isPriceNegotiable,
    this.images,
    this.videos,
    this.rcBookFrontPhoto,
    this.rcBookBackPhoto,
    this.isVerifiedByAdmin,
    this.isBlockedByAdmin,
    this.isDisabled,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['_id'],
      userId: json['userId'],
      vehicleType: json['vehicleType'],
      vehicleName: json['vehicleName'],
      vehicleNumber: json['vehicleNumber'],
      seatingCapacity: json['seatingCapacity'],
      airConditioning: json['airConditioning'],
      vehicleSpecifications: json['vehicleSpecifications']!=null ?List<String>.from(json['vehicleSpecifications']):[],
      serviceLocation: json['serviceLocation'],
      minimumChargePerHour: json['minimumChargePerHour'] != null
          ? double.tryParse(json['minimumChargePerHour'].toString())
          : null,
      isPriceNegotiable: json['isPriceNegotiable'],
      images: json['images'] != null ? List<String>.from(json['images']) : [],   // ✅ safe parsing
      videos: json['videos'] != null ? List<String>.from(json['videos']) : [],   // ✅ safe parsing
      rcBookFrontPhoto: json['rcBookFrontPhoto'],
      rcBookBackPhoto: json['rcBookBackPhoto'],
      isVerifiedByAdmin: json['isVerifiedByAdmin'],
      isBlockedByAdmin: json['isBlockedByAdmin'],
      isDisabled: json['isDisabled'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      v: json['__v'],
    );
  }
}
class BasicField {
  final String? id;
  final String? name;

  BasicField({this.id, this.name});

  factory BasicField.fromJson(Map<String, dynamic> json) {
    return BasicField(
      id: json['id'],
      name: json['name'],
    );
  }
}
class ServiceLocation {
  final double? lat;
  final double? lng;

  ServiceLocation({this.lat, this.lng});

  factory ServiceLocation.fromJson(Map<String, dynamic> json) {
    return ServiceLocation(
      lat: (json['lat'] != null) ? json['lat'].toDouble() : null,
      lng: (json['lng'] != null) ? json['lng'].toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
    };
  }
}
class FleetSize {
  final int? small;
  final int? medium;
  final int? large;

  FleetSize({this.small, this.medium, this.large});

  factory FleetSize.fromJson(Map<String, dynamic> json) {
    return FleetSize(
      small: json['small'],
      medium: json['medium'],
      large: json['large'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'small': small,
      'medium': medium,
      'large': large,
    };
  }
}