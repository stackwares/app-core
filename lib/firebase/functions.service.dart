import 'package:cloud_functions/cloud_functions.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';

class FirebaseFunctionsService extends GetxService with ConsoleMixin {
  static FirebaseFunctionsService get to => Get.find();

  // VARIABLES

  // PROPERTIES

  // GETTERS
  FirebaseFunctions get instance => FirebaseFunctions.instance;

  // INIT

  // FUNCTIONS

  Future<Either<String, String>> getRemoteConfig() async {
    console.debug('fetching...');
    HttpsCallableResult? result;

    try {
      result = await instance.httpsCallable('getRemoteConfig').call();
    } on FirebaseFunctionsException catch (e) {
      return Left('error fetching remote config: $e');
    }

    // console.wtf('response: ${result.data}');

    if (result.data == false) {
      return const Left('failed to fetch remote config');
    }

    return Right(result.data);
  }
}
