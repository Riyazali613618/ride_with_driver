import 'dart:convert';

class BecomeDriverModel {
String? profilePhoto;
String? firstName;
String? lastName;
String? businessMobileNumber;
String? bio;
Address? address;
String? aadharCardNumber;
String? aadharCardPhotoFront;
String? aadharCardPhotoBack;
String? drivingLicenceNumber;
String? drivingLicencePhoto;
String? transportationPermitPhoto;
FleetSize? independentCarOwnerFleetSize;

BecomeDriverModel({
this.profilePhoto,
this.firstName,
this.lastName,
this.businessMobileNumber,
this.bio,
this.address,
this.aadharCardNumber,
this.aadharCardPhotoFront,
this.aadharCardPhotoBack,
this.drivingLicenceNumber,
this.drivingLicencePhoto,
this.transportationPermitPhoto,
this.independentCarOwnerFleetSize,
});

BecomeDriverModel copyWith({
String? profilePhoto,
String? firstName,
String? lastName,
String? businessMobileNumber,
String? bio,
Address? address,
String? aadharCardNumber,
String? aadharCardPhotoFront,
String? aadharCardPhotoBack,
String? drivingLicenceNumber,
String? drivingLicencePhoto,
String? transportationPermitPhoto,
FleetSize? independentCarOwnerFleetSize,
}) {
return BecomeDriverModel(
profilePhoto: profilePhoto ?? this.profilePhoto,
firstName: firstName ?? this.firstName,
lastName: lastName ?? this.lastName,
businessMobileNumber:
businessMobileNumber ?? this.businessMobileNumber,
bio: bio ?? this.bio,
address: address ?? this.address,
aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
aadharCardPhotoFront: aadharCardPhotoFront ?? this.aadharCardPhotoFront,
aadharCardPhotoBack: aadharCardPhotoBack ?? this.aadharCardPhotoBack,
drivingLicenceNumber: drivingLicenceNumber ?? this.drivingLicenceNumber,
drivingLicencePhoto: drivingLicencePhoto ?? this.drivingLicencePhoto,
transportationPermitPhoto:
transportationPermitPhoto ?? this.transportationPermitPhoto,
independentCarOwnerFleetSize:
independentCarOwnerFleetSize ?? this.independentCarOwnerFleetSize,
);
}

Map<String, dynamic> toJson() {
return {
'profilePhoto': profilePhoto,
'firstName': firstName,
'lastName': lastName,
'businessMobileNumber': businessMobileNumber,
'bio': bio,
'address': address?.toJson(),
'aadharCardNumber': aadharCardNumber,
'aadharCardPhotoFront': aadharCardPhotoFront,
'aadharCardPhotoBack': aadharCardPhotoBack,
'drivingLicenceNumber': drivingLicenceNumber,
'drivingLicencePhoto': drivingLicencePhoto,
'transportationPermitPhoto': transportationPermitPhoto,
'independentCarOwnerFleetSize':
independentCarOwnerFleetSize?.toJson(),
};
}

factory BecomeDriverModel.fromJson(Map<String, dynamic> json) {
return BecomeDriverModel(
profilePhoto: json['profilePhoto'] as String?,
firstName: json['firstName'] as String?,
lastName: json['lastName'] as String?,
businessMobileNumber: json['businessMobileNumber'] as String?,
bio: json['bio'] as String?,
address: json['address'] != null
? Address.fromJson(json['address'] as Map<String, dynamic>)
    : null,
aadharCardNumber: json['aadharCardNumber'] as String?,
aadharCardPhotoFront: json['aadharCardPhotoFront'] as String?,
aadharCardPhotoBack: json['aadharCardPhotoBack'] as String?,
drivingLicenceNumber: json['drivingLicenceNumber'] as String?,
drivingLicencePhoto: json['drivingLicencePhoto'] as String?,
transportationPermitPhoto: json['transportationPermitPhoto'] as String?,
independentCarOwnerFleetSize: json['independentCarOwnerFleetSize'] != null
? FleetSize.fromJson(
json['independentCarOwnerFleetSize'] as Map<String, dynamic>)
    : null,
);
}

@override
String toString() => jsonEncode(toJson());
}

class Address {
String? addressLine;
int? pincode;
String? city;
String? state;

Address({this.addressLine, this.pincode, this.city, this.state});

Address copyWith({
String? addressLine,
int? pincode,
String? city,
String? state,
}) {
return Address(
addressLine: addressLine ?? this.addressLine,
pincode: pincode ?? this.pincode,
city: city ?? this.city,
state: state ?? this.state,
);
}

Map<String, dynamic> toJson() {
return {
'addressLine': addressLine,
'pincode': pincode,
'city': city,
'state': state,
};
}

factory Address.fromJson(Map<String, dynamic> json) {
return Address(
addressLine: json['addressLine'] as String?,
pincode: json['pincode'] as int?,
city: json['city'] as String?,
state: json['state'] as String?,
);
}

@override
String toString() => jsonEncode(toJson());
}

class FleetSize {
int? cars;
int? minivans;
int? buses;
    int? suvs;

FleetSize({this.cars, this.minivans,this.buses,this.suvs});

FleetSize copyWith({
int? cars,
int? minivans,
  int? buses,
  int? suvs
}) {
return FleetSize(
cars: cars ?? this.cars,
minivans: minivans ?? this.minivans,
  buses: buses ?? this.buses,
);
}

Map<String, dynamic> toJson() {
return {
'cars': cars,
'minivans': minivans,
  'buses':buses,
  'suvs':suvs
};
}

factory FleetSize.fromJson(Map<String, dynamic> json) {
return FleetSize(
cars: json['cars'] as int?,
minivans: json['minivans'] as int?,
  buses: json['buses'] as int?,
  suvs: json['suvs'] as int?
);
}

@override
String toString() => jsonEncode(toJson());
}
