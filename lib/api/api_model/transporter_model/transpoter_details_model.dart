class TransporterDetailsModel {
  final bool status;
  final String message;
  final TransporterData data;

  TransporterDetailsModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TransporterDetailsModel.fromJson(Map<String, dynamic> json) {
    return TransporterDetailsModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: TransporterData.fromJson(json['data'] ?? {}),
    );
  }
}

class TransporterData {
  final List<TransporterVehicle> vehicles;
  final TransporterInfo transporter;

  TransporterData({
    required this.vehicles,
    required this.transporter,
  });

  factory TransporterData.fromJson(Map<String, dynamic> json) {
    return TransporterData(
      vehicles: (json['vehicles'] as List<dynamic>?)
          ?.map((v) => TransporterVehicle.fromJson(v))
          .toList() ??
          [],
      transporter: TransporterInfo.fromJson(json['transporter'] ?? {}),
    );
  }
}

class TransporterVehicle {
  final String id;
  final String userId;
  final String vehicleOwnership;
  final String vehicleName;
  final String vehicleModelName;
  final String manufacturing;
  final String maxPower;
  final String maxSpeed;
  final String fuelType;
  final int first2Km;
  final String milage;
  final String registrationDate;
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
  final bool isVerifiedByAdmin;
  final bool isBlockedByAdmin;
  final VehicleDetails details;

  TransporterVehicle({
    required this.id,
    required this.userId,
    required this.vehicleOwnership,
    required this.vehicleName,
    required this.vehicleModelName,
    required this.manufacturing,
    required this.maxPower,
    required this.maxSpeed,
    required this.fuelType,
    required this.first2Km,
    required this.milage,
    required this.registrationDate,
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
    required this.isVerifiedByAdmin,
    required this.isBlockedByAdmin,
    required this.details,
  });

  factory TransporterVehicle.fromJson(Map<String, dynamic> json) {
    return TransporterVehicle(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      vehicleOwnership: json['vehicleOwnership'] ?? '',
      vehicleName: json['vehicleName'] ?? '',
      vehicleModelName: json['vehicleModelName'] ?? '',
      manufacturing: json['manufacturing'] ?? '',
      maxPower: json['maxPower'] ?? '',
      maxSpeed: json['maxSpeed'] ?? '',
      fuelType: json['fuelType'] ?? '',
      first2Km: json['first2Km'] ?? 0,
      milage: json['milage'] ?? '',
      registrationDate: json['registrationDate'] ?? '',
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
      isVerifiedByAdmin: json['isVerifiedByAdmin'] ?? false,
      isBlockedByAdmin: json['isBlockedByAdmin'] ?? false,
      details: VehicleDetails.fromJson(json['details'] ?? {}),
    );
  }
}

class VehicleDetails {
  final TransporterAddress address;
  final String? fullName;
  final String? mobileNumber;
  final String? profilePhoto;
  final String? languageSpoken;
  final String? bio;
  final String? experience;
  final double rating;

  VehicleDetails({
    required this.address,
    this.fullName,
    this.mobileNumber,
    this.profilePhoto,
    this.languageSpoken,
    this.bio,
    this.experience,
    required this.rating,
  });

  factory VehicleDetails.fromJson(Map<String, dynamic> json) {
    return VehicleDetails(
      address: TransporterAddress.fromJson(json['address'] ?? {}),
      fullName: json['fullName'],
      mobileNumber: json['mobileNumber'],
      profilePhoto: json['profilePhoto'],
      languageSpoken: json['languageSpoken'],
      bio: json['bio'],
      experience: json['experience'],
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }
}

class TransporterInfo {
  final String id;
  final String userId;
  final String companyName; // Company/proprietor Name (autofill from GST data)
  final String phoneNumber; // Phone No.
  final TransporterAddress address; // Address with autofill from GST data
  final String addressType;
  final String fleetSize; // Fleet size: small(1-5), medium(6-10), large(11+)
  final TransporterCounts counts; // Vehicle counts (should not exceed fleet size limit)
  final String contactPersonName; // Contact person
  final TransporterPoints points;
  final String bio; // About (prefilled and editable)
  final String photo; // Profile image (from gallery and camera)
  final double rating;
  final bool isVerifiedByAdmin;
  final bool isBlockedByAdmin;
  final TransporterDocuments documents; // Includes GST verification and transportation permit

