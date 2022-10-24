import 'package:get/utils.dart';

class ConfigSecrets {
  const ConfigSecrets({
    this.revenuecat = const ConfigSecretsRevenuecat(),
    this.sentry = const ConfigSecretsSentry(),
    this.unsplash = const ConfigSecretsUnsplash(),
    this.supabase = const ConfigSecretsSupabase(),
  });

  final ConfigSecretsRevenuecat revenuecat;
  final ConfigSecretsSentry sentry;
  final ConfigSecretsUnsplash unsplash;
  final ConfigSecretsSupabase supabase;

  factory ConfigSecrets.fromJson(Map<String, dynamic> json) => ConfigSecrets(
        revenuecat: ConfigSecretsRevenuecat.fromJson(json["revenuecat"]),
        sentry: ConfigSecretsSentry.fromJson(json["sentry"]),
        unsplash: ConfigSecretsUnsplash.fromJson(json["unsplash"]),
        supabase: ConfigSecretsSupabase.fromJson(json["supabase"]),
      );

  Map<String, dynamic> toJson() => {
        "revenuecat": revenuecat.toJson(),
        "sentry": sentry.toJson(),
        "unsplash": unsplash.toJson(),
        "supabase": supabase.toJson(),
      };
}

class ConfigSecretsRevenuecat {
  const ConfigSecretsRevenuecat({
    this.appleApiKey = '',
    this.googleApiKey = '',
  });

  final String appleApiKey;
  final String googleApiKey;

  factory ConfigSecretsRevenuecat.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsRevenuecat(
        appleApiKey: json["appleApiKey"],
        googleApiKey: json["googleApiKey"],
      );

  Map<String, dynamic> toJson() => {
        "appleApiKey": appleApiKey,
        "googleApiKey": googleApiKey,
      };

  String get apiKey {
    if (GetPlatform.isAndroid) {
      return googleApiKey;
    } else {
      return appleApiKey;
    }
  }
}

class ConfigSecretsSentry {
  const ConfigSecretsSentry({
    this.dsn = '',
  });

  final String dsn;

  factory ConfigSecretsSentry.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsSentry(
        dsn: json["dsn"],
      );

  Map<String, dynamic> toJson() => {
        "dsn": dsn,
      };
}

class ConfigSecretsUnsplash {
  const ConfigSecretsUnsplash({
    this.accessKey = '',
    this.secretKey = '',
  });

  final String accessKey;
  final String secretKey;

  factory ConfigSecretsUnsplash.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsUnsplash(
        accessKey: json["accessKey"],
        secretKey: json["secretKey"],
      );

  Map<String, dynamic> toJson() => {
        "accessKey": accessKey,
        "secretKey": secretKey,
      };
}

class ConfigSecretsSupabase {
  const ConfigSecretsSupabase({
    this.url = '',
    this.key = '',
    this.redirect = const ConfigSecretsSupabaseRedirect(),
  });

  final String url;
  final String key;
  final ConfigSecretsSupabaseRedirect redirect;

  factory ConfigSecretsSupabase.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsSupabase(
        url: json["url"],
        key: json["key"],
        redirect: ConfigSecretsSupabaseRedirect.fromJson(json["redirect"]),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "key": key,
        "redirect": redirect.toJson(),
      };
}

class ConfigSecretsSupabaseRedirect {
  const ConfigSecretsSupabaseRedirect({
    this.scheme = '',
    this.host = '',
  });

  final String scheme;
  final String host;

  factory ConfigSecretsSupabaseRedirect.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsSupabaseRedirect(
        scheme: json["scheme"],
        host: json["host"],
      );

  Map<String, dynamic> toJson() => {
        "scheme": scheme,
        "host": host,
      };
}
