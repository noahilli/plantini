import 'errors/app_failure.dart';

/// Explicit result values keep errors out of normal UI control flow.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is Failure<T>;

  T? get valueOrNull => switch (this) {
    Success<T>(:final value) => value,
    Failure<T>() => null,
  };

  AppFailure? get failureOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(:final failure) => failure,
  };

  R when<R>({
    required R Function(T value) success,
    required R Function(AppFailure failure) failure,
  }) => switch (this) {
    Success<T>(:final value) => success(value),
    Failure<T>(failure: final resultFailure) => failure(resultFailure),
  };
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);

  final AppFailure failure;
}
