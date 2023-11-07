import 'package:app_core/animations/animations.dart';
import 'package:app_core/config.dart';

import 'package:app_core/globals.dart';
import 'package:app_core/pages/upgrade/item.tile.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/gradient.widget.dart';
import 'package:app_core/widgets/pro.widget.dart';
import 'package:app_core/widgets/remote_image.widget.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../config/app.model.dart';
import '../routes.dart';
import 'feature.tile.dart';
import 'upgrade_screen.controller.dart';

class UpgradeScreen extends StatelessWidget with ConsoleMixin {
  const UpgradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpgradeScreenController());

    final benefits = ListView(
      shrinkWrap: true,
      controller: ScrollController(),
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15),
          child: Text(
            '${'unlock_all_access'.tr} ⤵',
            style: const TextStyle(fontSize: 12),
          ),
        ),
        Divider(color: Colors.grey.withOpacity(0.1)),
        Obx(
          () => Column(
            children: controller.pricing.features
                .map(
                  (e) => FeatureTile(
                    title: e.tr,
                    highlighted: [
                      'money_back_guarantee',
                      'cancel_anytime',
                      'join_over_users',
                      'premium_pro_limit',
                    ].contains(e),
                  ),
                )
                .toList(),
          ),
        ),
        // if (controller.pricing.upcomingFeatures.isNotEmpty) ...[
        //   Column(
        //     crossAxisAlignment: CrossAxisAlignment.start,
        //     children: [
        //       const Divider(),
        //       Padding(
        //         padding: const EdgeInsets.only(left: 15),
        //         child: Text(
        //           'upcoming_features'.tr,
        //           style: const TextStyle(color: Colors.grey),
        //         ),
        //       ),
        //       ...controller.pricing.upcomingFeatures
        //           .map((e) => FeatureTile(title: e.tr))
        //           .toList(),
        //     ],
        //   ),
        // ]
      ],
    );

    final scrollController = ScrollController();

    final productsListView = Obx(
      () => Scrollbar(
        controller: scrollController,
        thumbVisibility: isDesktop,
        child: ListView.builder(
          controller: scrollController,
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          // scrollDirection: Axis.horizontal,
          itemCount: controller.data.length,
          itemBuilder: (context, index) => ListItemAnimation(
            axis: Axis.horizontal,
            offset: const Offset(0, -50),
            child: IAPProductTile(package: controller.data[index]),
          ),
        ),
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
              foregroundColor: Get.theme.colorScheme.onPrimary,
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
                  controller.buttonSubText,
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
        // const Positioned(
        //   top: 7,
        //   right: 6,
        //   child: RemoteImage(
        //     url: 'https://cdn-icons-png.flaticon.com/512/4840/4840351.png',
        //     width: 32,
        //     height: 32,
        //   ),
        // ),
      ],
    );

    final actionCardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.center,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    RemoteImage(
                      url:
                          'https://cdn-icons-png.flaticon.com/512/4840/4840351.png',
                      width: 32,
                      height: 32,
                    ),
                    const SizedBox(width: 10),
                    Obx(
                      () => GradientWidget(
                        gradient: LinearGradient(
                          colors: CoreConfig().gradientColors,
                        ),
                        child: Text(
                          controller.footerText,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.fade,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
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
            ),
          ),
          const SizedBox(height: 5),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              isIAPSupported && CoreConfig().upgradeConfig.grouped
                  ? Align(
                      alignment: Alignment.centerRight,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'pay_yearly'.tr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              Text(
                                '${'pay_yearly_sub'.tr} ⤴',
                                style: TextStyle(
                                  color: Get.theme.colorScheme.tertiary,
                                  fontSize: 10,
                                ),
                              )
                            ],
                          ),
                          const SizedBox(width: 10),
                          Obx(
                            () => Switch(
                              value: controller.showYearlyPlans.value,
                              onChanged: (value) =>
                                  controller.showYearlyPlans.value = value,
                            ),
                          ),
                        ],
                      ),
                    )
                  : SizedBox.fromSize(),
              isIAPSupported
                  ? Obx(
                      () => Visibility(
                        visible: controller.data.isNotEmpty,
                        replacement: const EmptyPackages(),
                        child: productsListView,
                      ),
                    )
                  : Obx(
                      () => IAPProductTileWeb(
                        product: controller.gumroadProduct.value,
                      ),
                    ),
              const SizedBox(height: 5),
              upgradeButton,
            ],
          ),
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
                onPressed: () => Utils.openUrl(appConfig.links.terms),
                child: Text('terms_of_use'.tr),
              ),
              const Text('|'),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Get.theme.primaryColor,
                  textStyle: const TextStyle(fontSize: 10),
                ),
                onPressed: () => Utils.openUrl(appConfig.links.privacy),
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
      title: ProText(
        size: 20,
        premiumSize: 15,
        text: 'premium'.tr.toUpperCase(),
      ),
      actions: [
        Obx(
          () => IconButton(
            icon: controller.timerSeconds.value == 0
                ? const Icon(Icons.close)
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      const SizedBox(
                        width: 30,
                        height: 30,
                        child: CircularProgressIndicator(),
                      ),
                      Text(
                        controller.timerSeconds.value.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
            onPressed: controller.timerSeconds.value == 0
                ? () {
                    Get.back();
                    CoreConfig().onCancelledUpgradeScreen?.call();
                  }
                : null,
          ),
        ),
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: Text('help_question'.tr),
        ),
        const SizedBox(width: 10),
      ],
    );

    return WillPopScope(
      onWillPop: () async => controller.timerSeconds.value == 0,
      child: Scaffold(
        backgroundColor:
            Get.isDarkMode ? const Color.fromARGB(255, 29, 29, 29) : null,
        appBar: appBar,
        body: content,
      ),
    );
  }
}

class EmptyPackages extends StatelessWidget {
  const EmptyPackages({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.warning,
            size: 70,
            color: Colors.red,
          ),
          const SizedBox(height: 5),
          const Text(
            'An error occured',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 5),
          OutlinedButton.icon(
            onPressed: UpgradeScreenController.to.load,
            label: Text('refresh'.tr),
            icon: const Icon(Icons.refresh),
          ),
          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
