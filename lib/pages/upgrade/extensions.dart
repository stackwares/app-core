import 'package:app_core/config.dart';
import 'package:app_core/pages/upgrade/currency_data.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/object_wrappers.dart';

import '../../globals.dart';
import 'pricing.model.dart';

extension StoreProductExtension on StoreProduct {
  bool get hasFreeTrial => introductoryPrice?.price == 0;
  bool get isSubscription => identifier.contains('.sub.');
  bool get isNonConsumable => identifier.contains('.iap.');
  bool get isLifetime => isNonConsumable;
  bool get isAnnually => identifier.contains('annual');
  bool get isMonthly => identifier.contains('month');
  bool get isWeekly => identifier.contains('week');

  bool get isStarter => identifier.contains('.starter.');
  bool get isPlus => identifier.contains('.plus.');
  bool get isPro => identifier.contains('.pro.');
  bool get isMax => identifier.contains('.max.');

  String get planId => pricing.id;

  String get primaryFeature => pricing.primaryFeature;

  Pricing get pricing {
    final id =
        identifier.contains(':') ? identifier.split(':').first : identifier;
    return CoreConfig().upgradeConfig.pricing[id]!;
  }

  String get periodUnitName {
    if (isAnnually) {
      return 'year';
    } else if (isMonthly) {
      return 'month';
    } else if (isWeekly) {
      return 'week';
    } else if (isLifetime) {
      return 'lifetime';
    }

    return '';
  }

  String get itemTitle {
    return '$priceString / ${periodUnitName.tr.capitalize!}';
  }

  String get itemTitleNext {
    if (isAnnually && identifier.contains('.pro.')) {
      return ' - ${'best_deal'.tr}';
    } else if (isMonthly) {
      return '';
    } else if (isWeekly) {
      return '';
    }

    return '';
  }

  String get itemOrigPrice {
    return '$currencyCode ${price * 2}';
  }

  String get currencySymbol {
    return kCurrencyData[currencyCode]?['symbol'] ?? '';
  }

  String get itemSubTitle {
    if (isAnnually) {
      final monthlyPrice = price / 12;
      return '$currencySymbol${currencyFormatter.format(monthlyPrice)} / ${'month'.tr.capitalize!}';
    } else if (isMonthly) {
      final monthlyPrice = price / 4;
      return '$currencySymbol${currencyFormatter.format(monthlyPrice)} / ${'week'.tr.capitalize!}';
    } else if (isWeekly) {
      final monthlyPrice = price / 7;
      return '$currencySymbol${currencyFormatter.format(monthlyPrice)} / ${'day'.tr.capitalize!}';
    } else if (isLifetime) {
      return 'lifetime'.tr;
    }

    return description;
  }

  String get itemSubTitleNext {
    if (isAnnually) {
      return '';
    } else if (isMonthly) {
      return '';
    } else if (isWeekly) {
      return '';
    }

    return '';
  }

  String get buttonTitle {
    return hasFreeTrial ? 'redeem_trial'.tr : 'upgrade_to_pro'.tr;
  }

  String get buttonSubTitle {
    return '${!isSubscription ? '${'now_only'.tr} $itemTitle' : '${'now_only'.tr} $itemTitle'}${!isApple ? ' - ${'cancel_anytime'.tr}' : ''}';
  }

  String get trialDurationText {
    if (introductoryPrice == null) return '';
    return '${introductoryPrice!.periodNumberOfUnits}-${introductoryPrice!.periodUnit.name.tr.capitalizeFirst} ${'free_trial'.tr}';
  }

  String get discount {
    final origPrice = '$currencySymbol${currencyFormatter.format(price * 2)}';
    final discountedPrice = '$currencySymbol${currencyFormatter.format(price)}';
    return '${'from'.tr} $origPrice ${'to_only'.tr} $discountedPrice';
  }
}
