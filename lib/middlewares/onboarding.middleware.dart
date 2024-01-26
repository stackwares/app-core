import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/services/main.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingMiddleware extends GetMiddleware with ConsoleMixin {
  @override
  RouteSettings? redirect(String? route) {
    if (!Persistence.to.onboarded.val) {
      return const RouteSettings(name: Routes.welcome);
    } else {
      MainService.to.onboarded();
    }

    return super.redirect(route);
  }
}
