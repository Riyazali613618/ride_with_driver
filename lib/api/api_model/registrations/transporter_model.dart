// class TransporterModel {
//   final String? companyName;
//   final String? phoneNumber;
//   final Address address;
//   final String? photo;
//   final String? bio;
//   final String? addressType;
//   final String? gstin;
//   final String? businessRegistrationCertificate;
//   // final String? aadharCardNumber;
//   // final String? aadharCardPhoto;
//   // final String? aadharCardPhotoBack;
//
//   final String? transportationPermit;
//   final String? fleetSize;
//   final Counts counts;
//   final bool allowNegotiation;
//   final String? contactPersonName;
//   final Points points;
//
//   //gst no
//
//   TransporterModel({
//     required this.companyName,
//     required this.phoneNumber,
//     required this.address,
//     this.photo,
//     this.bio,
//     this.addressType,
//     this.gstin,
//     this.businessRegistrationCertificate,
//     // this.aadharCardNumber,
//     // this.aadharCardPhoto,
//     // this.aadharCardPhotoBack,
//     this.transportationPermit,
//     this.fleetSize,
//     required this.counts,
//     this.allowNegotiation = true,
//     this.contactPersonName,
//     required this.points,
//   });
//
//   factory TransporterModel.empty() => TransporterModel(
//         companyName: null,
//         phoneNumber: null,
//         address: Address.empty(),
//         counts: Counts.empty(),
//         points: Points.empty(),
//       );
//
//   Map<String, dynamic> toJson() => {
//         'companyName': companyName,
//         'phoneNumber': phoneNumber,
//         'address': address.toJson(),
//         'photo': photo,
//         'bio': bio,
//         'addressType': addressType,
//         'gstin': gstin,
//         'business_registration_certificate': businessRegistrationCertificate,
//         // 'aadharCardNumber': aadharCardNumber,
//         // 'aadharCardPhoto': aadharCardPhoto,
//         // 'aadharCardPhotoBack': aadharCardPhotoBack,
//         'transportationPermit': transportationPermit,
//         'fleetSize': fleetSize,
//         'counts': counts.toJson(),
//         'allowNegotiation': allowNegotiation,
//         'contactPersonName': contactPersonName,
//         'points': points.toJson(),
//       };
//
//   TransporterModel copyWith({
//     String? companyName,
//     String? phoneNumber,
//     Address? address,
//     String? photo,
//     String? bio,
//     String? addressType,
//     String? gstin,
//     String? businessRegistrationCertificate,
//     String? aadharCardNumber,
//     String? aadharCardPhoto,
//     String? aadharCardPhotoBack,
//     String? transportationPermit,
//     String? fleetSize,
//     Counts? counts,
//     bool? allowNegotiation,
//     String? contactPersonName,
//     Points? points,
//   }) {
//     return TransporterModel(
//       companyName: companyName ?? this.companyName,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       address: address ?? this.address,
//       photo: photo ?? this.photo,
//       bio: bio ?? this.bio,
//       addressType: addressType ?? this.addressType,
//       gstin: gstin ?? this.gstin,
//       businessRegistrationCertificate: businessRegistrationCertificate ??
//           this.businessRegistrationCertificate,
//       // aadharCardNumber: aadharCardNumber ?? this.aadharCardNumber,
//       // aadharCardPhoto: aadharCardPhoto ?? this.aadharCardPhoto,
//       // aadharCardPhotoBack: aadharCardPhotoBack ?? this.aadharCardPhotoBack,
//       transportationPermit: transportationPermit ?? this.transportationPermit,
//       fleetSize: fleetSize ?? this.fleetSize,
//       counts: counts ?? this.counts,
//       allowNegotiation: allowNegotiation ?? this.allowNegotiation,
//       contactPersonName: contactPersonName ?? this.contactPersonName,
//       points: points ?? this.points,
//     );
//   }
// }
//
// class Address {
//   final String? addressLine;
//   final String? state;
//   final String? city;
//   final int? pincode;
//
//   Address({
//     this.addressLine,
//     this.state,
//     this.city,
//     this.pincode,
//   });
//
//   factory Address.empty() => Address(
//         addressLine: null,
//         state: null,
//         city: null,
//         pincode: null,
//       );
//
//   Map<String, dynamic> toJson() => {
//         'addressLine': addressLine,
//         'state': state,
//         'city': city,
//         'pincode': pincode,
//       };
//
//   Address copyWith({
//     String? addressLine,
//     String? state,
//     String? city,
//     int? pincode,
//   }) {
//     return Address(
//       addressLine: addressLine ?? this.addressLine,
//       state: state ?? this.state,
//       city: city ?? this.city,
//       pincode: pincode ?? this.pincode,
//     );
//   }
// }
//
// class Counts {
//   final int car;
//   final int bus;
//   final int van;
//
//   Counts({
//     this.car = 0,
//     this.bus = 0,
//     this.van = 0,
//   });
//
//   factory Counts.empty() => Counts(car: 0, bus: 0, van: 0);
//
//   Map<String, dynamic> toJson() => {
//         'car': car,
//         'bus': bus,
//         'van': van,
//       };
//
//   Counts copyWith({
//     int? car,
//     int? bus,
//     int? van,
//   }) {
//     return Counts(
//       car: car ?? this.car,
//       bus: bus ?? this.bus,
//       van: van ?? this.van,
//     );
//   }
// }
//
// class Points {
//   final bool useLoginNumber;
//   final bool showNumberOnAppWebsite;
//   final bool enableChat;
//
//   Points({
//     this.useLoginNumber = true,
//     this.showNumberOnAppWebsite = true,
//     this.enableChat = true,
//   });
//
//   factory Points.empty() => Points(
//         useLoginNumber: true,
//         showNumberOnAppWebsite: true,
//         enableChat: true,
//       );
//
//   Map<String, dynamic> toJson() => {
//         'use_login_number': useLoginNumber,
//         'show_number_on_app_website': showNumberOnAppWebsite,
//         'enable_chat': enableChat,
//       };
//
//   Points copyWith({
//     bool? useLoginNumber,
//     bool? showNumberOnAppWebsite,
//     bool? enableChat,
//   }) {
//     return Points(
//       useLoginNumber: useLoginNumber ?? this.useLoginNumber,
//       showNumberOnAppWebsite:
//           showNumberOnAppWebsite ?? this.showNumberOnAppWebsite,
//       enableChat: enableChat ?? this.enableChat,
//     );
//   }
// }
class TransporterModel {
  final String? firstName;
  final String? companyName;
  final String? phoneNumber;
  final Address address;
  final String? photo;
  final String? profilePhoto;
  final String? bio;
  final String? gstin;
  final String? transportationPermit;
  final String? fleetSize;
  final Counts counts;
  final String? contactPersonName;

