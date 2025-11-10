import 'dart:convert';

class BecomeDriverModel {
String? drivingLicenceNumber;
String? drivingLicencePhoto;
String? aadharCardNumber;
String? aadharCardPhotoFront;
String? aadharCardPhotoBack;
bool? negotiable;
String? firstName;
String? lastName;
String? businessMobileNumber;
String? profilePhoto;
List<String>? languageSpoken;
List<String>? vehicleType;
List<String>? servicesCities;
String? bio;
int? experience;
Address? address;
double? minimumCharges;
String? dob;
String? gender;
ServiceLocation? serviceLocation;

BecomeDriverModel({
this.drivingLicenceNumber,
this.drivingLicencePhoto,
this.aadharCardNumber,
this.aadharCardPhotoFront,
this.aadharCardPhotoBack,
this.firstName,
this.lastName,
this.businessMobileNumber,
this.profilePhoto,
this.languageSpoken,
this.vehicleType,
this.servicesCities,
this.bio,
this.experience,
this.address,
this.minimumCharges,
this.dob,
this.gender,
this.negotiable,
this.serviceLocation,
});

BecomeDriverModel copyWith({
String? drivingLicenceNumber,
String? drivingLicencePhoto,
String? aadharCardNumber,
String? aadharCardPhotoFront,
String? aadharCardPhotoBack,
String? firstName,
String? lastName,
String? businessMobileNumber,
String? profilePhoto,
List<String>? languageSpoken,
List<String>? vehicleType,
List<String>? servicesCities,
String? bio,
int? experience,
Address? address,
double? minimumCharges,
String? dob,
String? gender,
bool? negotiable,
ServiceLocation? serviceLocation,
}) {
return BecomeDriverModel(
drivingLicenceNumber: drivingLicenceNumber ?? this.drivingLicenceNumber,
drivingLicencePhoto: drivingLicencePhoto ?? this.drivingLicencePhoto,
aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
aadharCardPhotoFront: aadharCardPhotoFront ?? this.aadharCardPhotoFront,
aadharCardPhotoBack: aadharCardPhotoBack ?? this.aadharCardPhotoBack,
firstName: firstName ?? this.firstName,
lastName: lastName ?? this.lastName,
businessMobileNumber: businessMobileNumber ?? this.businessMobileNumber,
profilePhoto: profilePhoto ?? this.profilePhoto,
languageSpoken: languageSpoken ?? this.languageSpoken,
vehicleType: vehicleType ?? this.vehicleType,
servicesCities: servicesCities ?? this.servicesCities,
bio: bio ?? this.bio,
experience: experience ?? this.experience,
address: address ?? this.address,
minimumCharges: minimumCharges ?? this.minimumCharges,
dob: dob ?? this.dob,
gender: gender ?? this.gender,
negotiable: negotiable ?? this.negotiable,
serviceLocation: serviceLocation ?? this.serviceLocation,
);
}

Map<String, dynamic> toJson() {
return {
'drivingLicenceNumber': drivingLicenceNumber,
'drivingLicencePhoto': drivingLicencePhoto,
'aadharCardNumber': aadharCardNumber,
'aadharCardPhotoFront': aadharCardPhotoFront,
'aadharCardPhotoBack': aadharCardPhotoBack,
'firstName': firstName,
'lastName': lastName,
'businessMobileNumber': businessMobileNumber,
'profilePhoto': profilePhoto,
'languageSpoken': languageSpoken ?? [],
'vehicleType': vehicleType ?? [],
'servicesCities': servicesCities ?? [],
'bio': bio,
'experience': experience,
'address': address?.toJson(),
'minimumCharges': minimumCharges,
'dob': dob,
'gender': gender,
'negotiable': negotiable,
'serviceLocation': serviceLocation?.toJson(),
};
}

factory BecomeDriverModel.fromJson(Map<String, dynamic> json) {
return BecomeDriverModel(
drivingLicenceNumber: json['drivingLicenceNumber'] as String?,
drivingLicencePhoto: json['drivingLicencePhoto'] as String?,
aadharCardNumber: json['aadharCardNumber'] as String?,
aadharCardPhotoFront: json['aadharCardPhotoFront'] as String?,
aadharCardPhotoBack: json['aadharCardPhotoBack'] as String?,
firstName: json['firstName'] as String?,
lastName: json['lastName'] as String?,
businessMobileNumber: json['businessMobileNumber'] as String?,
profilePhoto: json['profilePhoto'] as String?,
languageSpoken: json['languageSpoken'] != null
? List<String>.from(json['languageSpoken'] as List)
    : null,
vehicleType: json['vehicleType'] != null
? List<String>.from(json['vehicleType'] as List)
    : null,
servicesCities: json['servicesCities'] != null
? List<String>.from(json['servicesCities'] as List)
    : null,
bio: json['bio'] as String?,
experience: json['experience'] as int?,
address: json['address'] != null
? Address.fromJson(json['address'] as Map<String, dynamic>)
    : null,
minimumCharges: (json['minimumCharges'] as num?)?.toDouble(),
dob: json['dob'] as String?,
gender: json['gender'] as String?,
negotiable: json['negotiable'] as bool?,
serviceLocation: json['serviceLocation'] != null
? ServiceLocation.fromJson(
json['serviceLocation'] as Map<String, dynamic>)
    : null,
);
}

@override
String toString() => jsonEncode(toJson());
}

class Address {
String? addressLine;
String? state;
String? city;
int? pincode;

Address({this.addressLine, this.state, this.city, this.pincode});

Address copyWith({
String? addressLine,
String? state,
String? city,
int? pincode,
}) {
return Address(
addressLine: addressLine ?? this.addressLine,
state: state ?? this.state,
city: city ?? this.city,
pincode: pincode ?? this.pincode,
);
}

Map<String, dynamic> toJson() => {
'addressLine': addressLine,
'state': state,
'city': city,
'pincode': pincode,
};

factory Address.fromJson(Map<String, dynamic> json) {
return Address(
addressLine: json['addressLine'] as String?,
state: json['state'] as String?,
city: json['city'] as String?,
pincode: int.tryParse(json['pincode'].toString()),
);
}

@override
String toString() => jsonEncode(toJson());
}

class ServiceLocation {
double? lat;
double? lng;

ServiceLocation({this.lat, this.lng});

ServiceLocation copyWith({double? lat, double? lng}) {
return ServiceLocation(lat: lat ?? this.lat, lng: lng ?? this.lng);
}

Map<String, dynamic> toJson() => {
'lat': lat,
'lng': lng,
};

factory ServiceLocation.fromJson(Map<String, dynamic> json) {
return ServiceLocation(
lat: (json['lat'] as num?)?.toDouble(),
lng: (json['lng'] as num?)?.toDouble(),
);
}

@override
String toString() => jsonEncode(toJson());
}
