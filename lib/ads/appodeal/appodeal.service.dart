import 'dart:async';

import 'package:app_core/config.dart';
import 'package:app_core/config/app.model.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/purchases/purchases.services.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:stack_appodeal_flutter/stack_appodeal_flutter.dart';

import '../../persistence/persistence.dart';

class AppodealService extends GetxService with ConsoleMixin {
  static AppodealService get to => Get.find();

  // VARIABLES
  String placement = 'default';
  bool busy = false;
  int failedConsentCount = 0;
  var lastShowTime = DateTime.now().subtract(1.days);

  // GETTERS
  bool get timeToShow => Persistence.to.sessionCount.val >= 4;

  @override
  void onInit() async {
    init();
    super.onInit();
  }

  // FUNCTIONS
  void updateLastShowTime() => lastShowTime = DateTime.now();

  void init() async {
    if (!isAdSupportedPlatform) return;
    final r = await Permission.appTrackingTransparency.request();
    console.wtf('att: ${r.isGranted}');

    Appodeal.setTesting(kDebugMode);
    Appodeal.setLogLevel(Appodeal.LogLevelNone);

    Appodeal.setAdRevenueCallbacks(
      onAdRevenueReceive: (adRevenue) {
        console.wtf('Revenue: ${adRevenue.currency}${adRevenue.revenue}');
        // TODO: convert to free word limits
        // disable ads for a few minutes
      },
    );

    Appodeal.initialize(
      appKey: CoreConfig().appodealKey,
      adTypes: [
        AppodealAdType.Interstitial,
        AppodealAdType.RewardedVideo,
        AppodealAdType.Banner,
        AppodealAdType.MREC,
      ],
      onInitializationFinished: (errors) => errors?.forEach(
        (e) {
          console.error('onInitializationFinished Error');
          console.error(e.description);
        },
      ),
    );

    _showConsent();
    // console.info('init');
  }

  void initAds(String placement_) {
    placement = placement_;
    // console.info("initAds: $placement");
  }

  Future<AdResult> _show(AppodealAdType adType) async {
    if (PurchasesService.to.isPremium || !isAdSupportedPlatform) {
      return AdResult(AdResult.failed, description: 'unsupported');
    }

    if (busy) {
      return AdResult(AdResult.busy, description: 'busy');
    }

    if (!await Appodeal.canShow(adType, placement)) {
      return AdResult(AdResult.busy, description: 'cannot show');
    }

    if (!await Appodeal.isLoaded(adType)) {
      return AdResult(AdResult.busy, description: 'not loaded');
    }

    // only show after duration has passed
    final cooldown = CoreConfig().premiumScreenCooldown;

    if (lastShowTime.isAfter(DateTime.now().subtract(cooldown.seconds)) &&
        isAdSupportedPlatform) {
      return AdResult(
        AdResult.failed,
        description: 'next show time: ${lastShowTime.add(cooldown.seconds)}',
      );
    }

    console.info('_show: $placement');
    final completer = Completer<AdResult>();

    void onCancelled() {
      busy = false;
      completer.complete(
        AdResult(AdResult.failed, description: 'onCancelled'),
      );

      // console.info('onCancelled');
    }

    void onSuccess() {
      busy = false;
      completer.complete(
        AdResult(AdResult.success, description: 'onSuccess'),
      );

      // console.info('onSuccess');
    }

    // LISTENERS
    Appodeal.setInterstitialCallbacks(
      onInterstitialLoaded: (isPrecache) => console.wtf('onInterstitialLoaded'),
      onInterstitialFailedToLoad: onCancelled,
      onInterstitialShown: updateLastShowTime,
      onInterstitialShowFailed: onCancelled,
      onInterstitialClicked: () => console.wtf('onInterstitialClicked'),
      onInterstitialClosed: onSuccess,
      onInterstitialExpired: onCancelled,
    );

    Appodeal.setRewardedVideoCallbacks(
      onRewardedVideoLoaded: (isPrecache) =>
          console.wtf('onRewardedVideoLoaded'),
      onRewardedVideoFailedToLoad: onCancelled,
      onRewardedVideoShown: updateLastShowTime,
      onRewardedVideoShowFailed: onCancelled,
      onRewardedVideoFinished: (amount, reward) => onSuccess(),
      onRewardedVideoClosed: (isFinished) => onSuccess(),
      onRewardedVideoExpired: onCancelled,
      onRewardedVideoClicked: () => console.wtf('onRewardedVideoClicked'),
    );

    busy = true;
    Appodeal.show(adType, placement).then((value) {
      // console.info('then show() => $value');
    });

    return completer.future;
  }

