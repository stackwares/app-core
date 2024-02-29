import 'dart:io';

import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService extends GetxService with ConsoleMixin {
  static StorageService get to => Get.find();

  // VARIABLES

  // GETTERS
  User? get user => client.auth.currentUser;
  SupabaseClient get client => Supabase.instance.client;

  // FUNCTIONS

  Future<Either<dynamic, String>> upload(
    File file, {
    required String bucket,
    required String path,
  }) async {
    if (user == null) {
      console.warning('not authenticated');
      return const Left('not authenticated');
    }

    // UPDATE PROFILE
    try {
      final response = await client.storage.from(bucket).upload(path, file);
      console.info('response! ${response}');
      return Right(response);
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<dynamic, List<FileObject>>> list(
    File file, {
    required String bucket,
    required String path,
  }) async {
    if (user == null) {
      console.warning('not authenticated');
      return const Left('not authenticated');
    }

    // UPDATE PROFILE
    try {
      final response = await client.storage.from(bucket).list(path: path);
      console.info('files on ${path}: ${response.length}');
      return Right(response);
    } catch (e) {
      return Left('Exception: $e');
    }
  }
}
