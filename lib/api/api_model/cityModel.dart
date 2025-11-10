class CityModel {
  bool? success;
  String? message;
  List<Data>? data;

  CityModel({this.success, this.message, this.data});

  CityModel.fromJson(Map<String, dynamic> json) {
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
  StateId? stateId;
  StateId? countryId;
  bool? isActive;
  int? sortOrder;
  int? iV;
  String? createdAt;
  String? updatedAt;

  Data(
      {this.sId,
        this.name,
        this.stateId,
        this.countryId,
        this.isActive,
        this.sortOrder,
        this.iV,
        this.createdAt,
        this.updatedAt});

  Data.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    name = json['name'];
    stateId =
    json['stateId'] != null ? new StateId.fromJson(json['stateId']) : null;
    countryId = json['countryId'] != null
        ? new StateId.fromJson(json['countryId'])
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
    if (this.stateId != null) {
      data['stateId'] = this.stateId!.toJson();
    }
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

class StateId {
  String? sId;
  String? name;
  String? code;

  StateId({this.sId, this.name, this.code});

  StateId.fromJson(Map<String, dynamic> json) {
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
