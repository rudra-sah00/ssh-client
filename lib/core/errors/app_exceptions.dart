sealed class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => message;
}

class ConnectionException extends AppException {
  const ConnectionException(super.message);
}

class AuthenticationException extends AppException {
  const AuthenticationException(super.message);
}

class SessionException extends AppException {
  const SessionException(super.message);
}
