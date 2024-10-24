import 'package:app_core/pages/upgrade/extensions.dart';
import 'package:app_core/pages/upgrade/upgrade_screen.controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../globals.dart';
import '../../purchases/purchases.services.dart';
import '../../supabase/model/gumroad_product.model.dart';

class IAPProductTile extends StatelessWidget {
  final Package package;
  const IAPProductTile({super.key, required this.package});

  bool get isSelected =>
      UpgradeScreenController.to.packageId == package.identifier;

  bool get isFirst => UpgradeScreenController.to.data.first == package;

  @override
  Widget build(BuildContext context) {
    final product = package.storeProduct;
    final currencySymbol = product.priceString.substring(0, 1);
    final prefixId = product.identifier.split('.sub.')[0];
    // ignore: unused_local_variable
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
        children: [
          Row(
            children: [
              // PRICE & PERIOD
              Text(
                product.itemTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              // DISCOUNTED PRICE & PERIOD
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  product.itemSubTitle,
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: darkThemeData.colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
          if (product.primaryFeature.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  product.itemOrigPrice,
                  style: TextStyle(
                    color: darkThemeData.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.lineThrough,
                    decorationThickness: 0.4,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.pink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '50% OFF', // TODO: localize
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                // TRIAL DURATION
                Visibility(
                  visible: product.hasFreeTrial,
                  child: Expanded(
                    child: Text(
                      product.trialDurationText,
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ],
      ),
    );

    return InkWell(
      onTap: () => UpgradeScreenController.to.package.value = package,
      child: Badge(
        isLabelVisible: isFirst,
        alignment: Alignment.topRight,
        offset: Offset(-100, -7),
        label: Text('✅ ${'best_deal'.tr}'),
        backgroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 10),
        textStyle: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        child: Obx(
          () => Card(
            color:
                isSelected ? darkThemeData.primaryColor.withOpacity(0.5) : null,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: isSelected
                  ? BorderSide(color: darkThemeData.primaryColor, width: 2)
                  : const BorderSide(color: Colors.grey, width: 0.1),
            ),
            child: content,
          ),
        ),
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
            color: darkThemeData.colorScheme.tertiary,
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
          style: subTitleStyle.copyWith(color: darkThemeData.primaryColor),
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
          Icon(Icons.check_circle, color: darkThemeData.primaryColor),
        ],
      ),
    );

    return Card(
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: darkThemeData.primaryColor, width: 2),
      ),
      child: content,
    );
  }
}
