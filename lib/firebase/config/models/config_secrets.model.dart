import 'package:get/utils.dart';

class ConfigSecrets {
  const ConfigSecrets({
    this.revenuecat = const ConfigSecretsRevenuecat(),
    this.sentry = const ConfigSecretsSentry(),
    this.supabase = const ConfigSecretsSupabase(),
    this.upgradeFallback = const ConfigSecretUpgradeFallback(),
  });

  final ConfigSecretsRevenuecat revenuecat;
  final ConfigSecretsSentry sentry;
  final ConfigSecretsSupabase supabase;
  final ConfigSecretUpgradeFallback upgradeFallback;

  factory ConfigSecrets.fromJson(Map<String, dynamic> json) => ConfigSecrets(
        revenuecat: ConfigSecretsRevenuecat.fromJson(json["revenuecat"]),
        sentry: ConfigSecretsSentry.fromJson(json["sentry"]),
        supabase: ConfigSecretsSupabase.fromJson(json["supabase"]),
        upgradeFallback:
            ConfigSecretUpgradeFallback.fromJson(json["upgrade_fallback"]),
      );

  Map<String, dynamic> toJson() => {
        "revenuecat": revenuecat.toJson(),
        "sentry": sentry.toJson(),
        "supabase": supabase.toJson(),
        "upgrade_fallback": upgradeFallback.toJson(),
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
    this.redirectUrl = '',
    this.redirectUrlWeb = '',
    this.redirect = const ConfigSecretsSupabaseRedirect(),
  });

  final String url;
  final String key;
  final String redirectUrl;
  final String redirectUrlWeb;
  final ConfigSecretsSupabaseRedirect redirect;

  factory ConfigSecretsSupabase.fromJson(Map<String, dynamic> json) =>
      ConfigSecretsSupabase(
        url: json["url"],
        key: json["key"],
        redirectUrl: json["redirect_url"],
        redirectUrlWeb: json["redirect_url_web"],
        redirect: ConfigSecretsSupabaseRedirect.fromJson(json["redirect"]),
      );

  Map<String, dynamic> toJson() => {
        "url": url,
        "key": key,
        "redirect_url": redirectUrl,
        "redirect_url_web": redirectUrlWeb,
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

class ConfigSecretUpgradeFallback {
  const ConfigSecretUpgradeFallback({
    this.apple = const Promo(),
    this.google = const Promo(),
    this.gumroad = const Promo(),
  });

  final Promo apple;
  final Promo google;
  final Promo gumroad;

  factory ConfigSecretUpgradeFallback.fromJson(Map<String, dynamic> json) =>
      ConfigSecretUpgradeFallback(
        apple: Promo.fromJson(json["apple"]),
        google: Promo.fromJson(json["google"]),
        gumroad: Promo.fromJson(json["gumroad"]),
      );

  Map<String, dynamic> toJson() => {
        "apple": apple.toJson(),
        "google": google.toJson(),
        "gumroad": gumroad.toJson(),
      };
}

class Promo {
  const Promo({
    this.code = '',
  });

  final String code;

  factory Promo.fromJson(Map<String, dynamic> json) => Promo(
        code: json["code"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
      };
}
