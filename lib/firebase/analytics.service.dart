import 'package:app_core/globals.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

class AnalyticsService extends GetxService with ConsoleMixin {
  static AnalyticsService get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // GETTERS
  FirebaseAnalytics get instance => FirebaseAnalytics.instance;

  // INIT
  @override
  void onInit() async {
    if (isWindowsLinux) return;
    await instance.setAnalyticsCollectionEnabled(Persistence.to.analytics.val);
    await instance.logAppOpen();
    super.onInit();
  }

  // FUNCTIONS
  void logSignIn() {
    if (isWindowsLinux) return;
    instance.logLogin();
  }

  void logSignOut() {
    if (isWindowsLinux) return;
    instance.logEvent(name: 'logout');
  }

  void logSearch(String query) {
    if (isWindowsLinux) return;
    instance.logSearch(searchTerm: query);
  }

  void logEvent(
    String name, {
    Map<String, Object?>? parameters,
    AnalyticsCallOptions? callOptions,
  }) {
    if (isWindowsLinux) return;
    instance.logEvent(name: name);
  }

  Future<void> setUserID(String userId) async {
    if (isWindowsLinux) return;
    await instance.setUserId(id: userId);
  }
}
