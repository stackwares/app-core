import 'package:app_core/config/app.model.dart';

class ConfigResponse {
  ConfigResponse({
    this.id = 0,
    this.app = const AppConfig(),
    this.license = const {},
    this.extra = const {},
    this.updatedAt,
    this.createdAt,
    this.platform = '',
  });

  final int id;
  final AppConfig app;
  final Map<String, dynamic> license;
  final Map<String, dynamic> extra;
  final DateTime? updatedAt;
  final DateTime? createdAt;
  final String platform;

  factory ConfigResponse.fromJson(Map<String, dynamic> json) => ConfigResponse(
        id: json["id"],
        app: AppConfig.fromJson(json["app"]),
        license: json["license"],
        extra: json["extra"],
        updatedAt: json["updated_at"],
        createdAt: DateTime.parse(json["created_at"]),
        platform: json["platform"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "app": app.toJson(),
        "license": license,
        "extra": extra,
        "updated_at": updatedAt?.toIso8601String(),
        "created_at": createdAt?.toIso8601String(),
        "platform": platform,
      };
}