  TransporterInfo({
    required this.id,
    required this.userId,
    required this.companyName,
    required this.phoneNumber,
    required this.address,
    required this.addressType,
    required this.fleetSize,
    required this.counts,
    required this.contactPersonName,
    required this.points,
    required this.bio,
    required this.photo,
    required this.rating,
    required this.isVerifiedByAdmin,
    required this.isBlockedByAdmin,
    required this.documents,
  });

  factory TransporterInfo.fromJson(Map<String, dynamic> json) {
    return TransporterInfo(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      companyName: json['companyName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      address: TransporterAddress.fromJson(json['address'] ?? {}),
      addressType: json['addressType'] ?? '',
      fleetSize: json['fleetSize'] ?? '',
      counts: TransporterCounts.fromJson(json['counts'] ?? {}),
      contactPersonName: json['contactPersonName'] ?? '',
      points: TransporterPoints.fromJson(json['points'] ?? {}),
      bio: json['bio'] ?? '',
      photo: json['photo'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
      isVerifiedByAdmin: json['isVerifiedByAdmin'] ?? false,
      isBlockedByAdmin: json['isBlockedByAdmin'] ?? false,
      documents: TransporterDocuments.fromJson(json['documents'] ?? {}),
    );
  }
}

class TransporterAddress {
  final String? addressLine;
  final String? city;
  final String? state;
  final dynamic pincode;
  final String? country;

  TransporterAddress({
    this.addressLine,
    this.city,
    this.state,
    this.pincode,
    this.country,
  });

  factory TransporterAddress.fromJson(Map<String, dynamic> json) {
    return TransporterAddress(
      addressLine: json['addressLine'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
      country: json['country'],
    );
  }
}

class TransporterCounts {
  final int car;
  final int bus;
  final int van;


  TransporterCounts({
    required this.car,
    required this.bus,
    required this.van,
  });

  factory TransporterCounts.fromJson(Map<String, dynamic> json) {
    return TransporterCounts(
      car: json['car'] ?? 0,
      bus: json['bus'] ?? 0,
      van: json['van'] ?? 0,
    );
  }

  // Helper method to get total vehicle count
  int get totalVehicles => car + bus + van;

  // Helper method to validate against fleet size
  bool isValidForFleetSize(String fleetSize) {
    final total = totalVehicles;
    switch (fleetSize.toLowerCase()) {
      case 'small':
        return total >= 1 && total <= 5;
      case 'medium':
        return total >= 6 && total <= 10;
      case 'large':
        return total >= 11;
      default:
        return false;
    }
  }
}

class TransporterPoints {
  final bool useLoginNumber;
  final bool showNumberOnAppWebsite;
  final bool enableChat;

  TransporterPoints({
    required this.useLoginNumber,
    required this.showNumberOnAppWebsite,
    required this.enableChat,
  });

  factory TransporterPoints.fromJson(Map<String, dynamic> json) {
    return TransporterPoints(
      useLoginNumber: json['use_login_number'] ?? false,
      showNumberOnAppWebsite: json['show_number_on_app_website'] ?? false,
      enableChat: json['enable_chat'] ?? false,
    );
  }
}

class TransporterDocuments {
  final String gstin; // GST NO. (verify by API)
  final String aadharCardNumber;
  final String aadharCardPhoto;
  final String panCardNumber;
  final String panCardPhoto;
  final String businessRegistrationCertificate;
  final String transportationPermit; // Transportation permit image upload (optional)

  TransporterDocuments({
    required this.gstin,
    required this.aadharCardNumber,
    required this.aadharCardPhoto,
    required this.panCardNumber,
    required this.panCardPhoto,
    required this.businessRegistrationCertificate,
    required this.transportationPermit,
  });

  factory TransporterDocuments.fromJson(Map<String, dynamic> json) {
    return TransporterDocuments(
      gstin: json['gstin'] ?? '',
      aadharCardNumber: json['aadharCardNumber'] ?? '',
      aadharCardPhoto: json['aadharCardPhoto'] ?? '',
      panCardNumber: json['panCardNumber'] ?? '',
      panCardPhoto: json['panCardPhoto'] ?? '',
      businessRegistrationCertificate:
      json['business_registration_certificate'] ?? '',
      transportationPermit: json['transportationPermit'] ?? '',
    );
  }
}