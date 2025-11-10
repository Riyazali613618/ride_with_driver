import 'dart:developer' as developer;

/// Represents a chat item with all necessary properties
class ChatItem {
  final String chatId;
  final String name;
  final String image;
  // final String userId;
  final String id;
  final DateTime? timestamp; // Nullable since it can be null in API
  // final String cause;

  const ChatItem({
    required this.chatId,
    required this.name,
    required this.image,
    // required this.userId,
    required this.id,
    this.timestamp,
    // required this.cause,
  });

  /// Creates a ChatItem from JSON with comprehensive error handling
  factory ChatItem.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('ChatItem.fromJson: $json', name: 'ChatItem');

      // Extract and validate required fields
      final chatId = _extractStringField(json, 'chatId', 'ChatItem');
      final name = _extractStringField(json, 'name', 'ChatItem', defaultValue: 'Unknown User');
      final image = _extractStringField(json, 'image', 'ChatItem', allowEmpty: true);
      // final userId = _extractStringField(json, 'userId', 'ChatItem');
      final id = _extractStringField(json, 'id', 'ChatItem');
      // final cause = _extractStringField(json, 'cause', 'ChatItem');

      // Handle timestamp separately as it can be null
      DateTime? parsedTimestamp;
      if (json['timestamp'] != null) {
        try {
          parsedTimestamp = DateTime.parse(json['timestamp'].toString());
          developer.log('Parsed timestamp: $parsedTimestamp', name: 'ChatItem');
        } catch (e) {
          developer.log('Error parsing timestamp: $e, using null',
              name: 'ChatItem');
          parsedTimestamp = null;
        }
      } else {
        developer.log('Timestamp is null', name: 'ChatItem');
      }

      final chatItem = ChatItem(
        chatId: chatId,
        name: name,
        image: image,
        // userId: userId,
        id: id,
        timestamp: parsedTimestamp,
        // cause: cause,
      );

      developer.log('Successfully created ChatItem: $chatItem',
          name: 'ChatItem');
      return chatItem;
    } catch (e, stackTrace) {
      developer.log(
        'Error creating ChatItem from JSON: $e',
        name: 'ChatItem',
        error: e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// Helper method to extract string fields with validation
  static String _extractStringField(
      Map<String, dynamic> json,
      String fieldName,
      String className, {
        String? defaultValue,
        bool allowEmpty = false,
      }) {
    final value = json[fieldName];
    if (value == null) {
      if (defaultValue != null) {
        developer.log('Using default value for $fieldName: $defaultValue', name: className);
        return defaultValue;
      }
      throw FormatException('Missing required field: $fieldName in $className');
    }
    final stringValue = value.toString().trim();
    if (stringValue.isEmpty && !allowEmpty) {
      if (defaultValue != null) {
        developer.log('Using default value for empty $fieldName: $defaultValue', name: className);
        return defaultValue;
      }
      throw FormatException('Empty required field: $fieldName in $className');
    }

    developer.log('Extracted $fieldName: $stringValue', name: className);
    return stringValue;
  }
  /// Converts the ChatItem to JSON
  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'name': name,
      'image': image,
      // 'userId': userId,
      'id': id,
      'timestamp': timestamp?.toIso8601String(),
      // 'cause': cause,
    };
  }

  /// Creates a copy of this ChatItem with optional field updates
  ChatItem copyWith({
    String? chatId,
    String? name,
    String? image,
    String? userId,
    String? id,
    DateTime? timestamp,
    String? cause,
  }) {
    return ChatItem(
      chatId: chatId ?? this.chatId,
      name: name ?? this.name,
      image: image ?? this.image,
      // userId: userId ?? this.userId,
      id: id ?? this.id,
      timestamp: timestamp ?? this.timestamp,
      // cause: cause ?? this.cause,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatItem &&
        other.chatId == chatId &&
        other.name == name &&
        other.image == image &&
        // other.userId == userId &&
        other.id == id &&
        other.timestamp == timestamp;
        // other.cause == cause;
  }

  @override
  int get hashCode {
    return Object.hash(chatId, name, image, id, timestamp);
  }

  @override
  String toString() {
    return 'ChatItem{'
        'chatId: $chatId, '
        'name: $name, '
        'image: $image, '
        // 'userId: $userId, '
        'id: $id, '
        'timestamp: $timestamp, '
        // 'cause: $cause'
        '}';
  }
}

/// Custom exception for chat-related errors
class ChatException implements Exception {
  final String message;
  final String? details;
  final dynamic originalError;

  const ChatException(this.message, {this.details, this.originalError});

  @override
  String toString() {
    final buffer = StringBuffer('ChatException: $message');
    if (details != null) {
      buffer.write('\nDetails: $details');
    }
    if (originalError != null) {
      buffer.write('\nOriginal error: $originalError');
    }
    return buffer.toString();
  }
}

