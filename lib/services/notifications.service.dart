import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

import '../config.dart';
import '../persistence/persistence.dart';
import '../utils/ui_utils.dart';

class NotificationsService extends GetxService with ConsoleMixin {
  static NotificationsService get to => Get.find();

  // VARIABLES
  final plugin = FlutterLocalNotificationsPlugin();
  String? fcmToken = '';

  // PROPERTIES

  // GETTERS
  FirebaseMessaging get fcm => FirebaseMessaging.instance;

  Future<void> init() async {
    final darwinSettings = DarwinInitializationSettings(
      onDidReceiveLocalNotification: onForegroundPayload,
    );

    // initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    await plugin.initialize(
      onDidReceiveNotificationResponse: onBackgroundPayload,
      InitializationSettings(
        android: AndroidInitializationSettings('notification_icon'),
        iOS: darwinSettings,
        macOS: darwinSettings,
      ),
    );

    fcmInit();
  }

  void fcmInit() async {
    if (!CoreConfig().fcmEnabled) return;
    fcmToken = await fcm.getToken(vapidKey: CoreConfig().fcmVapidKey);
    console.wtf('FCM Token: ## $fcmToken ##');
  }

  void notify({
    required final String title,
    required final String body,
    String payload = '',
    bool inApp = false,
  }) async {
    // show snackbar if unsupported or denied
    if (inApp ||
        GetPlatform.isWindows ||
        GetPlatform.isLinux ||
        GetPlatform.isWeb) {
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
    // console.info('notify: $title');
  }

  void onBackgroundPayload(NotificationResponse? response) async {
    console.info('onBackgroundPayload payload: ${response?.payload}');
  }

  void onForegroundPayload(
    int? id,
    String? title,
    String? body,
    String? payload,
  ) async {
    console.info('onForegroundPayload payload: ${payload!}');
  }
}
