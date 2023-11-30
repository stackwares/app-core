import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/utils/ui_utils.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../config/app.model.dart';
import '../pages/feedback/feedback_screen.controller.dart';

class RateWidgetController extends GetxController with ConsoleMixin {
  // VARIABLES
  final formKey = GlobalKey<FormState>();
  final textController = TextEditingController();

  // PROPERTIES
  final rating = 0.0.obs;

  // GETTERS

  // FUNCTIONS

  void skip() async {
    Get.back();
    AnalyticsService.to.logEvent('skipped-rate');
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;

    if (rating.value >= 4.0) {
      if (textController.text.isNotEmpty) {
        Utils.copyToClipboard(textController.text);
      }

      UIUtils.requestReview();
    } else {
      Utils.contactEmail(
        subject: '${appConfig.name} Review',
        preBody: textController.text,
        rating: rating.value,
        previousRoute: Get.previousRoute,
        feedbackType: FeedbackType.feedback,
      );
    }
  }
}
