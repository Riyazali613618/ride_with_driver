class FilterModel {
  final String name;
  final bool multiple;
  final List<String> values;

  FilterModel({
    required this.name,
    required this.multiple,
    required this.values,
  });

  factory FilterModel.fromJson(Map<String, dynamic> json) {
    return FilterModel(
      name: json['name'] as String,
      multiple: json['multiple'] as bool,
      values: List<String>.from(json['values'] as List),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'multiple': multiple,
      'values': values,
    };
  }
}

class FilterResponse {
  final bool status;
  final String message;
  final List<FilterModel> data;

  FilterResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory FilterResponse.fromJson(Map<String, dynamic> json) {
    return FilterResponse(
      status: json['status'] as bool,
      message: json['message'] as String,
      data: ((json['data'] as List?) ?? [])
          .map((item) => FilterModel.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
