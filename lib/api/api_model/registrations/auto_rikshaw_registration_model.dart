class AutoRickshawModel {
String? firstName;
String? lastName;
String? businessMobileNumber;
String? profilePhoto;
String? bio;
Address? address;
String? aadharCardNumber;
String? aadharCardPhotoFront;
String? aadharCardPhotoBack;
String? drivingLicenceNumber;
String? drivingLicencePhoto;
String? vehicleNumber;
int? seatingCapacity;
List<String>? vehicleImages;
String? vehicleVideo;
double? minimumCharges;
bool? negotiable;
ServiceLocation? serviceLocation;
List<String>? languageSpoken;
List<String>? servicesCities;

AutoRickshawModel({
this.firstName,
this.lastName,
this.businessMobileNumber,
this.profilePhoto,
this.bio,
this.address,
this.aadharCardNumber,
this.aadharCardPhotoFront,
this.aadharCardPhotoBack,
this.drivingLicenceNumber,
this.drivingLicencePhoto,
this.vehicleNumber,
this.seatingCapacity,
this.vehicleImages,
this.vehicleVideo,
this.minimumCharges,
this.negotiable,
this.serviceLocation,
this.languageSpoken,
this.servicesCities,
});

factory AutoRickshawModel.fromJson(Map<String, dynamic> json) {
return AutoRickshawModel(
firstName: json['firstName'],
lastName: json['lastName'],
businessMobileNumber: json['businessMobileNumber'],
profilePhoto: json['profilePhoto'],
bio: json['bio'],
address: json['address'] != null ? Address.fromJson(json['address']) : null,
aadharCardNumber: json['aadharCardNumber'],
aadharCardPhotoFront: json['aadharCardPhotoFront'],
aadharCardPhotoBack: json['aadharCardPhotoBack'],
drivingLicenceNumber: json['drivingLicenceNumber'],
drivingLicencePhoto: json['drivingLicencePhoto'],
vehicleNumber: json['vehicleNumber'],
seatingCapacity: json['seatingCapacity'],
vehicleImages: json['vehicleImages'] != null
? List<String>.from(json['vehicleImages'])
    : null,
vehicleVideo: json['vehicleVideo'],
minimumCharges: json['minimumCharges'] != null
? (json['minimumCharges'] as num).toDouble()
    : null,
negotiable: json['negotiable'],
serviceLocation: json['serviceLocation'] != null
? ServiceLocation.fromJson(json['serviceLocation'])
    : null,
languageSpoken: json['languageSpoken'] != null
? List<String>.from(json['languageSpoken'])
    : null,
servicesCities: json['servicesCities'] != null
? List<String>.from(json['servicesCities'])
    : null,
);
}

Map<String, dynamic> toJson() {
final Map<String, dynamic> data = <String, dynamic>{};
if (firstName != null) data['firstName'] = firstName;
if (lastName != null) data['lastName'] = lastName;
if (businessMobileNumber != null) {
data['businessMobileNumber'] = businessMobileNumber;
}
if (profilePhoto != null) data['profilePhoto'] = profilePhoto;
if (bio != null) data['bio'] = bio;
if (address != null) data['address'] = address!.toJson();
if (aadharCardNumber != null) data['aadharCardNumber'] = aadharCardNumber;
if (aadharCardPhotoFront != null) {
data['aadharCardPhotoFront'] = aadharCardPhotoFront;
}
if (aadharCardPhotoBack != null) {
data['aadharCardPhotoBack'] = aadharCardPhotoBack;
}
if (drivingLicenceNumber != null) {
data['drivingLicenceNumber'] = drivingLicenceNumber;
}
if (drivingLicencePhoto != null) {
data['drivingLicencePhoto'] = drivingLicencePhoto;
}
if (vehicleNumber != null) data['vehicleNumber'] = vehicleNumber;
if (seatingCapacity != null) data['seatingCapacity'] = seatingCapacity;
if (vehicleImages != null) data['vehicleImages'] = vehicleImages;
if (vehicleVideo != null) data['vehicleVideo'] = vehicleVideo;
if (minimumCharges != null) data['minimumCharges'] = minimumCharges;
if (negotiable != null) data['negotiable'] = negotiable;
if (serviceLocation != null) {
data['serviceLocation'] = serviceLocation!.toJson();
}
if (languageSpoken != null) data['languageSpoken'] = languageSpoken;
if (servicesCities != null) data['servicesCities'] = servicesCities;
return data;
}

AutoRickshawModel copyWith({
String? firstName,
String? lastName,
String? businessMobileNumber,
String? profilePhoto,
String? bio,
Address? address,
String? aadharCardNumber,
String? aadharCardPhotoFront,
String? aadharCardPhotoBack,
String? drivingLicenceNumber,
String? drivingLicencePhoto,
String? vehicleNumber,
int? seatingCapacity,
List<String>? vehicleImages,
String? vehicleVideo,
double? minimumCharges,
bool? negotiable,
ServiceLocation? serviceLocation,
List<String>? languageSpoken,
List<String>? servicesCities,
}) {
return AutoRickshawModel(
firstName: firstName ?? this.firstName,
lastName: lastName ?? this.lastName,
businessMobileNumber: businessMobileNumber ?? this.businessMobileNumber,
profilePhoto: profilePhoto ?? this.profilePhoto,
bio: bio ?? this.bio,
address: address ?? this.address,
aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
aadharCardPhotoFront: aadharCardPhotoFront ?? this.aadharCardPhotoFront,
aadharCardPhotoBack: aadharCardPhotoBack ?? this.aadharCardPhotoBack,
drivingLicenceNumber: drivingLicenceNumber ?? this.drivingLicenceNumber,
drivingLicencePhoto: drivingLicencePhoto ?? this.drivingLicencePhoto,
vehicleNumber: vehicleNumber ?? this.vehicleNumber,
seatingCapacity: seatingCapacity ?? this.seatingCapacity,
vehicleImages: vehicleImages ?? this.vehicleImages,
vehicleVideo: vehicleVideo ?? this.vehicleVideo,
minimumCharges: minimumCharges ?? this.minimumCharges,
negotiable: negotiable ?? this.negotiable,
serviceLocation: serviceLocation ?? this.serviceLocation,
languageSpoken: languageSpoken ?? this.languageSpoken,
servicesCities: servicesCities ?? this.servicesCities,
);
}

@override
String toString() {
return 'AutoRickshawModel(firstName: $firstName, lastName: $lastName, businessMobileNumber: $businessMobileNumber, vehicleNumber: $vehicleNumber, negotiable: $negotiable)';
}
}

