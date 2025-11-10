class BecomeErickshawModel {
  String? name;
  String? photo;
  String? bio;
  String? phoneNumber; // Added missing field
  Address? address;
  List<String>? serviceCity;
  String? aadharCardNumber;
  String? aadharCardPhoto;
  String? aadharCardPhotoBack;

  int? experience; // Added missing field
  List<String>? language; // Added missing field
  String? vehicleNumber; // Added missing field
  int? seatingCapacity;
  String? fuelType;
  String? vehicleOwnership;
  List<String>? vehiclePhotos;
  List<String>? vehicleVideos;
  int? minimumFare;
  int? first2Km;
  bool? allowNegosiation;

  BecomeErickshawModel({
    this.name,
    this.photo,
    this.bio,
    this.phoneNumber,
    this.address,
    this.serviceCity,
    this.aadharCardNumber,
    this.aadharCardPhoto,
    this.aadharCardPhotoBack,
    this.experience,
    this.language,
    this.vehicleNumber,
    this.seatingCapacity,
    this.fuelType,
    this.vehicleOwnership,
    this.vehiclePhotos,
    this.vehicleVideos,
    this.minimumFare,
    this.first2Km,
    this.allowNegosiation,
  });

  /// Creates a model instance from JSON map
  factory BecomeErickshawModel.fromJson(Map<String, dynamic> json) {
    return BecomeErickshawModel(
      name: json['name'],
      photo: json['photo'],
      bio: json['bio'],
      phoneNumber: json['phoneNumber'],
      address:
          json['address'] != null ? Address.fromJson(json['address']) : null,
      serviceCity: json['serviceCity'] != null
          ? List<String>.from(json['serviceCity'])
          : null,
      aadharCardNumber: json['aadharCardNumber'],
      aadharCardPhoto: json['aadharCardPhoto'],
      aadharCardPhotoBack: json['aadharCardPhotoBack'],
      experience: json['experience'],
      language:
          json['language'] != null ? List<String>.from(json['language']) : null,
      vehicleNumber: json['vehicleNumber'],
      seatingCapacity: json['seatingCapacity'],
      fuelType: json['fuelType'],
      vehicleOwnership: json['vehicleOwnership'],
      vehiclePhotos: json['vehiclePhotos'] != null
          ? List<String>.from(json['vehiclePhotos'])
          : null,
      vehicleVideos: json['vehicleVideos'] != null
          ? List<String>.from(json['vehicleVideos'])
          : null,
      minimumFare: json['minimumFare'],
      first2Km: json['first2Km'],
      allowNegosiation: json['allowNegosiation'],
    );
  }

  /// Converts model to JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    // Only add non-null values to keep the JSON clean
    if (name != null) data['name'] = name;
    if (photo != null) data['photo'] = photo;
    if (bio != null) data['bio'] = bio;
    if (phoneNumber != null) data['phoneNumber'] = phoneNumber;
    if (address != null) data['address'] = address!.toJson();
    if (serviceCity != null) data['serviceCity'] = serviceCity;
    if (aadharCardNumber != null) data['aadharCardNumber'] = aadharCardNumber;
    if (aadharCardPhoto != null) data['aadharCardPhoto'] = aadharCardPhoto;
    if (aadharCardPhotoBack != null)
      data['aadharCardPhotoBack'] = aadharCardPhotoBack;

    if (experience != null) data['experience'] = experience;
    if (language != null) data['language'] = language;
    if (vehicleNumber != null) data['vehicleNumber'] = vehicleNumber;
    if (seatingCapacity != null) data['seatingCapacity'] = seatingCapacity;
    if (fuelType != null) data['fuelType'] = fuelType;
    if (vehicleOwnership != null) data['vehicleOwnership'] = vehicleOwnership;
    if (vehiclePhotos != null) data['vehiclePhotos'] = vehiclePhotos;
    if (vehicleVideos != null) data['vehicleVideos'] = vehicleVideos;
    if (minimumFare != null) data['minimumFare'] = minimumFare;
    if (first2Km != null) data['first2Km'] = first2Km;
    if (allowNegosiation != null) data['allowNegosiation'] = allowNegosiation;

    return data;
  }

  /// Creates a copy of this model with specified fields replaced
  BecomeErickshawModel copyWith({
    String? name,
    String? photo,
    String? bio,
    String? phoneNumber,
    Address? address,
    List<String>? serviceCity,
    String? aadharCardNumber,
    String? aadharCardPhoto,
    String? aadharCardPhotoBack,
    int? experience,
    List<String>? language,
    String? vehicleNumber,
    int? seatingCapacity,
    String? fuelType,
    String? vehicleOwnership,
    List<String>? vehiclePhotos,
    List<String>? vehicleVideos,
    int? minimumFare,
    int? first2Km,
    bool? allowNegosiation,
  }) {
    return BecomeErickshawModel(
      name: name ?? this.name,
      photo: photo ?? this.photo,
      bio: bio ?? this.bio,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      serviceCity: serviceCity ?? this.serviceCity,
      aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
      aadharCardPhoto: aadharCardPhoto ?? this.aadharCardPhoto,
      aadharCardPhotoBack: aadharCardPhotoBack ?? this.aadharCardPhotoBack,
      experience: experience ?? this.experience,
      language: language ?? this.language,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      seatingCapacity: seatingCapacity ?? this.seatingCapacity,
      fuelType: fuelType ?? this.fuelType,
      vehicleOwnership: vehicleOwnership ?? this.vehicleOwnership,
      vehiclePhotos: vehiclePhotos ?? this.vehiclePhotos,
      vehicleVideos: vehicleVideos ?? this.vehicleVideos,
      minimumFare: minimumFare ?? this.minimumFare,
      first2Km: first2Km ?? this.first2Km,
      allowNegosiation: allowNegosiation ?? this.allowNegosiation,
    );
  }

  /// Validate essential fields
  Map<String, String?> validate() {
    Map<String, String?> errors = {};

    if (name == null || name!.isEmpty) {
      errors['name'] = 'Name is required';
    }

    if (photo == null || photo!.isEmpty) {
      errors['photo'] = 'Profile photo is required';
    }

    if (phoneNumber == null || phoneNumber!.isEmpty) {
      errors['phoneNumber'] = 'Phone number is required';
    } else if (phoneNumber!.length != 10 ||
        !RegExp(r'^[0-9]{10}$').hasMatch(phoneNumber!)) {
      errors['phoneNumber'] = 'Invalid phone number format';
    }

    if (address == null) {
      errors['address'] = 'Address is required';
    } else {
      final addressErrors = address!.validate();
      for (final entry in addressErrors.entries) {
        errors['address.${entry.key}'] = entry.value;
      }
    }

    if (serviceCity == null || serviceCity!.isEmpty) {
      errors['serviceCity'] = 'At least one service city is required';
    }

    if (vehicleNumber == null || vehicleNumber!.isEmpty) {
      errors['vehicleNumber'] = 'Vehicle number is required';
    }

    if (vehiclePhotos == null || vehiclePhotos!.isEmpty) {
      errors['vehiclePhotos'] = 'At least one vehicle photo is required';
    }

    return errors;
  }
}

