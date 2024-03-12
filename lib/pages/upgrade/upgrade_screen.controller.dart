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
import '../../services/notifications.service.dart';
import '../../purchases/purchases.services.dart';
import '../../supabase/model/gumroad_product.model.dart';
import '../../supabase/supabase_functions.service.dart';
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
  final package = Rx<Package>(Package.fromJson(kPackageInitial));
  final gumroadProduct = const Product().obs;
  final timerSeconds = 0.obs;

  // GETTERS
  String get packageId => package.value.identifier;
  StoreProduct get product => package.value.storeProduct;

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
    change(null, status: RxStatus.loading());
    final result = await FunctionsService.to.gumroadProductDetail();
    change(null, status: RxStatus.success());

    result.fold(
      (left) => UIUtils.showSimpleDialog(
        'Gumroad Product Error',
        left,
      ),
      (right) {
        gumroadProduct.value = right.product;
        console.wtf('gumroad product: ${gumroadProduct.value.formattedPrice}');
      },
    );
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
