import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Global navigator key para navegar sin contexto si es necesario
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true, badge: true, sound: true,
    );

    if (settings.authorizationStatus != AuthorizationStatus.authorized) return;

    // Configuración Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initSettings = InitializationSettings(android: androidSettings);

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // ✅ Maneja el clic cuando la app está en foreground
        _handleNavigation(response.payload);
      },
    );

    // Escuchar mensajes en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showLocalNotification(
        title: message.notification?.title ?? 'Alerta',
        body: message.notification?.body ?? '',
        payload: message.data['route'] ?? '/notifications',
      );
    });

    // ✅ Maneja el clic cuando la app está en segundo plano o cerrada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNavigation(message.data['route']);
    });
  }

  // ✅ Nueva función centralizada de navegación
  void _handleNavigation(String? route) {
    if (route == '/notifications') {
      navigatorKey.currentState?.pushNamed('/notifications');
    }
  }

  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'stock_alerts', 'Alertas de Stock',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title, body,
      const NotificationDetails(android: androidDetails),
      payload: payload,
    );
  }

  Future<void> saveTokenToFirestore(String userId, String? token) async {
    if (token == null) return;
    try {
      await FirebaseFirestore.instance.collection('usuarios').doc(userId).update({
        'fcmToken': token,
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error saving token: $e');
    }
  }
}