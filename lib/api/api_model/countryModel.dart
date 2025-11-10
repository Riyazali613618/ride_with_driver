class CountryModel {
  bool? success;
  String? message;
  List<Data>? data;

  CountryModel({this.success, this.message, this.data});

  CountryModel.fromJson(Map<String, dynamic> json) {
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
  String? id;
  String? name;
  String? code;
  String? dialCode;
  String? countryFlag;
  String? countryFooter;

  Data(
      {this.id,
        this.name,
        this.code,
        this.dialCode,
        this.countryFlag,
        this.countryFooter});

  Data.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    code = json['code'];
    dialCode = json['dialCode'];
    countryFlag = json['country_flag'];
    countryFooter = json['country_footer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['code'] = this.code;
    data['dialCode'] = this.dialCode;
    data['country_flag'] = this.countryFlag;
    data['country_footer'] = this.countryFooter;
    return data;
  }
}
