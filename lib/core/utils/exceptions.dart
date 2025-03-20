
class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}
