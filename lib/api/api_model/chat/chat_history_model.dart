class ChatHistoryResponse {
  final bool status;
  final String message;
  final List<ChatMessage> data;

  ChatHistoryResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ChatHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ChatHistoryResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List?)
              ?.map((item) => ChatMessage.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class ChatMessage {
  final bool isSent;
  final String message;
  final String messageId;
  final String messageType;
  final String at;

  ChatMessage({
    required this.isSent,
    required this.message,
    required this.messageId,
    required this.messageType,
    required this.at,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      isSent: json['isSent'] ?? false,
      message: json['message'] ?? '',
      messageId: json['messageId'] ?? '',
      messageType: json['messageType'] ?? 'TEXT',
      at: json['at'] ?? '',
    );
  }

  String get formattedTime {
    try {
      final dateTime = DateTime.parse(at);
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      return "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return '';
    }
  }

  bool get isMediaMessage =>
      ['IMAGE', 'VIDEO', 'DOCUMENT'].contains(messageType);

  String get mediaIcon {
    switch (messageType) {
      case 'IMAGE':
        return '🖼️';
      case 'VIDEO':
        return '🎥';
      case 'DOCUMENT':
        return '📄';
      case 'AUDIO':
        return '🎵';
      default:
        return '';
    }
  }
}
