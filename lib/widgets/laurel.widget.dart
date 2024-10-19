import 'package:flutter/material.dart';

class LaurelImage extends StatelessWidget {
  const LaurelImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/laurel.png',
      height: 60,
    );
  }
}
