import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../config.dart';
import 'upgrade_screen.controller.dart';

class ExitButton extends StatelessWidget {
  const ExitButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UpgradeScreenController>();

    return Obx(
      () => IconButton(
        icon: controller.timerSeconds.value == 0
            ? const Icon(Icons.close)
            : Stack(
                alignment: Alignment.center,
                children: [
                  const SizedBox(
                    width: 30,
                    height: 30,
                    child: CircularProgressIndicator(),
                  ),
                  Text(
                    controller.timerSeconds.value.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
        onPressed: controller.timerSeconds.value == 0
            ? () {
                Get.back();
                CoreConfig().onCancelledUpgradeScreen?.call();
              }
            : null,
      ),
    );
  }
}
