class UserPresence {
  UserPresence({
    this.email = '',
    this.id = '',
    this.license = const PresenceLicense(),
    this.locale = '',
    this.country = '',
    this.plan = '',
    this.planSource = '',
    this.planTrial = false,
    this.platform = '',
    this.deviceType = '',
    this.theme = '',
    this.version = '',
  });

  final String email;
  final String id;
  final PresenceLicense? license;
  final String locale;
  final String? country;
  final String? plan;
  final String? planSource;
  final bool planTrial;
  final String platform;
  final String deviceType;
  final String theme;
  final String version;
  // user since
  // last used date

  factory UserPresence.fromJson(Map<String, dynamic> json) => UserPresence(
        email: json["email"],
        id: json["id"],
        license: json["license"] != null
            ? PresenceLicense.fromJson(json["license"])
            : null,
        locale: json["locale"],
        country: json["country"],
        plan: json["plan"],
        planSource: json["plan_source"],
        planTrial: json["plan_trial"] ?? false,
        platform: json["platform"],
        deviceType: json["device_type"],
        theme: json["theme"],
        version: json["version"],
      );

  Map<String, dynamic> toJson() => {
        "email": email,
        "id": id,
        "license": license?.toJson(),
        "locale": locale,
        "country": country,
        "plan": plan,
        "plan_source": planSource,
        "plan_trial": planTrial,
        "platform": platform,
        "device_type": deviceType,
        "theme": theme,
        "version": version,
      };
}

class PresenceLicense {
  const PresenceLicense({
    this.balance = 0,
    this.maxTokens = 0,
    this.usedTokens = 0,
  });

  final int balance;
  final int maxTokens;
  final int usedTokens;

  factory PresenceLicense.fromJson(Map<String, dynamic> json) =>
      PresenceLicense(
        balance: json["balance"],
        maxTokens: json["maxTokens"],
        usedTokens: json["usedTokens"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "maxTokens": maxTokens,
        "usedTokens": usedTokens,
      };
}
