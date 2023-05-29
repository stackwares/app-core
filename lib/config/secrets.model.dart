import 'package:app_core/globals.dart';
import 'package:get/utils.dart';

late SecretsConfig secretConfig;

class SecretsConfig {
  const SecretsConfig({
    this.persistence = const ConfigPersistence(),
    this.revenuecat = const ConfigRevenuecat(),
    this.sentry = const ConfigSentry(),
    this.supabase = const ConfigSupabase(),
  });

  final ConfigPersistence persistence;
  final ConfigRevenuecat revenuecat;
  final ConfigSentry sentry;
  final ConfigSupabase supabase;

  factory SecretsConfig.fromJson(Map<String, dynamic> json) => SecretsConfig(
        persistence: ConfigPersistence.fromJson(json["persistence"]),
        revenuecat: ConfigRevenuecat.fromJson(json["revenuecat"]),
        sentry: ConfigSentry.fromJson(json["sentry"]),
        supabase: ConfigSupabase.fromJson(json["supabase"]),
      );

  Map<String, dynamic> toJson() => {
        "persistence": persistence.toJson(),
        "revenuecat": revenuecat.toJson(),
        "sentry": sentry.toJson(),
        "supabase": supabase.toJson(),
      };
}

class ConfigPersistence {
  const ConfigPersistence({
    this.box = '',
    this.key = '',
  });

  final String box;
  final String key;

  factory ConfigPersistence.fromJson(Map<String, dynamic> json) =>
      ConfigPersistence(
        box: json["box"],
        key: json["key"],
      );

  Map<String, dynamic> toJson() => {
        "box": box,
        "key": key,
      };
}

class ConfigRevenuecat {
  const ConfigRevenuecat({
    this.appleKey = '',
    this.googleKey = '',
  });

  final String appleKey;
  final String googleKey;

  factory ConfigRevenuecat.fromJson(Map<String, dynamic> json) =>
      ConfigRevenuecat(
        appleKey: json["apple_key"],
        googleKey: json["google_key"],
      );

  Map<String, dynamic> toJson() => {
        "apple_key": appleKey,
        "google_key": googleKey,
      };

  String get key {
    if (isApple) return appleKey;
    if (GetPlatform.isAndroid) return googleKey;
    return '';
  }
}

class ConfigSentry {
  const ConfigSentry({
    this.dsn = '',
  });

  final String dsn;

  factory ConfigSentry.fromJson(Map<String, dynamic> json) => ConfigSentry(
        dsn: json["dsn"],
      );

  Map<String, dynamic> toJson() => {
        "dsn": dsn,
      };
}

class ConfigSupabase {
  const ConfigSupabase({
    this.url = '',
    this.key = '',
    this.redirect = const ConfigRedirect(),
    this.redirectUrl = '',
    this.redirectUrlWeb = '',
  });

  final String url;
  final String key;
  final ConfigRedirect redirect;
  final String redirectUrl;
  final String redirectUrlWeb;

  factory ConfigSupabase.fromJson(Map<String, dynamic> json) => ConfigSupabase(
        url: json["url"],
        key: json["key"],
        redirect: ConfigRedirect.fromJson(json["redirect"]),
        redirectUrl: json["redirect_url"],
        redirectUrlWeb: json["redirect_url_web"],
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "key": key,
        "redirect": redirect.toJson(),
        "redirect_url": redirectUrl,
        "redirect_url_web": redirectUrlWeb,
      };
}

class ConfigRedirect {
  const ConfigRedirect({
    this.scheme = '',
    this.host = '',
  });

  final String scheme;
  final String host;

  factory ConfigRedirect.fromJson(Map<String, dynamic> json) => ConfigRedirect(
        scheme: json["scheme"],
        host: json["host"],
      );

  Map<String, dynamic> toJson() => {
        "scheme": scheme,
        "host": host,
      };
}
