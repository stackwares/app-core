import 'package:app_core/hive/models/app.hive.dart';
import 'package:app_core/hive/models/device.hive.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'config.dart';

// VARIABLES
bool timeLockEnabled = true;
late ScrollBehavior scollBehavior;
late ThemeData darkThemeData;

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

VoidCallback? getOnboard;

String onboardingBGUri =
    'https://images.unsplash.com/photo-1586455122412-4576812ffe42?q=80&w=600&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

List<String> stringReviews = [
  "This app is absolutely fantastic! It has transformed how I manage my daily tasks and activities. Highly recommend!",
  "I love using this app every day. Its user-friendly design makes navigating through features a breeze and enjoyable.",
  "The features are incredibly useful and well-designed. It has made my life so much easier in countless ways.",
  "This app exceeded my expectations in every way. I find myself relying on it more than I ever imagined!",
  "I can't believe how much this app has improved my productivity. It's become an essential tool in my routine.",
  "The updates are frequent and always enhance the experience. This app keeps getting better, and I love it!",
  "This app is a lifesaver! I use it for everything, from planning my day to managing my projects efficiently.",
  "The customer support is outstanding! They are quick to respond and genuinely care about improving user experience.",
  "I highly recommend this app to everyone! It’s packed with features that really simplify daily tasks and activities.",
  "This app has a beautiful design that makes it enjoyable to use. I always look forward to opening it!",
  "It keeps me organized and on track like nothing else. I can’t imagine my life without this amazing app.",
  "The performance is stellar! It runs smoothly without any glitches, which makes using it a pleasure every single time.",
  "This app truly delivers on its promises. I’ve seen remarkable improvements in my daily workflow since using it.",
  "It has helped me stay focused and productive. I’m so glad I found this incredible app!",
  "Every time I use this app, I discover something new. It’s like a treasure trove of useful features!",
  "I appreciate the thoughtful design that makes navigation intuitive. It’s easy to find everything I need within the app.",
  "This app has everything I need in one place. It’s the perfect solution for managing my busy life!",
  "I’m consistently impressed with how this app evolves. The developers really listen to feedback and make meaningful updates.",
  "Using this app is a delightful experience. It combines functionality with an attractive interface that makes it enjoyable.",
  "I’ve recommended this app to all my friends. It’s the best tool I’ve found for staying organized and productive!"
];
