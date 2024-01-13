import 'dart:convert';

import 'package:app_core/config.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/secrets.model.dart';
import '../globals.dart';
import 'mutable_value.dart';

class Persistence extends GetxController with ConsoleMixin {
  // STATIC
  static Persistence get to => Get.find();
  static Box? box;

  // GENERAL
  final localeCode = 'en'.val('locale-code');
  final lastBuildNumber = 0.val('last-build-number');
  final notificationId = 0.val('notification-id');
  final sessionCount = 1.val('session-count');
  final reviewCount = 0.val('review-count');
  final rateDialogShown = false.val('rate-dialog-shown');
  final onboarded = false.val('onboarded');
  final consented = false.val('consented');
  final crashReporting = (isApple ? false : true).val('crash-reporting');
  final analytics = (isApple ? false : true).val('analytics');
  final fullscreenAdsAgreed = false.val('fullscreen-ads-agreed');
  // WINDOW SIZE
  final windowWidth = CoreConfig().initialWindowSize.width.val('window-width');

  final windowHeight =
      CoreConfig().initialWindowSize.height.val('window-height');

  final minimizeToTray = false.val('minimize-to-tray');
  final launchAtStartup = (isApple ? false : true).val('launch-at-startup');
  // THEME
  final theme = 'dark'.val('theme');
  // SECURITY
  final maxUnlockAttempts = 10.val('max-unlock-attempts');
  final timeLockDuration = 120.val('time-lock-duration'); // in seconds
  // SYNC
  final biometrics = true.val('biometrics');
  // SUPABASE
  final supabaseSession = ''.val('supabase-session');
  // CONFIG
  final configSecrets = ''.val('secrets_config');
  final configApp = ''.val('app_config');
  final configGeneral = ''.val('general_config');

  // GETTERS

  // INIT
  @override
  void onReady() {
    sessionCount.val++;
    console.wtf('session count: ${sessionCount.val}');
    super.onReady();
  }

  // FUNCTIONS
  static Future<void> open() async {
    await Hive.initFlutter();
    final cipher = HiveAesCipher(base64Decode(secretConfig.persistence.key));

    box = await Hive.openBox(
      secretConfig.persistence.box,
      encryptionCipher: cipher,
    );

    _initLocale();
  }

  static Future<void> reset() async {
    await box?.clear();
    await box?.deleteFromDisk();
    await open();
  }

  static void _initLocale() {
    final deviceLanguage = Get.deviceLocale?.languageCode;

    final isSystemLocaleSupported =
        CoreConfig().translationKeys[deviceLanguage ?? 'en'] != null;
    final defaultLocaleCode = isSystemLocaleSupported ? deviceLanguage : 'en';
    final localeCode = box?.get('locale-code');

    if (defaultLocaleCode != null && localeCode == null) {
      box?.put('locale-code', defaultLocaleCode);
    }
  }
}
