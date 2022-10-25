import 'package:app_core/config.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../firebase/config/config.service.dart';
import 'gradient.widget.dart';

class ProText extends StatelessWidget {
  final double? size;
  const ProText({Key? key, this.size}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          ConfigService.to.appName,
          style: TextStyle(fontSize: size, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        GradientWidget(
          gradient: LinearGradient(colors: CoreConfig().gradientColors),
          child: Text(
            'Pro',
            style: TextStyle(
              fontSize: size,
              fontWeight: FontWeight.bold,
              color: Get.theme.primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}
