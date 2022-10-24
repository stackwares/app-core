import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';

class VersionText extends StatelessWidget {
  const VersionText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      metadataApp.formattedVersion,
      style: const TextStyle(color: Colors.grey, fontSize: 10),
    );
  }
}
