import 'dart:ui' as ui;
import 'package:app_core/config.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

import '../controllers/pro.controller.dart';
import '../globals.dart';
import '../pages/feedback/feedback_screen.controller.dart';
import '../pages/routes.dart';

class Utils {
  // VARIABLES
  static final console = Console(name: 'Utils');

  // GETTERS

  // FUNCTIONS

  static void copyToClipboard(text) async {
    await Clipboard.setData(ClipboardData(text: text));
    UIUtils.showSnackBar(
      title: 'Copied',
      message: 'Successfully copied to clipboard',
      icon: const Icon(Iconsax.copy),
      seconds: 2,
    );
  }

  static String timeAgo(DateTime dateTime, {bool short = true}) {
    final locale =
        (Get.locale?.languageCode ?? 'en_US') + (short ? "_short" : "");
    return timeago.format(dateTime, locale: locale).replaceFirst("~", "");
  }

  // support higher refresh rate
  static void setDisplayMode() async {
    if (!GetPlatform.isAndroid) return;

    try {
      final mode = await FlutterDisplayMode.active;
      console.warning('active mode: $mode');
      final modes = await FlutterDisplayMode.supported;

      for (DisplayMode e in modes) {
        console.info('display modes: $e');
      }

      await FlutterDisplayMode.setPreferredMode(modes.last);
      console.info('set mode: ${modes.last}');
    } on PlatformException catch (e) {
      console.error('display mode error: $e');
    }
  }

  static Future<dynamic>? adaptiveRouteOpen({
    required String name,
    String method = 'toNamed',
    Size dialogSize = const Size(600, 900),
    Map<String, String> parameters = const {},
    dynamic arguments,
  }) {
    if (ProController.to.isPro && name == Routes.upgrade) {
      console.info('ignored upgrade screen');
      return Future.value(false);
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

  static String platformName() {
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

    if (SupabaseAuthService.to.authenticated) {
      body += 'User ID: ${SupabaseAuthService.to.user!.id}$ln';
    }

    // TODO: Entitlement
    // body += 'Entitlement: ${ProController.to.limits.id}$ln';
    body += 'Pro: ${ProController.to.isPro}$ln';
    body += 'RC User ID: ${ProController.to.info.value.originalAppUserId}$ln';

    if (Get.locale != null) {
      body += 'Locale: ${Get.locale?.languageCode}$ln';
    }

    body += 'App Version: ${metadataApp.formattedVersion}$ln';
    body += 'Platform: ${Utils.platformName()}$ln';
    body += 'Route: $previousRoute$ln';

    final emails = ConfigService.to.general.app.emails;
    String email = emails.support;

    if (feedbackType == FeedbackType.issue) {
      email = emails.issues;
    }

    final url = 'mailto:$email?subject=$subject&body=$body';
    openUrl(Uri.encodeFull(url));
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
}
