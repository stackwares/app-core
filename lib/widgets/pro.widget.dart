import 'package:app_core/config.dart';
import 'package:flutter/material.dart';

import '../firebase/config/config.service.dart';

class ProText extends StatelessWidget {
  final String text;
  final double? size;

  const ProText({
    Key? key,
    this.size,
    required this.text,
  }) : super(key: key);

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
        PremiumCard(text: text, size: size),
      ],
    );
  }
}

class PremiumCard extends StatelessWidget {
  final String text;
  final double? size;

  const PremiumCard({
    Key? key,
    this.size,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
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
          text,
          style: TextStyle(
            fontSize: size ?? 14 * 0.8,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
