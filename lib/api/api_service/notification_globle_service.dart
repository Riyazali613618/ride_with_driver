import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:r_w_r/screens/layout.dart';

import '../../screens/notification/notification.dart';

// Define notification types for better type safety
enum NotificationType {
  chat,
  home,
  notification,
  unknown;

  static NotificationType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'chat':
        return NotificationType.chat;
      case 'home':
        return NotificationType.home;
      case 'notification':
        return NotificationType.notification;
      default:
        return NotificationType.unknown;
    }
  }
}

// Data class for notification payload
class NotificationPayload {
  final NotificationType type;
  final Map<String, dynamic> data;

  NotificationPayload({
    required this.type,
    required this.data,
  });

  factory NotificationPayload.fromMap(Map<String, dynamic> map) {
    final type = NotificationType.fromString(map['type'] ?? '');
    return NotificationPayload(
      type: type,
      data: Map<String, dynamic>.from(map),
    );
  }

  String toPayloadString() {
    final typeString = type.name;
    final dataString = data.entries.map((e) => '${e.key}:${e.value}').join(',');
    return '$typeString|$dataString';
  }

  static NotificationPayload fromPayloadString(String payload) {
    final parts = payload.split('|');
    if (parts.length < 2) {
      return NotificationPayload(
        type: NotificationType.unknown,
        data: {},
      );
    }

    final type = NotificationType.fromString(parts[0]);
    final dataMap = <String, dynamic>{};

    if (parts[1].isNotEmpty) {
      final dataPairs = parts[1].split(',');
      for (final pair in dataPairs) {
        final keyValue = pair.split(':');
        if (keyValue.length == 2) {
          dataMap[keyValue[0]] = keyValue[1];
        }
      }
    }

    return NotificationPayload(type: type, data: dataMap);
  }
}

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // IMPORTANT: This navigator key should be used in MaterialApp
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  // Initialize notifications
  static Future<void> initialize() async {
    try {
      // Request permission
      NotificationSettings settings =
          await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      print('User granted permission: ${settings.authorizationStatus}');

      // Initialize local notifications
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const DarwinInitializationSettings iosSettings =
          DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      await _localNotifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );

      // Create Android notification channel
      await _createNotificationChannel();

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle notification tap when app is in background
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

      // Handle notification tap when app is terminated
      await _handleInitialMessage();

      print('Notification service initialized successfully');
    } catch (e) {
      print('Error initializing notifications: $e');
    }
  }

  // Create Android notification channel
  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel',
      'High Importance Notifications',
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle notification tap from local notification
  static void _onNotificationTap(NotificationResponse response) {
    print('Local notification tapped with payload: ${response.payload}');
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      final notificationPayload =
          NotificationPayload.fromPayloadString(payload);
      _navigateToScreen(notificationPayload);
    }
  }

  // Handle foreground messages
  static Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.notification?.title}');
    print('Message data: ${message.data}');

    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  // Handle notification tap from Firebase
  static void _handleNotificationTap(RemoteMessage message) {
    print('Firebase notification tapped');
    print('Message data: ${message.data}');

    final notificationPayload = NotificationPayload.fromMap(message.data);
    _navigateToScreen(notificationPayload);
  }

  // Handle initial message when app is launched from notification
  static Future<void> _handleInitialMessage() async {
    final RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      print('App launched from notification');
      print('Initial message data: ${initialMessage.data}');

      // Add a small delay to ensure the app is fully loaded
      Future.delayed(const Duration(seconds: 2), () {
        _handleNotificationTap(initialMessage);
      });
    }
  }

  // Show local notification
  static Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      badgeNumber: 1,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notificationPayload = NotificationPayload.fromMap(message.data);
    final payloadString = notificationPayload.toPayloadString();

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? 'You have a new message',
      notificationDetails,
      payload: payloadString,
    );
  }

  // Navigate to specific screen with improved logic
  static void _navigateToScreen(NotificationPayload payload) {
    print('Navigating with payload: ${payload.type.name}');
    print('Payload data: ${payload.data}');

    final context = navigatorKey.currentContext;
    if (context == null) {
      print('Navigator context is null, scheduling navigation for later');
      // Retry navigation after a delay
      Future.delayed(const Duration(milliseconds: 500), () {
        _navigateToScreen(payload);
      });
      return;
    }

    try {
      switch (payload.type) {
        case NotificationType.chat:
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Layout(
                        initialIndex: 2,
                      )));

          break;
        case NotificationType.home:
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Layout()));
          break;
        case NotificationType.notification:
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => NotificationListScreen()));
          break;
        case NotificationType.unknown:
          print('Unknown notification type, navigating to home');
        // _navigateToHome(context);
      }
    } catch (e) {
      print('Error during navigation: $e');
      // Fallback to home screen
      // _navigateToHome(context);
    }
  }

  // // Navigation helper methods
  // static void _navigateToChat(BuildContext context, Map<String, dynamic> data) {
  //   final chatId = data['chatId'] ?? data['chat_id'] ?? '';
  //   final userId = data['userId'] ?? data['user_id'] ?? '';
  //
  //   print('Navigating to Chat - ChatID: $chatId, UserID: $userId');
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => _createChatScreen(chatId, userId),
  //     ),
  //   );
  // }
  //
  // static void _navigateToProfile(BuildContext context, Map<String, dynamic> data) {
  //   final userId = data['userId'] ?? data['user_id'] ?? data['profileId'] ?? '';
  //
  //   print('Navigating to Profile - UserID: $userId');
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => _createProfileScreen(userId),
  //     ),
  //   );
  // }
  //
  // static void _navigateToRide(BuildContext context, Map<String, dynamic> data) {
  //   final rideId = data['rideId'] ?? data['ride_id'] ?? data['bookingId'] ?? '';
  //   final driverId = data['driverId'] ?? data['driver_id'] ?? '';
  //
  //   print('Navigating to Ride - RideID: $rideId, DriverID: $driverId');
  //
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(
  //       builder: (context) => _createRideScreen(rideId, driverId),
  //     ),
  //   );
  // }

  // Get FCM token
  static Future<String?> getToken() async {
    try {
      final token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  static Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  // Unsubscribe from topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  // Clear all notifications
  static Future<void> clearAllNotifications() async {
    try {
      await _localNotifications.cancelAll();
      print('All notifications cleared');
    } catch (e) {
      print('Error clearing notifications: $e');
    }
  }

  // Clear specific notification
  static Future<void> clearNotification(int id) async {
    try {
      await _localNotifications.cancel(id);
      print('Notification $id cleared');
    } catch (e) {
      print('Error clearing notification $id: $e');
    }
  }
}
