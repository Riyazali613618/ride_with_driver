import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;

import 'package:http/http.dart' as http;
import 'package:r_w_r/api/api_model/chat/chat_model.dart';
import 'package:r_w_r/constants/api_constants.dart';
import 'package:r_w_r/constants/token_manager.dart';

import '../../api_model/chat/delet_chat_api_model.dart';

class ChatApiService {
  static const String baseUrl = ApiConstants.baseUrl;

  static Future<ChatResponse> getChatList() async {
    developer.log('Starting getChatList request', name: 'ChatApiService');

    try {
      final token = await TokenManager.getToken();
      developer.log('Retrieved token: ${token ?? 'null'}...',
          name: 'ChatApiService');
print("token $token");
      final url = '$baseUrl/user/chat/conversations';
      developer.log('Request URL: $url', name: 'ChatApiService');

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          developer.log('Request timeout occurred', name: 'ChatApiService');
          throw TimeoutException(
              'Request timeout', const Duration(seconds: 30));
        },
      );

      developer.log('Response status code: ${response.statusCode}',
          name: 'ChatApiService');
      developer.log('Response body: ${response.body}', name: 'ChatApiService');

      if (response.statusCode == 200) {
        try {
          final Map<String, dynamic> jsonData = json.decode(response.body);
          developer.log('Successfully decoded JSON response',
              name: 'ChatApiService');
          return ChatResponse.fromJson(jsonData);
        } catch (e) {
          developer.log('Error decoding JSON: $e', name: 'ChatApiService');
          throw FormatException('Invalid response format from server: $e');
        }
      } else {
        developer.log('HTTP error: ${response.statusCode} - ${response.body}',
            name: 'ChatApiService');
        throw Exception('Failed to load chat list: ${response.statusCode}');
      }
    } on TimeoutException catch (e) {
      developer.log('Timeout exception: $e', name: 'ChatApiService');
      throw Exception(
          'Request timeout. Please check your internet connection.');
    } on FormatException catch (e) {
      developer.log('Format exception: $e', name: 'ChatApiService');
      throw Exception('Invalid response format from server.');
    } catch (e) {
      developer.log('General exception: $e', name: 'ChatApiService');
      throw Exception('Network error: ${e.toString()}');
    }
  }

  static Future<DeleteChatApiResponse> deleteChat(String chatId) async {
    developer.log('Attempting to delete chat with ID: $chatId',
        name: 'ChatApiService');

    try {
      // Validate chatId
      if (chatId.isEmpty) {
        throw Exception('Chat ID cannot be empty');
      }

      final url = Uri.parse('$baseUrl/user/chat/conversations/$chatId');
      developer.log('Delete URL: $url', name: 'ChatApiService');
      final token = await TokenManager.getToken();
      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception(
              'Request timeout. Please check your internet connection.');
        },
      );

      developer.log(
        'Delete response - Status: ${response.statusCode}, Body: ${response.body}',
        name: 'ChatApiService',
      );

      // Parse the response
      final Map<String, dynamic> jsonResponse;
      try {
        jsonResponse = json.decode(response.body);
      } catch (e) {
        developer.log('Failed to parse JSON response: $e',
            name: 'ChatApiService');
        throw Exception('Invalid response format from server');
      }

      // Handle different HTTP status codes
      if (response.statusCode == 200 || response.statusCode == 204) {
        // Success response
        return DeleteChatApiResponse(
          status: jsonResponse['status'] ?? true,
          message: jsonResponse['message'] ?? 'Chat deleted successfully',
          data: [],
        );
      } else if (response.statusCode == 404) {
        // Chat not found or already deleted
        return DeleteChatApiResponse(
          status: true, // Consider this as success since chat is already gone
          message:
              jsonResponse['message'] ?? 'Chat not found or already deleted',
          data: [],
        );
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized access. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('You don\'t have permission to delete this chat.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        // Other error responses
        final errorMessage = jsonResponse['message'] ?? 'Failed to delete chat';
        return DeleteChatApiResponse(
          status: false,
          message: errorMessage,
          data: [],
        );
      }
    } on http.ClientException catch (e) {
      developer.log('Network error during chat deletion: $e',
          name: 'ChatApiService');
      throw Exception('Network error. Please check your internet connection.');
    } on FormatException catch (e) {
      developer.log('JSON parsing error during chat deletion: $e',
          name: 'ChatApiService');
      throw Exception('Invalid response from server');
    } catch (e) {
      developer.log('Unexpected error during chat deletion: $e',
          name: 'ChatApiService');

      // Re-throw known exceptions
      if (e.toString().startsWith('Exception: ')) {
        rethrow;
      }

      // Handle unknown errors
      throw Exception('An unexpected error occurred: ${e.toString()}');
    }
  }
}
