class Response {
  dynamic message;
  final String status;

  Response({this.status});

  bool get successful => this.status == "success";
}
