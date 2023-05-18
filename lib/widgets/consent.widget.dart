import 'package:app_core/config/app.model.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/utils/utils.dart';

import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/persistence/persistence_builder.widget.dart';
import 'package:app_core/widgets/gradient.widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ConsentWidget extends StatelessWidget {
  const ConsentWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    void submit() {
      Persistence.to.consented.val = true;
      Get.back();
    }

    return PersistenceBuilder(
      builder: (p, context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GradientWidget(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 0, 212),
                    Color.fromARGB(255, 0, 166, 255),
                  ],
                ),
                child: Text(
                  'consent'.tr,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.raleway(
                    fontSize: isSmallScreen ? 20 : 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: submit,
                icon: const Icon(LucideIcons.arrowRight),
                label: Text('continue'.tr),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'anonymous_report_desc'.tr,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 15),
          SwitchListTile(
            title: Text('errors_crashes'.tr),
            secondary: const Icon(LucideIcons.serverCrash),
            value: p.crashReporting.val,
            subtitle: isSmallScreen ? null : Text("send_reports".tr),
            onChanged: (value) => p.crashReporting.val = value,
          ),
          const SizedBox(height: 15),
          SwitchListTile(
            title: Text('usage_stats'.tr),
            secondary: const Icon(LucideIcons.barChart),
            value: p.analytics.val,
            subtitle: isSmallScreen ? null : Text('send_stats'.tr),
            onChanged: (value) => p.analytics.val = value,
          ),
          const Divider(),
          TextButton(
            onPressed: () => Utils.openUrl(appConfig.links.privacy),
            child: Text(
              'privacy_policy'.tr,
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
