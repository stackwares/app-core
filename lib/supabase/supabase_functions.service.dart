import 'dart:convert';

import 'package:app_core/config.dart';
import 'package:app_core/controllers/pro.controller.dart';
import 'package:app_core/firebase/config/config.service.dart';
import 'package:app_core/globals.dart';
import 'package:console_mixin/console_mixin.dart';
import 'package:either_dart/either.dart';
import 'package:get/get.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'model/entitlement_response.model.dart';
import 'model/gumroad_product.model.dart';
import 'model/server_response.model.dart';
import 'model/sync_user_response.model.dart';

class SupabaseFunctionsService extends GetxService with ConsoleMixin {
  static SupabaseFunctionsService get to => Get.find();

  // VARIABLES
  final config = Get.find<ConfigService>();
  int sessionId = 0;

  // GETTERS
  User? get user => Supabase.instance.client.auth.currentUser;
  FunctionsClient get functions => Supabase.instance.client.functions;

  // INIT

  // FUNCTIONS

  Future<void> sync({Map<String, dynamic> data = const {}}) async {
    if (user == null) return console.warning('not authenticated');
    console.info('sync...');

    // enforce auth to be logged in
    if (isIAPSupported &&
        await Purchases.isAnonymous &&
        !CoreConfig().allowAnonymousRcUserSync) {
      return console.info('ignored anonymous user sync');
    }

    final response = await functions.invoke(
      'sync-user',
      body: {
        if (isIAPSupported) ...{
          "rcUserId": await Purchases.appUserID,
        },
        "email": user?.email,
        "phone": user?.phone,
        "userMetadata": user?.userMetadata,
        "device": metadataDevice.toJson(),
      }..addAll(data),
    );

    if (response.status != 200) {
      return console.error(
        'supabase error: ${response.status}: ${response.data}',
      );
    }

    final serverResponse = ServerResponse.fromJson(response.data);

    if (serverResponse.errors.isNotEmpty) {
      return console.error('server error: ${serverResponse.errors}');
    }

    console.wtf('synced: ${jsonEncode(serverResponse.toJson())}');
    final syncUserResponse = SyncUserResponse.fromJson(serverResponse.data);
    ProController.to.licenseKey.value = syncUserResponse.licenseKey;
    sessionId = syncUserResponse.sessionId;

    // VERIFY PRO
    if (ProController.to.proEntitlement?.isActive != true) {
      if (syncUserResponse.licenseKey.length >= 35) {
        verifyGumroad(syncUserResponse.licenseKey);
      } else if (syncUserResponse.rcUserId.isNotEmpty && !isIAPSupported) {
        verifyRevenueCat(syncUserResponse.rcUserId);
      } else {
        ProController.to.verifiedPro.value = false;
      }
    }
  }

  Future<Either<String, GumroadProduct>> gumroadProductDetail() async {
    console.info('gumroadProductDetail...');

    final response = await functions.invoke(
      'gumroad-product-detail',
      body: {"localeCode": Get.locale?.languageCode},
    );

    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    final serverResponse = ServerResponse.fromJson(response.data);

    if (serverResponse.errors.isNotEmpty) {
      String errors = '';

      for (var e in serverResponse.errors) {
        errors += '${e.code}: ${e.message}';
      }

      console.error('server error: $errors');
      return Left(errors);
    }

    // console.debug('product: ${jsonEncode(serverResponse.data)}');
    final product = GumroadProduct.fromJson(serverResponse.data);
    return Right(product);
  }

  Future<Either<String, EntitlementResponse>> verifyGumroad(String licenseKey,
      {bool updateEntitlement = true}) async {
    if (user == null) {
      console.warning('not authenticated');
      return const Left('Please sign in to continue');
    }

    console.info('verifyGumroad...');

    final response = await functions.invoke(
      'verify-gumroad',
      body: {"licenseKey": licenseKey},
    );

    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    final serverResponse = ServerResponse.fromJson(response.data);

    if (serverResponse.errors.isNotEmpty) {
      String errors = '';

      for (var e in serverResponse.errors) {
        errors += '${e.code}: ${e.message}';
      }

      console.error('server error: $errors');
      ProController.to.verifiedPro.value = false;
      return Left(errors);
    }

    final entitlement = EntitlementResponse.fromJson(serverResponse.data);
    console.info('entitlement: ${jsonEncode(entitlement.toJson())}');

    if (updateEntitlement) {
      ProController.to.verifiedPro.value = entitlement.entitled;
      if (entitlement.entitled) console.wtf('PRO ENTITLED');
    }

    return Right(entitlement);
  }

  Future<Either<String, EntitlementResponse>> verifyRevenueCat(String rcUserId,
      {bool updateEntitlement = true}) async {
    if (user == null) {
      console.warning('not authenticated');
      return const Left('Please sign in to continue');
    }

    console.info('verifyRevenueCat...');

    final response = await functions.invoke(
      'verify-revenuecat',
      body: {"userId": rcUserId},
    );

    if (response.status != 200) {
      return Left('supabase error: ${response.status}: ${response.data}');
    }

    final serverResponse = ServerResponse.fromJson(response.data);

    if (serverResponse.errors.isNotEmpty) {
      String errors = '';

      for (var e in serverResponse.errors) {
        errors += '${e.code}: ${e.message}';
      }

      console.error('server error: $errors');
      ProController.to.verifiedPro.value = false;
      return Left(errors);
    }

    final entitlement = EntitlementResponse.fromJson(serverResponse.data);
    console.wtf('entitlement: ${jsonEncode(entitlement.toJson())}');

    if (updateEntitlement) {
      ProController.to.verifiedPro.value = entitlement.entitled;
      if (entitlement.entitled) console.wtf('PRO ENTITLED');
    }

    return Right(entitlement);
  }
}
