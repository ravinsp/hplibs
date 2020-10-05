
class SignedInputContainer {
  final String type;
  List<int> signature;
  List<int> content;
  String signatureJson;
  String contentJson;

  SignedInputContainer(
      {this.type,
      this.signature,
      this.content,
      this.signatureJson,
      this.contentJson});

  Map<String, dynamic> toMap() =>
      {'type': type, 'sig': signature, 'input_container': content};

  Map<String, dynamic> toJson() =>
      {'type': type, 'sig': signatureJson, 'input_container': contentJson};

  SignedInputContainer.fromJson(Map<String, dynamic> json)
      : type = json['type'];
}
