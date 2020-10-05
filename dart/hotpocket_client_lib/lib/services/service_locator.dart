import 'dart:math';

import 'package:bson/bson.dart';
import 'package:event_bus/event_bus.dart';
import 'package:get_it/get_it.dart';
import 'package:hotpocket_client_lib/models/constants.dart';
import 'package:hotpocket_client_lib/models/hp_keypair.dart';
import 'package:hotpocket_client_lib/services/hp_wrapper.dart';
import 'package:hotpocket_client_lib/services/secure_storage_service.dart';
import 'package:hotpocket_client_lib/utility/hp_key_generator.dart';

GetIt locator = GetIt.instance;

setupServiceLocator(List<String> hpNodes,
    {String protocol = Protocols.BSON}) async {
  locator.registerLazySingleton<SecureStorageService>(
      () => SecureStorageService());
  locator.registerLazySingleton<EventBus>(() => EventBus());
  locator.registerLazySingleton<BSON>(() => BSON());

  HPKeypair keys = await HotPocketKeyGenerator.generate();
  locator.registerLazySingleton<HotPocketWrapper>(() => HotPocketWrapper(
      hpNodes[Random().nextInt(hpNodes.length)], keys, protocol));
}
