class DatabaseException implements Exception {
  final String message;
  final Object? originalException;

  DatabaseException(this.message, [this.originalException]);

  @override
  String toString() =>
      'DatabaseException: $message, original: $originalException';
}

class ValidationException implements Exception {
  final String message;
  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}

class NotFoundException implements Exception {
  final String message;
  NotFoundException(this.message);

  @override
  String toString() => 'NotFoundException: $message';
}

class PermissionException implements Exception {
  final String message;
  PermissionException(this.message);

  @override
  String toString() => 'PermissionException: $message';
}
