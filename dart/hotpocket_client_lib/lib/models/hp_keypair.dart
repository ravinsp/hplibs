import 'dart:typed_data';

class HPKeypair {
  final Uint8List secretKey;
  final Uint8List publicKey;

  HPKeypair(this.secretKey, this.publicKey);

  HPKeypair.fromJson(Map<String, Uint8List> json)
      : secretKey = json['secretKey'],
        publicKey = json['publicKey'];

  Map<String, dynamic> toJson() =>
      {'secretKey': secretKey, 'publicKey': publicKey};
}