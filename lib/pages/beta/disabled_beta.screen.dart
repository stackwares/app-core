import 'package:app_core/config.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:line_icons/line_icons.dart';

import '../../config/app.model.dart';
import '../../utils/utils.dart';
import '../../widgets/version.widget.dart';

class DisabledBetaScreen extends StatelessWidget {
  const DisabledBetaScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final content = Container(
      constraints: CoreConfig().mainConstraints,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // RemoteImage(
          //   url: 'https://i.imgur.com/XygjDNZ.png',
          //   height: 150,
          //   placeholder: ,
          // ),
          const Icon(LineIcons.rocket, size: 100),
          const SizedBox(height: 20),
          const Text(
            'Expired Beta',
            style: TextStyle(fontSize: 25),
          ),
          const SizedBox(height: 10),
          const Text(
            'This beta version has expired. Please request another update from @oliverbytes or maybe the app is already in production? Check it out.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const Divider(),
          const SizedBox(height: 20),
          SizedBox(
            width: 200,
            child: ElevatedButton.icon(
              label: const Text('Check'),
              icon: const Icon(Iconsax.document_download),
              onPressed: () => Utils.openUrl(
                appConfig.links.website,
              ),
            ),
          ),
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
