import 'package:app_core/config.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/busy_indicator.widget.dart';
import 'package:app_core/widgets/pro.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../controllers/pro.controller.dart';
import '../../widgets/logo.widget.dart';
import '../routes.dart';
import 'feature.tile.dart';
import 'upgrade_screen.controller.dart';

class UpgradeScreen extends StatelessWidget with ConsoleMixin {
  const UpgradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpgradeScreenController());
    final upgradeConfig = CoreConfig().upgradeConfig;

    // String deviceAccess = 'Other devices';

    // if (isMac) {
    //   deviceAccess = 'iOS & ${'other_platform_access'.tr}';
    // } else if (GetPlatform.isIOS) {
    //   deviceAccess = 'macOS & ${'other_platform_access'.tr}';
    // } else if (GetPlatform.isAndroid) {
    //   deviceAccess = 'iOS, macOS, Windows, \nand Web ${'app_access'.tr}';
    // } else if (isWindows) {
    //   deviceAccess = 'iOS, macOS, Android, \nand Web ${'app_access'.tr}';
    // } else if (isLinux) {
    //   deviceAccess =
    //       'iOS, macOS, Windows, Android, \nand Web ${'app_access'.tr}';
    // } else if (kIsWeb) {
    //   deviceAccess = 'iOS, macOS, Windows, \nand Android ${'app_access'.tr}';
    // }

    final benefits = ListView(
      shrinkWrap: true,
      controller: ScrollController(),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            'unlock_all_access'.tr,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ...upgradeConfig.features.map((e) => FeatureTile(title: e)).toList(),
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

    final productsListView = Obx(
      () => ListView.builder(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        controller: ScrollController(),
        itemCount: ProController.to.packages.length,
        itemBuilder: (_, index) {
          final package = ProController.to.packages[index];
          final product = package.storeProduct;
          final packageType = package.packageType.name.toLowerCase();

          Widget title = Text('Just ${product.priceString} ${packageType.tr}');
          Widget? subTitle =
              product.description.isEmpty ? null : Text(product.description);
          Widget? secondary;

          if (product.introductoryPrice != null) {
            final intro = product.introductoryPrice!;
            final periodCycle = intro.cycles > 1
                ? '${intro.cycles} ${intro.periodUnit.name.tr}s'
                : intro.periodUnit.name.tr;

            title = Obx(
              () => RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Get.theme.textTheme.titleLarge?.color,
                  ),
                  children: [
                    TextSpan(text: product.priceString),
                    TextSpan(text: ' / ${controller.periodUnitName.tr}'),
                  ],
                ),
              ),
            );

            secondary = Card(
              elevation: 1.0,
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 2, 10, 5),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  // crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ExtendedImage.network(
                      'https://i.imgur.com/zUCN6gk.png',
                      height: 20,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      'Gumroad',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Get.theme.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            );

            subTitle = RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey,
                ),
                children: [
                  const TextSpan(text: 'Start with '),
                  TextSpan(
                    text: intro.priceString,
                    style: TextStyle(
                      color: Get.theme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: ' on the first $periodCycle'),
                ],
              ),
            );

            if (controller.isFreeTrial) {
              final monthlyPrice = product.price / 12;
              final currencySymbol = product.priceString.substring(0, 1);

              subTitle = RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                  children: [
                    TextSpan(
                      text:
                          '$currencySymbol${currencyFormatter.format(monthlyPrice)}',
                      style: TextStyle(color: Get.theme.primaryColor),
                    ),
                    TextSpan(text: ' / ${'month_billed_annually'.tr}'),
                  ],
                ),
              );
            }
          }

          return Obx(
            () => RadioListTile<String>(
              title: title,
              subtitle: subTitle,
              value: package.identifier,
              secondary: !isIAPSupported ? secondary : null,
              groupValue: controller.identifier,
              activeColor: Get.theme.primaryColor,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) => controller.package.value =
                  ProController.to.packages.firstWhere(
                (e) => e.identifier == value,
              ),
            ),
          );
        },
      ),
    );

    final actionCardContent = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            isIAPSupported
                ? productsListView
                : RadioListTile<int>(
                    title: Obx(
                      () => Text(
                        controller.gumroadProduct.value.formattedPrice,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Get.theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ),
                    contentPadding: EdgeInsets.zero,
                    groupValue: null,
                    onChanged: (_) {},
                    value: 0,
                  ),
            const SizedBox(height: 5),
            ElevatedButton(
              onPressed: controller.purchase,
              style: ElevatedButton.styleFrom(
                backgroundColor: Get.theme.primaryColor,
                visualDensity: VisualDensity.standard,
                padding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 15,
                ),
              ),
              child: Obx(
                () => Column(
                  children: [
                    Text(
                      '${controller.isFreeTrial ? 'try_free'.tr : 'subscribe'.tr} & ${'cancel_anytime'.tr}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (controller.isFreeTrial) ...[
                      Text(
                        "trial_remind".tr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(duration: 2000.ms)
                .then(delay: 2000.ms),
            const SizedBox(height: 5),
            Text(
              "easy_cancel".tr,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        const SizedBox(height: 10),
      ],
    );

    final actionCard = Card(
      elevation: 4.0,
      color: Get.isDarkMode ? const Color(0xFF0B1717) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: controller.obx(
          (state) => actionCardContent,
          onLoading: BusyIndicator(color: Get.theme.primaryColor),
        ),
      ),
    );

    final content = Padding(
      padding: const EdgeInsets.only(left: 5, right: 5, bottom: 5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: benefits),
          actionCard,
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
      title: Row(
        children: const [
          LogoWidget(size: 30),
          SizedBox(width: 15),
          ProText(size: 23),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Get.back();
            CoreConfig().onCloseUpgradeScreen?.call();
          },
        ),
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: Text('help_question'.tr),
        ),
        const SizedBox(width: 10),
      ],
    );

    return Container(
      decoration:
          Get.isDarkMode ? CoreConfig().upgradeConfig.darkDecoration : null,
      child: Scaffold(
        backgroundColor: Get.isDarkMode ? Colors.transparent : null,
        appBar: appBar,
        body: content,
      ),
    );
  }
}
