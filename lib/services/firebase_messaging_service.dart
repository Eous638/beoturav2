import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseMessagingService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  FirebaseMessagingService() {
    _initialize();
  }

  void _initialize() async {
    // Request permissions for iOS
    await _firebaseMessaging.requestPermission();

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Configure FCM message handlers
    FirebaseMessaging.onMessage.listen(_handleMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Get the FCM token
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    if (token != null) {
      _sendTokenToServer(token);
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    final prefs = await SharedPreferences.getInstance();

    final response = await http.post(
      Uri.parse('https://api2.gladni.rs/api/beotura/save_fcm_token'),
      body: {
        "user_id": prefs.getString('device_uuid'),
        "fcm_token": token,
      },
    );

    if (response.statusCode == 200) {
      print("Token successfully sent to server");
    } else {
      print("Failed to send token to server: ${response.statusCode}");
    }
  }

  void _handleMessage(RemoteMessage message) {
    print("Received a message: ${message.messageId}");
    if (message.data['type'] == 'notification') {
      _handleGeneralNotification(message);
    }
    // Handle other types of notifications here
  }

  void _handleGeneralNotification(RemoteMessage message) {
    print("Handling general notification: ${message.data['notification_id']}");
    _showNotification(message);
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    print("Message clicked!");
    // Handle the message when the app is opened from a notification
  }

  void _showNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: false,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      message.notification?.title,
      message.notification?.body,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }
}
