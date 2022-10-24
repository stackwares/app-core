import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../firebase/config/config.service.dart';
import '../../globals.dart';
import '../../widgets/appbar_leading.widget.dart';
import 'feedback_screen.controller.dart';

class FeedbackScreen extends StatelessWidget with ConsoleMixin {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FeedbackScreenController());

    final content = Form(
      key: controller.formKey,
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<FeedbackType>(
                value: controller.feedbackType,
                onChanged: (value) => controller.feedbackType = value!,
                decoration: InputDecoration(labelText: 'type'.tr),
                items: [
                  DropdownMenuItem(
                    value: FeedbackType.feedback,
                    child: Text('feedback'.tr),
                  ),
                  DropdownMenuItem(
                    value: FeedbackType.suggestion,
                    child: Text('suggestion'.tr),
                  ),
                  DropdownMenuItem(
                    value: FeedbackType.issue,
                    child: Text('issue'.tr),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextFormField(
                autofocus: true,
                controller: controller.textController,
                validator: (data) =>
                    data!.split(' ').length < 5 ? 'feedback_short'.tr : null,
                maxLength: 2000,
                minLines: 3,
                maxLines: 10,
                decoration: InputDecoration(
                  labelText: '${'write_concern'.tr}...',
                  alignLabelWithHint: true,
                  helperMaxLines: 5,
                  helperText: "write_concern_helper".tr,
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
                itemBuilder: (context, _) => Icon(
                  Icons.star,
                  color: Get.theme.primaryColor,
                ),
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
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
              ),
              Obx(
                () => Visibility(
                  visible: controller.showRateButton,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: controller.review,
                        icon: const Icon(Icons.star_border),
                        label: Text(
                          '${'rate_review'.tr} ${ConfigService.to.appName} on ${isApple ? 'the App Store' : 'Google Play'}',
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'spread_word'.trParams(
                          {'w1': ConfigService.to.appName},
                        ),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          )),
    );

    final appBar = AppBar(
      title: Text('${'contact'.tr} ${ConfigService.to.appName}'),
      leading: const AppBarLeadingButton(),
      actions: [
        TextButton.icon(
          label: Text('send'.tr),
          icon: const Icon(Iconsax.send_2),
          onPressed: controller.send,
        ),
        const SizedBox(width: 10),
      ],
    );

    return Scaffold(
      appBar: appBar,
      body: content,
    );
  }
}
