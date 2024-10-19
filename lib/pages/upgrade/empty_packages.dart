import 'package:flutter/material.dart';

class EmptyPackages extends StatelessWidget {
  const EmptyPackages({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
