import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/notifications/notifications.manager.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/gradient.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../controllers/pro.controller.dart';
import '../../supabase/model/gumroad_product.model.dart';
import '../../supabase/supabase_functions.service.dart';
import '../routes.dart';

class UpgradeScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  static UpgradeScreenController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final busy = false.obs;
  final showMoreFeatures = false.obs;
  final tabIndex = 0.obs;
  final package = Rx<Package>(Package.fromJson(kPackageInitial));
  final gumroadProduct = const Product().obs;

  // GETTERS
  String get identifier => package.value.identifier;

  StoreProduct get product => package.value.storeProduct;

  bool get isSubscription => product.identifier.contains('.sub.');

  String get priceString =>
      product.introductoryPrice?.priceString ?? product.priceString;

  String get periodUnitName {
    if (product.identifier.contains('annual')) {
      return 'year';
    } else if (product.identifier.contains('month')) {
      return 'month';
    }

    return 'error';
  }

  bool get isFreeTrial => product.introductoryPrice?.price == 0;

  String get promoText {
    final intro = product.introductoryPrice!;

    final percentageDifference_ =
        ((product.price - intro.price) / product.price) * 100;

    return isFreeTrial
        ? '${intro.periodNumberOfUnits} ${GetUtils.capitalizeFirst(intro.periodUnit.name.tr)} ${'free_trial'.tr}'
        : '${percentageDifference_.round()}%\nOFF';
  }

  // INIT
  @override
  void onInit() async {
    _load();
    change(null, status: RxStatus.success());
    super.onInit();
  }

  @override
  void onReady() {
    final title = Get.parameters['title'];
    final body = Get.parameters['body'];

    if (title != null && body != null) {
      UIUtils.showImageDialog(
        const GradientWidget(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 255, 0, 212),
              Color.fromARGB(255, 0, 166, 255),
            ],
          ),
          child: Icon(Icons.rocket, size: 150),
        ),
        title: title,
        body: body,
        closeText: 'try_app_pro'.trParams({'w1': ConfigService.to.appName}),
      );
    }

    super.onReady();
  }

  @override
  void change(newState, {RxStatus? status}) {
    busy.value = status?.isLoading ?? false;
    super.change(newState, status: status);
  }

  // FUNCTIONS
  Future<void> _load() async {
    if (!isIAPSupported) return _loadGumroad();
    await ProController.to.load();

    if (ProController.to.packages.isNotEmpty) {
      package.value = ProController.to.packages.first;
    }
  }

  Future<void> _loadGumroad() async {
    change(null, status: RxStatus.loading());
    final result = await SupabaseFunctionsService.to.gumroadProductDetail();
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
      Utils.openUrl(
        ConfigService.to.general.app.links.store.gumroad,
      );

      Get.back();

      return Utils.adaptiveRouteOpen(
        name: Routes.settings,
        parameters: {'expand': 'account', 'action': 'license_key'},
      );
    }

    if (ProController.to.packages.isEmpty) {
      return console.error('empty packages');
    }

    change(null, status: RxStatus.loading());

    final package = ProController.to.packages.firstWhere(
      (e) => e.identifier == identifier,
    );

    await ProController.to.purchase(package);
    change(null, status: RxStatus.success());

    if (ProController.to.isPro) {
      NotificationsManager.notify(
        title: '${ConfigService.to.appName} ${'pro_activated'.tr}',
        body: 'pro_thanks'.tr,
      );

      Get.back();
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
    await ProController.to.restore();
    change(null, status: RxStatus.success());

    if (ProController.to.isPro) {
      NotificationsManager.notify(
        title: '${ConfigService.to.appName} ${'pro_restored'.tr}',
        body: 'Thanks for being a ${ConfigService.to.appName} Pro rockstar!',
      );

      Get.back();
    } else {
      UIUtils.showSimpleDialog(
        'no_purchases'.tr,
        'not_subscribed'.trParams({'w1': ConfigService.to.appName}),
      );
    }
  }
}
