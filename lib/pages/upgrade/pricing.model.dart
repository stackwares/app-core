class Pricing {
  Pricing({
    this.id = '',
    this.primaryFeature = '',
    this.features = const [],
    this.upcomingFeatures = const [],
  });

  final String id;
  final String primaryFeature;
  final List<String> features;
  final List<String> upcomingFeatures;

  factory Pricing.fromJson(Map<String, dynamic> json) => Pricing(
        id: json["id"],
        primaryFeature: json["primary_feature"],
        features: List<String>.from(json["features"].map((x) => x)),
        upcomingFeatures:
            List<String>.from(json["upcoming_features"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "primary_feature": primaryFeature,
        "features": List<dynamic>.from(features.map((x) => x)),
        "upcoming_features": List<dynamic>.from(upcomingFeatures.map((x) => x)),
      };
}
