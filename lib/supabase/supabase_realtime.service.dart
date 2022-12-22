import 'package:app_core/globals.dart';
import 'package:app_core/license/license.service.dart';
import 'package:app_core/supabase/model/user_presence.model.dart';
import 'package:app_core/supabase/supabase_auth.service.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/utils.dart';

class RealtimeService extends GetxService with ConsoleMixin {
  static RealtimeService get to => Get.find();

  // VARIABLES
  RealtimeChannel? channel;

  // PROPERTIES
  final data = <UserPresence>[].obs;

  // GETTERS

  // INIT
  @override
  void onInit() {
    init();
    super.onInit();
  }

  // FUNCTIONS

  void init() async {
    channel = Supabase.instance.client.channel('online_users');

    channel!.on(
      RealtimeListenTypes.broadcast,
      ChannelFilter(event: 'broadcast'),
      (payload, [ref]) {
        console.debug('event broadcast: $payload -> $ref');
      },
    );

    channel!.on(
      RealtimeListenTypes.presence,
      ChannelFilter(event: 'online_users'),
      (payload, [ref]) {
        console.debug('event presence: $payload -> $ref');
      },
    );

    // subscribe to the above changes
    channel!.subscribe(
      (status, [value]) {
        console.debug('subscribe: $status -> $value');
        if (status == 'SUBSCRIBED') track();
      },
    );

    console.wtf('init');
  }

  Future<void> deinit() async {
    final response = await channel?.unsubscribe();
    console.wtf('unsubscribe: $response');
  }

  void channels() async {
    data.clear();

    final channels = Supabase.instance.client.getChannels();
    console.wtf('channels: ${channels.length}');

    for (var x in channels) {
      console.info('topic: ${x.topic}');

      for (var y in x.presence.state.entries) {
        // console.info('states: ${y.key} -> ${y.value.length}}');

        for (var z in y.value) {
          // console.warning(
          //   'presence: ${z.presenceRef} -> ${jsonEncode(z.payload)}}',
          // );

          try {
            data.add(UserPresence.fromJson(z.payload));
          } catch (e) {
            console.debug('error: $e');
          }
        }
      }
    }
  }

  void track({Map<String, dynamic> extra = const {}}) async {
    final Map<String, dynamic> data = {
      'id': AuthService.to.user?.id,
      'email': AuthService.to.user?.email,
      'plan': LicenseService.to.id,
      'locale': Get.locale?.languageCode ?? 'none',
      'country': Get.locale?.countryCode ?? 'none',
      'theme': Get.isDarkMode ? 'Dark' : 'Light',
      'platform': Utils.platform,
      'device_type': Utils.deviceType,
      'version': metadataApp.formattedVersion,
    }..addAll(extra);

    final response = await channel!.track(data);
    console.wtf('track: $response');
  }

  void broadcast() async {
    final response = await channel!.send(
      type: RealtimeListenTypes.broadcast,
      event: 'broadcast',
      payload: {'key': 'broadcast value'},
    );

    console.wtf('broadcast: $response');

    final response2 = await channel!.send(
      type: RealtimeListenTypes.presence,
      event: 'presence',
      payload: {'key': 'presence value'},
    );

    console.wtf('broadcast: $response2');
  }
}
