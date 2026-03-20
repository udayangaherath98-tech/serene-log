import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  static final NotificationService instance =
      NotificationService._();
  NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz_data.initializeTimeZones();
    // ✅ Device timezone set කරනවා — නැතිව UTC use කරනවා, notifications wrong time එකේ fire වෙනවා
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const settings = InitializationSettings(
      android: AndroidInitializationSettings(
          '@mipmap/ic_launcher'));
    await _plugin.initialize(settings);
    await _createChannels();
    await _requestPermissions();
    await _scheduleDailyReminder();
  }

  Future<void> _createChannels() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'events_channel', 'Event Reminders',
        description: 'Event start notifications',
        importance: Importance.max,
        enableVibration: true,
        playSound: true,
      ));

    await android.createNotificationChannel(
      const AndroidNotificationChannel(
        'reminder_channel', 'Daily Reminders',
        description: 'Daily app reminders',
        importance: Importance.high,
      ));
  }

  Future<void> _requestPermissions() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    await android.requestNotificationsPermission();
    // Opens Android system settings to allow exact alarms if not yet granted
    await android.requestExactAlarmsPermission();
  }

  Future<void> scheduleEventReminder({
    required int id,
    required String title,
    required String date,
    required String time,
  }) async {
    if (time.isEmpty) return;
    try {
      final dateParts = date.split('-');
      int hour = 0, minute = 0;

      if (time.contains(':')) {
        final t = time.toUpperCase();
        final clean = t
            .replaceAll('AM', '')
            .replaceAll('PM', '')
            .trim();
        final parts = clean.split(':');
        hour = int.parse(parts[0].trim());
        minute = int.parse(parts[1].trim());
        if (t.contains('PM') && hour != 12) hour += 12;
        if (t.contains('AM') && hour == 12) hour = 0;
      }

      final scheduledDate = tz.TZDateTime(
        tz.local,
        int.parse(dateParts[0]),
        int.parse(dateParts[1]),
        int.parse(dateParts[2]),
        hour, minute,
      );

      if (scheduledDate.isBefore(DateTime.now())) return;

      await _plugin.zonedSchedule(
        id,
        '📅 $title — Starting Now!',
        "Your event is beginning. You've got this 🌿",
        scheduledDate,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'events_channel',
            'Event Reminders',
            importance: Importance.max,
            priority: Priority.high,
            color: Color(0xFF7BAE8B),
            enableVibration: true,
            playSound: true,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation
                .absoluteTime,
      );

      debugPrint(
          'Notification scheduled: $title at $date $time');
    } catch (e) {
      debugPrint('Notification error: $e');
    }
  }

  Future<void> cancelEventReminder(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> showImmediateNotification(
      String title, String body) async {
    await _plugin.show(
      999, title, body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'events_channel', 'Event Reminders',
          importance: Importance.max,
          priority: Priority.high,
          color: Color(0xFF7BAE8B)),
      ),
    );
  }

  Future<void> _scheduleDailyReminder() async {
    final List<(String, String)> messages = [
      ("Are you okay today? 💙",
          "DayBloom is here. Take a moment to share."),
      ("Hey, I miss you! 🌿",
          "Come write — even 2 lines can help."),
      ("How are you feeling? 🌸",
          "Your emotions matter. Let's check in."),
      ("Daily check-in time 📖",
          "A few words can change your whole day."),
      ("Your mind deserves rest 🧘",
          "Open DayBloom for 2 minutes of calm."),
      ("Life is busy, but so is your heart 💫",
          "DayBloom is always listening."),
    ];

    try {
      final idx = DateTime.now().day % messages.length;
      final msg = messages[idx];

      final now = tz.TZDateTime.now(tz.local);
      var scheduled = tz.TZDateTime(
          tz.local, now.year, now.month, now.day, 20, 0);
      if (scheduled.isBefore(now)) {
        scheduled =
            scheduled.add(const Duration(days: 1));
      }

      // Cancel existing reminder before re-scheduling
      await _plugin.cancel(88888);

      await _plugin.zonedSchedule(
        88888, msg.$1, msg.$2, scheduled,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminder_channel', 'Daily Reminders',
            importance: Importance.high,
            color: Color(0xFF7BAE8B)),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation
                .absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('Daily reminder scheduled for: $scheduled');
    } catch (e) {
      debugPrint('Daily reminder error: $e');
    }
  }

  static Future<void> markAppUsed() async {
    final prefs = await SharedPreferences.getInstance();
    final today =
        "${DateTime.now().year}-${DateTime.now().month}"
        "-${DateTime.now().day}";
    await prefs.setString('last_used_date', today);
  }
}