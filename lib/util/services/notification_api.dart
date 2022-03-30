import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationAPI {
  static final _notification = FlutterLocalNotificationsPlugin();

  static Future showNotification(
      {int? id, String? title, String? body, String? payload}) async {
    var rng =  Random();
    var id = rng.nextInt(900000) + 100000;
    return _notification.show(id, title, body, await _notificationDetails(),
        payload: payload);
  }

  static init() async {
    tz.initializeTimeZones();
    final locationName=await FlutterNativeTimezone.getLocalTimezone(); 
    tz.setLocalLocation(tz.getLocation(locationName));
  }

  static Future showScheduleNotification(
      {int? id,
      String? title,
      String? body,
      String? payload,
      required DateTime dateTime}) async {
    var rng =  Random();
    var id = rng.nextInt(900000) + 100000;
    print("Notification id is ${id}");

    return _notification.zonedSchedule(id, title, body,
        tz.TZDateTime.from(dateTime, tz.local), await _notificationDetails(),
        payload: payload,
        androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  static Future _notificationDetails() async {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'channel id', //Required for Android 8.0 or after
            'channel name', //Required for Android 8.0 or after
            channelDescription: 'channel discription',
            //Required for Android 8.0 or after
            importance: Importance.max,
            priority: Priority.max),
        iOS: IOSNotificationDetails());
  }
}
