import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:icons_plus/icons_plus.dart';

import '../globals.dart';

class AppBarLeadingButton extends StatelessWidget {
  final Function()? action;

  const AppBarLeadingButton({Key? key, this.action}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: action ?? Get.back,
      icon: Icon(
        isSmallScreen ? LineAwesome.arrow_left_solid : Icons.close,
      ),
    );
  }
}
