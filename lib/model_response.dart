class ModelResponse {
  ModelResponse({this.error, this.message, this.data});

  final dynamic error;
  final dynamic message;
  final dynamic data;

  Map<String, dynamic> toJson() =>
      {'error': error ?? '', 'message': message ?? '', 'data': data ?? ''};
}
