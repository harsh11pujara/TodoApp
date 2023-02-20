import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/standalone.dart' as tz;
import 'package:timezone/timezone.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final AndroidInitializationSettings _androidInitializationSettings = const AndroidInitializationSettings('logo');

  void initialiseNotification() async {
    InitializationSettings initializationSettings = InitializationSettings(android: _androidInitializationSettings);

    await _flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  void sendNotification(String title, String body) async {
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails('channelId', 'channelName',
        importance: Importance.max, priority: Priority.defaultPriority);

    await _flutterLocalNotificationsPlugin.show(1, title, body, NotificationDetails(android: androidNotificationDetails));
  }

  void scheduleNotification(int id, String title, String body, {required DateTime alarmTime}) async {
    AndroidNotificationDetails androidNotificationDetails = const AndroidNotificationDetails('channelId', 'channelName',
        importance: Importance.max, priority: Priority.defaultPriority);

    await _flutterLocalNotificationsPlugin.zonedSchedule(id, title, body, tz.TZDateTime.from(alarmTime, tz.getLocation('Asia/Kolkata')),
        NotificationDetails(android: androidNotificationDetails),
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime, androidAllowWhileIdle: true);
    print('successful');
  }
}
