// USED FOR WINDOWS ONLY

import 'dart:convert';

import 'config_app.model.dart';
import 'config_general.model.dart';
import 'config_secrets.model.dart';

class ConfigRoot {
  ConfigRoot({
    required this.conditions,
    required this.parameters,
    required this.etag,
    required this.version,
  });

  List<Condition> conditions;
  ConfigParameters parameters;
  String etag;
  Version version;

  factory ConfigRoot.fromJson(Map<String, dynamic> json) => ConfigRoot(
        conditions: List<Condition>.from(
            json["conditions"].map((x) => Condition.fromJson(x))),
        parameters: ConfigParameters.fromJson(json["parameters"]),
        etag: json["etag"],
        version: Version.fromJson(json["version"]),
      );

  Map<String, dynamic> toJson() => {
        "conditions": List<dynamic>.from(conditions.map((x) => x.toJson())),
        "parameters": parameters.toJson(),
        "etag": etag,
        "version": version.toJson(),
      };
}

class Condition {
  Condition({
    required this.name,
    required this.expression,
    required this.tagColor,
  });

  String name;
  String expression;
  String tagColor;

  factory Condition.fromJson(Map<String, dynamic> json) => Condition(
        name: json["name"],
        expression: json["expression"],
        tagColor: json["tagColor"],
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "expression": expression,
        "tagColor": tagColor,
      };
}

class ConfigValue {
  ConfigValue({
    required this.defaultValue,
    required this.valueType,
  });

  DefaultValue defaultValue;
  String valueType;

  factory ConfigValue.fromJson(Map<String, dynamic> json) => ConfigValue(
        defaultValue: DefaultValue.fromJson(json["defaultValue"]),
        valueType: json["valueType"],
      );

  Map<String, dynamic> toJson() => {
        "defaultValue": defaultValue.toJson(),
        "valueType": valueType,
      };
}

class DefaultValue {
  DefaultValue({
    required this.value,
  });

  String value;

  factory DefaultValue.fromJson(Map<String, dynamic> json) => DefaultValue(
        value: json["value"],
      );

  Map<String, dynamic> toJson() => {
        "value": value,
      };
}

class ConfigParameters {
  ConfigParameters({
    required this.generalConfig,
    required this.secretsConfig,
    required this.appConfig,
  });

  ConfigGeneral generalConfig;
  ConfigSecrets secretsConfig;
  ConfigApp appConfig;

  factory ConfigParameters.fromJson(Map<String, dynamic> json) =>
      ConfigParameters(
        generalConfig: ConfigGeneral.fromJson(
          jsonDecode(
            ConfigValue.fromJson(json["general_config"]).defaultValue.value,
          ),
        ),
        secretsConfig: ConfigSecrets.fromJson(
          jsonDecode(
            ConfigValue.fromJson(json["secrets_config"]).defaultValue.value,
          ),
        ),
        appConfig: ConfigApp.fromJson(
          jsonDecode(
            ConfigValue.fromJson(json["app_config"]).defaultValue.value,
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
        "general_config": generalConfig.toJson(),
        "secrets_config": secretsConfig.toJson(),
        "app_config": appConfig.toJson(),
      };
}

class Version {
  Version({
    required this.versionNumber,
    required this.updateOrigin,
    required this.updateType,
    required this.updateUser,
    required this.updateTime,
  });

  String versionNumber;
  String updateOrigin;
  String updateType;
  UpdateUser updateUser;
  String updateTime;

  factory Version.fromJson(Map<String, dynamic> json) => Version(
        versionNumber: json["versionNumber"],
        updateOrigin: json["updateOrigin"],
        updateType: json["updateType"],
        updateUser: UpdateUser.fromJson(json["updateUser"]),
        updateTime: json["updateTime"],
      );

  Map<String, dynamic> toJson() => {
        "versionNumber": versionNumber,
        "updateOrigin": updateOrigin,
        "updateType": updateType,
        "updateUser": updateUser.toJson(),
        "updateTime": updateTime,
      };
}

class UpdateUser {
  UpdateUser({
    required this.email,
  });

  String email;

  factory UpdateUser.fromJson(Map<String, dynamic> json) => UpdateUser(
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
      };
}
