import 'package:app_core/config.dart';
import 'package:app_core/controllers/pro.controller.dart';
import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/firebase/crashlytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/notifications/notifications.manager.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/supabase/supabase_functions.service.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseAuthService extends GetxService with ConsoleMixin {
  static SupabaseAuthService get to => Get.find();

  // VARIABLES
  final persistence = Get.find<Persistence>();
  final config = Get.find<ConfigService>();
  VoidCallback? signedIn;
  bool ready = false;

  // GETTERS
  bool get authenticated => user != null;
  User? get user => auth.currentUser;
  GoTrueClient get auth => Supabase.instance.client.auth;

  // INIT

  // FUNCTIONS
  void init() async {
    final supabaseConfig = config.secrets.supabase;

    await Supabase.initialize(
      url: supabaseConfig.url,
      anonKey: supabaseConfig.key,
      authCallbackUrlHostname: supabaseConfig.redirect.host,
      debug: false,
    );

    initAuthState();
    recoverSession();
  }

  void initAuthState() {
    auth.onAuthStateChange.listen((data) {
      console.info(
        'onAuthStateChange! ${data.event}: user id: ${data.session?.user.id}}',
      );

      persistence.supabaseSession.val =
          data.session?.persistSessionString ?? '';

      if (data.event == AuthChangeEvent.signedIn) {
        EasyDebounce.debounce('auth-sign-in', 5.seconds, () async {
          if (user == null) return;

          if (!isWindowsLinux) {
            await CrashlyticsService.to.instance.setUserIdentifier(user!.id);
            await AnalyticsService.to.instance.setUserId(id: user!.id);
          }

          ProController.to.login(user!);
          SupabaseFunctionsService.to.sync();

          // refresh token 2 minutes before expiration time
          if (data.session?.expiresIn != null) {
            final refreshAfter = (data.session!.expiresIn! - 120);
            Future.delayed(refreshAfter.seconds)
                .then((value) => recoverSession());
          }

          signedIn?.call();
        });
      } else if (data.event == AuthChangeEvent.signedOut) {
        EasyDebounce.debounce('auth-sign-out', 1.seconds, () async {
          CoreConfig().onSignedOut?.call();
          AnalyticsService.to.logSignOut();
          ProController.to.logout();
          Get.offNamedUntil(Routes.main, (route) => false);
        });
      } else if (data.event == AuthChangeEvent.tokenRefreshed) {
        //
      } else if (data.event == AuthChangeEvent.userUpdated) {
        //
      }
    });
  }

  Future<void> recoverSession() async {
    var sessionString = persistence.supabaseSession.val;
    if (sessionString.isEmpty) return console.warning('no supabase session');

    try {
      final session = await auth.recoverSession(sessionString);
      console.info('recovered session! user id: ${session.user?.id}');
    } on AuthException catch (e) {
      persistence.supabaseSession.val = '';
      console.error('recover session error: $e');
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      console.error('recover session exception: $e');
    }
  }

  Future<Either<String, bool>> magicLink(String email) async {
    final redirect = config.secrets.supabase.redirect;
    final redirectTo = GetPlatform.isWeb
        ? kReleaseMode
            ? '${CoreConfig().supabaseAuthHost}/%23/${redirect.host}'
            : 'http://localhost:9000/%23/${redirect.host}'
        : '${redirect.scheme}://${redirect.host}';

    console.info('redirectTo: $redirectTo');

    try {
      await auth.signInWithOtp(
        email: email,
        emailRedirectTo: redirectTo,
      );

      return const Right(true);
    } on AuthException catch (e) {
      return Left('signIn error: $e');
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      return Left('signIn exception: $e');
    }
  }

  Future<void> signIn(String email, String password) async {
    try {
      await auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      // invalid credentials
      if (e.statusCode == '400') {
        return console.error('signIn error: $e');
      } else {
        return console.error('signIn error: $e');
      }
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      return console.error('signIn exception: $e');
    }
  }

  Future<void> authenticate({
    required String email,
    required String password,
  }) async {
    if (user != null) return console.info('already authenticated');

    try {
      await auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      // already registered
      if (e.statusCode == '400') {
        await signIn(email, password);
      } else {
        return console.error('signUp error: $e');
      }
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      return console.error('signIn exception: $e');
    }

    console.wtf('authentication successful');
  }

  Future<void> signInUri(Uri uri, Map<String, dynamic>? attributes) async {
    try {
      console.info('signInUri: ${uri.toString()}');
      final response = await auth.getSessionFromUrl(uri);
      // updateUserAttribute(attributes);
      console.info('signInUri session user id: ${response.session.user.id}');

      NotificationsManager.notify(
        title: '${'welcome_to'.tr} ${config.appName}',
        body: 'welcome_notif_body'.tr,
      );

      AnalyticsService.to.logSignIn();
      await Utils.adaptiveRouteOpen(name: Routes.upgrade);
      await Get.offNamedUntil(Routes.main, (route) => false);
    } on AuthException catch (e) {
      console.error('signInUri error: $e');
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      console.error('signInUri exception: $e');
    }
  }

  void updateUserAttribute(Map<String, dynamic>? data) async {
    if (data == null) return;

    try {
      final response = await auth.updateUser(
        UserAttributes(data: data),
      );

      console.wtf('updateUser success! ${response.user?.updatedAt}');
    } on AuthException catch (e) {
      console.error('updateUser error: $e');
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      console.error('updateUser exception: $e');
    }
  }

  Future<void> deleteAccount() async {
    // client.auth.user().
    auth.signOut();
  }
}
