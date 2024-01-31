import 'package:app_core/config.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../globals.dart';
import '../persistence/persistence.dart';
import '../purchases/purchases.services.dart';
import '../widgets/upgrade_button.widget.dart';

class NexBannerAd extends StatelessWidget with ConsoleMixin {
  final bool small;
  final bool fallbackPremium;
  final String placement;

  const NexBannerAd({
    super.key,
    this.small = true,
    required this.placement,
    this.fallbackPremium = true,
  });

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

    if (isAdSupportedPlatform && Persistence.to.fullscreenAdsAgreed.val) {
      return Obx(
        () => Visibility(
          visible: !PurchasesService.to.isPremium,
          child: AppodealBanner(
            adSize: small
                ? AppodealBannerSize.BANNER
                : AppodealBannerSize.MEDIUM_RECTANGLE,
            placement: placement,
          ),
        ),
      );
    }

    // premium button fallback
    if (!CoreConfig().purchasesEnabled || !fallbackPremium) {
      return SizedBox.shrink();
    }

    return Obx(
      () => Visibility(
        visible: !PurchasesService.to.isPremium,
        child: UpgradeButton(),
      ),
    );
  }
}
