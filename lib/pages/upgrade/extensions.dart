import 'package:app_core/pages/upgrade/currency_data.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/object_wrappers.dart';

import '../../globals.dart';

extension StoreProductExtension on StoreProduct {
  bool get isFreeTrial => introductoryPrice?.price == 0;
  bool get isSubscription => identifier.contains('.sub.');
  bool get isNonConsumable => identifier.contains('.iap.');
  bool get isLifetime => isNonConsumable;
  bool get isAnnually => identifier.contains('annual');
  bool get isMonthly => identifier.contains('month');
  bool get isWeekly => identifier.contains('week');

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
    return '$priceString / ${periodUnitName.tr}';
  }

  String get itemTitleNext {
    if (isAnnually) {
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
    if (periodUnitName == 'year') {
      final monthlyPrice = price / 12;
      return '$currencySymbol${currencyFormatter.format(monthlyPrice)} / ${'month'.tr}';
    } else if (periodUnitName == 'month') {
      final monthlyPrice = price / 4;
      return '$currencySymbol${currencyFormatter.format(monthlyPrice)} / ${'week'.tr}';
    } else if (periodUnitName == 'week') {
      final monthlyPrice = price / 7;
      return '$currencySymbol${currencyFormatter.format(monthlyPrice)} / ${'day'.tr}';
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
    return isFreeTrial ? 'redeem_trial'.tr : 'upgrade_to_pro'.tr;
  }

  String get buttonSubTitle {
    return '${!isSubscription ? '${'now_only'.tr} $itemTitle' : '${'now_only'.tr} $itemTitle'} - ${'cancel_anytime'.tr}';
  }

  String get trialDurationText {
    return '${introductoryPrice!.periodNumberOfUnits} ${GetUtils.capitalizeFirst(introductoryPrice!.periodUnit.name.tr)}';
  }

  String get discount {
    final origPrice = '$currencySymbol${currencyFormatter.format(price * 2)}';
    final discountedPrice = '$currencySymbol${currencyFormatter.format(price)}';
    return '${'from'.tr} $origPrice ${'to_only'.tr} $discountedPrice';
  }

  List<String> get features {
    final features_ = ['money_back_guarantee'.tr];

    if (isFreeTrial) {
      features_.add('$trialDurationText ${'free_trial'.tr}');
    }

    if (isSubscription) {
      features_.add('cancel_anytime'.tr);
    }

    return features_;
  }
}
