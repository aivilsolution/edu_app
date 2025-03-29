class AppException implements Exception {
  final String message;
  final dynamic error;

  AppException(this.message, {this.error});

  @override
  String toString() =>
      error != null
          ? 'AppException: $message, Details: $error'
          : 'AppException: $message';
}

class NotFoundException extends AppException {
  NotFoundException(String resource, String id, {dynamic error})
    : super('$resource not found with id: $id', error: error);
}
