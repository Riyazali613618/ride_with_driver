class LoginModel {
  final bool status;
  final String message;
  final String data;

  LoginModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    return LoginModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] ?? '',
    );
  }
}
