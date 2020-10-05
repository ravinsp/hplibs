class ContractReadResponse {
  final String type;
  dynamic content;

  ContractReadResponse(this.type, this.content);

  ContractReadResponse.fromJson(Map<String, dynamic> json)
      : type = json['type'];
}
