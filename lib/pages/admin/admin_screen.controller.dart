import 'dart:async';

import 'package:app_core/supabase/supabase_realtime.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';

class AdminScreenController extends GetxController with ConsoleMixin {
  static AdminScreenController get to => Get.find();

  // VARIABLES
  Timer? timer;

  // PROPERTIES

  // INIT
  @override
  void onClose() {
    timer?.cancel();
    super.onClose();
  }

  @override
  void onInit() {
    RealtimeService.to.channels();

    timer = Timer.periodic(10.seconds, (timer) {
      RealtimeService.to.channels();
    });

    super.onInit();
  }

  // FUNCTIONS

  void reload() {
    RealtimeService.to.channels();
  }
}
