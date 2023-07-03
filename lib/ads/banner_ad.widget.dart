import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../globals.dart';
import '../license/license.service.dart';

class NexBannerAd extends StatelessWidget with ConsoleMixin {
  final bool small;
  final String placement;
  const NexBannerAd({super.key, this.small = true, required this.placement});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Visibility(
        visible: !LicenseService.to.isPremium && isAdSupportedPlatform,
        child: AppodealBanner(
          adSize: small
              ? AppodealBannerSize.BANNER
              : AppodealBannerSize.MEDIUM_RECTANGLE,
          placement: placement,
        ),
      ),
    );
  }
}
