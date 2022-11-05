import 'dart:convert';

import 'package:app_core/config.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

import '../../controllers/pro.controller.dart';
import '../../globals.dart';
import '../../pages/routes.dart';
import '../functions.service.dart';
import 'models/config_app.model.dart';
import 'models/config_general.model.dart';
import 'models/config_root.model.dart';
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
    fetchFromFunctions();
  }

  Future<void> fetchFromFunctions() async {
    console.info('fetching...');
    final result = await FirebaseFunctionsService.to.getRemoteConfig();

    result.fold(
      (error) => console.info('failed to fetch from functions: $error'),
      (data) {
        final parametersMap = jsonDecode(data)['parameters'];
        final parameters = ConfigParameters.fromJson(parametersMap);

        app = parameters.appConfig;
        Persistence.to.configApp.val = jsonEncode(app.toJson());

        secrets = parameters.secretsConfig;
        Persistence.to.configSecrets.val = jsonEncode(secrets.toJson());

        general = parameters.generalConfig;
        Persistence.to.configGeneral.val = jsonEncode(general.toJson());
        ProController.to.init();
        // return raw parameters
        postInit(parametersMap);

        // check if update is required
        if (app.build.min > int.parse(metadataApp.buildNumber)) {
          console.error('### must update');
          Get.toNamed(Routes.update);
        } else if (isBeta && !ConfigService.to.app.beta.enabled) {
          Get.toNamed(Routes.disabledBeta);
        }

        fetched = true;
        console.wtf('remote config from functions synced');
      },
    );
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

    SupabaseAuthService.to.init();
  }
}
