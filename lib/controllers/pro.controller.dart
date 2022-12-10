import 'dart:async';
import 'dart:convert';

import 'package:app_core/config.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/rate/rate.widget.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../pages/routes.dart';

class ProController extends GetxController with ConsoleMixin {
  static ProController get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final info = Rx<CustomerInfo>(CustomerInfo.fromJson(kPurchaserInfoInitial));
  final offerings = Rx<Offerings>(Offerings.fromJson(kOfferingsInitial));
  final packages = <Package>[].obs;
  final verifiedPro = Persistence.to.verifiedProCache.val.obs;
  final licenseKey = ''.obs;

  // GETTERS

  bool get isPro => proEntitlement?.isActive == true || verifiedPro.value;

  EntitlementInfo? get proEntitlement => info.value.entitlements.all['pro'];

  String get proPrefixString =>
      proEntitlement?.willRenew == true ? 'renews'.tr : 'expires'.tr;

  String get proDateString => DateFormat.yMMMMd()
      .add_jm()
      .format(DateTime.parse(proEntitlement!.expirationDate!).toLocal());

  String get shortLicenseKey => licenseKey.isEmpty ||
          licenseKey.value.length < 35
      ? 'none'.tr
      : '${licenseKey.substring(0, 7)}...${licenseKey.substring(licenseKey.value.length - 7)} ${verifiedPro.value ? '' : '- Inactive'}';

  // INIT

  @override
  void onClose() {
    if (!isIAPSupported) return;
    Purchases.removeCustomerInfoUpdateListener((info_) => info.value = info_);
    super.onClose();
  }

  @override
  void onInit() {
    verifiedPro.listen((value) => Persistence.to.verifiedProCache.val = value);
    super.onInit();
  }

  @override
  void onReady() {
    verifiedPro.value = Persistence.to.verifiedProCache.val;
    super.onReady();
  }

  // FUNCTIONS
  Future<void> init() async {
    if (!isIAPSupported) return;
    await Purchases.setDebugLogsEnabled(false);

    await Purchases.configure(
      PurchasesConfiguration(ConfigService.to.secrets.revenuecat.apiKey),
    );

    Purchases.addCustomerInfoUpdateListener((info_) {
      info.value = info_;
    });

    sync();
  }

  Future<void> invalidate() async {
    if (!isIAPSupported) return;
    await Purchases.invalidateCustomerInfoCache();
  }

  void login(User user) {
    if (!isIAPSupported) return;
    Purchases.logIn(user.id);
    Purchases.setEmail(user.email!);

    Purchases.setAttributes({
      'version': metadataApp.formattedVersion,
      'platform': Utils.platformName(),
      'device-id': metadataDevice.id,
    });
  }

  Future<void> logout() async {
    verifiedPro.value = false;
    licenseKey.value = '';
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
    } on PlatformException catch (e) {
      console.error('load error: $e');
      return _showError(e);
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

    // show upgrade screen every after 5th times opened
    if (!isPro && (Persistence.to.sessionCount.val % 2) == 0) {
      await Future.delayed(1.seconds);

      if (isIAPSupported) {
        await Utils.adaptiveRouteOpen(name: Routes.upgrade);
      }
    } else {
      if (!Persistence.to.rateDialogShown.val &&
          Persistence.to.sessionCount.val > 16 &&
          isRateReviewSupported) {
        Persistence.to.rateDialogShown.val = true;

        const dialog = AlertDialog(
          content: SizedBox(
            width: 400,
            child: RateWidget(),
          ),
        );

        Get.dialog(dialog);
      }
    }
  }

  Future<void> purchase(Package package) async {
    if (!isIAPSupported) return;
    timeLockEnabled = false; // temporarily disable
    CustomerInfo? info_;

    try {
      info_ = await Purchases.purchasePackage(package);
      console.warning('purchase: ${jsonEncode(info_.toJson())}');
    } on PlatformException catch (e) {
      console.error('purchase error: $e');
      timeLockEnabled = true;
      _showError(e);
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
    } on PlatformException catch (e) {
      _showError(e);
      return;
    }

    info.value = info_;
  }

  Future<void> _showError(PlatformException e) async {
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
        errorMessage =
            'There was a problem with ${GetPlatform.isIOS || GetPlatform.isMacOS ? 'the App Store' : 'Google Play'}';
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
      await UIUtils.showSimpleDialog('Purchase Error', errorMessage);
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
