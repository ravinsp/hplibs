import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:bson/bson.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_sodium/flutter_sodium.dart';
import 'package:hotpocket_client_lib/models/challenge.dart';
import 'package:hotpocket_client_lib/models/constants.dart';
import 'package:hotpocket_client_lib/models/contract_input_container.dart';
import 'package:hotpocket_client_lib/models/contract_output_container.dart';
import 'package:hotpocket_client_lib/models/contract_read_request.dart';
import 'package:hotpocket_client_lib/models/contract_read_response.dart';
import 'package:hotpocket_client_lib/models/hotpocket_request.dart';
import 'package:hotpocket_client_lib/models/hp_error.dart';
import 'package:hotpocket_client_lib/models/hp_keypair.dart';
import 'package:hotpocket_client_lib/models/request_result.dart';
import 'package:hotpocket_client_lib/models/response.dart';
import 'package:hotpocket_client_lib/models/signed_input_container.dart';
import 'package:hotpocket_client_lib/models/status.dart';
import 'package:hotpocket_client_lib/services/service_locator.dart';
import 'package:hotpocket_client_lib/utility/hp_msg_helper.dart';
import 'package:web_socket_channel/io.dart';
import 'package:convert/convert.dart';

class HotPocketWrapper {
  String _serverAddress;
  HPKeypair _keys;
  String _protocol;
  IOWebSocketChannel channel;
  Function messageListener;
  static final _eventBus = locator<EventBus>();
  static final _bson = locator<BSON>();
  bool isHotPocketConnected = false;
  bool _publicChallengeVerified = false;

  List<HotPocketRequest> pendingRequests = new List<HotPocketRequest>();

  HotPocketWrapper(String server, HPKeypair keys, String protocol) {
    this._serverAddress = server;
    _keys = keys;
    _protocol = protocol;
  }

  connect() async {
    if (channel == null &&
        _serverAddress != null &&
        _serverAddress.trim() != "" &&
        !isHotPocketConnected) {
      channel = new IOWebSocketChannel.connect(_serverAddress);
      channel.stream.listen(_onMessage, onDone: _onDone);

      while (!isHotPocketConnected && channel != null) {
        await new Future.delayed(const Duration(milliseconds: 100));
      }
    }
    return isHotPocketConnected;
  }

  close({bool force = true}) async {
    if (force && channel != null && channel.sink != null) {
      await channel.sink.close();
      channel = null;
      isHotPocketConnected = false;
      _publicChallengeVerified = false;
    }
  }

  _onDone() async {
    await close(force: false);
    channel = null;
    isHotPocketConnected = false;
    _publicChallengeVerified = false;
  }

  send<T>(T message) {
    if (channel != null && channel.sink != null) {
      channel.sink.add(message);
    }
  }

  Future<Response> queueRequest(HotPocketRequest request) async {
    pendingRequests.add(request);
    return request.onResponse;
  }

  _onMessage(msg) async {
    HotPocketRequest request;
    final decryptedMsg = (!_publicChallengeVerified)
        ? HotPocketMessageHelper.deserialize(msg, Protocols.JSON)
        : HotPocketMessageHelper.deserialize(msg, _protocol);

    switch (decryptedMsg['type']) {
      case HotPocketTypes.HandshakeChallenge:
        var challengeMsg = ChallengeMesssage.fromJson(decryptedMsg);
        await _handlePublicChallenge(challengeMsg.challenge);
        break;
      case HotPocketTypes.ContractOutput:
        var output = ContactOutputContainer.fromJson(decryptedMsg);

        if (_protocol == Protocols.BSON)
          output.content = decryptedMsg['content'].byteList;
        else
          output.content = utf8.decode(hex.decode(decryptedMsg['content']));

        _eventBus.fire(output);
        break;
      case HotPocketTypes.ContractReadResponse:
        var output = ContractReadResponse.fromJson(decryptedMsg);

        if (_protocol == Protocols.BSON)
          output.content = decryptedMsg['content'].byteList;
        else
          output.content = utf8.decode(hex.decode(decryptedMsg['content']));

        _eventBus.fire(output);
        break;
      case HotPocketTypes.ContractInputStatus:
        var result = RequestResult.fromJson(decryptedMsg);

        if (_protocol == Protocols.BSON)
          result.inputSignature =
              hex.encode(decryptedMsg['input_sig'].byteList);
        else
          result.inputSignature = decryptedMsg['input_sig'];

        request = pendingRequests.firstWhere(
            (req) => req.message.signatureJson == result.inputSignature);

        if (request != null) {
          pendingRequests.remove(request);
          if (result.status == 'accepted') {
            request.response = Response(status: 'success');
          } else {
            request.response = Response(status: 'failure');
          }
          request.response.message = result;
        }
        break;
      case HotPocketTypes.StatusResponse:
        var status = StatusResponse.fromJson(decryptedMsg);

        request = pendingRequests.firstWhere(
            (req) => req.requestType == HotPocketRequestTypes.GetStatus);

        if (request != null) {
          pendingRequests.remove(request);
          request.response = Response(status: 'success');
          request.response.message = status;
        }
        break;
      default:
        break;
    }

    if (request != null) request.handleResponse(true);
  }

