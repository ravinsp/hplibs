library hotpocket_client_lib;

import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:hotpocket_client_lib/models/constants.dart';
import 'package:hotpocket_client_lib/models/contract_output_container.dart';
import 'package:hotpocket_client_lib/models/contract_read_response.dart';
import 'package:hotpocket_client_lib/models/request_result.dart';
import 'package:hotpocket_client_lib/models/response.dart';
import 'package:hotpocket_client_lib/models/status.dart';
import 'package:hotpocket_client_lib/services/hp_wrapper.dart';
import 'package:hotpocket_client_lib/services/service_locator.dart';

class HotPocketClient {
  static final _hpClient = locator<HotPocketWrapper>();
  static final _eventBus = locator<EventBus>();
  static StreamSubscription subscription;
  static void Function(List<int>) contractOutputCallBack;
  static void Function(List<int>) contractReadResponseCallBack;
  static void Function(String) contractOutputCallBackJson;
  static void Function(String) contractReadResponseCallBackJson;

  static void listenForContractOutput({Function(dynamic) callback}) {
    if (subscription != null) {
      subscription.cancel();
    }
    subscription = _eventBus.on<ContactOutputContainer>().listen((output) {
      if (output.content.runtimeType != String)
        contractOutputCallBack = callback(output.content);
      else
        contractOutputCallBackJson = callback(output.content);
    });
  }

  static void listenForContractReadResponse({Function(dynamic) callback}) {
    if (subscription != null) {
      subscription.cancel();
    }
    subscription = _eventBus.on<ContractReadResponse>().listen((output) {
      if (output.content.runtimeType != String)
        contractReadResponseCallBack = callback(output.content);
      else
        contractReadResponseCallBackJson = callback(output.content);
    });
  }

  static Future<StatusResponse> getLedgerStatus() async {
    StatusResponse response;
    try {
      await _hpClient.getLedgerStatus().then((Response resp) async {
        if (resp.successful) {
          response = resp.message as StatusResponse;
        } else {
          response = null;
        }
      });
    } on Exception {
      response = null;
    }
    return response;
  }

  static Future<RequestResult> sendContractInput(List<int> input) async {
    RequestResult result;
    try {
      var status = await getLedgerStatus();
      if (status != null) {
        var container = await _hpClient.createSignedInputContainer(
            new DateTime.now().millisecondsSinceEpoch.toString(),
            input,
            (status.sequence + 20));
        if (container != null) {
          await _hpClient.sendInput(container).then((Response resp) async {
            if (resp.successful) {
              result = resp.message as RequestResult;
            } else {
              result = null;
            }
          });
        }
      }
    } on Exception {
      result = null;
    }
    return result;
  }

  static void sendContractReadRequest(List<int> input) async {
    _hpClient.createReadRequest(input);
  }

  static Future<bool> connect() async {
    return await _hpClient.connect();
  }

  static Future<void> disconnect() async {
    return await _hpClient.close();
  }

  static Future<void> init(List<String> hpNodes,
      {String protocol = Protocols.BSON}) async {
    setupServiceLocator(hpNodes, protocol: protocol);
  }
}
