import 'package:app_core/config.dart';
import 'package:app_core/config/app.model.dart';
import 'package:flutter/material.dart';

class ProText extends StatelessWidget {
  final String text;
  final double? size;
  final double? premiumSize;

  const ProText({
    Key? key,
    this.size,
    this.premiumSize,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          appConfig.name,
          style: TextStyle(fontSize: size, fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 4),
        ProCard(text: text, size: premiumSize ?? size),
      ],
    );
  }
}

class ProCard extends StatelessWidget {
  final String text;
  final double? size;

  const ProCard({
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
          overflow: TextOverflow.fade,
          style: TextStyle(
            fontSize: size ?? 14 * 0.8,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            fontFamily: '',
          ),
        ),
      ),
    );
  }
}
