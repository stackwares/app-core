import 'package:app_core/config.dart';
import 'package:flutter/material.dart';

import '../firebase/config/config.service.dart';

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
          style: TextStyle(fontSize: size!, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        Card(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: CoreConfig().gradientColors,
                begin: Alignment.bottomLeft,
                end: Alignment.topRight,
              ),
            ),
            child: Text(
              'PRO',
              style: TextStyle(
                fontSize: size! * 0.8,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
