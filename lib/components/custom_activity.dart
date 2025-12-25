import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:r_w_r/constants/token_manager.dart';
import 'package:r_w_r/utils/color.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../screens/user_screens/chat/message.dart';

Future<bool> logUserActivity({
  required String id,
  required ActivityType activity,
  required UserType type,
  required String baseUrl,
}) async {
  try {
    final token = await TokenManager.getToken();

    if (token == null) {
      debugPrint("❌ Token not found.");
      return false;
    }

    final uri = Uri.parse("$baseUrl/user/communications");

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        "driverId": id,
        "status": true,
        "communicationType": activity.apiName,
      }),
    );

    debugPrint(
        "📥 Activity Log Response: ${response.statusCode} - ${response.body}");

    return response.statusCode >= 200 && response.statusCode < 300;
  } catch (e) {
    debugPrint("🛑 logUserActivity error: $e");
    return false;
  }
}

// Enhanced createChatConversation function with better error handling
Future<ChatConversationResponse> createChatConversation({
  required String cause,
  required String baseUrl,
  required String id,
}) async {
  final token = await TokenManager.getToken();

  final uri = Uri.parse('$baseUrl/user/chat/conversations');

  try {
    final response = await http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            if (token != null) 'Authorization': 'Bearer $token',
          },
          body: jsonEncode({
            'cause': cause,
            'id': id,
          }),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint(
        "📥 Chat API Response: ${response.statusCode} - ${response.body}");

    if (response.statusCode == 200 || response.statusCode == 201) {
      try {
        final jsonData = json.decode(response.body);
        return ChatConversationResponse.fromJson(jsonData);
      } catch (parseError) {
        debugPrint("🛑 JSON Parse Error: $parseError");
        debugPrint("🛑 Raw Response: ${response.body}");
        throw FormatException(' $parseError');
      }
    } else {
      // Handle HTTP error responses
      String errorMessage = 'NA';

      try {
        final errorJson = json.decode(response.body);
        if (errorJson['message'] != null &&
            errorJson['message'].toString().isNotEmpty) {
          errorMessage = errorJson['message'].toString();
        }
      } catch (e) {
        debugPrint("🛑 Error parsing error response: $e");
      }

      throw ApiException(
        statusCode: response.statusCode,
        message: errorMessage,
        reasonPhrase: response.reasonPhrase ?? 'Unknown error',
      );
    }
  } on SocketException {
    throw const SocketException(' ');
  } on TimeoutException {
    throw TimeoutException('NA');
  } on ApiException {
    rethrow; // Re-throw our custom exception
  } on FormatException catch (e) {
    throw FormatException('  ${e.message}');
  } catch (e) {
    debugPrint("🛑 Unexpected error in createChatConversation: $e");
    throw Exception(' $e');
  }
}

// Custom exception class for API errors
class ApiException implements Exception {
  final int statusCode;
  final String message;
  final String reasonPhrase;

  const ApiException({
    required this.statusCode,
    required this.message,
    required this.reasonPhrase,
  });

  @override
  String toString() => message;
}

// Updated CustomActivity widget with enhanced error handling
class CustomActivity extends StatelessWidget {
  final String baseUrl;
  final String userId;
  final String icon;
  final String type;
  final String phone;
  final ActivityType activityType;
  final UserType userType;
  final VoidCallback? onBeforeTap;

  const CustomActivity({
    super.key,
    required this.baseUrl,
    required this.userId,
    required this.icon,
    required this.type,
    required this.phone,
    required this.activityType,
    required this.userType,
    this.onBeforeTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onBeforeTap != null) {
          onBeforeTap!();
        }

        // Then continue with existing logic
        await logUserActivity(
          activity: activityType,
          baseUrl: baseUrl,
          type: userType,
          id: userId,
        );

        switch (type) {
          case "WHATSAPP":
            final whatsappUrl = Uri.parse("https://wa.me/$phone");
            if (await canLaunchUrl(whatsappUrl)) {
              await launchUrl(whatsappUrl,
                  mode: LaunchMode.externalApplication);
            } else {
              debugPrint("❌ Cannot launch WhatsApp");
              _showSnackBar(context, "Cannot launch WhatsApp", isError: true);
            }
            break;

          case "PHONE":
            final phoneUrl = Uri.parse("tel:$phone");
            if (await canLaunchUrl(phoneUrl)) {
              await launchUrl(phoneUrl);
            } else {
              debugPrint("❌ Cannot launch phone dialer");
              _showSnackBar(context, "Cannot launch phone dialer",
                  isError: true);
            }
            break;

          case "CHAT":
            try {
              final chatModel = await createChatConversation(
                cause: userType.apiName,
                baseUrl: baseUrl,
                id: userId,
              );
              debugPrint("✅ Chat Created: ID -> ${chatModel.data.chatId}");
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MessagingScreen(
                            // userId: userId,
                            // cause: userType.name,
                            conversationId: chatModel.data.chatId,
                            chatId: chatModel.data.chatId,
                            name: chatModel.data.name,
                            image: chatModel.data.image,
                            otherPersonId: chatModel.data.otherPersonId,
                            otherPersonUserId: chatModel.data.otherPersonUserId,
                          )));
            } catch (e) {
              debugPrint("❌ Chat creation failed: $e");

              String errorMessage = "Failed to create chat";

              if (e is ApiException) {
                // Use the specific API error message
                errorMessage = e.message;
              } else if (e is SocketException) {
                errorMessage = "No internet connection";
              } else if (e is TimeoutException) {
                errorMessage = "Request timed out. Please try again";
              } else if (e is FormatException) {
                errorMessage = "Server response error. Please try again";
              }

              _showSnackBar(context, errorMessage, isError: true);
            }
            break;

