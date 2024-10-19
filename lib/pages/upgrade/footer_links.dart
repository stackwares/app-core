import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config/app.model.dart';
import '../../globals.dart';
import '../../utils/utils.dart';
import 'upgrade_screen.controller.dart';

class FooterLinks extends StatelessWidget {
  const FooterLinks({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpgradeScreenController>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: darkThemeData.primaryColor,
            textStyle: const TextStyle(fontSize: 10),
            minimumSize: Size.zero,
          ),
          onPressed: () => Utils.openUrl(appConfig.links.terms),
          child: Text('terms_of_use'.tr),
        ),
        const Text('.'),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: darkThemeData.primaryColor,
            textStyle: const TextStyle(fontSize: 10),
            minimumSize: Size.zero,
          ),
          onPressed: () => Utils.openUrl(appConfig.links.privacy),
          child: Text('privacy_policy'.tr),
        ),
        const Text('.'),
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: darkThemeData.primaryColor,
            textStyle: const TextStyle(fontSize: 10),
            minimumSize: Size.zero,
          ),
          onPressed: controller.restore,
          child: Text('restore_purchases'.tr),
        ),
      ],
    );
  }
}
