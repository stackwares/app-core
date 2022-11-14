import 'package:app_core/supabase/model/profile.model.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseDBService extends GetxService with ConsoleMixin {
  static SupabaseDBService get to => Get.find();

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

      console.info('Upsert success! $response');

      if (response.isEmpty) {
        return const Left('Upsert Profile Error: empty data response');
      }

      final profile = SupabaseProfile.fromJson(response.first);
      return Right(profile);
    } catch (e) {
      return Left('Upsert Exception: $e');
    }
  }
}
