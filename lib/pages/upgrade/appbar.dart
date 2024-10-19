import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/utils.dart';
import '../routes.dart';
import 'exit_button.dart';

class UpgradeAppBar extends StatelessWidget {
  const UpgradeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 10, right: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextButton(
            onPressed: () => Utils.adaptiveRouteOpen(name: Routes.feedback),
            child: Text('help_question'.tr),
          ),
          const ExitButton()
        ],
      ),
    );
  }
}
