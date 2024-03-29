import 'package:app_core/purchases/purchases.services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../config.dart';
import '../config/app.model.dart';
import '../pages/routes.dart';
import '../utils/utils.dart';
import 'pro.widget.dart';

class PremiumCard extends StatelessWidget {
  final EdgeInsets padding;
  final double maxWidth;

  const PremiumCard({
    super.key,
    this.padding = EdgeInsets.zero,
    this.maxWidth = 400,
  });

  @override
  Widget build(BuildContext context) {
    if (PurchasesService.to.isPremium || !CoreConfig().purchasesEnabled) {
      return const SizedBox.shrink();
    }

    final content = Padding(
      padding: const EdgeInsets.all(15),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ProText(
                  size: 17,
                  premiumSize: 13,
                  text: 'premium'.tr.toUpperCase(),
                ),
                Text(
                  'unlock_all_access'.tr,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.rocket, size: 50),
        ],
      ),
    );

    return Tooltip(
      message: 'Redeem your free ${appConfig.name} Premium',
      child: Padding(
        padding: padding,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Card(
              child: InkWell(
                onTap: () => Utils.adaptiveRouteOpen(name: Routes.upgrade),
                child: content,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 2000.ms,
                  color: Colors.purple,
                  blendMode: BlendMode.hue,
                )
                .shakeX(duration: 1000.ms, hz: 2, amount: 1)
                .then(delay: 3000.ms),
          ),
        ),
      ),
    );
  }
}
