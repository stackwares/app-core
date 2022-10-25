import 'dart:convert';

class ConfigApp {
  const ConfigApp({
    this.enabled = true,
    this.build = const ConfigAppBuild(),
    this.beta = const ConfigAppBeta(),
    this.giveaway = const ConfigAppGiveaway(),
  });

  final bool enabled;
  final ConfigAppBuild build;
  final ConfigAppBeta beta;
  final ConfigAppGiveaway giveaway;

  factory ConfigApp.fromJson(Map<String, dynamic> json) => ConfigApp(
        enabled: json["enabled"],
        build: ConfigAppBuild.fromJson(json["build"]),
        beta: ConfigAppBeta.fromJson(json["beta"]),
        giveaway: ConfigAppGiveaway.fromJson(json["giveaway"]),
      );

  Map<String, dynamic> toJson() => {
        "enabled": enabled,
        "build": build.toJson(),
        "beta": beta.toJson(),
        "giveaway": giveaway.toJson(),
      };

  String toJsonString() => jsonEncode(toJson());
}

class ConfigAppBuild {
  const ConfigAppBuild({
    this.latest = 0,
    this.min = 0,
    this.disabled = const [],
  });

  final int latest;
  final int min;
  final List<int> disabled;

  factory ConfigAppBuild.fromJson(Map<String, dynamic> json) => ConfigAppBuild(
        latest: json["latest"],
        min: json["min"],
        disabled: List<int>.from(json["disabled"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "latest": latest,
        "min": min,
        "disabled": List<dynamic>.from(disabled.map((x) => x)),
      };
}

class ConfigAppBeta {
  const ConfigAppBeta({
    this.latest = 0,
    this.min = 0,
    this.enabled = true,
  });

  final int latest;
  final int min;
  final bool enabled;

  factory ConfigAppBeta.fromJson(Map<String, dynamic> json) => ConfigAppBeta(
        latest: json["latest"],
        min: json["min"],
        enabled: json["enabled"],
      );

  Map<String, dynamic> toJson() => {
        "latest": latest,
        "min": min,
        "enabled": enabled,
      };
}

class ConfigAppGiveaway {
  const ConfigAppGiveaway({
    this.message = '',
    this.highlight = '',
    this.imageUrl = '',
    this.detailsUrl = '',
  });

  final String message;
  final String highlight;
  final String imageUrl;
  final String detailsUrl;

  factory ConfigAppGiveaway.fromJson(Map<String, dynamic> json) =>
      ConfigAppGiveaway(
        message: json["message"],
        highlight: json["highlight"],
        imageUrl: json["imageUrl"],
        detailsUrl: json["detailsUrl"],
      );

  Map<String, dynamic> toJson() => {
        "message": message,
        "highlight": highlight,
        "imageUrl": imageUrl,
        "detailsUrl": detailsUrl,
      };
}
