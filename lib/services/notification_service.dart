import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/reminder.dart';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final FlutterLocalNotificationsPlugin plugin =
      FlutterLocalNotificationsPlugin();

  static const normalChannel = 'normal_reminders';
  static const emergencyChannel = 'emergency_reminders';

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);

    await plugin.initialize(settings);

    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();

    const normal = AndroidNotificationChannel(
      normalChannel,
      'Normal reminders',
      description: 'Regular RecallPro reminders',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    const emergency = AndroidNotificationChannel(
      emergencyChannel,
      'Emergency reminders',
      description: 'High-priority RecallPro reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 500, 250, 700, 250, 900]),
    );

    await androidPlugin?.createNotificationChannel(normal);
    await androidPlugin?.createNotificationChannel(emergency);
  }

  Future<void> schedule(Reminder reminder) async {
    final details = AndroidNotificationDetails(
      reminder.priority == ReminderPriority.emergency
          ? emergencyChannel
          : normalChannel,
      reminder.priority == ReminderPriority.emergency
          ? 'Emergency reminders'
          : 'Normal reminders',
      channelDescription: reminder.priority == ReminderPriority.emergency
          ? 'High-priority reminders'
          : 'Regular reminders',
      importance: reminder.priority == ReminderPriority.emergency
          ? Importance.max
          : Importance.high,
      priority: reminder.priority == ReminderPriority.emergency
          ? Priority.max
          : Priority.high,
      playSound: true,
      enableVibration: true,
      vibrationPattern: reminder.priority == ReminderPriority.emergency
          ? Int64List.fromList([0, 500, 250, 700, 250, 900])
          : Int64List.fromList([0, 250, 150, 250]),
      category: AndroidNotificationCategory.alarm,
    );

    final notificationDetails = NotificationDetails(android: details);

    final scheduled = tz.TZDateTime.from(reminder.dateTime, tz.local);
    if (scheduled.isBefore(tz.TZDateTime.now(tz.local))) return;

    await plugin.zonedSchedule(
      reminder.id,
      reminder.priority == ReminderPriority.emergency
          ? '🚨 ${reminder.title}'
          : reminder.title,
      reminder.note.isEmpty ? 'It is time for your reminder.' : reminder.note,
      scheduled,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: _matchComponents(reminder.repeat),
    );
  }

  DateTimeComponents? _matchComponents(RepeatType repeat) {
    switch (repeat) {
      case RepeatType.daily:
        return DateTimeComponents.time;
      case RepeatType.weekly:
        return DateTimeComponents.dayOfWeekAndTime;
      case RepeatType.monthly:
        return DateTimeComponents.dayOfMonthAndTime;
      case RepeatType.none:
        return null;
    }
  }

  Future<void> cancel(int id) => plugin.cancel(id);
  Future<void> cancelAll() => plugin.cancelAll();
}
