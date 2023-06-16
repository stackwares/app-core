import 'dart:async';
import 'dart:convert';

import 'package:app_core/config.dart';
import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/firebase/crashlytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/secrets.model.dart';
import '../pages/routes.dart';

class PurchasesService extends GetxService with ConsoleMixin {
  static PurchasesService get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final info = Rx<CustomerInfo>(CustomerInfo.fromJson(kPurchaserInfoInitial));
  final offerings = Rx<Offerings>(Offerings.fromJson(kOfferingsInitial));
  final packages = <Package>[].obs;

  // GETTERS
  String get planId {
    final entitlements = info.value.entitlements;
    if (entitlements.active.isEmpty) return 'free';
    return entitlements.active.entries.first.key;
  }

  bool get isPremium => planId != 'free';

  // INIT
  @override
  void onClose() {
    if (!isIAPSupported) return;
    Purchases.removeCustomerInfoUpdateListener((info_) => info.value = info_);
    super.onClose();
  }

  // FUNCTIONS
  Future<void> init() async {
    if (!isIAPSupported) return;
    // await Purchases.setLogLevel(LogLevel.debug);

    await Purchases.configure(
      PurchasesConfiguration(secretConfig.revenuecat.key),
    );

    Purchases.addCustomerInfoUpdateListener((info_) {
      info.value = info_;
    });

    setAttributes();
    sync();
  }

  Future<void> invalidate() async {
    console.wtf('invalidate');
    if (!isIAPSupported) return;
    await Purchases.invalidateCustomerInfoCache();
  }

  Future<void> login(User user) async {
    if (!isIAPSupported) return;
    await init();
    await Purchases.logIn(user.id);
    await Purchases.setEmail(user.email!);
  }

  Future<void> logout() async {
    console.wtf('logout');
    if (!isIAPSupported) return;

    // prevent exception if logging out with an anonymous user
    if (await Purchases.isAnonymous) {
      return console.error('anonymous user');
    }

    try {
      await Purchases.logOut();
    } on PlatformException catch (e) {
      console.error('exception error: $e');
    } catch (e) {
      console.error('logout error: $e');
    }
  }

  Future<void> load() async {
    if (!isIAPSupported) return;

    try {
      offerings.value = await Purchases.getOfferings();
      packages.value = offerings.value.current?.availablePackages ?? [];

      if (CoreConfig().offeringId.isNotEmpty) {
        packages.value = offerings.value
                .getOffering(CoreConfig().offeringId)
                ?.availablePackages ??
            [];
      }
    } on PlatformException catch (e, s) {
      console.error('load error: $e');
      return _showError(e, s);
    }

    console.info('packages: ${packages.length}');
  }

  Future<void> sync() async {
    if (!isIAPSupported) return;

    try {
      info.value = await Purchases.getCustomerInfo();
      // console.warning('sync: ${jsonEncode(info.value.toJson())}');
    } on PlatformException catch (e) {
      return console.error('sync error: $e');
    }
  }

  void setAttributes() {
    Purchases.setAttributes({
      'version': metadataApp.formattedVersion,
      'platform': Utils.platform,
      'device-id': metadataDevice.id,
    });

    AnalyticsService.to.setUserProperty(
      name: 'plan',
      value: planId,
    );

    AnalyticsService.to.setUserProperty(
      name: 'theme',
      value: Get.isDarkMode ? 'Dark' : 'Light',
    );

    AnalyticsService.to.setUserProperty(
      name: 'platform',
      value: Utils.platform,
    );

    AnalyticsService.to.setUserProperty(
      name: 'version',
      value: metadataApp.formattedVersion,
    );

    if (Get.locale?.languageCode != null) {
      AnalyticsService.to.setUserProperty(
        name: 'language',
        value: Get.locale!.languageCode,
      );
    }

    if (Get.locale?.countryCode != null) {
      AnalyticsService.to.setUserProperty(
        name: 'country',
        value: Get.locale!.countryCode,
      );
    }

    Future.delayed(10.seconds).then(
      (value) => AnalyticsService.to.setUserProperty(
        name: 'device_type',
        value: Utils.deviceType,
      ),
    );
  }

  Future<void> purchase(Package package) async {
    if (!isIAPSupported) return;
    timeLockEnabled = false; // temporarily disable
    CustomerInfo? info_;

    try {
      info_ = await Purchases.purchasePackage(package);
      console.warning('purchase: ${jsonEncode(info_.toJson())}');
    } on PlatformException catch (e, s) {
      console.error('purchase error: $e');
      timeLockEnabled = true;
      _showError(e, s);
      return;
    }

    info.value = info_;
    timeLockEnabled = true;
  }

  Future<void> restore() async {
    if (!isIAPSupported) return;
    CustomerInfo? info_;

    try {
      info_ = await Purchases.restorePurchases();
      console.warning('restore: ${jsonEncode(info_.toJson())}');
    } on PlatformException catch (e, s) {
      _showError(e, s);
      return;
    }

    info.value = info_;
  }

