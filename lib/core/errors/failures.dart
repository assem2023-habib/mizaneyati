import 'package:meta/meta.dart';

@immutable
abstract class Failure {
  final String message;
  final String? code;
  final Map<String, dynamic>? info;

  const Failure(this.message, {this.code, this.info});

  @override
  String toString() => 'Failure(code: $code, message: $message, info: $info)';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(
    String message, {
    String? code,
    Map<String, dynamic>? info,
  }) : super(message, code: code, info: info);
}

class ValidationFailure extends Failure {
  const ValidationFailure(
    String message, {
    String? code,
    Map<String, dynamic>? info,
  }) : super(message, code: code, info: info);
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(
    String message, {
    String? code,
    Map<String, dynamic>? info,
  }) : super(message, code: code, info: info);
}

class PermissionFailure extends Failure {
  const PermissionFailure(
    String message, {
    String? code,
    Map<String, dynamic>? info,
  }) : super(message, code: code, info: info);
}

class UnknownFailure extends Failure {
  const UnknownFailure(
    String message, {
    String? code,
    Map<String, dynamic>? info,
  }) : super(message, code: code, info: info);
}
