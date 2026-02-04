import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/**
 * Push Notifications Service
 * 
 * File: lib/core/services/push_notification_service.dart
 * 
 * Manages Firebase Cloud Messaging (FCM) for push notifications
 * Handles local notifications as fallback
 */

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();

  late FirebaseMessaging _firebaseMessaging;
  late FlutterLocalNotificationsPlugin _localNotifications;

  final StreamController<Map<String, dynamic>> _notificationStream =
      StreamController<Map<String, dynamic>>.broadcast();

  factory PushNotificationService() {
    return _instance;
  }

  PushNotificationService._internal();

  Stream<Map<String, dynamic>> get notificationStream =>
      _notificationStream.stream;

  /**
   * Initialize push notification services
   */
  Future<void> initialize() async {
    try {
      // Initialize Firebase Messaging
      _firebaseMessaging = FirebaseMessaging.instance;

      // Initialize Local Notifications
      _localNotifications = FlutterLocalNotificationsPlugin();
      await _initializeLocalNotifications();

      // Request permissions (iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carryForward: true,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      print('Notification permissions: ${settings.authorizationStatus}');

      // Get FCM token
      final token = await _firebaseMessaging.getToken();
      print('✅ FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Handle background messages
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

      // Handle terminated app notifications
      final initialMessage = await _firebaseMessaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpenedApp(initialMessage);
      }

      // Token refresh listener
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        print('FCM Token refreshed: $newToken');
        _saveFCMToken(newToken);
      });

      print('✅ Push notification service initialized');
    } catch (e) {
      print('Error initializing push notifications: $e');
    }
  }

  /**
   * Initialize local notifications
   */
  Future<void> _initializeLocalNotifications() async {
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
      onDidReceiveNotificationResponse: _handleLocalNotificationTap,
    );
  }

  /**
   * Handle foreground messages (app is open)
   */
  void _handleForegroundMessage(RemoteMessage message) {
    print('📬 Foreground message: ${message.notification?.title}');

    final data = {
      'title': message.notification?.title ?? 'Notification',
      'body': message.notification?.body ?? '',
      'trackingId': message.data['trackingId'],
      'parcelId': message.data['parcelId'],
      'status': message.data['status'],
      'timestamp': DateTime.now().toString(),
    };

    // Show local notification
    _showLocalNotification(data);

    // Emit to stream
    _notificationStream.add(data);
  }

  /**
   * Handle message when app is opened from notification
   */
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('📧 App opened from notification: ${message.notification?.title}');

    final data = {
      'title': message.notification?.title ?? 'Notification',
      'body': message.notification?.body ?? '',
      'trackingId': message.data['trackingId'],
      'parcelId': message.data['parcelId'],
      'status': message.data['status'],
      'opened': true,
      'timestamp': DateTime.now().toString(),
    };

    _notificationStream.add(data);
  }

  /**
   * Handle local notification tap
   */
  void _handleLocalNotificationTap(NotificationResponse response) {
    print('📌 Local notification tapped');

    final payload = response.payload ?? '';
    _notificationStream.add({'payload': payload, 'tapped': true});
  }

  /**
   * Show local notification
   */
  Future<void> _showLocalNotification(Map<String, dynamic> data) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'pathau_now_channel',
          'PathauNow',
          channelDescription: 'Parcel tracking notifications',
          importance: Importance.max,
          priority: Priority.high,
          color: Color.fromARGB(255, 245, 124, 0),
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      DateTime.now().hashCode,
      data['title'],
      data['body'],
      platformChannelSpecifics,
      payload: data['trackingId'],
    );
  }

  /**
   * Save FCM token to backend
   */
  Future<void> _saveFCMToken(String token) async {
    // TODO: Call backend API to save token
    // await _authService.updateDeviceToken(token);
  }

  /**
   * Get current FCM token
   */
  Future<String?> getFCMToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  /**
   * Enable notifications
   */
  Future<bool> enableNotifications() async {
    try {
      final settings = await _firebaseMessaging.requestPermission();
      return settings.authorizationStatus == AuthorizationStatus.authorized;
    } catch (e) {
      print('Error enabling notifications: $e');
      return false;
    }
  }

  /**
   * Disable notifications
   */
  Future<void> disableNotifications() async {
    try {
      await _firebaseMessaging.deleteToken();
      print('✅ Notifications disabled');
    } catch (e) {
      print('Error disabling notifications: $e');
    }
  }

  /**
   * Subscribe to topic (for targeted notifications)
   */
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      print('✅ Subscribed to topic: $topic');
    } catch (e) {
      print('Error subscribing to topic: $e');
    }
  }

  /**
   * Unsubscribe from topic
   */
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      print('✅ Unsubscribed from topic: $topic');
    } catch (e) {
      print('Error unsubscribing from topic: $e');
    }
  }

  /**
   * Cleanup resources
   */
  Future<void> dispose() async {
    await _notificationStream.close();
  }
}
 
 
 
 
 
