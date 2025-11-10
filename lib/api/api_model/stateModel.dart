class StateModel {
  bool? success;
  String? message;
  List<Data>? data;

  StateModel({this.success, this.message, this.data});

  StateModel.fromJson(Map<String, dynamic> json) {
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
  String? sId;
  String? name;
  String? code;
  CountryId? countryId;
  bool? isActive;
  int? sortOrder;
  int? iV;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.sId,
        this.name,
        this.code,
        this.countryId,
        this.isActive,
        this.sortOrder,
        this.iV,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    code = json['code'];
    countryId = json['countryId'] != null
        ? new CountryId.fromJson(json['countryId'])
        : null;
    isActive = json['isActive'];
    sortOrder = json['sortOrder'];
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['code'] = this.code;
    if (this.countryId != null) {
      data['countryId'] = this.countryId!.toJson();
    }
    data['isActive'] = this.isActive;
    data['sortOrder'] = this.sortOrder;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class CountryId {
  String? sId;
  String? name;
  String? code;

  CountryId({this.sId, this.name, this.code});

  CountryId.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    code = json['code'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['code'] = this.code;
    return data;
  }
}