  Future<void> _showError(PlatformException e, StackTrace s) async {
    final errorCode = PurchasesErrorHelper.getErrorCode(e);
    console.error('errorCode: ${errorCode.name}');

    String errorMessage =
        'Code: ${errorCode.name}. Please report to the developer.';

    switch (errorCode) {
      case PurchasesErrorCode.purchaseCancelledError:
        errorMessage = '';
        break;
      case PurchasesErrorCode.purchaseNotAllowedError:
        errorMessage =
            'For some reason you or the device is not allowed to do purchases';
        break;
      case PurchasesErrorCode.purchaseInvalidError:
        errorMessage = 'Invalid purchase';
        break;
      case PurchasesErrorCode.productAlreadyPurchasedError:
        break;
      case PurchasesErrorCode.productNotAvailableForPurchaseError:
        errorMessage =
            'The package you selected is currently not available for purchase';
        break;
      case PurchasesErrorCode.configurationError:
        break;
      case PurchasesErrorCode.ineligibleError:
        errorMessage = 'Ineligible to purchase this package';
        break;
      case PurchasesErrorCode.insufficientPermissionsError:
        break;
      case PurchasesErrorCode.invalidAppUserIdError:
        break;
      case PurchasesErrorCode.invalidAppleSubscriptionKeyError:
        break;
      case PurchasesErrorCode.invalidCredentialsError:
        break;
      case PurchasesErrorCode.invalidReceiptError:
        break;
      case PurchasesErrorCode.invalidSubscriberAttributesError:
        break;
      case PurchasesErrorCode.missingReceiptFileError:
        errorMessage = '';
        break;
      case PurchasesErrorCode.networkError:
        errorMessage = 'A network error occurred. Please try again.';
        break;
      case PurchasesErrorCode.operationAlreadyInProgressError:
        errorMessage = 'The operation is already in progress';
        break;
      case PurchasesErrorCode.paymentPendingError:
        errorMessage = 'The payment is already pending';
        break;
      case PurchasesErrorCode.receiptAlreadyInUseError:
        break;
      case PurchasesErrorCode.receiptInUseByOtherSubscriberError:
        break;
      case PurchasesErrorCode.storeProblemError:
        // errorMessage =
        //     'There was a problem with ${GetPlatform.isIOS || GetPlatform.isMacOS ? 'the App Store' : 'Google Play'}';
        break;
      case PurchasesErrorCode.unexpectedBackendResponseError:
        break;
      case PurchasesErrorCode.unknownBackendError:
        break;
      case PurchasesErrorCode.unsupportedError:
        break;
      case PurchasesErrorCode.unknownError:
        errorMessage = '';
        // errorMessage = 'Unknown error. Please report to the developer.';
        break;
      default:
        errorMessage = '';
        // errorMessage = 'Weird error. Please report to the developer.';
        break;
    }

    if (errorMessage.isNotEmpty) {
      await UIUtils.showSimpleDialog(
        'Purchase Error',
        errorMessage,
        actionText: 'need_help'.tr,
        action: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
      );
    } else {
      CrashlyticsService.to.record(e, s);
    }
  }
}

const kPurchaserInfoInitial = {
  "entitlements": {"all": {}, "active": {}},
  "allPurchaseDates": {},
  "activeSubscriptions": [],
  "allPurchasedProductIdentifiers": [],
  "nonSubscriptionTransactions": [],
  "firstSeen": "",
  "originalAppUserId": "",
  "allExpirationDates": {},
  "requestDate": "",
  "latestExpirationDate": null,
  "originalPurchaseDate": null,
  "originalApplicationVersion": null,
  "managementURL": null
};

const kOfferingsInitial = {
  "all": {
    "default": {
      "identifier": "",
      "serverDescription": "",
      "metadata": {},
      "availablePackages": [],
      "lifetime": null,
      "annual": null,
      "sixMonth": null,
      "threeMonth": null,
      "twoMonth": null,
      "monthly": null,
      "weekly": null,
    }
  },
  "current": {
    "identifier": "",
    "serverDescription": "",
    "metadata": {},
    "availablePackages": [],
    "lifetime": null,
    "annual": null,
    "sixMonth": null,
    "threeMonth": null,
    "twoMonth": null,
    "monthly": null,
  }
};

const kPackageInitial = {
  "identifier": "",
  "packageType": "",
  "product": {
    "identifier": "",
    "description": "",
    "title": "",
    "price": 0.0,
    "priceString": "",
    "currencyCode": "",
    "introPrice": {
      "price": 0.0,
      "priceString": "",
      "period": "",
      "cycles": 0,
      "periodUnit": "",
      "periodNumberOfUnits": 0
    },
    "discounts": []
  },
  "offeringIdentifier": "annual",
};
