import 'package:app_core/globals.dart';
import 'package:flutter/material.dart';

class VersionText extends StatelessWidget {
  const VersionText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      heightFactor: 1,
      alignment: Alignment.bottomRight,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 5, right: 5),
        child: Text(
          metadataApp.formattedVersion,
          style: const TextStyle(color: Colors.grey, fontSize: 10),
        ),
      ),
    );
  }
}
