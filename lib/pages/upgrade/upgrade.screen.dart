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
            style: const TextStyle(fontSize: 15),
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
                      // 'premium_pro_limit',
                    ].contains(e),
                  ),
                )
                .toList()
                .animate(interval: 400.ms)
                .fade(duration: 300.ms),
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

    final upgradeButton = Obx(
      () => ElevatedButton(
        onPressed: controller.busy.value ? null : controller.purchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.primaryColor,
          foregroundColor: Get.theme.colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 15 : 25),
        ),
        child: Text(
          controller.buttonText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            fontFamily: '',
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2000.ms)
        .then(delay: 2000.ms);

    final discountCard = Align(
      alignment: Alignment.center,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RemoteImage(
                url: 'https://cdn-icons-png.flaticon.com/512/4840/4840351.png',
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
            ],
          ),
        ),
      )
          .animate()
          .shimmer(duration: 2000.ms)
          .scaleXY(
            duration: 1000.ms,
            curve: Curves.fastOutSlowIn,
            begin: 0.7,
            end: 1,
          )
          .then(delay: 3000.ms),
    );

    final actionCardContent = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          discountCard,
          const SizedBox(height: 5),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isIAPSupported && CoreConfig().upgradeConfig.grouped) ...[
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'pay_yearly'.tr,
                            style: const TextStyle(fontWeight: FontWeight.w500),
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
              ],
              if (isIAPSupported) ...[
                Obx(
                  () => Visibility(
                    visible: controller.data.isNotEmpty,
                    replacement: const EmptyPackages(),
                    child: productsListView,
                  ),
                )
              ],
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

    final exitButton = Obx(
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
    );

    final appBar = AppBar(
      backgroundColor: Get.isDarkMode ? Colors.transparent : null,
      elevation: 0.0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: ProText(
        size: 25,
        premiumSize: 18,
        text: 'premium'.tr.toUpperCase(),
      ),
      actions: [
        exitButton,
        TextButton(
          onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
          child: Text('help_question'.tr),
        ),
        const SizedBox(width: 10),
      ],
    );

    return PopScope(
      canPop: controller.timerSeconds.value == 0,
      child: Scaffold(
        backgroundColor: (Get.isDarkMode && !isSmallScreen)
            ? Color.fromARGB(255, 18, 18, 18)
            : null,
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
