class ERikshawModel {
  bool? status;
  String? message;
  Data? data;

  ERikshawModel({this.status, this.message, this.data});

  ERikshawModel.fromJson(Map<String, dynamic> json) {
    status = json['status'] ?? false;
    message = json['message'] ?? '';
    data = json['data'] != null ? Data.fromJson(json['data']) : Data();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status ?? false;
    data['message'] = message ?? '';
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class Data {
  String? sId;
  String? userId;
  String? uuid;
  String? photo;
  String? name;
  String? phoneNumber;
  String? about;
  Address? address;
  String? aadharCardNumber;
  String? aadharCardPhoto;
  String? aadharCardPhotoBack;
  String? vehicleNumber;
  int? seatingCapacity;
  List<String>? vehicleImages;
  String? vehicleVideo;
  int? minimumCharges;
  bool? negotiable;
  ServiceLocation? serviceLocation;
  List<String>? languageSpoken;
  DocumentVerificationStatus? documentVerificationStatus;
  bool? isBlockedByAdmin;
  bool? isActive;
  String? planExpiredDate;
  double? rating;
  int? totalRating;
  int? totalRatingSum;
  bool? isUpgradeAccount;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? userType;

  Data({
    this.sId,
    this.userId,
    this.uuid,
    this.photo,
    this.name,
    this.phoneNumber,
    this.about,
    this.address,
    this.aadharCardNumber,
    this.aadharCardPhoto,
    this.aadharCardPhotoBack,
    this.vehicleNumber,
    this.seatingCapacity,
    this.vehicleImages,
    this.vehicleVideo,
    this.minimumCharges,
    this.negotiable,
    this.serviceLocation,
    this.languageSpoken,
    this.documentVerificationStatus,
    this.isBlockedByAdmin,
    this.isActive,
    this.planExpiredDate,
    this.rating,
    this.totalRating,
    this.totalRatingSum,
    this.isUpgradeAccount,
    this.createdAt,
    this.updatedAt,
    this.iV,
    this.userType,
  });

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'] ?? '';
    userId = json['userId'] ?? '';
    uuid = json['uuid'] ?? '';
    photo = json['photo'] ?? '';
    name = json['name'] ?? 'N/A';
    phoneNumber = json['phoneNumber'] ?? '';
    about = json['about'] ?? '';
    address = json['address'] != null ? Address.fromJson(json['address']) : Address();
    aadharCardNumber = json['aadharCardNumber'] ?? '';
    aadharCardPhoto = json['aadharCardPhoto'] ?? '';
    aadharCardPhotoBack = json['aadharCardPhotoBack'] ?? '';
    vehicleNumber = json['vehicleNumber'] ?? '';
    seatingCapacity = json['seatingCapacity'] ?? 0;
    
    // Safe handling for vehicleImages with default empty list
    vehicleImages = json['vehicleImages'] != null 
        ? List<String>.from(json['vehicleImages'])
        : <String>[];
    
    vehicleVideo = json['vehicleVideo'] ?? '';
    minimumCharges = json['minimumCharges'] ?? 0;
    negotiable = json['negotiable'] ?? false;
    serviceLocation = json['serviceLocation'] != null
        ? ServiceLocation.fromJson(json['serviceLocation'])
        : ServiceLocation();
    
    // Safe handling for languageSpoken with default empty list
    languageSpoken = json['languageSpoken'] != null 
        ? List<String>.from(json['languageSpoken'])
        : <String>[];
    
    documentVerificationStatus = json['documentVerificationStatus'] != null
        ? DocumentVerificationStatus.fromJson(json['documentVerificationStatus'])
        : DocumentVerificationStatus();
    
    isBlockedByAdmin = json['isBlockedByAdmin'] ?? false;
    isActive = json['isActive'] ?? false;
    planExpiredDate = json['planExpiredDate'] ?? '';
    
    // Handle rating as double with default value
    if (json['rating'] != null) {
      rating = json['rating'] is int 
          ? (json['rating'] as int).toDouble()
          : json['rating'].toDouble();
    } else {
      rating = 0.0;
    }
    
    totalRating = json['totalRating'] ?? 0;
    totalRatingSum = json['totalRatingSum'] ?? 0;
    isUpgradeAccount = json['isUpgradeAccount'] ?? false;
    createdAt = json['createdAt'] ?? '';
    updatedAt = json['updatedAt'] ?? '';
    iV = json['__v'] ?? 0;
    userType = json['userType'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['_id'] = sId ?? '';
    data['userId'] = userId ?? '';
    data['uuid'] = uuid ?? '';
    data['photo'] = photo ?? '';
    data['name'] = name ?? '';
    data['phoneNumber'] = phoneNumber ?? '';
    data['about'] = about ?? '';
    if (address != null) {
      data['address'] = address!.toJson();
    }
    data['aadharCardNumber'] = aadharCardNumber ?? '';
    data['aadharCardPhoto'] = aadharCardPhoto ?? '';
    data['aadharCardPhotoBack'] = aadharCardPhotoBack ?? '';
    data['vehicleNumber'] = vehicleNumber ?? '';
    data['seatingCapacity'] = seatingCapacity ?? 0;
    data['vehicleImages'] = vehicleImages ?? <String>[];
    data['vehicleVideo'] = vehicleVideo ?? '';
    data['minimumCharges'] = minimumCharges ?? 0;
    data['negotiable'] = negotiable ?? false;
    if (serviceLocation != null) {
      data['serviceLocation'] = serviceLocation!.toJson();
    }
    data['languageSpoken'] = languageSpoken ?? <String>[];
    if (documentVerificationStatus != null) {
      data['documentVerificationStatus'] = documentVerificationStatus!.toJson();
    }
    data['isBlockedByAdmin'] = isBlockedByAdmin ?? false;
    data['isActive'] = isActive ?? false;
    data['planExpiredDate'] = planExpiredDate ?? '';
    data['rating'] = rating ?? 0.0;
    data['totalRating'] = totalRating ?? 0;
    data['totalRatingSum'] = totalRatingSum ?? 0;
    data['isUpgradeAccount'] = isUpgradeAccount ?? false;
    data['createdAt'] = createdAt ?? '';
    data['updatedAt'] = updatedAt ?? '';
    data['__v'] = iV ?? 0;
    data['userType'] = userType ?? '';
    return data;
  }
}

class Address {
  String? addressLine;
  int? pincode;
  String? city;
  String? state;
  String? country;

  Address({this.addressLine, this.pincode, this.city, this.state, this.country});

  Address.fromJson(Map<String, dynamic> json) {
    addressLine = json['addressLine'] ?? '';
    pincode = json['pincode'] ?? 0;
    city = json['city'] ?? '';
    state = json['state'] ?? '';
    country = json['country'] ?? '';
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['addressLine'] = addressLine ?? '';
    data['pincode'] = pincode ?? 0;
    data['city'] = city ?? '';
    data['state'] = state ?? '';
    data['country'] = country ?? '';
    return data;
  }
}

class ServiceLocation {
  double? lat;
  double? lng;

  ServiceLocation({this.lat, this.lng});

  ServiceLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat']?.toDouble() ?? 0.0;
    lng = json['lng']?.toDouble() ?? 0.0;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['lat'] = lat ?? 0.0;
    data['lng'] = lng ?? 0.0;
    return data;
  }
}

class DocumentVerificationStatus {
  bool? aadharVerified;
  bool? isVerifiedByAdmin;

  DocumentVerificationStatus({this.aadharVerified, this.isVerifiedByAdmin});

  DocumentVerificationStatus.fromJson(Map<String, dynamic> json) {
    aadharVerified = json['aadharVerified'] ?? false;
    isVerifiedByAdmin = json['isVerifiedByAdmin'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['aadharVerified'] = aadharVerified ?? false;
    data['isVerifiedByAdmin'] = isVerifiedByAdmin ?? false;
    return data;
  }
}