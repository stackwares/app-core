import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/services/local_auth.service.dart';
import 'package:app_core/services/main.service.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:app_core/supabase/supabase_database.service.dart';
import 'package:app_core/supabase/supabase_functions.service.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'connectivity/connectivity.service.dart';
import 'controllers/pro.controller.dart';
import 'firebase/analytics.service.dart';
import 'firebase/config/config.service.dart';
import 'firebase/crashlytics.service.dart';
import 'firebase/functions.service.dart';
import 'globals.dart';
import 'notifications/notifications.manager.dart';

class CoreConfig with ConsoleMixin {
  late String persistenceCipherKey;
  late Map<String, dynamic> translationKeys;
  late String logoDarkPath;
  late String logoLightPath;
  late String persistenceBoxName;
  late Size minWindowSize;
  late double desktopChangePoint;
  late BuildMode buildMode;
  late BoxConstraints mainConstraints;
  late List<GetPage<dynamic>> pages;
  late Function()? onCloseUpgradeScreen;

  // SINGLETON
  static final CoreConfig _singleton = CoreConfig._internal();
  // FACTORY
  factory CoreConfig() => _singleton;
  // CONSTRUCTOR
  CoreConfig._internal();

  // INIT
  CoreConfig init({
    required String persistenceCipherKey,
    required Map<String, dynamic> translationKeys,
    required List<GetPage<dynamic>> pages,
    required String logoDarkPath,
    required String logoLightPath,
    String persistenceBoxName = 'persistence',
    Size minWindowSize = const Size(400, 700),
    double desktopChangePoint = 800,
    BuildMode buildMode = BuildMode.production,
    BoxConstraints mainConstraints = const BoxConstraints(maxWidth: 500),
    Function()? onCloseUpgradeScreen,
  }) {
    this.persistenceCipherKey = persistenceCipherKey;
    this.translationKeys = translationKeys;
    this.pages = pages;
    this.logoDarkPath = logoDarkPath;
    this.logoLightPath = logoLightPath;
    this.persistenceBoxName = persistenceBoxName;
    this.minWindowSize = minWindowSize;
    this.desktopChangePoint = desktopChangePoint;
    this.mainConstraints = mainConstraints;
    this.onCloseUpgradeScreen = onCloseUpgradeScreen;
    _initDependencies();
    return this;
  }

  void _initDependencies() async {
    // services
    Get.lazyPut(() => CrashlyticsService());
    Get.lazyPut(() => Persistence());
    Get.lazyPut(() => MainService());
    Get.lazyPut(() => ConnectivityService());
    Get.lazyPut(() => LocalAuthService());
    Get.lazyPut(() => FirebaseFunctionsService());
    Get.lazyPut(() => ConfigService());

    // controllers
    Get.put(SupabaseAuthService());
    Get.put(SupabaseDBService());
    Get.put(SupabaseFunctionsService());
    Get.put(AnalyticsService());
    Get.put(ProController());
  }

  Future<void> postInit() async {
    // initializations
    initGlobals();
    CrashlyticsService.to.init();
    NotificationsManager.init();
    Utils.setDisplayMode(); // refresh rate
    await Persistence.open();

    if (GetPlatform.isDesktop && !GetPlatform.isWeb) {
      console.wtf('### window: ${Persistence.to.windowWidth.val}');
      await windowManager.ensureInitialized();

      final windowOptions = WindowOptions(
        skipTaskbar: false,
        minimumSize: minWindowSize,
        size: Size(
          Persistence.to.windowWidth.val,
          Persistence.to.windowHeight.val,
        ),
      );

      windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
      });
    }
  }
}
