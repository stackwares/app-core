import 'package:app_core/persistence/persistence.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get_utils/src/platform/platform.dart';

import '../utils/ui_utils.dart';

class NotificationsManager {
  static final plugin = FlutterLocalNotificationsPlugin();
  static final console = Console(name: 'NotificationsManager');
  static bool initialized = false;

  static void cancel(int id) => plugin.cancel(id);
  static void cancelAll() => plugin.cancelAll();

  static Future<void> init() async {
    const darwinSettings = DarwinInitializationSettings(
      onDidReceiveLocalNotification: onForegroundPayload,
    );

    const androidSettings = AndroidInitializationSettings('notification_icon');

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    await plugin.initialize(
      onDidReceiveNotificationResponse: onBackgroundPayload,
      const InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );

    initialized = true;

    console.info("init");
  }

  static void notify({
    required final String title,
    required final String body,
    String payload = '',
  }) async {
    if (!initialized) await init();

    // show snackbar if unsupported or denied
    if (GetPlatform.isWindows || GetPlatform.isLinux || GetPlatform.isWeb) {
      return UIUtils.showSnackBar(title: title, message: body, seconds: 5);
    }

    const darwinDetails = DarwinNotificationDetails();
    const linuxDetails = LinuxNotificationDetails();

    const androidDetails = AndroidNotificationDetails(
      "general",
      "General",
      channelDescription: "General Notifications",
      priority: Priority.high,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );

    final id = Persistence.to.notificationId.val++;
    await plugin.show(id, title, body, details, payload: payload);
    console.info('notify: $title');
  }

  static void onBackgroundPayload(NotificationResponse? response) async {
    console.info('onBackgroundPayload payload: ${response?.payload}');
  }

  static void onForegroundPayload(
    int? id,
    String? title,
    String? body,
    String? payload,
  ) async {
    console.info('onForegroundPayload payload: ${payload!}');
  }
}