          default:
            // No external action needed for CLICK, etc.
            break;
        }
      },
      child: SvgPicture.asset(
        icon,
        height: 20,
        width: 20,
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    final localizations = AppLocalizations.of(context)!;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.all(16),
        action: SnackBarAction(
          label: localizations.ok,
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }
}

class ChatConversationResponse {
  final bool status;
  final String message;
  final StartChatModelChatData data;

  ChatConversationResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ChatConversationResponse.fromJson(Map<String, dynamic> json) {
    return ChatConversationResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: StartChatModelChatData.fromJson(json['data'] ?? {}),
    );
  }
}

class StartChatModelChatData {
  final String chatId;
  final String name;
  final String image;
  final String otherPersonId;
  final String otherPersonUserId;

  StartChatModelChatData({
    required this.chatId,
    required this.name,
    required this.image,
    required this.otherPersonId,
    required this.otherPersonUserId,
  });

  factory StartChatModelChatData.fromJson(Map<String, dynamic> json) {
    return StartChatModelChatData(
      chatId: json['chatId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      otherPersonId: json['otherPersonId']?.toString() ?? '',
      otherPersonUserId: json['otherPersonUserId']?.toString() ?? '',
    );
  }
}

enum ActivityType {
  WHATSAPP,
  MESSAGE,
  CHAT,
  PHONE,
  CLICK,
}

enum UserType {
  DRIVER,
  TRANSPORTER,
  E_RICKSHAW,
  RICKSHAW,
  INDEPENDENT_CAR_OWNER,
}

extension ActivityTypeExtension on ActivityType {
  String get apiName => toString().split('.').last;
}

extension UserTypeExtension on UserType {
  String get apiName {
    switch (this) {
      case UserType.E_RICKSHAW:
        return "E_RICKSHAW";
      default:
        return toString().split('.').last;
    }
  }
}

UserType getMyType(String vehicleType) {
  vehicleType = vehicleType.trim().toUpperCase();
  print("_🕗🕗🕗🕗🕗🕗🕗🕗🕗🕗🕗_________$vehicleType");

  if (vehicleType == 'DRIVER') {
    return UserType.DRIVER;
  } else if (vehicleType == 'AUTO' || vehicleType == 'RICKSHAW') {
    return UserType.RICKSHAW;
  } else if (vehicleType == 'E_RICKSHAW' || vehicleType == 'E-RICKSHAW') {
    return UserType.E_RICKSHAW;
  } else {
    return UserType.TRANSPORTER;
  }
}

String convertVehicleType(String vehicleType) {
  vehicleType = vehicleType.trim();
  print("convertVehicleType${vehicleType}");
  switch (vehicleType.toUpperCase()) {
    case 'DRIVER':
      return 'DRIVER';
    case 'CAR':
      return 'CAR';
    case 'SUV':
      return 'SUV';
    case 'BUS':
      return 'BUS';
    case 'MINI VAN':
      return 'MINIVAN';
    case 'VAN':
      return 'VAN';
    case 'AUTO':
    case 'RICKSHAW':
      return 'RICKSHAW';
    case 'E-RICKSHAW':
      return 'E_RICKSHAW';
    case 'ALL VEHICLES':
    case 'ALLVEHICLES':
      return 'ALL_VEHICLES';
    case 'OTHER':
      return vehicleType == 'OTHER' ? 'OTHER' : 'Other';
    default:
      if (vehicleType == 'Other') return 'Other';
      return 'CAR';
  }
}

String getReviewTypes(String vehicleType) {
  vehicleType = vehicleType.trim();
  print(vehicleType); // For debugging
  switch (vehicleType.toUpperCase()) {
    case 'DRIVER':
      return 'DRIVER';
    case 'AUTO':
    case 'RICKSHAW':
      return 'RICKSHAW';
    case 'E-RICKSHAW':
    case 'E_RICKSHAW':
      return 'E_RICKSHAW';
    default:
      return 'TRANSPORTER';
  }
}
