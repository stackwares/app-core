class ConfigLimits {
  const ConfigLimits({
    this.free = const ConfigLimitsTier(),
    this.pro = const ConfigLimitsTier(),
  });

  final ConfigLimitsTier free;
  final ConfigLimitsTier pro;

  factory ConfigLimits.fromJson(Map<String, dynamic> json) => ConfigLimits(
        free: ConfigLimitsTier.fromJson(json["free"]),
        pro: ConfigLimitsTier.fromJson(json["pro"]),
      );

  Map<String, dynamic> toJson() => {
        "free": free.toJson(),
        "pro": pro.toJson(),
      };
}

class ConfigLimitsTier {
  const ConfigLimitsTier({
    this.id = '',
    this.storageSize = 0,
    this.uploadSize = 0,
    this.items = 0,
    this.devices = 0,
  });

  final String id;
  final int storageSize;
  final int uploadSize;
  final int items;
  final int devices;

  factory ConfigLimitsTier.fromJson(Map<String, dynamic> json) =>
      ConfigLimitsTier(
        id: json["id"],
        storageSize: json["storage_size"],
        uploadSize: json["upload_size"],
        items: json["items"],
        devices: json["devices"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "storage_size": storageSize,
        "upload_size": uploadSize,
        "items": items,
        "devices": devices,
      };
}
