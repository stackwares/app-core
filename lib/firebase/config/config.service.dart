import 'dart:convert';

import 'package:app_core/config.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

import 'models/config_app.model.dart';
import 'models/config_general.model.dart';
import 'models/config_secrets.model.dart';

class ConfigService extends GetxService with ConsoleMixin {
  static ConfigService get to => Get.find();

  // VARIABLES
  var app = const ConfigApp();
  var general = const ConfigGeneral();
  var secrets = const ConfigSecrets();

  // TODO: use typedef
  Function(Map<String, dynamic> parameters) postInit =
      (_) => throw 'unimplemented';

  bool fetched = false;

  // GETTERS
  String get appName => general.app.name;
  String get devName => general.developer.name;

  // INIT

  // FUNCTIONS
  Future<void> init({
    required Function(Map<String, dynamic> parameters) postInit,
  }) async {
    this.postInit = postInit;
    _prePopulate();
  }

  Future<void> _prePopulate() async {
    app = ConfigApp.fromJson(CoreConfig().appConfig);
    secrets = ConfigSecrets.fromJson(CoreConfig().secretsConfig);
    general = ConfigGeneral.fromJson(CoreConfig().generalConfig);

    if (Persistence.to.configApp.val.isNotEmpty) {
      app = ConfigApp.fromJson(
        jsonDecode(Persistence.to.configApp.val),
      );

      secrets = ConfigSecrets.fromJson(
        jsonDecode(Persistence.to.configSecrets.val),
      );

      general = ConfigGeneral.fromJson(
        jsonDecode(Persistence.to.configGeneral.val),
      );
    }
  }
}
