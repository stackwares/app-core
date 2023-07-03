import 'package:app_core/config.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';

class FCMService extends GetxService with ConsoleMixin {
  static FCMService get to => Get.find();

  // VARIABLES
  String? token = '';

  // GETTERS
  FirebaseMessaging get instance => FirebaseMessaging.instance;

  // INIT
  @override
  void onReady() {
    init();
    super.onReady();
  }

  // FUNCTIONS
  void init() async {
    final settings = await instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    console.wtf('FCM Permission: ${settings.authorizationStatus}');
    token = await instance.getToken(vapidKey: CoreConfig().fcmVapidKey);
    console.wtf('FCM Token: ## $token ##');
  }
}