class Address {
  String? addressLine;
  String? city;
  String? state;
  int? pincode;

  Address({
    this.addressLine,
    this.city,
    this.state,
    this.pincode,
  });

  /// Creates an address from JSON map
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine: json['addressLine'],
      city: json['city'],
      state: json['state'],
      pincode: json['pincode'],
    );
  }

  /// Converts address to JSON map
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    if (addressLine != null) data['addressLine'] = addressLine;
    if (city != null) data['city'] = city;
    if (state != null) data['state'] = state;
    if (pincode != null) data['pincode'] = pincode;

    return data;
  }

  /// Creates a copy of this address with specified fields replaced
  Address copyWith({
    String? addressLine,
    String? city,
    String? state,
    int? pincode,
  }) {
    return Address(
      addressLine: addressLine ?? this.addressLine,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
    );
  }

  /// Validate essential address fields
  Map<String, String?> validate() {
    Map<String, String?> errors = {};

    if (addressLine == null || addressLine!.isEmpty) {
      errors['addressLine'] = 'Address line is required';
    }

    if (city == null || city!.isEmpty) {
      errors['city'] = 'City is required';
    }

    if (state == null || state!.isEmpty) {
      errors['state'] = 'State is required';
    }

    if (pincode == null) {
      errors['pincode'] = 'Pincode is required';
    } else if (pincode.toString().length != 6) {
      errors['pincode'] = 'Pincode must be 6 digits';
    }

    return errors;
  }
}
