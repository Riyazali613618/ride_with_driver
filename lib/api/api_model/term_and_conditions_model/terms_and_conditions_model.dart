class TermsResponse {
  final bool status;
  final String message;
  final TermsData data;

  TermsResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory TermsResponse.fromJson(Map<String, dynamic> json) {
    return TermsResponse(
      status: json['success'] ?? false,
      message: json['message'] ?? '',
      data: TermsData.fromJson(json['data'] ?? {}),
    );
  }
}

class TermsData {
  final String title;
  final String content;

  TermsData({
    required this.title,
    required this.content,
  });

  factory TermsData.fromJson(Map<String, dynamic> json) {
    return TermsData(
      title: json['title'] ?? '',
      content: json['content'] ?? '',
    );
  }
}
