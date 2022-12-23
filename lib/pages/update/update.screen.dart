import 'package:app_core/config.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../firebase/analytics.service.dart';

import '../../config/app.model.dart';
import '../../globals.dart';
import '../../utils/utils.dart';
import '../../widgets/logo.widget.dart';
import '../../widgets/version.widget.dart';

class UpdateScreen extends StatelessWidget {
  const UpdateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: CoreConfig().mainConstraints,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const LogoWidget(size: 150),
          const SizedBox(height: 40),
          const Text(
            'Update Required',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            "Please update to the latest version to enjoy the latest features, bug fixes, and security patches.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              label: const Text('Download'),
              icon: const Icon(Iconsax.arrow_down_2),
              onPressed: () {
                AnalyticsService.to.logEvent('download_required_update');
                Utils.openUrl(appConfig.links.website);
              },
            ),
          ),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 20),
          Text(
            'Current build # ${metadataApp.buildNumber}',
            style: const TextStyle(color: Colors.grey),
          ),
          // TODO: supabase config app build minimum
          // Text(
          //   'Minimum build # ${appConfig.app.build.min}',
          //   style: const TextStyle(color: Colors.grey),
          // ),
        ],
      ),
    );

    return WillPopScope(
      onWillPop: () => Future.value(false),
      child: Scaffold(
        bottomNavigationBar: const VersionText(),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Center(child: content),
        ),
      ),
    );
  }
}
