import 'package:app_core/supabase/model/profile.model.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/utils.dart';
import 'model/config_response.model.dart';

class DatabaseService extends GetxService with ConsoleMixin {
  static DatabaseService get to => Get.find();

  // VARIABLES

  // GETTERS
  User? get user => client.auth.currentUser;
  SupabaseClient get client => Supabase.instance.client;

  // FUNCTIONS

  Future<Either<dynamic, SupabaseProfile>> updateLicenseKey(String key) async {
    if (user == null) {
      console.warning('not authenticated');
      return const Left('not authenticated');
    }

    // UPDATE PROFILE
    try {
      final response = await client.from('profiles').upsert(
        {
          'id': user!.id,
          'gumroad_license_key': key,
          'updated_at': 'now()',
        },
      ).select();

      console.info('response! $response');

      if (response.isEmpty) {
        return const Left('Error: empty data response');
      }

      final profile = SupabaseProfile.fromJson(response.first);
      return Right(profile);
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<dynamic, ConfigResponse>> configuration() async {
    // if (user == null) {
    //   console.warning('not authenticated');
    //   return const Left('not authenticated');
    // }

    // UPDATE PROFILE
    try {
      var response = await client.from('configuration').select().eq(
            'platform',
            Utils.platform.toLowerCase(),
          );

      // console.info('platform response! ${jsonEncode(response)}');

      if (response.isEmpty) {
        response = await client.from('configuration').select().eq(
              'platform',
              'all',
            );

        // console.info('all response! ${jsonEncode(response)}');

        if (response.isEmpty) {
          return const Left('Error: empty all platform configuration');
        }
      }

      final config = ConfigResponse.fromJson(response.first);
      return Right(config);
    } catch (e) {
      return Left('Exception: $e');
    }
  }
}
