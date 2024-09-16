import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FCMService {
  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // Ініціалізація FCM
  static Future<void> initializeFCM({
    required Future<void> Function(Map<String, dynamic>) onMessage,
  }) async {
    await Firebase.initializeApp();

    // Налаштування обробника для отримання повідомлень, коли аплікація у фоні або закрита
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Налаштування обробника для отримання повідомлень, коли аплікація активна
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      if (message.notification != null) {
        print('Message also contained a notification: ${message.notification}');
      }
      onMessage(message.data);
    });

    // Отримання токена
    String? token = await _firebaseMessaging.getToken();
    print("FCM Token: $token");

    // Запит дозволу на отримання повідомлень для iOS
    await _firebaseMessaging.requestPermission();
  }

  // Обробка повідомлень у фоновому режимі
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    // Ініціалізуйте Firebase App перед використанням в бекграундному обробнику
    await Firebase.initializeApp();
    print("Handling a background message: ${message.messageId}");
  }
}
