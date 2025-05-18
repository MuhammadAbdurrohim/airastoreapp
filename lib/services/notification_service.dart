import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences.dart';

class NotificationService {
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    // Request permission for notifications
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    const initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _localNotifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onSelectNotification,
    );

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification open
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpen);
  }

  static Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }
      return token;
    } catch (e) {
      print('Error getting FCM token: $e');
      return null;
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print('Handling background message: ${message.messageId}');
    _showLocalNotification(message);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');
    _showLocalNotification(message);
  }

  static void _handleNotificationOpen(RemoteMessage message) {
    print('Notification opened: ${message.messageId}');
    if (message.data['type'] == 'live_start') {
      final context = NavigationService.navigatorKey.currentContext;
      if (context != null) {
        Navigator.of(context).pushNamed(
          '/live-stream',
          arguments: {
            'streamId': message.data['stream_id'].toString(),
            'isHost': false,
            'userId': '', // unknown from notification
            'userName': '', // unknown from notification
          },
        );
      }
    } else {
      _navigateToOrder(message.data);
    }
  }

  static Future<void> _onSelectNotification(NotificationResponse response) async {
    final payload = response.payload;
    if (payload != null) {
      final data = Map<String, dynamic>.from(
        Map.from(Uri.splitQueryString(payload))
          .map((key, value) => MapEntry(key, value.toString()))
      );
      _navigateToOrder(data);
    }
  }

  static void _navigateToOrder(Map<String, dynamic> data) {
    if (data.containsKey('order_id')) {
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushNamed(
        '/order-detail',
        arguments: int.parse(data['order_id'].toString()),
      );
    }
    }
  }

  static Future<void> _showLocalNotification(RemoteMessage message) async {
    final androidDetails = AndroidNotificationDetails(
      'order_status_channel',
      'Order Status',
      channelDescription: 'Notifications about order status updates',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final notification = message.notification;
    if (notification != null) {
      String? title = notification.title;
      String? body = notification.body;

      if (message.data['type'] == 'live_start') {
        title = 'Live Tayang Dimulai!';
        body = 'Streaming "${message.data['stream_title']}" sudah dimulai. Klik untuk menonton.';
      }

      await _localNotifications.show(
        notification.hashCode,
        title,
        body,
        details,
        payload: Uri(
          queryParameters: message.data
            .map((key, value) => MapEntry(key, value.toString()))
        ).query,
      );
    }
  }

  static Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
  }

  static Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
  }

  static Future<void> clearNotifications() async {
    await _localNotifications.cancelAll();
  }

  static Future<void> updateFCMTokenIfNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final oldToken = prefs.getString('fcm_token');
    final newToken = await getFCMToken();

    if (oldToken != newToken && newToken != null) {
      try {
        await ApiService.updateFCMToken(newToken);
        await prefs.setString('fcm_token', newToken);
      } catch (e) {
        print('Error updating FCM token: $e');
      }
    }
  }

  // Channel configuration
  static Future<void> createNotificationChannel() async {
    const channel = AndroidNotificationChannel(
      'order_status_channel',
      'Order Status',
      description: 'Notifications about order status updates',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Badge count management (iOS)
  static Future<void> resetBadgeCount() async {
    await _localNotifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
}
