import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/notification_provider.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  static const String _tokenKey = 'fcm_token';

  // Збереження токену
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  // Отримання токену
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Видалення токену
  static Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> initializeFCM({
    required BuildContext context,
  }) async {
    // Налаштування обробника для повідомлень у фоновому режимі
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Налаштування обробника для повідомлень, коли аплікація активна
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message received: ${message.data}');
      Provider.of<NotificationsProvider>(context, listen: false)
          .addNotification(message.data);
    });

    // Запит дозволу для iOS
    await _firebaseMessaging.requestPermission();

    // Отримання токена
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      await saveToken(token);
      print("FCM Token: $token");
    }
  }

  static Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    print("Handling a background message: ${message.messageId}");
  }
}
