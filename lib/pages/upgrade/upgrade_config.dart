import 'pricing.model.dart';

class UpgradeConfig {
  final bool grouped;
  final double listViewHeight;
  final Map<String, Pricing> pricing;

  const UpgradeConfig({
    this.listViewHeight = 200,
    this.grouped = true,
    required this.pricing,
  });
}
