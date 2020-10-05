class ContactOutputContainer {
  final String type;
  final String lastClodeLedgerId;
  final int sequenceOfLastLedger;
  dynamic content;

  ContactOutputContainer(
      {this.type,
      this.lastClodeLedgerId,
      this.sequenceOfLastLedger,
      this.content});

  ContactOutputContainer.fromJson(Map<String, dynamic> json)
      : type = json['type'],
        lastClodeLedgerId = json['lcl'],
        sequenceOfLastLedger = json['lcl_seqno'];
}
