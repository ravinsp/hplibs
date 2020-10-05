import 'dart:typed_data';

import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:hotpocket_client_lib/models/constants.dart';
import 'package:hotpocket_client_lib/models/hp_keypair.dart';
import 'package:hotpocket_client_lib/services/secure_storage_service.dart';
import 'package:hotpocket_client_lib/services/service_locator.dart';

class HotPocketKeyGenerator {
  static final _secureStorage = locator<SecureStorageService>();

    static Future<HPKeypair> generate() async {
    var storedKeypair = await _secureStorage.read(Keys.hpKeys);

    if (storedKeypair != null) {
      var privateKey = new List<int>.from(storedKeypair['secretKey']);
      var publicKey = new List<int>.from(storedKeypair['publicKey']);
      return HPKeypair(
          Uint8List.fromList(privateKey), Uint8List.fromList(publicKey));
    } else {
      var keyPair = Sodium.cryptoSignKeypair();
      var hpKeys = HPKeypair(keyPair.sk, keyPair.pk);
      _secureStorage.write(Keys.hpKeys, hpKeys);
      return hpKeys;
    }
  }
}
