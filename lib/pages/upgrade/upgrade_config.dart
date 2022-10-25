import 'package:flutter/material.dart';

class UpgradeConfig {
  final List<String> features;
  final List<String> upcomingFeatures;
  final BoxDecoration darkDecoration;

  const UpgradeConfig({
    required this.features,
    required this.upcomingFeatures,
    required this.darkDecoration,
  });
}