class Address {
String? addressLine;
String? city;
String? state;
String? country;
int? pincode;

Address({this.addressLine, this.city, this.state, this.country, this.pincode});

factory Address.fromJson(Map<String, dynamic> json) {
return Address(
addressLine: json['addressLine'],
city: json['city'],
state: json['state'],
country: json['country'],
pincode: json['pincode'],
);
}

Map<String, dynamic> toJson() {
final Map<String, dynamic> data = <String, dynamic>{};
if (addressLine != null) data['addressLine'] = addressLine;
if (city != null) data['city'] = city;
if (state != null) data['state'] = state;
if (country != null) data['country'] = country;
if (pincode != null) data['pincode'] = pincode;
return data;
}

Address copyWith({
String? addressLine,
String? city,
String? state,
String? country,
int? pincode,
}) {
return Address(
addressLine: addressLine ?? this.addressLine,
city: city ?? this.city,
state: state ?? this.state,
country: country ?? this.country,
pincode: pincode ?? this.pincode,
);
}

@override
String toString() {
return 'Address(addressLine: $addressLine, city: $city, state: $state, country: $country, pincode: $pincode)';
}
}

class ServiceLocation {
double? lat;
double? lng;

ServiceLocation({this.lat, this.lng});

factory ServiceLocation.fromJson(Map<String, dynamic> json) {
return ServiceLocation(
lat: (json['lat'] as num?)?.toDouble(),
lng: (json['lng'] as num?)?.toDouble(),
);
}

Map<String, dynamic> toJson() {
final Map<String, dynamic> data = <String, dynamic>{};
if (lat != null) data['lat'] = lat;
if (lng != null) data['lng'] = lng;
return data;
}

ServiceLocation copyWith({
double? lat,
double? lng,
}) {
return ServiceLocation(
lat: lat ?? this.lat,
lng: lng ?? this.lng,
);
}

@override
String toString() {
return 'ServiceLocation(lat: $lat, lng: $lng)';
}
}
