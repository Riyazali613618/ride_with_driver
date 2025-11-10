// models/user_profile_model.dart

class UserProfileModel {
  final bool status;
  final String message;
  final UserData? data;

  UserProfileModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UserData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }
}

class UserData {
  final String firstName;
  final String lastName;
  final String? number;
  final String email;
  final String language;

  UserData({
    required this.firstName,
    required this.lastName,
    this.number,
    required this.email,
    required this.language,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      number: json['number'],
      email: json['email'] ?? '',
      language: json['language'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      if (number != null) 'number': number,
      'email': email,
      'language': language,
    };
  }

  UserData copyWith({
    String? firstName,
    String? lastName,
    String? number,
    String? email,
    String? language,
  }) {
    return UserData(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      number: number ?? this.number,
      email: email ?? this.email,
      language: language ?? this.language,
    );
  }
}

class UpdateProfileResponse {
  final bool status;
  final String message;

  UpdateProfileResponse({
    required this.status,
    required this.message,
  });

  factory UpdateProfileResponse.fromJson(Map<String, dynamic> json) {
    return UpdateProfileResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}
