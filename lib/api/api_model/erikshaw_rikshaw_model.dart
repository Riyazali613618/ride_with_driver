// lib/models/rickshaw_profile_model.dart
class RickshawAddress {
  final String addressLine;
  final String city;
  final String state;
  final int pincode;
  final String country;

  RickshawAddress({
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
  });

  factory RickshawAddress.fromJson(Map<String, dynamic> json) {
    try {
      return RickshawAddress(
        addressLine: json['addressLine']?.toString() ?? '',
        city: json['city']?.toString() ?? '',
        state: json['state']?.toString() ?? '',
        pincode: int.tryParse(json['pincode']?.toString() ?? '0') ?? 0,
        country: json['country']?.toString() ?? '',
      );
    } catch (e) {
      throw Exception('Failed to parse RickshawAddress: $e');
    }
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

class RickshawProfile {
  final String myId;
  final String id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final RickshawAddress address;
  final String bio;
  final String photo;
  final double rating;
  final String userType;
  final String vehicleOwnership;
  final String vehicleName;
  final String vehicleModelName;
  final String manufacturing;
  final String fuelType;
  final int first2Km;
  final String airConditioning;
  final String vehicleType;
  final int seatingCapacity;
  final String vehicleNumber;
  final List<String> vehicleSpecifications;
  final List<String> servedLocation;
  final int minimumChargePerHour;
  final List<String> images;
  final List<String> videos;
  final bool isPriceNegotiable;
  final bool isVerifiedByAdmin;

  RickshawProfile({
    required this.myId,
    required this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.bio,
    required this.photo,
    required this.rating,
    required this.userType,
    required this.vehicleOwnership,
    required this.vehicleName,
    required this.vehicleModelName,
    required this.manufacturing,
    required this.fuelType,
    required this.first2Km,
    required this.airConditioning,
    required this.vehicleType,
    required this.seatingCapacity,
    required this.vehicleNumber,
    required this.vehicleSpecifications,
    required this.servedLocation,
    required this.minimumChargePerHour,
    required this.images,
    required this.videos,
    required this.isPriceNegotiable,
    required this.isVerifiedByAdmin,
  });

  factory RickshawProfile.fromJson(Map<String, dynamic> json) {
    try {
      return RickshawProfile(
        myId: json['myId']?.toString() ?? '',
        id: json['id']?.toString() ?? '',
        userId: json['userId']?.toString() ?? '',
        fullName: json['fullName']?.toString() ?? '',
        phoneNumber: json['phoneNumber']?.toString() ?? '',
        address: RickshawAddress.fromJson(json['address'] ?? {}),
        bio: json['bio']?.toString() ?? '',
        photo: json['photo']?.toString() ?? '',
        rating: double.tryParse(json['rating']?.toString() ?? '0.0') ?? 0.0,
        userType: json['userType']?.toString() ?? '',
        vehicleOwnership: json['vehicleOwnership']?.toString() ?? '',
        vehicleName: json['vehicleName']?.toString() ?? '',
        vehicleModelName: json['vehicleModelName']?.toString() ?? '',
        manufacturing: json['manufacturing']?.toString() ?? '',
        fuelType: json['fuelType']?.toString() ?? '',
        first2Km: int.tryParse(json['first2Km']?.toString() ?? '0') ?? 0,
        airConditioning: json['airConditioning']?.toString() ?? '',
        vehicleType: json['vehicleType']?.toString() ?? '',
        seatingCapacity:
            int.tryParse(json['seatingCapacity']?.toString() ?? '0') ?? 0,
        vehicleNumber: json['vehicleNumber']?.toString() ?? '',
        vehicleSpecifications:
            List<String>.from(json['vehicleSpecifications'] ?? []),
        servedLocation: List<String>.from(json['servedLocation'] ?? []),
        minimumChargePerHour:
            int.tryParse(json['minimumChargePerHour']?.toString() ?? '0') ?? 0,
        images: List<String>.from(json['images'] ?? []),
        videos: List<String>.from(json['videos'] ?? []),
        isPriceNegotiable: json['isPriceNegotiable'] ?? false,
        isVerifiedByAdmin: json['isVerifiedByAdmin'] ?? false,
      );
    } catch (e) {
      throw Exception('Failed to parse RickshawProfile: $e');
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'myId': myId,
      'id': id,
      'userId': userId,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address.toJson(),
      'bio': bio,
      'photo': photo,
      'rating': rating,
      'userType': userType,
      'vehicleOwnership': vehicleOwnership,
      'vehicleName': vehicleName,
      'vehicleModelName': vehicleModelName,
      'manufacturing': manufacturing,
      'fuelType': fuelType,
      'first2Km': first2Km,
      'airConditioning': airConditioning,
      'vehicleType': vehicleType,
      'seatingCapacity': seatingCapacity,
      'vehicleNumber': vehicleNumber,
      'vehicleSpecifications': vehicleSpecifications,
      'servedLocation': servedLocation,
      'minimumChargePerHour': minimumChargePerHour,
      'images': images,
      'videos': videos,
      'isPriceNegotiable': isPriceNegotiable,
      'isVerifiedByAdmin': isVerifiedByAdmin,
    };
  }
}

class RickshawApiResponse {
  final bool status;
  final String message;
  final RickshawProfile? data;

  RickshawApiResponse({
    required this.status,
    required this.message,
    this.data,
  });

  factory RickshawApiResponse.fromJson(Map<String, dynamic> json) {
    try {
      return RickshawApiResponse(
        status: json['status'] ?? false,
        message: json['message']?.toString() ?? '',
        data: json['data'] != null
            ? RickshawProfile.fromJson(json['data'])
            : null,
      );
    } catch (e) {
      throw Exception('Failed to parse RickshawApiResponse: $e');
    }
  }
}
