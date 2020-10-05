class ChallengeMesssage {
  final String version;
  final String type;
  final String challenge;

  ChallengeMesssage({this.version, this.type, this.challenge});

  ChallengeMesssage.fromJson(Map<String, dynamic> json)
      : version = json['version'],
        type = json['type'],
        challenge = json['challenge'];
}

class ChallengeResponse {
  String type;
  String challenge;
  String sig;
  String pubkey;
  String protocol;

  ChallengeResponse({this.type, this.challenge, this.sig, this.pubkey, this.protocol});

  Map<String, dynamic> toJson() => {
        'type': type,
        'challenge': challenge,
        'sig': sig,
        'pubkey': pubkey,
        'protocol': protocol
      };
}
