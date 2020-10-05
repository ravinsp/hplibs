class ContractReadRequest {
  final String type;
  final dynamic content;

  ContractReadRequest(this.type, this.content);

  Map<String, dynamic> toMap() =>
      {'type': type, 'content': content};
}
