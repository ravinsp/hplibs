import 'dart:convert';

import 'package:bson/bson.dart';
import 'package:hotpocket_client_lib/models/constants.dart';
import 'package:hotpocket_client_lib/services/service_locator.dart';

class HotPocketMessageHelper {
  static final _bson = locator<BSON>();

  static serialize<T>(T obj, String protocol) {
    if (protocol == Protocols.JSON) {
      return jsonEncode(obj);
    } else {
      var buffer = _bson.serialize(obj);
      buffer.rewind();
      return buffer.byteList;
    }
  }

  static deserialize(dynamic msg, String protocol) {
    if (protocol == Protocols.JSON) {
      return json.decode(utf8.decode(msg));
    } else {
      return _bson.deserialize(BsonBinary.from(msg));
    }
  }
}
