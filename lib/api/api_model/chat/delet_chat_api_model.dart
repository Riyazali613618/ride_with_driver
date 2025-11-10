import 'chat_model.dart';

class DeleteChatApiResponse {
  final bool status;
  final String message;
  final List<ChatItem> data;

  DeleteChatApiResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory DeleteChatApiResponse.fromJson(Map<String, dynamic> json) {
    return DeleteChatApiResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => ChatItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    return 'ApiResponse(status: $status, message: $message, data: ${data.length} items)';
  }
}
