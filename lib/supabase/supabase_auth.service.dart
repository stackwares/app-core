import 'dart:convert';

import 'package:app_core/config.dart';
import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/firebase/crashlytics.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/purchases/purchases.services.dart';
import 'package:app_core/supabase/supabase_functions.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:crypto/crypto.dart';
import 'package:easy_debounce/easy_debounce.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config/app.model.dart';
import '../config/secrets.model.dart';
import '../services/notifications.service.dart';
import '../utils/utils.dart';
import '../widgets/gradient.widget.dart';

class AuthService extends GetxService with ConsoleMixin {
  static AuthService get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final busy = false.obs;
  final authenticatedRx = false.obs;

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
    await Supabase.initialize(url: s.url, anonKey: s.key, debug: false);
    initAuthState();
    super.onInit();
  }

  void onSignedOut() {
    AnalyticsService.to.logSignOut();
    PurchasesService.to.logout();
    CoreConfig().onSignedOut?.call();
    authenticatedRx.value = false;
    FunctionsService.to.sessionId = 0;
  }

  void onSignedIn(User user_) async {
    busy.value = false;
    authenticatedRx.value = true;
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
      console.wtf('${data.event}: ${data.session?.user.id}');

      if (data.event == AuthChangeEvent.signedIn) {
        EasyDebounce.debounce('auth-sign-in', 2.seconds, () async {
          onSignedIn(data.session!.user);
        });
      } else if (data.event == AuthChangeEvent.tokenRefreshed) {
        EasyDebounce.debounce('auth-token-refreshed', 2.seconds, () async {
          onSignedIn(data.session!.user);
        });
      } else if (data.event == AuthChangeEvent.initialSession) {
        if (data.session == null) return;
        EasyDebounce.debounce('auth-initial-session', 2.seconds, () async {
          onSignedIn(data.session!.user);
        });
      } else if (data.event == AuthChangeEvent.signedOut) {
        EasyDebounce.debounce('auth-signed-out', 2.seconds, () async {
          onSignedOut();
        });
      } else if (data.event == AuthChangeEvent.userUpdated) {
        //
      }
    });
  }

  Future<Either<String, bool>> providerAuth(OAuthProvider provider) async {
    busy.value = true;

    try {
      if (provider == OAuthProvider.apple && isApple) {
        await signInWithApple();
      } else if (provider == OAuthProvider.google && !isMac && !isWeb) {
        await signInWithGoogle();
      } else {
        final s = secretConfig.supabase;

        final redirectTo = GetPlatform.isWeb
            ? kReleaseMode
                ? s.redirectUrlWeb
                : 'http://localhost:9000/#/auth-callback'
            : s.redirectUrl;

        console.info('redirect url: ${redirectTo}');

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

  void updateUserAttribute(Map<String, dynamic>? data) async {
    if (data == null) return;

    try {
      final response = await auth.updateUser(UserAttributes(data: data));
      console.wtf('updateUser success! ${response.user?.updatedAt}');
    } on AuthException catch (e) {
      console.error('updateUser error: $e');
    } catch (e, s) {
      CrashlyticsService.to.record(e, s);
      console.error('updateUser exception: $e');
    }
  }

  Future<void> deleteAccount() async {
    AnalyticsService.to.logEvent('delete_account');
    auth.signOut();
  }

  Future<void> signInUri(Uri uri, Map<String, dynamic>? attributes) async {
    console.wtf('signInUri: $uri');

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

    NotificationsService.to.notify(
      title: '${'welcome_to'.tr} ${appConfig.name}',
      body: 'welcome_notif_body'.tr,
    );
  }

  // GOOGLE SIGN IN
  Future<AuthResponse> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn(
      clientId: CoreConfig().appleGoogleClientId,
      serverClientId: CoreConfig().webGoogleClientId,
    );

    final googleUser = await googleSignIn.signIn();
    final googleAuth = await googleUser!.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null) throw 'No Access Token found.';
    if (idToken == null) throw 'No ID Token found.';

    return auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
  }

  // APPLE SIGN IN
  Future<AuthResponse> signInWithApple() async {
    final rawNonce = auth.generateRawNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: hashedNonce,
    );

    final idToken = credential.identityToken;
    if (idToken == null) {
      throw const AuthException(
        'Could not find ID Token from generated credential.',
      );
    }

    return auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
      nonce: rawNonce,
    );
  }

  // SIGN IN
  Future<Either<String, bool>> magicLink(String email) async {
    try {
      busy.value = true;

      final s = secretConfig.supabase;

      final redirectTo = GetPlatform.isWeb
          ? kReleaseMode
              ? s.redirectUrlWeb
              : 'http://localhost:9000/#/auth-callback'
          : s.redirectUrl;

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
  }

  // UI
  void showAuthDialog() {
    const appleImage = 'assets/images/providers/apple.png';
    const googleImage = 'assets/images/providers/google.png';

    final appleButton = Padding(
      padding: EdgeInsets.only(top: 15),
      child: OutlinedButton.icon(
        label: Text('signin_apple'.tr),
        icon: Image.asset(
          appleImage,
          width: 20,
          color: Get.isDarkMode ? Colors.white : Colors.black,
        ),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(300, 45),
          visualDensity: VisualDensity.comfortable,
        ),
        onPressed: () {
          AuthService.to.providerAuth(OAuthProvider.apple);
          Get.back();
        },
      ),
    );

    final googleButton = Padding(
      padding: EdgeInsets.only(top: 15),
      child: OutlinedButton.icon(
        label: Text('signin_google'.tr),
        icon: Image.asset(googleImage, width: 20),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(300, 45),
          visualDensity: VisualDensity.comfortable,
        ),
        onPressed: () {
          AuthService.to.providerAuth(OAuthProvider.google);
          Get.back();
        },
      ),
    );

    final footer = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => Utils.openUrl(appConfig.links.terms),
          child: Text(
            'terms_of_use'.tr,
            style: const TextStyle(fontSize: 11),
          ),
        ),
        const SizedBox(width: 3),
        Text(
          'and'.tr,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        const SizedBox(width: 3),
        TextButton(
          style: TextButton.styleFrom(padding: EdgeInsets.zero),
          onPressed: () => Utils.openUrl(appConfig.links.privacy),
          child: Text(
            'privacy_policy'.tr,
            style: const TextStyle(fontSize: 11),
          ),
        ),
      ],
    );

    final title = GradientWidget(
      gradient: LinearGradient(colors: CoreConfig().gradientColors),
      child: Text(
        'authenticate'.tr,
        textAlign: TextAlign.center,
        style: GoogleFonts.raleway(
          fontSize: isSmallScreen ? 20 : 32,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final buttons = [appleButton, googleButton];

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 15),
        title,
        if (isMac) ...[
          appleButton,
        ] else ...[
          if (isApple) ...buttons else ...buttons.reversed,
        ],
        const SizedBox(height: 15),
        Text(
          'proceed_agreement'.tr,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
        ),
        footer,
      ],
    );

    if (isSmallScreen) {
      Get.bottomSheet(
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: content,
          ),
        ),
      );
    } else {
      Get.dialog(
        AlertDialog(
          content: SizedBox(width: 400, child: content),
        ),
      );
    }
  }
}
