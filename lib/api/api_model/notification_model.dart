class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? image;
  final DateTime date;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.image,
    required this.date,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      image: json['image'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'image': image,
      'date': date.toIso8601String(),
    };
  }
}

class NotificationResponse {
  final bool status;
  final String message;
  final List<NotificationModel> data;

  NotificationResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory NotificationResponse.fromJson(Map<String, dynamic> json) {
    return NotificationResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((item) => NotificationModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
