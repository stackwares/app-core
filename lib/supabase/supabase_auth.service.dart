import 'package:app_core/config.dart';
import 'package:app_core/controllers/pro.controller.dart';
import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/firebase/config/models/config_secrets.model.dart';
import 'package:app_core/firebase/crashlytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/notifications/notifications.manager.dart';
import 'package:app_core/pages/routes.dart';
import 'package:app_core/supabase/supabase_functions.service.dart';
import 'package:app_core/utils/utils.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../persistence/persistence.dart';
import '../rate/rate.widget.dart';

class SupabaseAuthService extends GetxService with ConsoleMixin {
  static SupabaseAuthService get to => Get.find();

  // VARIABLES
  // final persistence = Get.find<Persistence>();
  final config = Get.find<ConfigService>();

  // PROPERTIES

  // GETTERS
  bool get authenticated => user != null;
  User? get user => auth.currentUser;
  GoTrueClient get auth => Supabase.instance.client.auth;

  // INIT

  @override
  void onInit() {
    init();
    super.onInit();
  }

  // FUNCTIONS
  void init() async {
    final s = ConfigSecrets.fromJson(CoreConfig().secretsConfig).supabase;

    await Supabase.initialize(
      url: s.url,
      anonKey: s.key,
      authCallbackUrlHostname: s.redirect.host,
      debug: false,
    );

    initAuthState();

    try {
      final initialSession = await SupabaseAuth.instance.initialSession;
      console.warning('initialSession user id: ${initialSession?.user.id}');
      if (initialSession != null) authenticatedInit(initialSession.user);
    } catch (e) {
      // Handle initial auth state fetch error here
      console.error('initialSession error: $e');
    }
  }

  void authenticatedInit(User user_) async {
    onSignedIn(user_);
  }

  void onSignedIn(User user_) async {
    CoreConfig().onSignedIn?.call();

    if (!isWindowsLinux) {
      await CrashlyticsService.to.instance.setUserIdentifier(user_.id);
      await AnalyticsService.to.instance.setUserId(id: user_.id);
    }

    ProController.to.login(user_);
    SupabaseFunctionsService.to.sync(user_);
    AnalyticsService.to.logSignIn();
  }

  void initAuthState() {
    auth.onAuthStateChange.listen((data) {
      console.wtf('onAuthStateChange! ${data.event}');
      console.info('User ID: ${data.session?.user.id}');

      if (data.event == AuthChangeEvent.signedIn) {
        EasyDebounce.debounce('auth-sign-in', 2.seconds, () async {
          onSignedIn(data.session!.user);
          Get.offNamedUntil(Routes.main, (route) => false);
        });
      } else if (data.event == AuthChangeEvent.signedOut) {
        EasyDebounce.debounce('auth-sign-out', 1.seconds, () async {
          AnalyticsService.to.logSignOut();
          ProController.to.logout();
          CoreConfig().onSignedOut?.call();
        });
      } else if (data.event == AuthChangeEvent.tokenRefreshed) {
        //
      } else if (data.event == AuthChangeEvent.userUpdated) {
        //
      }
    });
  }

  Future<Either<String, bool>> providerAuth(Provider provider) async {
    final s = config.secrets.supabase;
    final redirect = s.redirectUrl;
    final redirectWeb = s.redirectUrlWeb;

    final redirectTo = GetPlatform.isWeb
        ? kReleaseMode
            ? redirectWeb
            : 'http://localhost:9000/%23/auth-callback'
        : redirect;

    try {
      await auth.signInWithOAuth(provider, redirectTo: redirectTo);
      return const Right(true);
    } on AuthException catch (e) {
      return Left('signIn error: $e');
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      return Left('signIn exception: $e');
    }
  }

  Future<Either<String, bool>> magicLink(String email) async {
    final s = config.secrets.supabase;
    final redirect = s.redirectUrl;
    final redirectWeb = s.redirectUrlWeb;

    final redirectTo = GetPlatform.isWeb
        ? kReleaseMode
            ? redirectWeb
            : 'http://localhost:9000/%23/auth-callback'
        : redirect;

    try {
      await auth.signInWithOtp(email: email, emailRedirectTo: redirectTo);
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
      final response = await auth.getSessionFromUrl(uri);
      updateUserAttribute(attributes);
      console.info('signInUri session user id: ${response.session.user.id}');

      NotificationsManager.notify(
        title: '${'welcome_to'.tr} ${config.appName}',
        body: 'welcome_notif_body'.tr,
      );
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
    auth.signOut();
  }
}
