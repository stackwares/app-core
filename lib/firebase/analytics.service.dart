import 'package:app_core/controllers/pro.controller.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:get/get.dart';

import '../utils/utils.dart';

class AnalyticsService extends GetxService with ConsoleMixin {
  static AnalyticsService get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // GETTERS
  FirebaseAnalytics get instance => FirebaseAnalytics.instance;

  // INIT
  @override
  void onInit() {
    if (isWindowsLinux) return;
    instance.setAnalyticsCollectionEnabled(Persistence.to.analytics.val);
    instance.logAppOpen();
    super.onInit();
  }

  @override
  void onReady() {
    if (isWindowsLinux) return;

    instance.setDefaultEventParameters({
      'version': metadataApp.formattedVersion,
      'platform': Utils.platform,
      'theme': Get.isDarkMode ? 'Dark' : 'Light',
      'device_type': Utils.deviceType,
      if (Get.locale?.languageCode != null) ...{
        'language': Get.locale!.languageCode,
      },
      if (Get.locale?.countryCode != null) ...{
        'country': Get.locale!.countryCode,
      },
    });

    super.onReady();
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

  void logViewSearchResults(String query) {
    if (isWindowsLinux) return;
    instance.logViewSearchResults(searchTerm: query);
  }

  void logSelectContent({required String contentType, required String itemId}) {
    if (isWindowsLinux) return;
    instance.logSelectContent(contentType: contentType, itemId: itemId);
  }

  void logSelectItem({
    String? itemListId,
    String? itemListName,
    List<AnalyticsEventItem>? items,
  }) {
    if (isWindowsLinux) return;
    instance.logSelectItem(
      itemListId: itemListId,
      itemListName: itemListName,
      items: items,
    );
  }

  void logShare({
    required String contentType,
    required String itemId,
    required String method,
  }) {
    if (isWindowsLinux) return;
    instance.logShare(
      contentType: contentType,
      itemId: itemId,
      method: method,
    );
  }

  void logScreenView({String? screenClass, String? screenName}) {
    if (isWindowsLinux) return;
    instance.logScreenView(
      screenClass: screenClass,
      screenName: screenName,
    );
  }

  void logEvent(String name, {Map<String, Object?>? parameters}) {
    if (isWindowsLinux) return;
    instance.logEvent(name: name);
  }

  void setUserID(String userId) async {
    if (isWindowsLinux) return;
    instance.setUserId(id: userId);
  }

  void setUserProperty({required String name, required String? value}) async {
    if (isWindowsLinux) return;
    instance.setUserProperty(name: name, value: value);
  }
}
