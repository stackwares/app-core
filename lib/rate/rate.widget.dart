import 'package:app_core/globals.dart';
import 'package:app_core/widgets/gradient.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icons_plus/icons_plus.dart';

import '../config.dart';
import '../config/app.model.dart';
import 'rate_widget.controller.dart';

class RateWidget extends StatelessWidget {
  const RateWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RateWidgetController());

    return SingleChildScrollView(
      child: Form(
        key: controller.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GradientWidget(
                  gradient: LinearGradient(colors: CoreConfig().gradientColors),
                  child: Text(
                    'rate_review'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.raleway(
                      fontSize: isSmallScreen ? 20 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            TextFormField(
              autofocus: true,
              controller: controller.textController,
              // validator: (data) =>
              //     data!.split(' ').length < 5 ? 'review_short'.tr : null,
              maxLength: 2000,
              minLines: 3,
              maxLines: 10,
              decoration: InputDecoration(
                labelText: '${'write_review_here'.tr}...',
                alignLabelWithHint: true,
                helperMaxLines: 5,
                helperText: "why_love_hate".trParams({'w1': appConfig.name}),
              ),
            ),
            const SizedBox(height: 20),
            RatingBar.builder(
              initialRating: controller.rating.value,
              minRating: 0,
              direction: Axis.horizontal,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              onRatingUpdate: (rating) => controller.rating.value = rating,
              itemSize: 35,
              itemBuilder: (context, _) =>
                  Icon(Icons.star, color: Get.theme.primaryColor),
            ),
            Obx(
              () => Visibility(
                visible: controller.rating.value == 0.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    'please_give_rating'.tr,
                    style: TextStyle(
                      color: Colors.pink.shade200,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
            ),
            Obx(
              () => Visibility(
                visible: controller.rating.value > 0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    if (controller.rating.value >= 4.0) ...[
                      ElevatedButton.icon(
                        onPressed: controller.submit,
                        icon: const Icon(Iconsax.send_1_outline),
                        label: Text('rate_review'.tr),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'spread_word'.trParams({'w1': appConfig.name}),
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ] else ...[
                      ElevatedButton.icon(
                        onPressed: controller.submit,
                        icon: const Icon(Iconsax.message_question_outline),
                        label: Text('send_feedback'.tr),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "write_concern_helper".tr,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
