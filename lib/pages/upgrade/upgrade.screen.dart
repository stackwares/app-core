import 'package:app_core/config.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/pages/upgrade/appbar.dart';
import 'package:app_core/pages/upgrade/footer_links.dart';
import 'package:app_core/pages/upgrade/products_listview.dart';
import 'package:app_core/widgets/gradient.widget.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../onboarding/laurel.widget.dart';
import 'feature.tile.dart';
import 'review_card.dart';
import 'upgrade_button.dart';
import 'upgrade_screen.controller.dart';

class UpgradeScreen extends StatelessWidget with ConsoleMixin {
  const UpgradeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UpgradeScreenController());

    final premiumBadge = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo.png', height: 30),
        const SizedBox(width: 10),
        GradientWidget(
          gradient: LinearGradient(colors: CoreConfig().gradientColors),
          child: Text(
            'unlock_all_access'.tr,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2000.ms)
        .then(delay: 3000.ms);

    final features = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...controller.pricing.features
            .map((e) => FeatureTile(title: e.tr))
            .toList()
            .animate(interval: 400.ms)
            .fade(duration: 300.ms)
      ],
    );

    final topContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: isSmallScreen ? 100 : 50),
        premiumBadge,
        const SizedBox(height: 20),
        features,
        const SizedBox(height: 20),
        const LaurelWidget(),
        const SizedBox(height: 20),
        // userReviews,
        CarouselSlider(
          items: stringReviews.map((e) => ReviewCard(review: e)).toList(),
          options: CarouselOptions(
            height: 120,
            autoPlay: true,
            enlargeCenterPage: true,
          ),
        ),
        const SizedBox(height: 300),
      ],
    );

    final bottomContent = Center(
      heightFactor: 1,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 500),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isIAPSupported) ...[ProductsListView()],
              const SizedBox(height: 5),
              const CTAUpgradeButton(),
              const SizedBox(height: 3),
              const FooterLinks(),
            ],
          ),
        ),
      ),
    );

    final content = Theme(
      data: darkThemeData,
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(controller.bgImageUri),
                  fit: BoxFit.cover,
                  opacity: 0.2,
                ),
              ),
              child: Center(
                child: SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 500),
                    child: topContent,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: bottomContent,
            ),
            Align(
              alignment: Alignment.topRight,
              child: SafeArea(child: UpgradeAppBar()),
            )
          ],
        ),
      ),
    );

    return Obx(
      () => PopScope(
        canPop: controller.timerSeconds.value == 0,
        child: content,
      ),
    );
  }
}
