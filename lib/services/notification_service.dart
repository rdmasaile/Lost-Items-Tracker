import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  NotificationService._();
  static NotificationService get _instance => NotificationService._();
  static NotificationService get instance => _instance;

  Future<void> initialize() async {
    AndroidInitializationSettings androidInitializationSettings =
        const AndroidInitializationSettings('@drawable/bluetooth');

    var initializationSettingsIOS = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
        onDidReceiveLocalNotification: (int id, title, body, payload) async {});

    InitializationSettings initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: initializationSettingsIOS);
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {},
    );
  }

  NotificationDetails _getNotificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails('channelId', 'channelName',
            importance: Importance.max),
        iOS: DarwinNotificationDetails());
  }

  Future showNotification(
      {int id = 0, required String title, required String body}) async {
    return await _notificationsPlugin.show(
        id, title, body, _getNotificationDetails());
  }
}
