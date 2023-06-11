import 'package:app_core/config.dart';
import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/firebase/crashlytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/notifications/notifications.manager.dart';
import 'package:app_core/purchases/purchases.services.dart';
import 'package:app_core/supabase/supabase_functions.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app.model.dart';
import '../config/secrets.model.dart';

class AuthService extends GetxService with ConsoleMixin {
  static AuthService get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final busy = false.obs;

  // GETTERS
  bool get authenticated => user != null;
  User? get user => auth.currentUser;
  GoTrueClient get auth => Supabase.instance.client.auth;

  int get daysOld {
    if (!authenticated) return 0;
    final createdDate = DateTime.parse(user!.createdAt);
    final days = DateTime.now().difference(createdDate).inDays;
    console.info('user is $days old');
    return days;
  }
  // INIT

  @override
  void onInit() async {
    final s = secretConfig.supabase;

    await Supabase.initialize(
      url: s.url,
      anonKey: s.key,
      authCallbackUrlHostname: s.redirect.host,
      debug: false,
    );

    initAuthState();
    super.onInit();
  }

  void onSignedIn(User user_) async {
    busy.value = false;
    CoreConfig().onSignedIn?.call();

    if (!isWindowsLinux) {
      AnalyticsService.to.setUserID(user_.id);
      await CrashlyticsService.to.setUserID(user_.id);
    }

    await PurchasesService.to.login(user_);
    FunctionsService.to.sync(user_);
    AnalyticsService.to.logSignIn();
    if (GetPlatform.isIOS) closeInAppWebView();
  }

  void initAuthState() {
    auth.onAuthStateChange.listen((data) async {
      console.wtf(
        'onAuthStateChange! ${data.event} => ${data.session?.user.id}',
      );

      if (data.event == AuthChangeEvent.signedIn) {
        EasyDebounce.debounce('auth-sign-in', 2.seconds, () async {
          onSignedIn(data.session!.user);
        });
      } else if (data.event == AuthChangeEvent.tokenRefreshed) {
        EasyDebounce.debounce('auth-token-refreshed', 2.seconds, () async {
          onSignedIn(data.session!.user);
        });
      } else if (data.event == AuthChangeEvent.signedOut) {
        AnalyticsService.to.logSignOut();
        PurchasesService.to.logout();
        CoreConfig().onSignedOut?.call();
      } else if (data.event == AuthChangeEvent.userUpdated) {
        //
      }
    });
  }

  Future<Either<String, bool>> providerAuth(Provider provider) async {
    final s = secretConfig.supabase;
    final redirect = s.redirectUrl;
    final redirectWeb = s.redirectUrlWeb;

    final redirectTo = GetPlatform.isWeb
        ? kReleaseMode
            ? redirectWeb
            : 'http://localhost:9000/#/auth-callback'
        : redirect;

    busy.value = true;

    try {
      if (provider == Provider.apple && isApple) {
        console.info('APPLE SIGNING IN...');
        final response = await auth.signInWithApple();
        console.info('APPLE RESPONSE: $response');
      } else {
        await auth.signInWithOAuth(
          provider,
          redirectTo: redirectTo,
          authScreenLaunchMode: LaunchMode.externalApplication,
        );
      }
    } on AuthException catch (e) {
      busy.value = false;
      return Left('signIn error: $e');
    } catch (e, s) {
      busy.value = false;
      CrashlyticsService.to.record(e, s);
      return Left('signIn exception: $e');
    }

    busy.value = false;
    return const Right(true);
  }

  Future<Either<String, bool>> magicLink(String email) async {
    final s = secretConfig.supabase;
    final redirect = s.redirectUrl;
    final redirectWeb = s.redirectUrlWeb;

    final redirectTo = GetPlatform.isWeb
        ? kReleaseMode
            ? redirectWeb
            : 'http://localhost:9000/#/auth-callback'
        : redirect;

    try {
      busy.value = true;
      await auth.signInWithOtp(email: email, emailRedirectTo: redirectTo);
    } on AuthException catch (e) {
      busy.value = false;
      return Left('signIn error: $e');
    } catch (e, s) {
      busy.value = false;
      CrashlyticsService.to.record(e, s);
      return Left('signIn exception: $e');
    }

    busy.value = false;
    return const Right(true);
  }

  Future<void> signIn(String email, String password) async {
    try {
      busy.value = true;
      await auth.signInWithPassword(email: email, password: password);
    } on AuthException catch (e) {
      console.error('signIn error: $e');
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      console.error('signIn exception: $e');
    }

    busy.value = false;
  }

  // sign up or sign in
  Future<void> authenticate({
    required String email,
    required String password,
  }) async {
    if (user != null) return console.info('already authenticated');

    try {
      busy.value = true;
      await auth.signUp(email: email, password: password);
    } on AuthException catch (e) {
      // already registered
      if (e.statusCode == '400') {
        await signIn(email, password);
      } else {
        console.error('signUp error: $e');
      }
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      console.error('signIn exception: $e');
    }

    busy.value = false;
    console.wtf('authentication successful');
  }

  Future<void> signInUri(Uri uri, Map<String, dynamic>? attributes) async {
    try {
      busy.value = true;
      final response = await auth.getSessionFromUrl(uri);
      console.info('signInUri session user id: ${response.session.user.id}');
    } on AuthException catch (e) {
      busy.value = false;
      return console.error('signInUri error: $e');
    } catch (e, s) {
      busy.value = false;
      CrashlyticsService.to.record(e, s);
      return console.error('signInUri exception: $e');
    }

    busy.value = false;
    updateUserAttribute(attributes);

    NotificationsManager.notify(
      title: '${'welcome_to'.tr} ${appConfig.name}',
      body: 'welcome_notif_body'.tr,
    );
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
    AnalyticsService.to.logEvent('delete-account');
    auth.signOut();
  }
}
