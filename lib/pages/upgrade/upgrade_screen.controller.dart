import 'dart:async';

import 'package:app_core/config.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/upgrade/extensions.dart';
import 'package:app_core/pages/upgrade/pricing.model.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/gradient.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../config/app.model.dart';
import '../../purchases/purchases.services.dart';
import '../../services/notifications.service.dart';
import '../../supabase/model/gumroad_product.model.dart';
import '../routes.dart';

class UpgradeScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static UpgradeScreenController get to => Get.find();

  // VARIABLES
  Timer? cooldownTimer;

  // PROPERTIES
  final busy = false.obs;
  final showMoreFeatures = false.obs;
  final tabIndex = 0.obs;
  final data = <Package>[].obs;
  // final package = Rx<Package>(Package.fromJson(kPackageInitial));
  final package = Rxn<Package>();
  final gumroadProduct = const Product().obs;
  final timerSeconds = 0.obs;

  // GETTERS
  String get packageId => package.value?.identifier ?? '';
  StoreProduct get product =>
      package.value?.storeProduct ?? StoreProduct('', '', '', 0, '', '');
  String get bgImageUri =>
      PurchasesService.to.offerings.value.current!.metadata['bgImageURI']
          ?.toString() ??
      'https://images.unsplash.com/photo-1563089145-599997674d42?q=80&w=500&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

  Pricing get pricing {
    return CoreConfig().upgradeConfig.pricing[product.identifier] ??
        CoreConfig().upgradeConfig.pricing.entries.first.value;
  }

  String get buttonText {
    return busy.value
        ? '${'please_wait'.tr}...'
        : isIAPSupported
            ? product.buttonTitle
            : 'redeem_trial'.tr;
  }

  String get buttonSubText {
    // return isIAPSupported
    //     ? product.buttonSubTitle
    //     : gumroadProduct.value.buttonSubTitle;

    return isIAPSupported
        ? product.buttonSubTitle
        : 'Upgrade to get the best experience';
  }

  String get footerText {
    // return isIAPSupported ? product.discount : gumroadProduct.value.discount;
    final gumroadText = 'Limited Time Sale Offer'.obs;
    return isIAPSupported ? product.discount : gumroadText.value;
  }

  // INIT
  @override
  void onClose() {
    cooldownTimer?.cancel();
    super.onClose();
  }

  @override
  void onInit() async {
    load();
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void onReady() {
    console.wtf('data: ${data.length}');

    final title = Get.parameters['title'];
    final body = Get.parameters['body'];

    if (title != null && body != null) {
      UIUtils.showImageDialog(
        GradientWidget(
          gradient: LinearGradient(colors: CoreConfig().gradientColors),
          child: const Icon(Icons.rocket, size: 150),
        ),
        title: title,
        body: body,
        closeText: 'try_app_pro'.trParams({'w1': appConfig.name}),
      );
    }

    if (Get.parameters['cooldown'] != null) {
      final cooldown = int.tryParse(Get.parameters['cooldown']!) ?? 5;
      timerSeconds.value = cooldown;

      cooldownTimer = Timer.periodic(1.seconds, (timer) {
        timerSeconds.value = cooldown - timer.tick;

        if (timerSeconds.value <= 0) {
          timerSeconds.value = 0; // just to make sure
          cooldownTimer?.cancel();
          // console.info('cancelled cooldown timer');
        }
      });
    }

    super.onReady();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  Future<void> load() async {
    if (!isIAPSupported) return _loadGumroad();
    // just incase it hasn't been loaded on app start
    if (PurchasesService.to.packages.isEmpty) {
      await PurchasesService.to.load();
    }

    data.value = PurchasesService.to.packages;
    if (data.isNotEmpty) package.value = data.first;
  }

  Future<void> _loadGumroad() async {
    // change(null, status: RxStatus.loading());
    // final result = await FunctionsService.to.gumroadProductDetail();
    // change(null, status: RxStatus.success());

    // result.fold(
    //   (left) => UIUtils.showSimpleDialog(
    //     'Gumroad Product Error',
    //     left,
    //   ),
    //   (right) {
    //     gumroadProduct.value = right.product;
    //     console.wtf('gumroad product: ${gumroadProduct.value.formattedPrice}');
    //   },
    // );
  }

  void purchase() async {
    if (busy.value) return console.error('still busy');

    if (!isIAPSupported) {
      Utils.openUrl(appConfig.links.store.gumroad);
      Get.back();

      return Utils.adaptiveRouteOpen(
        name: Routes.settings,
        parameters: {'expand': 'account', 'action': 'license_key'},
      );
    }

    if (data.isEmpty) {
      return console.error('empty packages');
    }

    change(null, status: RxStatus.loading());

    final package = data.firstWhere(
      (e) => e.identifier == packageId,
    );

    await PurchasesService.to.purchase(package);
    change(null, status: RxStatus.success());

    if (PurchasesService.to.isPremium) {
      NotificationsService.to.notify(
        title: '${appConfig.name} ${'pro_activated'.tr}',
        body: 'pro_thanks'.tr,
      );

      Get.back();
      CoreConfig().onSuccessfulUpgrade?.call();
    }
  }

  void restore() async {
    if (!isIAPSupported) {
      return UIUtils.showSimpleDialog(
        'License Key',
        'If you have a license key. Please set it in Settings -> Account -> Update License Key',
      );
    }

    if (busy.value) return console.error('still busy');
    change(null, status: RxStatus.loading());
    await PurchasesService.to.restore();
    change(null, status: RxStatus.success());

    if (PurchasesService.to.isPremium) {
      NotificationsService.to.notify(
        title: '${appConfig.name} ${'pro_restored'.tr}',
        body: 'Thanks for being a ${appConfig.name} rockstar!',
      );

      Get.back();

      CoreConfig().onSuccessfulUpgrade?.call();
    } else {
      UIUtils.showSimpleDialog(
        'no_purchases'.tr,
        'not_subscribed'.trParams({'w1': appConfig.name}),
      );
    }
  }
}

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
