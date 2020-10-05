import 'dart:async';

import 'package:hotpocket_client_lib/models/response.dart';

import 'constants.dart';


class HotPocketRequest {
  final HotPocketRequestTypes requestType;
  dynamic message;
  Response response;
  Function onTimeout;

  Completer _completer;
  // Set a future and timeout for it
  Future<Response> get onResponse =>
      _completer.future.timeout(const Duration(seconds: 180),
          onTimeout: () => onTimeout(this) as Future<Response>);

  HotPocketRequest({this.requestType, this.onTimeout}) {
    _completer = new Completer<Response>();
  }

  void handleResponse(bool successful) {
    if (successful) {
      _completer.complete(response);
    } else {
      _completer.completeError(response);
    }
  }
}
