import 'package:app_core/config/app.model.dart';
import 'package:app_core/config/secrets.model.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/foundation.dart';
import 'package:get/utils.dart';

class UtilsCrypto {
  static final console = Console(name: 'UtilsCrypto');

  static String generateSecret() {
    final jwt = JWT({'app': appConfig.name, 'dev': appConfig.dev});

    final token = jwt.sign(
      SecretKey(secretConfig.persistence.key.substring(0, 15)),
      expiresIn: 1.minutes,
    );

    if (kDebugMode) console.info(token);
    return token;
  }
}
