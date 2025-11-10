class Vehicle {
  final String id;
  final String userId;
  final String vehicleOwnership;
  final String vehicleName;
  final String vehicleModelName;
  final String manufacturing;
  final String? maxPower;
  final String? maxSpeed;
  final String fuelType;
  final int first2Km;
  final String? milage;
  final String? registrationDate;
  final String airConditioning;
  final String vehicleType;
  final int seatingCapacity;
  final String vehicleNumber;
  final List<String> vehicleSpecifications;
  final List<String> servedLocation;
  final int minimumChargePerHour;
  final String currency;
  final List<String> images;
  final List<String> videos;
  final bool isPriceNegotiable;
  final bool isVerified;
  final bool isBlockedByAdmin;
  final String createdAt;
  final String updatedAt;
  final VehicleDocuments documents;
  final VehicleDetails details;
  final bool isDisabled;

  Vehicle({
    required this.id,
    required this.userId,
    required this.vehicleOwnership,
    required this.vehicleName,
    required this.vehicleModelName,
    required this.manufacturing,
    this.maxPower,
    this.maxSpeed,
    required this.fuelType,
    required this.first2Km,
    this.milage,
    this.registrationDate,
    required this.airConditioning,
    required this.vehicleType,
    required this.seatingCapacity,
    required this.vehicleNumber,
    required this.vehicleSpecifications,
    required this.servedLocation,
    required this.minimumChargePerHour,
    required this.currency,
    required this.images,
    required this.videos,
    required this.isPriceNegotiable,
    required this.isVerified,
    required this.isBlockedByAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.documents,
    required this.details,
    required this.isDisabled,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      isDisabled: json['isDisabled'] ?? false,
      id: json['vehicleId']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      vehicleOwnership: json['vehicleOwnership'] ?? '',
      vehicleName: json['vehicleName'] ?? '',
      vehicleModelName: json['vehicleModelName'] ?? '',
      manufacturing: json['manufacturing']?.toString() ?? '',
      maxPower: json['maxPower']?.toString(),
      maxSpeed: json['maxSpeed']?.toString(),
      fuelType: json['fuelType'] ?? '',
      first2Km: json['first2Km'] ?? 0,
      milage: json['milage']?.toString(),
      registrationDate: json['registrationDate']?.toString(),
      airConditioning: json['airConditioning'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      seatingCapacity: json['seatingCapacity'] ?? 0,
      vehicleNumber: json['vehicleNumber'] ?? '',
      vehicleSpecifications:
          List<String>.from(json['vehicleSpecifications'] ?? []),
      servedLocation: List<String>.from(json['servedLocation'] ?? []),
      minimumChargePerHour: json['minimumChargePerHour'] ?? 0,
      currency: json['currency'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      videos: List<String>.from(json['videos'] ?? []),
      isPriceNegotiable: json['isPriceNegotiable'] ?? false,
      isVerified: json['isVerified'] ?? false,
      isBlockedByAdmin: json['isBlockedByAdmin'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      documents: VehicleDocuments.fromJson(json['documents'] ?? {}),
      details: VehicleDetails.fromJson(json['details'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'vehicleOwnership': vehicleOwnership,
      'vehicleName': vehicleName,
      'vehicleModelName': vehicleModelName,
      'manufacturing': manufacturing,
      'maxPower': maxPower,
      'maxSpeed': maxSpeed,
      'fuelType': fuelType,
      'first2Km': first2Km,
      'milage': milage,
      'registrationDate': registrationDate,
      'airConditioning': airConditioning,
      'vehicleType': vehicleType,
      'seatingCapacity': seatingCapacity,
      'vehicleNumber': vehicleNumber,
      'vehicleSpecifications': vehicleSpecifications,
      'servedLocation': servedLocation,
      'minimumChargePerHour': minimumChargePerHour,
      'currency': currency,
      'images': images,
      'videos': videos,
      'isPriceNegotiable': isPriceNegotiable,
      'isVerified': isVerified,
      'isBlockedByAdmin': isBlockedByAdmin,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'documents': documents.toJson(),
      'details': details.toJson(),
    };
  }
}

class VehicleDocuments {
  final String? rcBookFrontPhoto;
  final String? rcBookBackPhoto;
  final String? aadharCardPhoto;
  final String? aadharCardNumber;
  final String? panCardPhoto;
  final String? panCardNumber;

  VehicleDocuments({
    this.rcBookFrontPhoto,
    this.rcBookBackPhoto,
    this.aadharCardPhoto,
    this.aadharCardNumber,
    this.panCardPhoto,
    this.panCardNumber,
  });

  factory VehicleDocuments.fromJson(Map<String, dynamic> json) {
    return VehicleDocuments(
      rcBookFrontPhoto: json['rcBookFrontPhoto']?.toString(),
      rcBookBackPhoto: json['rcBookBackPhoto']?.toString(),
      aadharCardPhoto: json['aadharCardPhoto']?.toString(),
      aadharCardNumber: json['aadharCardNumber']?.toString(),
      panCardPhoto: json['panCardPhoto']?.toString(),
      panCardNumber: json['panCardNumber']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rcBookFrontPhoto': rcBookFrontPhoto,
      'rcBookBackPhoto': rcBookBackPhoto,
      'aadharCardPhoto': aadharCardPhoto,
      'aadharCardNumber': aadharCardNumber,
      'panCardPhoto': panCardPhoto,
      'panCardNumber': panCardNumber,
    };
  }
}

class VehicleDetails {
  final VehicleAddress address;
  final String? fullName;
  final String? mobileNumber;
  final String? profilePhoto;
  final List<String>? languageSpoken;
  final String? bio;
  final dynamic experience;
  final int? rating;

  VehicleDetails({
    required this.address,
    this.fullName,
    this.mobileNumber,
    this.profilePhoto,
    this.languageSpoken,
    this.bio,
    this.experience,
    this.rating,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      address: VehicleAddress.fromJson(json['address'] ?? {}),
      fullName: json['fullName']?.toString(),
      mobileNumber: json['mobileNumber']?.toString(),
      profilePhoto: json['profilePhoto']?.toString(),
      languageSpoken: json['languageSpoken'] != null
          ? List<String>.from(json['languageSpoken'])
          : null,
      bio: json['bio']?.toString(),
      experience: json['experience'],
      rating: json['rating'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'address': address.toJson(),
      'fullName': fullName,
      'mobileNumber': mobileNumber,
      'profilePhoto': profilePhoto,
      'languageSpoken': languageSpoken,
      'bio': bio,
      'experience': experience,
      'rating': rating,
    };
  }
}

class VehicleAddress {
  final String? addressLine;
  final String? city;
  final String? state;
  final int? pincode;
  final String? country;

  VehicleAddress({
    this.addressLine,
    this.city,
    this.state,
    this.pincode,
    this.country,
  });

  factory VehicleAddress.fromJson(Map<String, dynamic> json) {
    return VehicleAddress(
      addressLine: json['addressLine']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      pincode: json['pincode'] is String
          ? int.tryParse(json['pincode'])
          : json['pincode'],
      country: json['country']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
    };
  }
}
