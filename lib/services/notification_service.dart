import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:notification/main.dart'; // Make sure MyApp is defined here
import 'package:notification/screens/second_screen.dart'; // Replace with your actual SecondScreen path

class NotificationService {
  static Future<void> initializeNotification() async {
    await AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelGroupKey: 'basic_channel_group',
          channelKey: 'basic_channel',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.Max,
          channelShowBadge: true,
          playSound: true,
          criticalAlerts: true,
        )
      ],
      channelGroups: [
        NotificationChannelGroup(
          channelGroupKey: 'basic_channel_group',
          channelGroupName: 'Basic notifications group',
        )
      ],
      debug: true,
    );

    // Request permissions
    await AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });

    // Set notification listeners
    await AwesomeNotifications().setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreateMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  static Future<void> createNotification({
    required int id,
    required String title,
    required String body,
    String? summary,
    Map<String, String>? payload,
    ActionType actionType = ActionType.Default,
    NotificationLayout notificationLayout = NotificationLayout.Default,
    NotificationCategory? category,
    String? bigPicture,
    List<NotificationActionButton>? actionButtons,
    bool scheduled = false,
    Duration? interval,
  }) async {
    assert(!scheduled || (scheduled && interval != null));

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id,
        channelKey: 'basic_channel',
        title: title,
        body: body,
        actionType: actionType,
        notificationLayout: notificationLayout,
        summary: summary,
        category: category,
        payload: payload,
        bigPicture: bigPicture,
      ),
      actionButtons: actionButtons,
      schedule: scheduled
          ? NotificationInterval(
        interval: interval!.inSeconds,
        timeZone: await AwesomeNotifications().getLocalTimeZoneIdentifier(),
        preciseAlarm: true,
      )
          : null,
    );
  }

  // Notification Listeners
  static Future<void> _onNotificationCreateMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification created: ${receivedNotification.title}');
  }

  static Future<void> _onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification displayed: ${receivedNotification.title}');
  }

  static Future<void> _onDismissActionReceivedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification dismissed: ${receivedNotification.title}');
  }

  static Future<void> _onActionReceivedMethod(ReceivedNotification receivedNotification) async {
    debugPrint('Notification action received');
    final payload = receivedNotification.payload;
    if (payload == null) return;

    if (payload['navigate'] == 'true') {
      debugPrint(MyApp.navigatorKey.currentContext.toString());

      Navigator.push(
        MyApp.navigatorKey.currentContext!,
        MaterialPageRoute(
          builder: (_) => const SecondScreen(),
        ),
      );
    }
  }
}