/// Represents the API response containing chat data
class ChatResponse {
  final bool status;
  final String message;
  final List<ChatItem> data;

  const ChatResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  /// Creates a ChatResponse from JSON with comprehensive error handling
  factory ChatResponse.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('ChatResponse.fromJson: $json', name: 'ChatResponse');

      // Validate and extract status
      final status = _parseStatus(json['success']);
      developer.log('Response status: $status', name: 'ChatResponse');

      // Extract message
      final message = json['message']?.toString() ?? '';
      developer.log('Response message: $message', name: 'ChatResponse');

      // Parse data array
      final chatList = _parseDataList(json['data']);
      developer.log('Successfully parsed ${chatList.length} chat items',
          name: 'ChatResponse');

      return ChatResponse(
        status: status,
        message: message,
        data: chatList,
      );
    } catch (e, stackTrace) {
      developer.log(
        'Error creating ChatResponse from JSON: $e',
        name: 'ChatResponse',
        error: e,
        stackTrace: stackTrace,
      );

      throw ChatException(
        'Failed to parse chat response',
        details: 'Error occurred while parsing JSON response',
        originalError: e,
      );
    }
  }

  /// Helper method to parse status field
  static bool _parseStatus(dynamic statusValue) {
    if (statusValue == null) {
      throw const FormatException('Status field is missing');
    }

    if (statusValue is bool) {
      return statusValue;
    }

    if (statusValue is String) {
      final lowerStatus = statusValue.toLowerCase();
      return lowerStatus == 'true' || lowerStatus == '1';
    }

    if (statusValue is int) {
      return statusValue == 1;
    }

    throw FormatException('Invalid status value: $statusValue');
  }

  /// Helper method to parse data list
  static List<ChatItem> _parseDataList(dynamic dataValue) {
    if (dataValue == null) {
      developer.log('No data field in response', name: 'ChatResponse');
      return <ChatItem>[];
    }

    if (dataValue is! List) {
      throw const FormatException('Data field must be a list');
    }

    final dataList = dataValue;
    developer.log('Data list length: ${dataList.length}', name: 'ChatResponse');

    final List<ChatItem> chatList = [];
    final List<String> errors = [];

    for (int i = 0; i < dataList.length; i++) {
      try {
        final item = dataList[i];
        if (item is! Map<String, dynamic>) {
          throw FormatException('Item at index $i is not a valid object');
        }

        developer.log('Processing item $i: $item', name: 'ChatResponse');
        final chatItem = ChatItem.fromJson(item);
        chatList.add(chatItem);
      } catch (e) {
        final errorMsg = 'Error parsing item at index $i: $e';
        developer.log(errorMsg, name: 'ChatResponse');
        errors.add(errorMsg);
      }
    }

    if (errors.isNotEmpty && chatList.isEmpty) {
      throw ChatException(
        'Failed to parse any chat items',
        details: errors.join('\n'),
      );
    }

    if (errors.isNotEmpty) {
      developer.log(
        'Some items failed to parse: ${errors.length}/${dataList.length}',
        name: 'ChatResponse',
      );
    }

    return chatList;
  }

  /// Converts the ChatResponse to JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data.map((item) => item.toJson()).toList(),
    };
  }

  /// Creates a copy of this ChatResponse with optional field updates
  ChatResponse copyWith({
    bool? status,
    String? message,
    List<ChatItem>? data,
  }) {
    return ChatResponse(
      status: status ?? this.status,
      message: message ?? this.message,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChatResponse &&
        other.status == status &&
        other.message == message &&
        _listEquals(other.data, data);
  }

  /// Helper method to compare lists
  static bool _listEquals<T>(List<T> a, List<T> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(status, message, Object.hashAll(data));

  @override
  String toString() {
    return 'ChatResponse{'
        'status: $status, '
        'message: $message, '
        'data: ${data.length} items'
        '}';
  }
}

/// Extension methods for ChatResponse to add utility functions
extension ChatResponseExtensions on ChatResponse {
  /// Returns only chat items with valid timestamps
  List<ChatItem> get itemsWithTimestamp {
    return data.where((item) => item.timestamp != null).toList();
  }

  /// Returns chat items sorted by timestamp (most recent first)
  List<ChatItem> get sortedByTimestamp {
    final itemsWithTime = itemsWithTimestamp;
    itemsWithTime.sort((a, b) => b.timestamp!.compareTo(a.timestamp!));
    return itemsWithTime;
  }

  /// Returns chat items filtered by cause
  // List<ChatItem> itemsByCause(String cause) {
  //   return data
  //       .where((item) => item.cause.toUpperCase() == cause.toUpperCase())
  //       .toList();
  // }

  /// Returns true if response is successful and has data
  bool get isSuccessWithData => status && data.isNotEmpty;
}
