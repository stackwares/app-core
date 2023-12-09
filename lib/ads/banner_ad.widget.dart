import 'package:app_core/config.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../config/app.model.dart';
import '../globals.dart';
import '../license/license.service.dart';
import '../pages/routes.dart';
import '../utils/utils.dart';
import '../widgets/logo.widget.dart';
import '../widgets/pro.widget.dart';

class NexBannerAd extends StatelessWidget with ConsoleMixin {
  final bool small;
  final String placement;
  const NexBannerAd({super.key, this.small = true, required this.placement});

  @override
  Widget build(BuildContext context) {
    // if (small) {
    //   Appodeal.setBannerCallbacks(
    //     onBannerLoaded: (isPrecache) {
    //       visible.value = true;
    //       console.wtf('## banner loaded');
    //     },
    //     onBannerFailedToLoad: () {
    //       // visible.value = false;
    //       console.wtf('## banner failed to load');
    //     },
    //     onBannerShown: () {
    //       console.wtf('## banner shown');
    //     },
    //     onBannerShowFailed: () {
    //       visible.value = false;
    //       console.wtf('## banner failed to show');
    //     },
    //     onBannerClicked: () {
    //       console.wtf('## banner clicked');
    //     },
    //     onBannerExpired: () {
    //       // visible.value = false;
    //       console.wtf('## banner expired');
    //     },
    //   );
    // } else {
    //   Appodeal.setMrecCallbacks(
    //     onMrecLoaded: (isPrecache) {
    //       visible.value = true;
    //       console.wtf('## mrec loaded');
    //     },
    //     onMrecFailedToLoad: () {
    //       visible.value = false;
    //       console.wtf('## mrec failed to load');
    //     },
    //     onMrecShown: () {
    //       console.wtf('## mrec shown');
    //     },
    //     onMrecShowFailed: () {
    //       visible.value = false;
    //       console.wtf('## mrec failed to show');
    //     },
    //     onMrecClicked: () {
    //       console.wtf('## mrec clicked');
    //     },
    //     onMrecExpired: () {
    //       visible.value = false;
    //       console.wtf('## mrec expired');
    //     },
    //   );
    // }

    if (isAdSupportedPlatform) {
      return Obx(
        () => Visibility(
          visible: !LicenseService.to.isPremium,
          child: AppodealBanner(
            adSize: small
                ? AppodealBannerSize.BANNER
                : AppodealBannerSize.MEDIUM_RECTANGLE,
            placement: placement,
          ),
        ),
      );
    }

    if (CoreConfig().purchasesEnabled) {
      return Obx(
        () => Visibility(
          visible: !LicenseService.to.isPremium,
          child: Tooltip(
            // TODO: localize
            message: 'Redeem your free ${appConfig.name} Premium',
            child: InkWell(
              onTap: () => Utils.adaptiveRouteOpen(name: Routes.upgrade),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      const LogoWidget(size: 20),
                      const SizedBox(width: 10),
                      Text(
                        '${'try'.tr} ',
                        style: TextStyle(
                          color: Get.theme.primaryColor,
                          // fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ProText(
                        // size: 16,
                        premiumSize: 12,
                        text: 'premium'.tr.toUpperCase(),
                      ),
                    ],
                  ),
                ],
              )
                  .animate(onPlay: (c) => c.repeat())
                  .shimmer(duration: 2000.ms)
                  .shakeX(duration: 1000.ms, hz: 2, amount: 1)
                  .then(delay: 3000.ms),
            ),
          ),
        ),
      );
    }

    return SizedBox.shrink();
  }
}
