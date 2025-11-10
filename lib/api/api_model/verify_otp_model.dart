class OtpVerificationRequest {
  final String number;
  final String otp;

  OtpVerificationRequest({required this.number, required this.otp});

  Map<String, dynamic> toJson() => {
        'number': number,
        'otp': otp,
      };
}

class OtpVerificationResponse {
  bool? success;
  String? message;
  OtpVerificationData? data;

  OtpVerificationResponse({this.success, this.message, this.data});

  OtpVerificationResponse.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new OtpVerificationData.fromJson(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['success'] = this.success;
    data['message'] = this.message;
    if (this.data != null) {
      data['data'] = this.data!.toJson();
    }
    return data;
  }
}

class OtpVerificationData {
  String? userId;
  String? name;
  bool? isFirstTimeUser;
  String? usertype;
  bool? isAllowed;
  String? message;
  String? accessToken;
  String? refreshToken;
  String? accessTokenExpiresIn;
  String? refreshTokenExpiresIn;
  Language? language;
  String? fcm;
  Country? country;

  OtpVerificationData(
      {this.userId,
        this.name,
        this.isFirstTimeUser,
        this.usertype,
        this.isAllowed,
        this.message,
        this.accessToken,
        this.refreshToken,
        this.accessTokenExpiresIn,
        this.refreshTokenExpiresIn,
        this.language,
        this.fcm,
        this.country});

  OtpVerificationData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    name = json['name'];
    isFirstTimeUser = json['isFirstTimeUser'];
    usertype = json['usertype'];
    isAllowed = json['isAllowed'];
    message = json['message'];
    accessToken = json['accessToken'];
    refreshToken = json['refreshToken'];
    accessTokenExpiresIn = json['accessTokenExpiresIn'];
    refreshTokenExpiresIn = json['refreshTokenExpiresIn'];
    language = json['language'] != null
        ? new Language.fromJson(json['language'])
        : null;
    fcm = json['fcm'];
    country =
    json['country'] != null ? new Country.fromJson(json['country']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['name'] = this.name;
    data['isFirstTimeUser'] = this.isFirstTimeUser;
    data['usertype'] = this.usertype;
    data['isAllowed'] = this.isAllowed;
    data['message'] = this.message;
    data['accessToken'] = this.accessToken;
    data['refreshToken'] = this.refreshToken;
    data['accessTokenExpiresIn'] = this.accessTokenExpiresIn;
    data['refreshTokenExpiresIn'] = this.refreshTokenExpiresIn;
    if (this.language != null) {
      data['language'] = this.language!.toJson();
    }
    data['fcm'] = this.fcm;
    if (this.country != null) {
      data['country'] = this.country!.toJson();
    }
    return data;
  }
}

class Language {
  String? id;
  String? name;

  Language({this.id, this.name});

  Language.fromJson(Map<String, dynamic> json) {
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

