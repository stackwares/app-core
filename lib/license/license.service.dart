import 'package:app_core/license/model/license.model.dart';
import 'package:get/get.dart';

class LicenseService extends GetxService {
  static LicenseService get to => Get.find();

  // VARIABLES

  // PROPERTIES
  final license = const License().obs;

  // GETTERS
  bool get isPremium => isReady && id != 'free';
  bool get isReady => id.isNotEmpty;
  String get id => license.value.entitlementId;
}
