import 'dart:async';
import 'dart:io';

import 'package:app_core/firebase/analytics.service.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:app_core/persistence/persistence.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:launch_at_startup/launch_at_startup.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/pro.controller.dart';

class MainService extends GetxService with ConsoleMixin, WindowListener {
  static MainService get to => Get.find();

  // VARIABLES
  final persistence = Get.find<Persistence>();
  final supabase = Get.find<SupabaseAuthService>();
  final analytics = Get.find<AnalyticsService>();

  DateTime? lastInactiveTime;

  // PROPERTIES
  final dark = true.obs;

  // GETTERS
  WindowManager get window => windowManager;
  bool get isDark => dark.value;

  // INIT

  @override
  void onInit() {
    if (isDesktop) {
      window.addListener(this);
      window.setPreventClose(true);
    }

    _initAppLifeCycleEvents();
    _updateBuildNumber();
    initLaunchAtStartup();
    super.onInit();
  }

  @override
  void onReady() async {
    Persistence.to.sessionCount.val++;
    console.wtf('session count: ${Persistence.to.sessionCount.val}');

    if (isDesktop) {
      window.setBrightness(
        Get.isDarkMode ? Brightness.dark : Brightness.light,
      );
    }

    super.onReady();
  }

  @override
  void onClose() {
    if (isDesktop) {
      window.removeListener(this);
    }

    super.onClose();
  }

  // FUNCTIONS
  void reset() async {
    console.info('resetting...');
    // reset persistence
    await Persistence.reset();
    // invalidate purchases
    ProController.to.invalidate();
    ProController.to.logout();
    console.info('reset!');
  }

  void initLaunchAtStartup() {
    if (!isDesktop) return;

    launchAtStartup.setup(
      appName: ConfigService.to.appName,
      appPath: Platform.resolvedExecutable,
    );

    console.info('initLaunchAtStartup');
  }

  void _initAppLifeCycleEvents() {
    // auto-lock after app is inactive
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      console.warning(msg!);

      if (!timeLockEnabled) {
        console.warning('lifecycle: timeLock is disabled');
        return Future.value(msg);
      }

      final timeLockDuration = persistence.timeLockDuration.val.seconds;

      // RESUMED
      if (msg == AppLifecycleState.resumed.toString()) {
        if (lastInactiveTime == null) return Future.value(msg);

        final expirationTime = lastInactiveTime!.add(timeLockDuration);

        console.wtf(
          'lifecycle: expires in ${DateFormat.yMMMMd().add_jms().format(expirationTime)}',
        );

        // TODO: time lock
        // // expired
        // if (expirationTime.isBefore(DateTime.now())) {
        //   console.wtf('lifecycle: expired time lock');
        //   Get.toNamed(Routes.unlock, parameters: {'mode': 'regular'});
        // }
      }
      // INACTIVE
      else if (msg == AppLifecycleState.inactive.toString()) {
        lastInactiveTime = DateTime.now();

        console.wtf(
          'lifecycle: locking in ${timeLockDuration.inSeconds} seconds of inactivity',
        );
      }

      return Future.value(msg);
    });
  }

  void _updateBuildNumber() async {
    if (isWindowsLinux) return;
    persistence.lastBuildNumber.val = int.parse(metadataApp.buildNumber);
  }

  @override
  void onWindowClose() async {
    bool preventClosing = await window.isPreventClose();

    console.info(
      'minimize: ${persistence.minimizeToTray.val}, preventClosing: $preventClosing',
    );

    if (persistence.minimizeToTray.val) {
      window.minimize();
    } else {
      window.destroy();
    }

    super.onWindowClose();
  }

  @override
  void onWindowResized() async {
    final size = await window.getSize();
    persistence.windowWidth.val = size.width;
    persistence.windowHeight.val = size.height;
    console.warning('window resized: $size');
    super.onWindowResized();
  }
}
