import 'package:app_core/pages/upgrade/extensions.dart';
import 'package:app_core/pages/upgrade/upgrade_screen.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../globals.dart';
import '../../purchases/purchases.services.dart';
import '../../supabase/model/gumroad_product.model.dart';
import '../../widgets/remote_image.widget.dart';

class IAPProductTile extends StatelessWidget {
  final Package package;
  const IAPProductTile({super.key, required this.package});

  bool get isSelected =>
      UpgradeScreenController.to.packageId == package.identifier;

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final currencySymbol = product.priceString.substring(0, 1);
    final prefixId = product.identifier.split('.sub.')[0];
    String savedText = '';

    if (product.isAnnually) {
      final monthly = PurchasesService.to.packages.where(
        (e) =>
            e.storeProduct.isMonthly &&
            e.storeProduct.identifier.contains(prefixId),
      );
      if (monthly.isNotEmpty) {
        final price =
            ((monthly.first.storeProduct.price * 12) - product.price).round();
        savedText =
            'Save $currencySymbol${currencyFormatter.format(price)} vs ${'monthly'.tr.toLowerCase()}';
      }
    } else if (product.isMonthly) {
      final weekly = PurchasesService.to.packages.where(
        (e) =>
            e.storeProduct.isWeekly &&
            e.storeProduct.identifier.contains(prefixId),
      );
      if (weekly.isNotEmpty) {
        final price =
            ((weekly.first.storeProduct.price * 4) - product.price).round();
        savedText =
            'Save $currencySymbol${currencyFormatter.format(price)} vs ${'weekly'.tr.toLowerCase()}';
      }
    }

    // final titleText = Text(
    //   GetUtils.capitalizeFirst(product.planId)!,
    //   style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
    // );

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              // // TITLE
              // Obx(
              //   () => Visibility(
              //     visible: isSelected,
              //     replacement: titleText,
              //     child: GradientWidget(
              //       gradient: LinearGradient(
              //         colors: CoreConfig().gradientColors,
              //       ),
              //       child: titleText,
              //     ),
              //   ),
              // ),
              // PRICE & PERIOD
              // const SizedBox(width: 5),
              Text(
                product.itemTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              // SUB PERIOD
              const SizedBox(width: 10),
              Text(
                product.itemSubTitle,
                style: TextStyle(
                  fontSize: 12,
                  color: Get.theme.colorScheme.tertiary,
                ),
              ),
              // SAVED
              Visibility(
                visible: savedText.isNotEmpty,
                child: Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    savedText,
                    style: const TextStyle(fontSize: 12, color: Colors.amber),
                  ),
                ),
              ),
            ],
          ),
          // const Divider(height: 10),
          // PRIMARY FEATURE
          if (product.primaryFeature.isNotEmpty) ...[
            Text(
              product.primaryFeature.tr,
              style: TextStyle(
                color: Get.theme.primaryColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
          // TRIAL DURATION
          Visibility(
            visible: product.hasFreeTrial,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                product.trialDurationText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Get.theme.colorScheme.tertiary,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    return InkWell(
      onTap: () => UpgradeScreenController.to.package.value = package,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Obx(
            () => Card(
              elevation: Get.isDarkMode ? 10 : 1,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: isSelected
                    ? BorderSide(color: Get.theme.primaryColor, width: 2)
                    : const BorderSide(color: Colors.grey, width: 0.2),
              ),
              child: content,
            ),
          ),
          Visibility(
            visible: UpgradeScreenController.to.data.first == package,
            child: Padding(
              padding: EdgeInsets.only(right: 15),
              child: RemoteImage(
                url: 'https://cdn-icons-png.flaticon.com/128/477/477406.png',
                width: 27,
                height: 27,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class IAPProductTileWeb extends StatelessWidget {
  final Product product;
  const IAPProductTileWeb({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    const subTitleStyle = TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: Colors.grey,
    );

    const titleStyle = TextStyle(
      fontWeight: FontWeight.w500,
      fontSize: 16,
    );

    final title = Row(
      children: [
        Text('For only ${product.formattedPrice}', style: titleStyle),
        Text(
          ' - 50% OFF Limited Time Sale',
          style: titleStyle.copyWith(
            color: Get.theme.colorScheme.tertiary,
            fontSize: 13,
          ),
        ),
      ],
    );

    final subTitle = Row(
      children: [
        const Text('via Gumroad.com', style: subTitleStyle),
        Text(
          ' - ${'cancel_anytime'.tr}',
          style: subTitleStyle.copyWith(color: Get.theme.primaryColor),
        ),
      ],
    );

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              const SizedBox(height: 5),
              subTitle,
            ],
          ),
          Icon(Icons.check_circle, color: Get.theme.primaryColor),
        ],
      ),
    );

    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Get.theme.primaryColor, width: 2),
      ),
      child: content,
    );
  }
}
