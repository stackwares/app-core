import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/firebase/crashlytics.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
// ignore: depend_on_referenced_packages
import 'package:local_auth_android/local_auth_android.dart';
// ignore: depend_on_referenced_packages
import 'package:local_auth_ios/local_auth_ios.dart';

import '../utils/ui_utils.dart';

// import 'package:local_auth_windows/local_auth_windows.dart';

class LocalAuthService extends GetxService with ConsoleMixin {
  static LocalAuthService get to => Get.find<LocalAuthService>();

  // VARIABLES
  final auth = LocalAuthentication();

  // PROPERTIES

  // INIT

  // FUNCTIONS

  Future<bool> authenticate({
    String? title,
    String? subTitle,
    required String body,
  }) async {
    bool authenticated = false;

    try {
      authenticated = await auth.authenticate(
        localizedReason: body,
        options: const AuthenticationOptions(stickyAuth: true),
        authMessages: [
          AndroidAuthMessages(
            signInTitle: '${ConfigService.to.appName} Biometrics',
            biometricHint: subTitle,
            cancelButton: 'Cancel',
          ),
          const IOSAuthMessages(cancelButton: 'Cancel'),
          // const WindowsAuthMessages(),
        ],
      );
    } on PlatformException catch (e, s) {
      console.error('exception: ${e.toString()}');

      if (e.code == auth_error.notAvailable) {
        _onError(e);
      } else if (e.code == auth_error.notEnrolled) {
        _onError(e);
      } else if (e.code == auth_error.passcodeNotSet) {
        _onError(e);
      } else if (e.code == auth_error.lockedOut ||
          e.code == auth_error.permanentlyLockedOut) {
        UIUtils.showSimpleDialog(
          'Locked Out',
          "Because of too many attempts you've been locked out. Please try again later.",
        );
      } else if (e.code == auth_error.otherOperatingSystem) {
        _failedAuth(e);
      } else {
        CrashlyticsService.to.record(e, s);
        _failedAuth(e);
      }

      return false;
    } catch (e, s) {
      console.error('error: ${e.toString()}');
      CrashlyticsService.to.record(e, s);
      _failedAuth(e);
      return false;
    }

    return authenticated;
  }

  void _onError(dynamic e) {
    _failedAuth(e);
  }

  void _failedAuth(dynamic e) {
    UIUtils.showSimpleDialog(
      'Failed Biometrics',
      'Please try again later\n\n$e',
    );
  }
}
