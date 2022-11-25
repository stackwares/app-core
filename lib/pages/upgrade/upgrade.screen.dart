import 'package:app_core/config.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/upgrade/extensions.dart';
import 'package:app_core/pages/upgrade/item.tile.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/pro.widget.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/pro.controller.dart';
import '../routes.dart';
import 'feature.tile.dart';
import 'upgrade_screen.controller.dart';

class UpgradeScreen extends StatelessWidget with ConsoleMixin {
  const UpgradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpgradeScreenController());
    final upgradeConfig = CoreConfig().upgradeConfig;

    final benefits = ListView(
      shrinkWrap: true,
      controller: ScrollController(),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            'unlock_all_access'.tr,
            style: const TextStyle(fontSize: 12),
          ),
        ),
        const Divider(),
        Obx(
          () => Visibility(
            visible: isIAPSupported,
            replacement: Column(
              children: [
                FeatureTile(
                  title: 'money_back_guarantee'.tr,
                  highlighted: true,
                ),
                FeatureTile(
                  title: 'money_back_guarantee'.tr,
                  highlighted: true,
                ),
                FeatureTile(
                  title: '7-Day ${'free_trial'.tr}',
                  highlighted: true,
                ),
                FeatureTile(
                  title: 'cancel_anytime'.tr,
                  highlighted: true,
                ),
              ],
            ),
            child: Column(
              children: controller.product.features
                  .map(
                    (e) => FeatureTile(title: e, highlighted: true),
                  )
                  .toList(),
            ),
          ),
        ),
        ...upgradeConfig.features
            .map((e) => FeatureTile(title: e == 'first' ? 'The First' : e))
            .toList(),
        Obx(
          () => Visibility(
            visible: controller.showMoreFeatures.value &&
                upgradeConfig.upcomingFeatures.isNotEmpty,
            replacement: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.eye, color: Get.theme.primaryColor),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: controller.showMoreFeatures.toggle,
                    child: Text(
                      'more_upcoming_features'.tr,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Text(
                    'upcoming_features'.tr,
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
                ...upgradeConfig.upcomingFeatures
                    .map((e) => FeatureTile(title: e))
                    .toList(),
              ],
            ),
          ),
        ),
      ],
    );

    Widget itemBuilder(_, index) {
      final package = ProController.to.packages[index];
      return IAPProductTile(package: package);
    }

    final productsListView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        controller: ScrollController(),
        itemCount: ProController.to.packages.length,
        itemBuilder: itemBuilder,
      ),
    );

    final upgradeButton = Stack(
      alignment: Alignment.topRight,
      children: [
        Obx(
          () => ElevatedButton(
            onPressed: controller.busy.value ? null : controller.purchase,
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              visualDensity: VisualDensity.standard,
              padding: const EdgeInsets.symmetric(
                vertical: 10,
                horizontal: 15,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  controller.buttonText,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  controller.product.buttonSubTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 2000.ms)
            .then(delay: 2000.ms),
        const Positioned(
          top: 7,
          right: 6,
          child: RemoteImage(
            url: 'https://cdn-icons-png.flaticon.com/512/4840/4840351.png',
            width: 32,
            height: 32,
          ),
        )
      ],
    );

    final actionCardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              isIAPSupported
                  ? productsListView
                  : Obx(
                      () => IAPProductTileWeb(
                        product: controller.gumroadProduct.value,
                      ),
                    ),
              const SizedBox(height: 5),
              upgradeButton,
              const SizedBox(height: 5),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Obx(
                      () => Text(
                        controller.product.discount,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.check_rounded,
                      color: Get.theme.primaryColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );

    final content = Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: benefits),
          actionCardContent,
          Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Get.theme.primaryColor,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                onPressed: () =>
                    Utils.openUrl(ConfigService.to.general.app.links.terms),
                child: Text('terms_of_use'.tr),
              ),
              const Text('|'),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Get.theme.primaryColor,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                onPressed: () => Utils.openUrl(
                  ConfigService.to.general.app.links.privacy,
                ),
                child: Text('privacy_policy'.tr),
              ),
              const Text('|'),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Get.theme.primaryColor,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                onPressed: controller.restore,
                child: Text('restore_purchases'.tr),
              ),
            ],
          ),
        ],
      ),
    );

    final appBar = AppBar(
      backgroundColor: Get.isDarkMode ? Colors.transparent : null,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: const ProText(size: 20),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.back();
            CoreConfig().onCancelledUpgradeScreen?.call();
          },
        ),
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: Text('help_question'.tr),
        ),
        const SizedBox(width: 10),
      ],
    );

    return Scaffold(
      backgroundColor:
          Get.isDarkMode ? const Color.fromARGB(255, 29, 29, 29) : null,
      appBar: appBar,
      body: content,
    );
  }
}