  TransporterModel({
    required this.firstName,
    required this.companyName,
    required this.phoneNumber,
    required this.address,
    this.photo,
    this.profilePhoto,
    this.bio,
    this.gstin,
    this.transportationPermit,
    this.fleetSize,
    required this.counts,
    this.contactPersonName,
  });

  factory TransporterModel.empty() => TransporterModel(
        firstName: null,
        companyName: null,
        phoneNumber: null,
        address: Address.empty(),
        counts: Counts.empty(),
      );

  factory TransporterModel.fromJson(Map<String, dynamic> json) {
    return TransporterModel(
      firstName: json['firstName'],
      companyName: json['companyName'],
      phoneNumber: json['phoneNumber'],
      address: json['address'] != null
          ? Address.fromJson(json['address'])
          : Address.empty(),
      photo: json['photo'],
      profilePhoto: json['profilePhoto'],
      bio: json['bio'],
      gstin: json['gstin'],
      transportationPermit: json['transportationPermit'],
      fleetSize: json['fleetSize'],
      counts: json['counts'] != null
          ? Counts.fromJson(json['counts'])
          : Counts.empty(),
      contactPersonName: json['contactPersonName'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'firstName': firstName,
      'companyName': companyName,
      'phoneNumber': phoneNumber,
      'address': address.toJson(),
      'bio': bio,
      'gstin': gstin,
      'fleetSize': fleetSize,
      'counts': counts.toJson(),
      'contactPersonName': contactPersonName,
    };
    if (photo != null) data['photo'] = photo;
    if (profilePhoto != null) data['profilePhoto'] = profilePhoto;
    if (transportationPermit != null) {
      data['transportationPermit'] = transportationPermit;
    }

    return data;
  }

  TransporterModel copyWith({
    String? firstName,
    String? companyName,
    String? phoneNumber,
    Address? address,
    String? profilePhoto,
    String? photo,
    String? bio,
    String? gstin,
    String? transportationPermit,
    String? fleetSize,
    Counts? counts,
    String? contactPersonName,
  }) {
    return TransporterModel(
      firstName: firstName ?? this.firstName,
      companyName: companyName ?? this.companyName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      photo: photo ?? this.photo,
      profilePhoto: profilePhoto ?? this.profilePhoto,
      bio: bio ?? this.bio,
      gstin: gstin ?? this.gstin,
      transportationPermit: transportationPermit ?? this.transportationPermit,
      fleetSize: fleetSize ?? this.fleetSize,
      counts: counts ?? this.counts,
      contactPersonName: contactPersonName ?? this.contactPersonName,
    );
  }
}

class Address {
  final String? addressLine;
  final String? state;
  final String? city;
  final int? pincode;

  Address({
    this.addressLine,
    this.state,
    this.city,
    this.pincode,
  });

  factory Address.empty() => Address(
        addressLine: null,
        state: null,
        city: null,
        pincode: null,
      );

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      addressLine: json['addressLine'],
      state: json['state'],
      city: json['city'],
      pincode: json['pincode'],
    );
  }

  Map<String, dynamic> toJson() => {
        'addressLine': addressLine,
        'state': state,
        'city': city,
        'pincode': pincode,
      };

  /// 👇 Add this back
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
}

class Counts {
  final int car;
  final int bus;
  final int van;

  Counts({
    this.car = 0,
    this.bus = 0,
    this.van = 0,
  });

  factory Counts.empty() => Counts(car: 0, bus: 0, van: 0);

  factory Counts.fromJson(Map<String, dynamic> json) {
    return Counts(
      car: json['car'] ?? 0,
      bus: json['bus'] ?? 0,
      van: json['van'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'car': car,
        'bus': bus,
        'van': van,
      };

  /// 👇 Add this back
  Counts copyWith({
    int? car,
    int? bus,
    int? van,
  }) {
    return Counts(
      car: car ?? this.car,
      bus: bus ?? this.bus,
      van: van ?? this.van,
    );
  }
}
