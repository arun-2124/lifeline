class ServerException implements Exception {
  final String message;
  final String? code;
  const ServerException({required this.message, this.code});
}

class AuthException implements Exception {
  final String message;
  final String? code;
  const AuthException({required this.message, this.code});
}

class NetworkException implements Exception {
  final String message;
  const NetworkException({this.message = 'Network operation failed'});
}
