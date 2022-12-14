import 'package:app_core/license/license.service.dart';
import 'package:app_core/pages/upgrade/upgrade_config.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/services/local_auth.service.dart';
import 'package:app_core/services/main.service.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:app_core/supabase/supabase_database.service.dart';
import 'package:app_core/supabase/supabase_functions.service.dart';
import 'package:app_core/supabase/supabase_realtime.service.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import 'connectivity/connectivity.service.dart';
import 'purchases/purchases.services.dart';
import 'firebase/analytics.service.dart';
import 'firebase/crashlytics.service.dart';
import 'globals.dart';
import 'notifications/notifications.manager.dart';

class CoreConfig with ConsoleMixin {
  late Map<String, dynamic> translationKeys;
  late String logoDarkPath;
  late String logoLightPath;
  late String persistenceBoxName;
  late Size minWindowSize;
  late Size initialWindowSize;
  late double desktopChangePoint;
  late BuildMode buildMode;
  late BoxConstraints mainConstraints;
  late List<GetPage<dynamic>> pages;
  late List<Color> gradientColors;
  late UpgradeConfig upgradeConfig;
  late bool allowAnonymousRcUserSync;
  late String offeringId;

  late Function()? onCancelledUpgradeScreen;
  late Function()? onSuccessfulUpgrade;
  late Function()? onSignedOut;
  late Function()? onSignedIn;

  // SINGLETON
  static final CoreConfig _singleton = CoreConfig._internal();
  // FACTORY
  factory CoreConfig() => _singleton;
  // CONSTRUCTOR
  CoreConfig._internal();

  // INIT
  Future<CoreConfig> init({
    required Map<String, dynamic> translationKeys,
    required List<GetPage<dynamic>> pages,
    required String logoDarkPath,
    required String logoLightPath,
    required List<Color> gradientColors,
    String persistenceBoxName = 'persistence',
    Size minWindowSize = const Size(350, 700),
    Size initialWindowSize = const Size(1500, 1000),
    double desktopChangePoint = 800,
    BuildMode buildMode = BuildMode.production,
    BoxConstraints mainConstraints = const BoxConstraints(maxWidth: 500),
    bool allowAnonymousRcUserSync = true,
    String offeringId = '',
    Function()? onCancelledUpgradeScreen,
    Function()? onSuccessfulUpgrade,
    Function()? onSignedOut,
    Function()? onSignedIn,
  }) async {
    this.translationKeys = translationKeys;
    this.pages = pages;
    this.logoDarkPath = logoDarkPath;
    this.logoLightPath = logoLightPath;
    this.persistenceBoxName = persistenceBoxName;
    this.minWindowSize = minWindowSize;
    this.initialWindowSize = initialWindowSize;
    this.desktopChangePoint = desktopChangePoint;
    this.buildMode = buildMode;
    this.mainConstraints = mainConstraints;
    this.gradientColors = gradientColors;
    this.allowAnonymousRcUserSync = allowAnonymousRcUserSync;
    this.offeringId = offeringId;
    this.onCancelledUpgradeScreen = onCancelledUpgradeScreen;
    this.onSuccessfulUpgrade = onSuccessfulUpgrade;
    this.onSignedOut = onSignedOut;
    this.onSignedIn = onSignedIn;
    await _initDependencies();
    return this;
  }

  Future<void> _initDependencies() async {
    await initGlobals();
    // services
    Get.lazyPut(() => CrashlyticsService());
    Get.lazyPut(() => Persistence());
    Get.lazyPut(() => MainService());
    Get.lazyPut(() => ConnectivityService());
    Get.lazyPut(() => LocalAuthService());

    // controllers
    Get.put(AuthService());
    Get.put(DatabaseService());
    Get.put(FunctionsService());
    Get.put(RealtimeService());
    Get.put(AnalyticsService());
    Get.put(LicenseService());
    Get.put(PurchasesService());
  }

  Future<void> postInit() async {
    CrashlyticsService.to.init();
    NotificationsManager.init();
    Utils.setDisplayMode(); // refresh rate
    await Persistence.open();
    await _initWindow();
  }

  Future<void> _initWindow() async {
    if (!isDesktop) return;
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
