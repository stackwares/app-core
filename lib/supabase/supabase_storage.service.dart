import 'dart:typed_data';

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
  SupabaseStorageClient get storage => client.storage;

  // FUNCTIONS

  Future<Either<dynamic, String>> upload(
    Uint8List bytes, {
    required String bucket,
    required String path,
  }) async {
    if (user == null) {
      console.warning('not authenticated');
      return const Left('not authenticated');
    }

    final api = storage.from(bucket);

    try {
      final resourcePath = await api.uploadBinary(
        path,
        bytes,
        fileOptions: FileOptions(upsert: true),
      );

      return Right(resourcePath);
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<dynamic, bool>> clean(
    String path, {
    required String bucket,
  }) async {
    if (user == null) {
      console.warning('not authenticated');
      return const Left('not authenticated');
    }

    bool success = false;
    final listResult = await list(path, bucket: bucket);

    await listResult.fold(
      (left) async => console.error('error: $left'),
      (right) async {
        console.info('removing: ${right.length} files');
        if (right.isEmpty) return;

        final filePaths = right.map((e) => '$path${e.name}').toList();
        final r = await remove(filePaths, bucket: bucket);

        r.fold(
          (left) => console.error('error removing: $left'),
          (right) => console.info('success removing: ${filePaths}'),
        );
      },
    );

    return Right(success);
  }

  Future<Either<dynamic, List<FileObject>>> list(
    String path, {
    required String bucket,
  }) async {
    if (user == null) {
      console.warning('not authenticated');
      return const Left('not authenticated');
    }

    try {
      final response = await storage.from(bucket).list(path: path);
      return Right(response);
    } catch (e) {
      return Left('Exception: $e');
    }
  }

  Future<Either<dynamic, List<FileObject>>> remove(
    List<String> filePaths, {
    required String bucket,
  }) async {
    if (user == null) {
      console.warning('not authenticated');
      return const Left('not authenticated');
    }

    try {
      final response = await storage.from(bucket).remove(filePaths);
      console.info('removed: ${response.map((e) => e.name)}');
      return Right(response);
    } catch (e) {
      return Left('Exception: $e');
    }
  }
}
