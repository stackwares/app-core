import 'package:get/get.dart';

class License {
  const License({
    this.data = const {},
    this.trial = true,
    this.source = '',
    this.updatedAt,
    this.entitlementId = '',
    this.licenseKey = '',
  });

  final Map<String, dynamic> data;
  final bool trial;
  final String source;
  final DateTime? updatedAt;
  final String entitlementId;
  final String licenseKey;

  factory License.fromJson(Map<String, dynamic> json) => License(
        data: json["data"],
        trial: json["trial"],
        source: json["source"],
        updatedAt: DateTime.tryParse(json["updated_at"] ?? ''),
        entitlementId: json["entitlementId"],
        licenseKey: json["licenseKey"],
      );

  Map<String, dynamic> toJson() => {
        "data": data,
        "trial": trial,
        "source": source,
        "updated_at": updatedAt?.toIso8601String(),
        "entitlementId": entitlementId,
        "licenseKey": licenseKey,
      };

  License copyWith({
    Map<String, dynamic>? data,
    bool? trial,
    String? source,
    DateTime? updatedAt,
    String? entitlementId,
    String? licenseKey,
  }) {
    return License(
      data: data ?? this.data,
      trial: trial ?? this.trial,
      source: source ?? this.source,
      updatedAt: updatedAt ?? this.updatedAt,
      entitlementId: entitlementId ?? this.entitlementId,
      licenseKey: licenseKey ?? this.licenseKey,
    );
  }

  String get key {
    if (licenseKey.isEmpty) return 'update'.tr;
    return '${licenseKey.substring(0, 10)}...';
  }
}