  Future<AdResult> showFullscreen({
    FullscreenAdType? adType,
    int delay = 0,
    bool proScreen = false,
  }) async {
    if (!CoreConfig().adsEnabled) {
      console.warning('disabled ads');
      return AdResult(AdResult.failed, description: 'disabled ads');
    }

    if (PurchasesService.to.isPremium) {
      console.warning('premium user');
      return AdResult(AdResult.failed, description: 'premium user');
    }

    if (!timeToShow && !proScreen) {
      console.warning("it's not time");
      return AdResult(AdResult.failed, description: "it's not time");
    }

    if (!Persistence.to.fullscreenAdsAgreed.val) {
      bool abort = false;

      final dialog = AlertDialog(
        title: Text('ads_title'.tr.capitalize!),
        content: SizedBox(
          width: 400,
          child: Text('ads_sub'.trParams({'w1': appConfig.name})),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Get.back();
              Utils.adaptiveRouteOpen(name: Routes.upgrade);
              abort = true;
            },
            child: Text('upgrade'.tr.capitalize!),
          ),
          TextButton(
            child: Text('continue_free'.tr.capitalize!),
            onPressed: () {
              Persistence.to.fullscreenAdsAgreed.val = true;
              Get.back();
            },
          ),
        ],
      );

      await Get.dialog(dialog, barrierDismissible: false);

      if (abort) {
        return AdResult(AdResult.failed, description: 'agreed');
      }
    }

    if (delay > 0) {
      await Future.delayed(delay.seconds);
    }

    if (!isAdSupportedPlatform || proScreen) {
      Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {'cooldown': CoreConfig().premiumScreenCooldown.toString()},
      );

      return AdResult(AdResult.failed, description: 'show alternative');
    }

    console.info('showFullscreen: $adType');

    if (adType == FullscreenAdType.interstitial) {
      return _show(Appodeal.INTERSTITIAL);
    } else if (adType == FullscreenAdType.rewarded) {
      return _show(Appodeal.REWARDED_VIDEO);
    } else {
      final rewardedResult = await _show(Appodeal.REWARDED_VIDEO);
      if (rewardedResult.code == AdResult.success) {
        return AdResult(AdResult.success);
      }

      final interstitialResult = await _show(Appodeal.INTERSTITIAL);
      if (interstitialResult.code == AdResult.success) {
        return AdResult(AdResult.success);
      }

      // show upgrade screen if ads fail to show
      Utils.adaptiveRouteOpen(
        name: Routes.upgrade,
        parameters: {'cooldown': CoreConfig().premiumScreenCooldown.toString()},
      );

      return AdResult(AdResult.failed);
    }
  }

  Future<AdResult> showInterstitial() async {
    return _show(Appodeal.INTERSTITIAL);
  }

  Future<AdResult> showRewarded() async {
    return _show(Appodeal.REWARDED_VIDEO);
  }

  void _showConsent() {
    if (!isAdSupportedPlatform || !isApple) return;

    void onConsentFormLoadSuccess(ConsentStatus status) {
      console.wtf('onConsentFormLoadSuccess: ${status.name}');

      Appodeal.ConsentForm.show(
        onConsentFormDismissed: (error) {
          console.wtf('onConsentFormDismissed: ${error?.description}');
        },
      );
    }

    void onConsentFormLoadFailure(ConsentError error) {
      console.wtf('onConsentFormLoadFailure: ${error.description}');
    }

    // load consent form
    Appodeal.ConsentForm.load(
      appKey: CoreConfig().appodealKey,
      onConsentFormLoadSuccess: onConsentFormLoadSuccess,
      onConsentFormLoadFailure: onConsentFormLoadFailure,
    );
  }
}

enum FullscreenAdType { interstitial, rewarded }

class AdResult {
  final int code;
  final String description;
  const AdResult(this.code, {this.description = ''});

  static int busy = 100;
  static int failed = 400;
  static int exception = 500;
  static int success = 200;
}
