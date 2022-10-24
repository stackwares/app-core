import 'package:app_core/connectivity/connectivity.service.dart';
import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ConnectivityBar extends StatelessWidget {
  const ConnectivityBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = InkWell(
      onTap: GetPlatform.isMobile ? AppSettings.openWIFISettings : null,
      child: Container(
        height: 20,
        color: Colors.red.withOpacity(0.3),
        child: Center(
          child: Text(
            'no_internet'.tr,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ),
    );

    return Obx(
      () => !ConnectivityService.to.connected()
          ? content
          : const SizedBox.shrink(),
    );
  }
}
