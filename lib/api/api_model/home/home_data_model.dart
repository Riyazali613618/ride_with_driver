class HomeInfoResponse {
  final bool status;
  final String message;
  final HomeData data;

  HomeInfoResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory HomeInfoResponse.fromJson(Map<String, dynamic> json) {
    return HomeInfoResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: HomeData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class HomeData {
  final List<String> banners;
  final bool showDashboard;

  HomeData({
    required this.banners,
    required this.showDashboard,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      banners: List<String>.from(json['banners'] ?? []),
      showDashboard: json['showDashboard'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'banners': banners,
      'showDashboard': showDashboard,
    };
  }
}
