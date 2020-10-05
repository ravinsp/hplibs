class StatusRequest {
  String type;

  StatusRequest({this.type});
  Map<String, dynamic> toMap() => {'type': type};
}

class StatusResponse {
  final String type;
  final String lastClosedLedgerId;
  final int sequence;

  StatusResponse({this.type, this.lastClosedLedgerId, this.sequence});

  StatusResponse.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        lastClosedLedgerId = json['lcl'],
        sequence = json['lcl_seqno'];
}
