import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../globals.dart';
import 'upgrade_screen.controller.dart';

class CTAUpgradeButton extends StatelessWidget {
  const CTAUpgradeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpgradeScreenController>();

    return Obx(
      () => ElevatedButton(
        onPressed: controller.busy.value ? null : controller.purchase,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkThemeData.primaryColor,
          foregroundColor: darkThemeData.colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: 15),
        ),
        child: Text(
          controller.buttonText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            fontFamily: '',
          ),
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2000.ms)
        .then(delay: 2000.ms);
  }
}
