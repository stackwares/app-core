import 'package:app_core/config.dart';
import 'package:app_core/services/main.service.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

class LogoWidget extends StatelessWidget {
  final double size;
  const LogoWidget({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Image.asset(
        MainService.to.isDark
            ? CoreConfig().logoDarkPath
            : CoreConfig().logoLightPath,
        height: size,
      ),
    );
  }
}
