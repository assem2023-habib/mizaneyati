import '../errors/failures.dart';

sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

final class Fail<T> extends Result<T> {
  final Failure failure;
  const Fail(this.failure);
}
