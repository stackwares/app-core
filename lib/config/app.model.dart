late AppConfig appConfig;

class AppConfig {
  const AppConfig({
    this.name = '',
    this.dev = '',
    this.build = const ConfigBuild(),
    this.links = const ConfigLinks(),
    this.emails = const ConfigEmails(),
  });

  final String name;
  final String dev;
  final ConfigBuild build;
  final ConfigLinks links;
  final ConfigEmails emails;

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
        name: json["name"],
        dev: json["dev"],
        build: ConfigBuild.fromJson(json["build"]),
        links: ConfigLinks.fromJson(json["links"]),
        emails: ConfigEmails.fromJson(json["emails"]),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "dev": dev,
        "build": build.toJson(),
        "links": links.toJson(),
        "emails": emails.toJson(),
      };
}

class ConfigBuild {
  const ConfigBuild({
    this.min = 0,
    this.latest = 0,
    this.disabled = const [],
  });

  final int min;
  final int latest;
  final List<int> disabled;

  factory ConfigBuild.fromJson(Map<String, dynamic> json) => ConfigBuild(
        min: json["min"],
        latest: json["latest"],
        disabled: List<int>.from(json["disabled"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "min": min,
        "latest": latest,
        "disabled": List<dynamic>.from(disabled.map((x) => x)),
      };
}

class ConfigEmails {
  const ConfigEmails({
    this.issues = '',
    this.premium = '',
    this.support = '',
  });

  final String issues;
  final String premium;
  final String support;

  factory ConfigEmails.fromJson(Map<String, dynamic> json) => ConfigEmails(
        issues: json["issues"],
        premium: json["premium"],
        support: json["support"],
      );

  Map<String, dynamic> toJson() => {
        "issues": issues,
        "premium": premium,
        "support": support,
      };
}

class ConfigLinks {
  const ConfigLinks({
    this.faqs = '',
    this.store = const ConfigStore(),
    this.terms = '',
    this.reddit = '',
    this.discord = '',
    this.privacy = '',
    this.roadmap = '',
    this.twitter = '',
    this.website = '',
    this.facebook = '',
    this.facebookGroup = '',
    this.giveaway = '',
    this.instagram = '',
    this.tutorials = '',
    this.contributors = '',
    this.productHunt = '',
    this.translations = '',
    this.affiliates = '',
  });

  final String faqs;
  final ConfigStore store;
  final String terms;
  final String reddit;
  final String discord;
  final String privacy;
  final String roadmap;
  final String twitter;
  final String website;
  final String facebook;
  final String facebookGroup;
  final String giveaway;
  final String instagram;
  final String tutorials;
  final String contributors;
  final String productHunt;
  final String translations;
  final String affiliates;

  factory ConfigLinks.fromJson(Map<String, dynamic> json) => ConfigLinks(
        faqs: json["faqs"],
        store: ConfigStore.fromJson(json["store"]),
        terms: json["terms"],
        reddit: json["reddit"],
        discord: json["discord"],
        privacy: json["privacy"],
        roadmap: json["roadmap"],
        twitter: json["twitter"],
        website: json["website"],
        facebook: json["facebook"],
        facebookGroup: json["facebook_group"],
        giveaway: json["giveaway"],
        instagram: json["instagram"],
        tutorials: json["tutorials"],
        contributors: json["contributors"],
        productHunt: json["product_hunt"],
        translations: json["translations"],
        affiliates: json["affiliates"],
      );

  Map<String, dynamic> toJson() => {
        "faqs": faqs,
        "store": store.toJson(),
        "terms": terms,
        "reddit": reddit,
        "discord": discord,
        "privacy": privacy,
        "roadmap": roadmap,
        "twitter": twitter,
        "website": website,
        "facebook": facebook,
        "giveaway": giveaway,
        "instagram": instagram,
        "tutorials": tutorials,
        "contributors": contributors,
        "product_hunt": productHunt,
        "translations": translations,
        "affiliates": affiliates,
      };
}

class ConfigStore {
  const ConfigStore({
    this.apple = '',
    this.amazon = '',
    this.google = '',
    this.huawei = '',
    this.gumroad = '',
    this.samsung = '',
  });

  final String apple;
  final String amazon;
  final String google;
  final String huawei;
  final String gumroad;
  final String samsung;

  factory ConfigStore.fromJson(Map<String, dynamic> json) => ConfigStore(
        apple: json["apple"],
        amazon: json["amazon"],
        google: json["google"],
        huawei: json["huawei"],
        gumroad: json["gumroad"],
        samsung: json["samsung"],
      );

  Map<String, dynamic> toJson() => {
        "apple": apple,
        "amazon": amazon,
        "google": google,
        "huawei": huawei,
        "gumroad": gumroad,
        "samsung": samsung,
      };
}
