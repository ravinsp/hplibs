
class RequestResult {
  final String type;
  final String status;
  final String reason;
  String inputSignature;

  RequestResult({this.type, this.status, this.reason, this.inputSignature});

  RequestResult.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        status = json['status'],
        reason = json['reason'];
}
