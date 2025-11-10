class FavouriteModel {
  bool? success;
  String? message;
  List<Data>? data;

  FavouriteModel({this.success, this.message, this.data});

  FavouriteModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    if (json['data'] != null) {
      data = <Data>[];
      json['data'].forEach((v) {
        data!.add(new Data.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Data {
  String? favoriteId;
  String? partnerId;
  String? vehicleId;
  String? partnerType;
  Vehicle? vehicle;
  Profile? profile;
  String? addedAt;
  bool? isBlocked;
  String? mobileNumber;

  Data(
      {this.favoriteId,
        this.partnerId,
        this.vehicleId,
        this.partnerType,
        this.vehicle,
        this.profile,
        this.addedAt,
        this.isBlocked,
        this.mobileNumber});

  Data.fromJson(Map<String, dynamic> json) {
    favoriteId = json['favoriteId'];
    partnerId = json['partnerId'];
    vehicleId = json['vehicleId'];
    partnerType = json['partnerType'];
    vehicle =
    json['vehicle'] != null ? new Vehicle.fromJson(json['vehicle']) : null;
    profile =
    json['profile'] != null ? new Profile.fromJson(json['profile']) : null;
    addedAt = json['addedAt'];
    isBlocked = json['isBlocked'];
    mobileNumber = json['mobileNumber'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['favoriteId'] = this.favoriteId;
    data['partnerId'] = this.partnerId;
    data['vehicleId'] = this.vehicleId;
    data['partnerType'] = this.partnerType;
    if (this.vehicle != null) {
      data['vehicle'] = this.vehicle!.toJson();
    }
    if (this.profile != null) {
      data['profile'] = this.profile!.toJson();
    }
    data['addedAt'] = this.addedAt;
    data['isBlocked'] = this.isBlocked;
    data['mobileNumber'] = this.mobileNumber;
    return data;
  }
}

class Vehicle {
  String? sId;
  String? userId;
  String? vehicleType;
  String? vehicleName;
  String? vehicleNumber;
  int? seatingCapacity;
  String? airConditioning;
  List<String>? vehicleSpecifications;
  ServiceLocation? serviceLocation;
  int? minimumChargePerHour;
  bool? isPriceNegotiable;
  List<String>? images;
  List<String>? videos;
  String? rcBookFrontPhoto;
  String? rcBookBackPhoto;
  bool? isVerifiedByAdmin;
  bool? isBlockedByAdmin;
  bool? isDisabled;
  String? createdAt;
  String? updatedAt;
  int? iV;
  String? brandName;

  Vehicle(
      {this.sId,
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
        this.iV,
        this.brandName});

  Vehicle.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    userId = json['userId'];
    vehicleType = json['vehicleType'];
    vehicleName = json['vehicleName'];
    vehicleNumber = json['vehicleNumber'];
    seatingCapacity = json['seatingCapacity'];
    airConditioning = json['airConditioning'];
    vehicleSpecifications = json['vehicleSpecifications'].cast<String>();
    serviceLocation = json['serviceLocation'] != null
        ? new ServiceLocation.fromJson(json['serviceLocation'])
        : null;
    minimumChargePerHour = json['minimumChargePerHour'];
    isPriceNegotiable = json['isPriceNegotiable'];
    images = json['images'].cast<String>();
    videos = json['videos'].cast<String>();
    rcBookFrontPhoto = json['rcBookFrontPhoto'];
    rcBookBackPhoto = json['rcBookBackPhoto'];
    isVerifiedByAdmin = json['isVerifiedByAdmin'];
    isBlockedByAdmin = json['isBlockedByAdmin'];
    isDisabled = json['isDisabled'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    iV = json['__v'];
    brandName = json['brandName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['userId'] = this.userId;
    data['vehicleType'] = this.vehicleType;
    data['vehicleName'] = this.vehicleName;
    data['vehicleNumber'] = this.vehicleNumber;
    data['seatingCapacity'] = this.seatingCapacity;
    data['airConditioning'] = this.airConditioning;
    data['vehicleSpecifications'] = this.vehicleSpecifications;
    if (this.serviceLocation != null) {
      data['serviceLocation'] = this.serviceLocation!.toJson();
    }
    data['minimumChargePerHour'] = this.minimumChargePerHour;
    data['isPriceNegotiable'] = this.isPriceNegotiable;
    data['images'] = this.images;
    data['videos'] = this.videos;
    data['rcBookFrontPhoto'] = this.rcBookFrontPhoto;
    data['rcBookBackPhoto'] = this.rcBookBackPhoto;
    data['isVerifiedByAdmin'] = this.isVerifiedByAdmin;
    data['isBlockedByAdmin'] = this.isBlockedByAdmin;
    data['isDisabled'] = this.isDisabled;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    data['__v'] = this.iV;
    data['brandName'] = this.brandName;
    return data;
  }
}

class ServiceLocation {
  double? lat;
  double? lng;
  String? name;

  ServiceLocation({this.lat, this.lng, this.name});

  ServiceLocation.fromJson(Map<String, dynamic> json) {
    lat = json['lat'];
    lng = json['lng'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['lat'] = this.lat;
    data['lng'] = this.lng;
    data['name'] = this.name;
    return data;
  }
}

class Profile {
  String? firstName;
  String? lastName;
  String? profilePhoto;
  String? email;
  double? rating;
  int? totalRating;
  int? experience;
  int? minimumCharges;
  bool? negotiable;
  List<String>? vehicleType;
  List<String>? languageSpoken;
  ServiceLocation? serviceLocation;
  City? city;
  City? state;
  Country? country;
  String? businessMobileNumber;
  String? companyName;
  String? fleetSize;
  Counts? counts;
  IndependentCarOwnerFleetSize? independentCarOwnerFleetSize;
  bool? preferencesWhatsapp;
  bool? preferencesPhone;
  bool? preferencesChat;

  Profile(
      {this.firstName,
        this.lastName,
        this.profilePhoto,
        this.email,
        this.rating,
        this.totalRating,
        this.experience,
        this.minimumCharges,
        this.negotiable,
        this.vehicleType,
        this.languageSpoken,
        this.serviceLocation,
        this.city,
        this.state,
        this.country,
        this.businessMobileNumber,
        this.companyName,
        this.fleetSize,
        this.counts,
        this.independentCarOwnerFleetSize,
        this.preferencesWhatsapp,
        this.preferencesPhone,
        this.preferencesChat});

  Profile.fromJson(Map<String, dynamic> json) {
    firstName = json['firstName'];
    lastName = json['lastName'];
    profilePhoto = json['profilePhoto'];
    email = json['email'];
    rating = toDouble(json['rating']);
    totalRating = json['totalRating'];
    experience = json['experience'];
    minimumCharges = json['minimumCharges'];
    negotiable = json['negotiable'];
    if (json['vehicleType'] != null) {
      vehicleType =(json['vehicleType'] as List<dynamic>?)?.cast<String>() ?? [];
    }
    if (json['languageSpoken'] != null) {
      languageSpoken =  (json['languageSpoken'] as List<dynamic>?)?.cast<String>() ?? [];
    }
    serviceLocation = json['serviceLocation'] != null
        ? new ServiceLocation.fromJson(json['serviceLocation'])
        : null;
    city = json['city'] != null ? new City.fromJson(json['city']) : null;
    state = json['state'] != null ? new City.fromJson(json['state']) : null;
    country =
    json['country'] != null ? new Country.fromJson(json['country']) : null;
    businessMobileNumber = json['businessMobileNumber'];
    companyName = json['companyName'];
    fleetSize = json['fleetSize'];
    counts =
    json['counts'] != null ? new Counts.fromJson(json['counts']) : null;
    independentCarOwnerFleetSize = json['independentCarOwnerFleetSize'] != null
        ? new IndependentCarOwnerFleetSize.fromJson(
        json['independentCarOwnerFleetSize'])
        : null;
    preferencesWhatsapp = json['preferencesWhatsapp'];
    preferencesPhone = json['preferencesPhone'];
    preferencesChat = json['preferencesChat'];
  }

  double? toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['firstName'] = this.firstName;
    data['lastName'] = this.lastName;
    data['profilePhoto'] = this.profilePhoto;
    data['email'] = this.email;
    data['rating'] = this.rating;
    data['totalRating'] = this.totalRating;
    data['experience'] = this.experience;
    data['minimumCharges'] = this.minimumCharges;
    data['negotiable'] = this.negotiable;
    if (this.vehicleType != null) {
      data['vehicleType'] = this.vehicleType!;
    }
    if (this.languageSpoken != null) {
      data['languageSpoken'] =
          this.languageSpoken!;
    }
    if (this.serviceLocation != null) {
      data['serviceLocation'] = this.serviceLocation!.toJson();
    }
    if (this.city != null) {
      data['city'] = this.city!.toJson();
    }
    if (this.state != null) {
      data['state'] = this.state!.toJson();
    }
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    data['businessMobileNumber'] = this.businessMobileNumber;
    data['companyName'] = this.companyName;
    data['fleetSize'] = this.fleetSize;
    if (this.counts != null) {
      data['counts'] = this.counts!.toJson();
    }
    if (this.independentCarOwnerFleetSize != null) {
      data['independentCarOwnerFleetSize'] =
          this.independentCarOwnerFleetSize!.toJson();
    }
    data['preferencesWhatsapp'] = this.preferencesWhatsapp;
    data['preferencesPhone'] = this.preferencesPhone;
    data['preferencesChat'] = this.preferencesChat;
    return data;
  }
}



class City {
  String? id;
  String? name;

  City({this.id, this.name});

  City.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    return data;
  }
}

class Country {
  String? id;
  String? name;
  String? countryFlag;
  String? countryFooter;

  Country({this.id, this.name, this.countryFlag, this.countryFooter});

  Country.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    countryFlag = json['country_flag'];
    countryFooter = json['country_footer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['country_flag'] = this.countryFlag;
    data['country_footer'] = this.countryFooter;
    return data;
  }
}

class Counts {
  int? car;
  int? bus;
  int? minivan;
  int? suv;

  Counts({this.car, this.bus, this.minivan, this.suv});

  Counts.fromJson(Map<String, dynamic> json) {
    car = json['car'];
    bus = json['bus'];
    minivan = json['minivan'];
    suv = json['suv'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['car'] = this.car;
    data['bus'] = this.bus;
    data['minivan'] = this.minivan;
    data['suv'] = this.suv;
    return data;
  }
}

class IndependentCarOwnerFleetSize {
  int? cars;
  int? minivans;

  IndependentCarOwnerFleetSize({this.cars, this.minivans});

  IndependentCarOwnerFleetSize.fromJson(Map<String, dynamic> json) {
    cars = json['cars'];
    minivans = json['minivans'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['cars'] = this.cars;
    data['minivans'] = this.minivans;
    return data;
  }
}
