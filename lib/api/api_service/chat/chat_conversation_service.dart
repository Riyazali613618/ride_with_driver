import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../constants/api_constants.dart';
import '../../../constants/token_manager.dart';
import '../../api_model/chat/chat_history_model.dart';

class ChatService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<ChatHistoryResponse> getChatHistory(
      String conversationId) async {
    try {
      final token = await TokenManager.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/user/chat/conversations/$conversationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return ChatHistoryResponse.fromJson(jsonData);
      } else {
        return ChatHistoryResponse(
          status: false,
          message: 'Failed to load chat history',
          data: [],
        );
      }
    } catch (e) {
      return ChatHistoryResponse(
        status: false,
        message: 'Network error: ${e.toString()}',
        data: [],
      );
    }
  }

  static Future<bool> sendMessage({
    required String conversationId,
    required String message,
    required String messageType,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/user/chat/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer YOUR_TOKEN', // Replace with actual token
        },
        body: jsonEncode({
          'conversationId': conversationId,
          'message': message,
          'messageType': messageType,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
