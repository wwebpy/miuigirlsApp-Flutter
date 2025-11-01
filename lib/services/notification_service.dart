import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iOSSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iOSSettings,
    );

    await _notifications.initialize(settings);

    // Request permissions for iOS
    await _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  static Future<void> scheduleReminder(Reminder reminder) async {
    if (!reminder.isActive) return;

    const NotificationDetails platformDetails = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        'reminders_channel',
        'Reminders',
        channelDescription: 'Daily reminders and motivations',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    final notificationId = reminder.notificationId ?? reminder.id.hashCode;

    if (reminder.isRepeating) {
      // Schedule repeating notification
      for (var day in reminder.repeatDays) {
        await _notifications.zonedSchedule(
          notificationId + day,
          reminder.title,
          reminder.description ?? 'Time for your daily reminder',
          _nextInstanceOfWeekday(day, reminder.time),
          platformDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    } else {
      // Schedule one-time notification
      await _notifications.zonedSchedule(
        notificationId,
        reminder.title,
        reminder.description ?? 'Time for your reminder',
        tz.TZDateTime.from(reminder.time, tz.local),
        platformDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }

  static Future<void> cancelReminder(Reminder reminder) async {
    final notificationId = reminder.notificationId ?? reminder.id.hashCode;

    if (reminder.isRepeating) {
      for (var day in reminder.repeatDays) {
        await _notifications.cancel(notificationId + day);
      }
    } else {
      await _notifications.cancel(notificationId);
    }
  }

  static tz.TZDateTime _nextInstanceOfWeekday(int weekday, DateTime time) {
    tz.TZDateTime scheduledDate = tz.TZDateTime.from(time, tz.local);
    while (scheduledDate.weekday != weekday) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  static Future<void> showDailyMotivation(String title, String body) async {
    const NotificationDetails platformDetails = NotificationDetails(
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
      android: AndroidNotificationDetails(
        'daily_motivation_channel',
        'Daily Motivation',
        channelDescription: 'Your daily dose of motivation',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await _notifications.show(
      0,
      title,
      body,
      platformDetails,
    );
  }
}