  _handlePublicChallenge(String challenge) async {
    try {
      var signedChallenge =
          Sodium.cryptoSignDetached(utf8.encode(challenge), _keys.secretKey);
      var challengeResponse = ChallengeResponse();
      challengeResponse.type = HotPocketTypes.HandshakeResponse;
      challengeResponse.challenge = challenge;
      challengeResponse.sig = hex.encode(signedChallenge);
      challengeResponse.pubkey = 'ed' + hex.encode(_keys.publicKey);
      challengeResponse.protocol = _protocol;
      await send(HotPocketMessageHelper.serialize(
          challengeResponse, Protocols.JSON));
      _publicChallengeVerified = true;
      isHotPocketConnected = true;
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<Response> getLedgerStatus() {
    HotPocketRequest req = HotPocketRequest(
        requestType: HotPocketRequestTypes.GetStatus, onTimeout: _onTimeout);
    req.message = StatusRequest(type: HotPocketTypes.Status);

    send(HotPocketMessageHelper.serialize(req.message.toMap(), _protocol));

    return queueRequest(req);
  }

  void createReadRequest(List<int> request) {
    var contractReadRequest = ContractReadRequest(
            HotPocketTypes.ContractReadRequest,
            (_protocol == Protocols.BSON ? request : hex.encode(request)))
        .toMap();
    send(HotPocketMessageHelper.serialize(contractReadRequest, _protocol));
  }

  Future<SignedInputContainer> createSignedInputContainer(
      String nonce, List<int> input, int maxSequence) async {
    var content = new ContractInputContainer(
            nonce,
            _protocol == Protocols.BSON ? input : hex.encode(input),
            maxSequence)
        .toMap();

    List<int> contentBuffer;
    if (_protocol == Protocols.BSON) {
      var contentBson = _bson.serialize(content);
      contentBson.rewind();
      contentBuffer = contentBson.byteList;
    }
    else{
      contentBuffer = utf8.encode(json.encode(content));
    }

    //var contentBuffer = _bson.serialize(content);
    //contentBuffer.rewind();

    var signature = Sodium.cryptoSignDetached(
        Uint8List.fromList(contentBuffer), _keys.secretKey);

    if (_protocol == Protocols.BSON) {
      return new SignedInputContainer(
          type: HotPocketTypes.ContractInput,
          signature: List.from(signature),
          signatureJson: hex.encode(List.from(signature)),
          content: contentBuffer);
    } else {
      return new SignedInputContainer(
          type: HotPocketTypes.ContractInput,
          signatureJson: hex.encode(List.from(signature)),
          contentJson: hex.encode(contentBuffer));
    }
  }

  Future<Response> sendInput(SignedInputContainer contractInput) {
    HotPocketRequest req = HotPocketRequest(
        requestType: HotPocketRequestTypes.CreateContractRequest,
        onTimeout: _onTimeout);
    send(HotPocketMessageHelper.serialize(
        _protocol == Protocols.BSON
            ? contractInput.toMap()
            : contractInput.toJson(),
        _protocol));
    contractInput.content = null;
    contractInput.signature = null;
    contractInput.contentJson = null;
    req.message = contractInput;

    return queueRequest(req);
  }

  Future<Response> _onTimeout(HotPocketRequest request) {
    pendingRequests.clear();

    final response = Response(status: 'error');
    final error = HotPocketError(errorCode: 'timeout', errorMessage: 'Timeout');
    response.message = error;
    final completer = Completer<Response>();
    completer.complete(response);
    return completer.future;
  }
}
