import 'dart:math';
import 'dart:ui' as ui;

import 'package:app_core/config.dart';
import 'package:app_core/config/app.model.dart';
import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../globals.dart';
import '../pages/feedback/feedback_screen.controller.dart';
import '../pages/routes.dart';
import '../purchases/purchases.services.dart';
import 'blocked_domains.dart';

class Utils {
  // VARIABLES
  static final console = Console(name: 'Utils');

  // GETTERS

  // FUNCTIONS

  static void closeKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }

  static void copyToClipboard(text) async {
    await Clipboard.setData(ClipboardData(text: text));

    // TODO: localize
    UIUtils.showSnackBar(
      title: 'Copied to Clipboard',
      message: "You're now ready to paste it",
      icon: const Icon(Iconsax.copy_outline),
      seconds: 2,
    );

    AnalyticsService.to.logEvent('copy_clipboard');
  }

  static String timeAgo(DateTime dateTime, {bool short = true}) {
    final locale =
        (Get.locale?.languageCode ?? 'en_US') + (short ? "_short" : "");
    return timeago.format(dateTime, locale: locale).replaceFirst("~", "");
  }

  static Future<dynamic>? adaptiveRouteOpen({
    required String name,
    String method = 'toNamed',
    Size dialogSize = const Size(650, 900),
    Map<String, String> parameters = const {},
    dynamic arguments,
    bool ignoreUpgradeGuard = true,
  }) {
    console.wtf('Route: ${name}');

    if (name == Routes.upgrade) {
      if (!CoreConfig().purchasesEnabled ||
          (PurchasesService.to.isPremium && ignoreUpgradeGuard)) {
        console.warning('ignored upgrade screen');
        return Future.value(false);
      }

      if (Get.previousRoute == Routes.upgrade) {
        console.warning('duplicate upgrade route');
        return Future.value(false);
      }
    }

    // Regular navigation for mobile
    if (isSmallScreen) {
      switch (method) {
        case 'toNamed':
          return Get.toNamed(
            name,
            parameters: parameters,
            arguments: arguments,
          );
        case 'offAndToNamed':
          return Get.offAndToNamed(
            name,
            parameters: parameters,
            arguments: arguments,
          );
        case 'offAllNamed':
          return Get.offAllNamed(
            name,
            parameters: parameters,
            arguments: arguments,
          );
        default:
      }
    }

    // Open page as dialog for desktop
    Get.parameters = parameters; // manually pass parameters
    final page = CoreConfig().pages.firstWhere((e) => e.name == name).page();

    final dialog = Dialog(
      child: SizedBox(
        width: dialogSize.width,
        height: dialogSize.height,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: page,
        ),
      ),
    );

    return Get.dialog(
      dialog,
      routeSettings: RouteSettings(name: name, arguments: arguments),
      barrierDismissible: name != Routes.upgrade,
    );
  }

  static String? validateUri(String data) {
    final uri = Uri.tryParse(data);

    if (uri != null &&
        !uri.hasQuery &&
        uri.hasEmptyPath &&
        uri.hasPort &&
        uri.host.isNotEmpty) {
      return null;
    }

    return 'Invalid Server URL';
  }

  static String get deviceType {
    if (GetPlatform.isDesktop) return 'Desktop';
    return Get.mediaQuery.size.shortestSide < 600 ? 'Phone' : 'Tablet';
  }

  static String get platform {
    if (GetPlatform.isWeb) {
      return "Web";
    } else if (GetPlatform.isAndroid) {
      return "Android";
    } else if (GetPlatform.isIOS) {
      return "iOS";
    } else if (GetPlatform.isWindows) {
      return "Windows";
    } else if (GetPlatform.isMacOS) {
      return "macOS";
    } else if (GetPlatform.isLinux) {
      return "Linux";
    } else if (GetPlatform.isFuchsia) {
      return "Fuchsia";
    } else {
      return "unknown";
    }
  }

  static void contactEmail({
    required String subject,
    required String preBody,
    required double rating,
    required String previousRoute,
    required FeedbackType feedbackType,
  }) async {
    String ratingEmojis = '';

    for (var i = 0; i < rating.toInt(); i++) {
      ratingEmojis += '✩';
    }

    final ln = GetPlatform.isIOS ? '\r\n' : '\n';

    String body = '$preBody$ln$ln';

    body += 'Rating: $ratingEmojis$ln';

    if (AuthService.to.authenticated) {
      body += 'User ID: ${AuthService.to.user!.id}$ln';
    }

    body += 'Plan: ${PurchasesService.to.planId}$ln';

    final rc = PurchasesService.to.info.value;
    final sinceDate = DateTime.tryParse(rc.firstSeen);

    body += 'RC ID: ${rc.originalAppUserId}$ln';
    if (sinceDate != null) {
      body += 'Since: ${DateFormat.yMMMMd().add_jms().format(sinceDate)}$ln';
    }

    if (Get.locale != null) {
      body += 'Locale: ${Get.locale?.languageCode}$ln';
    }

    body += 'Version: ${metadataApp.formattedVersion}$ln';
    body += 'Platform: $platform$ln';
    body += 'Route: $previousRoute$ln';

    final emails = appConfig.emails;
    String email = emails.support;

    if (feedbackType == FeedbackType.issue) {
      email = emails.issues;
    }

    final url = 'mailto:$email?subject=$subject&body=$body';
    openUrl(Uri.encodeFull(url));

    AnalyticsService.to.logEvent(
      'contact',
      parameters: {
        'rating': rating,
        'type': feedbackType,
      },
    );
  }

  static Future<void> openUrl(
    String url, {
    LaunchMode mode = LaunchMode.externalApplication,
  }) async {
    final canLaunch = await canLaunchUrlString(url);
    if (!canLaunch) console.error('cannot launch');
    launchUrlString(url, mode: mode);
  }

  static Future<void> openUri(
    Uri uri, {
    LaunchMode mode = LaunchMode.platformDefault,
  }) async {
    console.info('launching: $uri');
    final canLaunch = await canLaunchUrl(uri);
    if (!canLaunch) console.error('cannot launch');
    launchUrl(uri, mode: mode);
  }

  static Future<Color> extractBackgroundColorFromImage(ui.Image image) async {
    int rgbaToArgb(int rgbaColor) {
      int a = rgbaColor & 0xFF;
      int rgb = rgbaColor >> 8;
      return rgb + (a << 24);
    }

    final offset = Alignment.topLeft.alongSize(
      Size(
        image.width.toDouble() - 1.0,
        image.height.toDouble() - 1.0,
      ),
    );

    final byteOffset =
        4 * (offset.dx.round() + (offset.dy.round() * image.width));
    final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
    Color color = Color(rgbaToArgb(byteData!.getUint32(byteOffset)));
    if (color == Colors.transparent) color = Colors.white;
    return color;
  }

  static bool isDisposableEmail(String email) {
    final splittedEmail = email.split('@');
    if (splittedEmail.isEmpty) return false;
    final domain = splittedEmail.last;
    console.info('email domain: $domain');
    return kBlockedEmailDomains.contains(domain);
  }

  static String extractFileExtension(String filePath) {
    String fileName = filePath.split('/').last; // Get the file name
    List<String> fileNameParts = fileName.split('.'); // Split file name by '.'
    return fileNameParts.last; // Get the last part as extension
  }

  static String generateRandomString({int length = 10}) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random();
    return String.fromCharCodes(
      Iterable.generate(
        length,
        (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }
}
