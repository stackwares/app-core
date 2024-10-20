import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:get/get.dart';

import '../../config.dart';
import '../../config/app.model.dart';
import '../../globals.dart';
import '../../utils/utils.dart';
import '../../widgets/gradient.widget.dart';
import '../upgrade/review_card.dart';
import 'laurel.widget.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final versionText = Text(
      metadataApp.formattedVersion,
      style: const TextStyle(color: Colors.grey, fontSize: 10),
    );

    final footerLinks = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: darkThemeData.primaryColor,
            textStyle: const TextStyle(fontSize: 10),
            minimumSize: Size.zero,
          ),
          onPressed: () => Utils.openUrl(appConfig.links.terms),
          child: Text('terms_of_use'.tr),
        ),
        versionText,
        TextButton(
          style: TextButton.styleFrom(
            foregroundColor: darkThemeData.primaryColor,
            textStyle: const TextStyle(fontSize: 10),
            minimumSize: Size.zero,
          ),
          onPressed: () => Utils.openUrl(appConfig.links.privacy),
          child: Text('privacy_policy'.tr),
        ),
      ],
    );

    final premiumBadge = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset('assets/images/logo.png', height: 50),
        const SizedBox(height: 10),
        GradientWidget(
          gradient: LinearGradient(colors: CoreConfig().gradientColors),
          child: Text(
            appConfig.name,
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

    final topContent = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        premiumBadge,
        const SizedBox(height: 15),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 300),
          child: Text(
            'benefit_desc'.tr,
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 50),
        const LaurelWidget(),
        const SizedBox(height: 30),
        // userReviews,
        CarouselSlider(
          items: stringReviews.map((e) => ReviewCard(review: e)).toList(),
          options: CarouselOptions(
            height: 120,
            autoPlay: true,
            enlargeCenterPage: true,
          ),
        ),
      ],
    );

    final ctaButton = ElevatedButton(
      onPressed: getOnboard,
      style: ElevatedButton.styleFrom(
        backgroundColor: darkThemeData.primaryColor,
        foregroundColor: darkThemeData.colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(vertical: 15),
      ),
      child: Text(
        'get_started'.tr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 17,
          fontFamily: '',
        ),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 2000.ms)
        .then(delay: 2000.ms);

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
              ctaButton,
              const SizedBox(height: 10),
              footerLinks,
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );

    final content = [
      Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: NetworkImage(onboardingBGUri),
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
    ];

    return Theme(
      data: darkThemeData,
      child: Scaffold(
        body: Stack(children: content),
      ),
    );
  }
}
