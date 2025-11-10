// Model class for the Driver API response

class DriverResponse {
  final bool status;
  final String message;
  final DriverData data;

  DriverResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DriverResponse.fromJson(Map<String, dynamic> json) {
    return DriverResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: DriverData.fromJson(json['data'] ?? {}),
    );
  }
}

class DriverData {
  final Documents documents;
  final Address address;
  final String id;
  final String userId;
  final List<String> vehicleType;
  final List<String> servicesCities;
  final String fullName;
  final String mobileNumber;
  final String profilePhoto;
  final List<String> languageSpoken;
  final String bio;
  final int experience;
  final int minimumCharges;
  final String dob;
  final String gender;
  final bool isVerifiedByAdmin;
  final bool isBlockedByAdmin;
  final String createdAt;
  final String updatedAt;
  final double rating;

  //negotiable
  //Adhar card no.
  //Driving license No.

  DriverData({
    required this.documents,
    required this.address,
    required this.id,
    required this.userId,
    required this.vehicleType,
    required this.servicesCities,
    required this.fullName,
    required this.mobileNumber,
    required this.profilePhoto,
    required this.languageSpoken,
    required this.bio,
    required this.experience,
    required this.minimumCharges,
    required this.dob,
    required this.gender,
    required this.isVerifiedByAdmin,
    required this.isBlockedByAdmin,
    required this.createdAt,
    required this.updatedAt,
    required this.rating,
  });

  factory DriverData.fromJson(Map<String, dynamic> json) {
    return DriverData(
      documents: Documents.fromJson(json['documents'] ?? {}),
      address: Address.fromJson(json['address'] ?? {}),
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      vehicleType: List<String>.from(json['vehicleType'] ?? []),
      servicesCities: List<String>.from(json['servicesCities'] ?? []),
      fullName: json['fullName'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      profilePhoto: json['profilePhoto'] ?? '',
      languageSpoken: List<String>.from(json['languageSpoken'] ?? []),
      bio: json['bio'] ?? '',
      experience: json['experience'] ?? 0,
      minimumCharges: json['minimumCharges'] ?? 0,
      dob: json['dob'] ?? '',
      gender: json['gender'] ?? '',
      isVerifiedByAdmin: json['isVerifiedByAdmin'] ?? false,
      isBlockedByAdmin: json['isBlockedByAdmin'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      rating:
          (json['rating'] != null) ? (json['rating'] as num).toDouble() : 0.0,
    );
  }
}

class Documents {
  final String drivingLicenceNumber;
  final String drivingLicencePhoto;
  final String aadharCardNumber;
  final String aadharCardPhoto;
  final String panCardNumber;
  final String panCardPhoto;

  Documents({
    required this.drivingLicenceNumber,
    required this.drivingLicencePhoto,
    required this.aadharCardNumber,
    required this.aadharCardPhoto,
    required this.panCardNumber,
    required this.panCardPhoto,
  });

  factory Documents.fromJson(Map<String, dynamic> json) {
    return Documents(
      drivingLicenceNumber: json['drivingLicenceNumber'] ?? '',
      drivingLicencePhoto: json['drivingLicencePhoto'] ?? '',
      aadharCardNumber: json['aadharCardNumber'] ?? '',
      aadharCardPhoto: json['aadharCardPhoto'] ?? '',
      panCardNumber: json['panCardNumber'] ?? '',
      panCardPhoto: json['panCardPhoto'] ?? '',
    );
  }
}

class Address {
  final String addressLine;
  final String city;
  final String state;
  final int pincode;
  final String country;

  Address({
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine: json['addressLine'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      pincode: json['pincode'] ?? 0,
      country: json['country'] ?? '',
    );
  }
}
