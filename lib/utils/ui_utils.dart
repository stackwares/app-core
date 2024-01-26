import 'package:app_core/config.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';

import '../config/app.model.dart';
import '../firebase/analytics.service.dart';
import '../globals.dart';
import '../services/notifications.service.dart';
import '../persistence/persistence.dart';
import '../rate/rate.widget.dart';
import '../supabase/supabase_database.service.dart';
import '../supabase/supabase_functions.service.dart';
import '../widgets/consent.widget.dart';

class UIUtils {
  static final console = Console(name: 'UIUtils');
  static bool hasRequestedReview = false;

  static Future<void> showConsent() async {
    if (isApple && !Persistence.to.consented.val) {
      const dialog = AlertDialog(
        content: SizedBox(
          width: 400,
          child: ConsentWidget(),
        ),
      );

      await Get.dialog(dialog, barrierDismissible: false);
      Persistence.to.consented.val = true;
    }
  }

  static Future<void> showSnackBar({
    required String title,
    required String message,
    final Widget? icon,
    final int seconds = 7,
  }) async {
    Get.snackbar(
      title,
      message,
      icon: icon ?? const Icon(Icons.info, size: 25),
      titleText: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      maxWidth: 500,
      messageText: Text(message, style: const TextStyle(fontSize: 14)),
      duration: Duration(seconds: seconds),
      borderRadius: 8,
      shouldIconPulse: true,
      margin: const EdgeInsets.all(8),
      snackPosition: isSmallScreen ? SnackPosition.BOTTOM : SnackPosition.TOP,
    );
  }

  static Future<void> showSimpleDialog(
    String title,
    String body, {
    String? closeText,
    Function()? action,
    String? actionText,
  }) async {
    if (body.isEmpty) return;
    final content = SingleChildScrollView(child: Text(body));

    await Get.dialog(
      AlertDialog(
        title: Text(title),
        content: isSmallScreen
            ? content
            : Container(
                constraints: const BoxConstraints(maxHeight: 600),
                width: 400,
                child: content,
              ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text(closeText ?? 'okay'.tr),
          ),
          if (action != null) ...[
            TextButton(
              onPressed: action,
              child: Text(actionText ?? 'okay'.tr),
            ),
          ]
        ],
      ),
    );
  }

  static Future<void> showImageDialog(
    Widget image, {
    required String title,
    String? subTitle,
    required String body,
    Function()? onClose,
    String? closeText,
    Function()? action,
    String? actionText,
    ButtonStyle? actionStyle,
  }) async {
    final bodyContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(child: image),
        const SizedBox(height: 30),
        Text(
          title,
          style: const TextStyle(fontSize: 25),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        if (subTitle != null) ...[
          Text(
            subTitle,
            style: const TextStyle(fontSize: 15, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
        ],
        Text(body, textAlign: TextAlign.center),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: onClose ?? Get.back,
                child: Text(closeText ?? 'okay'.tr),
              ),
            ),
            if (action != null) ...[
              const SizedBox(width: 20),
              Expanded(
                child: ElevatedButton(
                  onPressed: action,
                  style: actionStyle,
                  child: Text(actionText ?? 'okay'.tr),
                ),
              ),
            ]
          ],
        ),
      ],
    );

    await Get.dialog(
      AlertDialog(
        title: const Text(''),
        actionsAlignment: MainAxisAlignment.center,
        content: isSmallScreen
            ? bodyContent
            : SizedBox(width: 400, child: bodyContent),
      ),
    );
  }

  static void requestReview() async {
    // if review is not supported or has already requested for this session
    if (!isRateReviewSupported || hasRequestedReview) return;
    // stop asking for a review after 5 requests
    if (Persistence.to.reviewCount.val >= 5) return;

    void showCustomReviewDialog() {
      Get.dialog(AlertDialog(
        content: SizedBox(width: 400, child: RateWidget()),
      ));
    }

    final inAppReview = InAppReview.instance;
    final available = await inAppReview.isAvailable();
    // console.info('rate review availability: $available');

    if (available) {
      await inAppReview.requestReview();
    } else {
      showCustomReviewDialog();
    }

    Persistence.to.reviewCount.val++;
    hasRequestedReview = true;
    AnalyticsService.to.logEvent('rate_review');
  }

  static Future<void> setLicenseKey() async {
    final formKey = GlobalKey<FormState>();
    final keyController = TextEditingController();
    final busy = false.obs;

    void submit() async {
      if (!formKey.currentState!.validate()) return;
      busy.value = true;
      final key = keyController.text.trim();
      final verifyResult = await FunctionsService.to.verifyGumroad(
        key,
        updateEntitlement: false,
      );

      verifyResult.fold(
        (left) {
          return UIUtils.showSimpleDialog(
            'Failed Verifying',
            left,
          );
        },
        (right) async {
          if (!right.entitled) {
            return UIUtils.showSimpleDialog(
              'Deactivated License',
              'We are sorry to inform you that your license key is not active anymore.',
            );
          }

          final updateResult = await DatabaseService.to.updateLicenseKey(key);

          updateResult.fold(
            (left) => UIUtils.showSimpleDialog(
              'Failed Updating',
              left,
            ),
            (right) {
              Get.back();

              // PurchasesService.to.licenseKey.value = right.gumroadLicenseKey;
              // PurchasesService.to.verifiedPro.value = true;

              NotificationsService.to.notify(
                title: 'License Key Updated',
                body: 'Thanks for subscribing to ${appConfig.name} Pro 🎉',
              );

              CoreConfig().onSuccessfulUpgrade?.call();
            },
          );

          AnalyticsService.to.logEvent('set_license_key');
        },
      );

      busy.value = false;
    }

    final content = Obx(
      () => TextFormField(
        enabled: !busy.value,
        controller: keyController,
        autofocus: true,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        validator: (data) =>
            data!.length != 35 ? 'Please a valid license key' : null,
        decoration: InputDecoration(
          labelText: 'license_key'.tr,
          hintText: 'Gumroad ${'license_key'.tr}',
        ),
      ),
    );

    Get.dialog(
      AlertDialog(
        title: Text('set_license_key'.tr),
        content: Form(
          key: formKey,
          child: isSmallScreen ? content : SizedBox(width: 450, child: content),
        ),
        actions: [
          TextButton(
            onPressed: Get.back,
            child: Text('cancel'.tr),
          ),
          Obx(
            () => Visibility(
              visible: !busy.value,
              replacement: const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(),
              ),
              child: TextButton(
                onPressed: submit,
                child: Text('update'.tr),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
