import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthCallbackMiddleware extends GetMiddleware with ConsoleMixin {
  @override
  RouteSettings? redirect(String? route) {
    if (route!.contains('#error')) {
      console.info('error route: $route');

      return const RouteSettings(
        name: Routes.welcome,
        arguments: 'callback_error',
      );
    }

    if (!route.contains('#access_token')) {
      console.info('no token route: $route');

      return const RouteSettings(
        name: Routes.welcome,
        arguments: 'callback_error',
      );
    }

    final uri = Uri.parse('${Uri.base.scheme}://${Uri.base.host}$route');

    AuthService.to.signInUri(
      uri,
      {'newsletter': Persistence.to.newsletter.val},
    );

    return super.redirect(route);
  }
}
