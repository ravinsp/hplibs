
class ContractInputContainer {
  final String nonce;
  final int maxLedgerSeqNo;
  final dynamic input;

  ContractInputContainer(this.nonce, this.input, this.maxLedgerSeqNo);

  Map<String, dynamic> toMap() =>
      {'nonce': nonce, 'input': input, 'max_lcl_seqno': maxLedgerSeqNo};
}
