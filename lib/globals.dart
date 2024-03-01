import 'package:app_core/hive/models/app.hive.dart';
import 'package:app_core/hive/models/device.hive.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'config.dart';

// VARIABLES
bool routerMode = false;
bool timeLockEnabled = true;
late ScrollBehavior scollBehavior;

final currencyFormatter = NumberFormat.currency(symbol: '', decimalDigits: 2);
final kFormatter = NumberFormat.compact();

// GETTERS
bool get isBeta => CoreConfig().buildMode == BuildMode.beta;
bool get isSmallScreen =>
    Get.mediaQuery.size.width < CoreConfig().desktopChangePoint;

bool get isThreeColumns => Get.mediaQuery.size.width > 1350;

bool get isLinux => GetPlatform.isLinux && !GetPlatform.isWeb;
bool get isWindows => GetPlatform.isWindows && !GetPlatform.isWeb;
bool get isMac => GetPlatform.isMacOS && !GetPlatform.isWeb;
bool get isWeb => GetPlatform.isWeb;
// bool get isAppStore => CoreConfig().isAppStore;

bool get isApple =>
    !GetPlatform.isWeb && (GetPlatform.isMacOS || GetPlatform.isIOS);

bool get isWindowsLinux =>
    !GetPlatform.isWeb && (GetPlatform.isWindows || GetPlatform.isLinux);

bool get isCrashlyticsSupported => isApple || isMobile;

bool get isDesktop =>
    !GetPlatform.isWeb &&
    (GetPlatform.isMacOS || GetPlatform.isWindows || GetPlatform.isLinux);

bool get isMobile =>
    !GetPlatform.isWeb && (GetPlatform.isIOS || GetPlatform.isAndroid);

bool isPurchaseAllowed = true;

bool get isIAPSupported =>
    !GetPlatform.isWeb &&
    (GetPlatform.isMacOS || GetPlatform.isMobile) &&
    isPurchaseAllowed;

bool get isAdSupportedPlatform =>
    (GetPlatform.isIOS || GetPlatform.isAndroid) && CoreConfig().adsEnabled;

bool get isGumroadSupported => !isIAPSupported;

bool get isLocalAuthSupported =>
    !GetPlatform.isWeb && GetPlatform.isMobile && Persistence.to.biometrics.val;

bool get isRateReviewSupported =>
    !GetPlatform.isWeb &&
    (GetPlatform.isAndroid || GetPlatform.isIOS || GetPlatform.isMacOS);

double get popupItemHeight => isSmallScreen ? kMinInteractiveDimension : 30;
double? get popupIconSize => isSmallScreen ? null : 20;

late HiveMetadataDevice metadataDevice;
late HiveMetadataApp metadataApp;

Future<void> initGlobals() async {
  metadataApp = await HiveMetadataApp.get();
  metadataDevice = await HiveMetadataDevice.get();
}

void initGlobalsWithContext(BuildContext context) {
  scollBehavior = ScrollConfiguration.of(context).copyWith(
    dragDevices: {
      PointerDeviceKind.touch,
      PointerDeviceKind.mouse,
      PointerDeviceKind.stylus,
      PointerDeviceKind.trackpad,
      PointerDeviceKind.invertedStylus,
      PointerDeviceKind.unknown,
    },
  );
}

enum BuildMode { beta, production }
