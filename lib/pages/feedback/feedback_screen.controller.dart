import 'package:app_core/globals.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../config/app.model.dart';
import '../../utils/ui_utils.dart';
import '../../utils/utils.dart';

enum FeedbackType {
  feedback,
  suggestion,
  issue,
}

class FeedbackScreenController extends GetxController
    with StateMixin, ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  var feedbackType = FeedbackType.feedback;
  final rating = 0.0.obs;

  // PROPERTIES

  // GETTERS

  bool get showRateButton => rating.value >= 4.0 && isRateReviewSupported;

  // INIT

  // FUNCTIONS

  void review() {
    Utils.copyToClipboard(textController.text);
    UIUtils.rateAndReview();
  }

  void send() async {
    if (!formKey.currentState!.validate()) return;

    if (rating.value == 0.0) {
      return UIUtils.showSimpleDialog(
        'give_rating'.tr,
        'please_give_rating'.tr,
      );
    }

    Utils.contactEmail(
      subject:
          '${appConfig.name} ${feedbackType.toString().replaceAll('FeedbackType.', '').capitalizeFirst}',
      preBody: textController.text,
      rating: rating.value,
      previousRoute: Get.previousRoute,
      feedbackType: feedbackType,
    );

    Purchases.setAttributes({'star-rating': rating.value.toString()});
  }
}
