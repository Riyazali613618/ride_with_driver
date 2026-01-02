class VehicleTypeModel {
  bool? success;
  String? message;
  Data? data;

  VehicleTypeModel({this.success, this.message, this.data});

  VehicleTypeModel.fromJson(Map<String, dynamic> json) {
    success = json['success'];
    message = json['message'];
    data = json['data'] != null ? new Data.fromJson(json['data']) : null;
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

class Data {
  List<Categories>? categories;

  Data({this.categories});

  Data.fromJson(Map<String, dynamic> json) {
    if (json['categories'] != null) {
      categories = <Categories>[];
      json['categories'].forEach((v) {
        categories!.add(new Categories.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.categories != null) {
      data['categories'] = this.categories!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Categories {
  String? sId;
  String? code;
  String? description;
  SeatingLimits? seatingLimits;
  List<String>? allowedForPartners;
  bool? isActive;
  List<String>? brands;
  int? iV;
  String? createdAt;
  String? updatedAt;

  Categories(
      {this.sId,
        this.code,
        this.description,
        this.seatingLimits,
        this.allowedForPartners,
        this.isActive,
        this.brands,
        this.iV,
        this.createdAt,
        this.updatedAt});

  Categories.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];
    code = json['code'];
    description = json['description'];
    seatingLimits = json['seatingLimits'] != null
        ? new SeatingLimits.fromJson(json['seatingLimits'])
        : null;
    allowedForPartners = json['allowedForPartners'].cast<String>();
    isActive = json['isActive'];
    brands = json['brands'].cast<String>();
    iV = json['__v'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['_id'] = this.sId;
    data['code'] = this.code;
    data['description'] = this.description;
    if (this.seatingLimits != null) {
      data['seatingLimits'] = this.seatingLimits!.toJson();
    }
    data['allowedForPartners'] = this.allowedForPartners;
    data['isActive'] = this.isActive;
    data['brands'] = this.brands;
    data['__v'] = this.iV;
    data['createdAt'] = this.createdAt;
    data['updatedAt'] = this.updatedAt;
    return data;
  }
}

class SeatingLimits {
  int? min;
  int? max;

  SeatingLimits({this.min, this.max});

  SeatingLimits.fromJson(Map<String, dynamic> json) {
    min = json['min'];
    max = json['max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['min'] = this.min;
    data['max'] = this.max;
    return data;
  }
}