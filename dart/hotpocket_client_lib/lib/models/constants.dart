class Protocols {
  static const String JSON = 'json';
  static const String BSON = 'bson';
}

class RoutePaths {
  static const String HomePage = '/home';
}

class Keys {
  static const String hpKeys = 'HotPocketKeys';
}

class HotPocketTypes {
  static const String HandshakeChallenge = 'handshake_challenge';
  static const String HandshakeResponse = 'handshake_response';
  static const String ContractInput = 'contract_input';
  static const String ContractInputStatus = 'contract_input_status';
  static const String ContractOutput = 'contract_output';
  static const String ContractReadRequest = 'contract_read_request';
  static const String ContractReadResponse = 'contract_read_response';
  static const String Status = 'stat';
  static const String StatusResponse = 'stat_response';
}

enum HotPocketRequestTypes {
  GetStatus,
  CreateContractRequest,
  CreateReadRequest
}