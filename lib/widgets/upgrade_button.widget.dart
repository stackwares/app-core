import 'package:app_core/config/app.model.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/utils/utils.dart';
import 'package:app_core/widgets/logo.widget.dart';
import 'package:app_core/widgets/pro.widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../config.dart';
import '../purchases/purchases.services.dart';

class UpgradeButton extends StatelessWidget {
  const UpgradeButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (PurchasesService.to.isPremium || !CoreConfig().purchasesEnabled) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      // TODO: localize
      message: 'Redeem your free ${appConfig.name} Premium',
      child: InkWell(
        onTap: () => Utils.adaptiveRouteOpen(name: Routes.upgrade),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const LogoWidget(size: 20),
                const SizedBox(width: 10),
                Text(
                  '${'try'.tr} ',
                  style: TextStyle(
                    color: Get.theme.primaryColor,
                    // fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                ProText(
                  // size: 16,
                  premiumSize: 12,
                  text: 'premium'.tr.toUpperCase(),
                ),
              ],
            ),
          ],
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(duration: 2000.ms)
            .shakeX(duration: 1000.ms, hz: 2, amount: 1)
            .then(delay: 3000.ms),
      ),
    );
  }
}
