import 'package:sqflite/sqflite.dart';

/// Classification of a data-layer failure.
///
/// The UI maps a [DataErrorKind] onto a localized message from the ARB files;
/// the data layer never produces user-facing strings for its own errors.
enum DataErrorKind {
  /// The requested row does not exist.
  notFound,

  /// A unique / foreign-key constraint rejected the write.
  conflict,

  /// The database could not be opened or is closed.
  unavailable,

  /// The database file is read-only.
  readOnly,

  /// Anything else.
  unknown,
}

/// A failure produced by the data layer.
///
/// [operation] is a stable technical label (`recordXp`, `claimAchievement`, ...)
/// and [cause] keeps the original error for logging. Neither is ever rendered
/// directly to the user.
final class DataFailure {
  const DataFailure({
    required this.kind,
    required this.operation,
    required this.message,
    this.cause,
  });

  /// Builds a failure from an arbitrary thrown object.
  factory DataFailure.from(Object error, String operation) {
    if (error is DatabaseException) {
      return DataFailure(
        kind: _kindOf(error),
        operation: operation,
        message: error.toString(),
        cause: error,
      );
    }
    return DataFailure(
      kind: DataErrorKind.unknown,
      operation: operation,
      message: error.toString(),
      cause: error,
    );
  }

  final DataErrorKind kind;

  /// Technical name of the repository call that failed.
  final String operation;

  /// Technical detail, for logs only.
  final String message;

  /// The original error object.
  final Object? cause;

  static DataErrorKind _kindOf(DatabaseException error) {
    if (error.isUniqueConstraintError()) return DataErrorKind.conflict;
    if (error.isNotNullConstraintError()) return DataErrorKind.conflict;
    if (error.isReadOnlyError()) return DataErrorKind.readOnly;
    if (error.isNoSuchTableError()) return DataErrorKind.unavailable;
    if (error.isDatabaseClosedError()) return DataErrorKind.unavailable;
    if (error.isOpenFailedError()) return DataErrorKind.unavailable;
    if (error.isSyntaxError()) return DataErrorKind.unknown;
    return DataErrorKind.unknown;
  }

  @override
  String toString() => 'DataFailure(${kind.name}, $operation)';
}

/// Result of a repository call.
///
/// Repositories never let a raw [DatabaseException] escape: every call returns
/// either [ResultOk] with a value or [ResultErr] with a classified
/// [DataFailure], so the UI layer can render loading / error / empty states
/// without knowing anything about SQL.
sealed class Result<T> {
  const Result();

  /// Wraps [value] as a successful result.
  const factory Result.ok(T value) = ResultOk<T>;

  /// Wraps [failure] as a failed result.
  const factory Result.err(DataFailure failure) = ResultErr<T>;

  /// `true` when this result carries a value.
  bool get isOk => this is ResultOk<T>;

  /// `true` when this result carries a failure.
  bool get isErr => this is ResultErr<T>;

  /// The value, or `null` when this result failed.
  T? get valueOrNull => switch (this) {
        ResultOk<T>(:final T value) => value,
        ResultErr<T>() => null,
      };

  /// The failure, or `null` when this result succeeded.
  DataFailure? get failureOrNull => switch (this) {
        ResultOk<T>() => null,
        ResultErr<T>(:final DataFailure failure) => failure,
      };

  /// Collapses both branches into a single value.
  R fold<R>(R Function(T value) onOk, R Function(DataFailure failure) onErr) =>
      switch (this) {
        ResultOk<T>(:final T value) => onOk(value),
        ResultErr<T>(:final DataFailure failure) => onErr(failure),
      };

  /// Transforms the success value, leaving a failure untouched.
  Result<R> map<R>(R Function(T value) transform) => switch (this) {
        ResultOk<T>(:final T value) => ResultOk<R>(transform(value)),
        ResultErr<T>(:final DataFailure failure) => ResultErr<R>(failure),
      };
}

/// Successful [Result] carrying [value].
final class ResultOk<T> extends Result<T> {
  const ResultOk(this.value);

  final T value;
}

/// Failed [Result] carrying [failure].
final class ResultErr<T> extends Result<T> {
  const ResultErr(this.failure);

  final DataFailure failure;
}

/// A read snapshot that can express every state a screen has to render.
///
/// Repositories return [Result]s; the UI folds one of those into a
/// [DataState] with [DataState.fromList] / [DataState.fromResult] to render a
/// spinner, an empty view, an error view or content without any extra logic.
sealed class DataState<T> {
  const DataState();

  /// Nothing has been requested yet, or a request is in flight.
  factory DataState.loading() => DataLoading<T>();

  /// The request succeeded but there is nothing to show.
  factory DataState.empty() => DataEmpty<T>();

  /// The request succeeded and produced [value].
  factory DataState.data(T value) => DataLoaded<T>(value);

  /// The request failed with [failure].
  factory DataState.error(DataFailure failure) => DataError<T>(failure);

  bool get isLoading => this is DataLoading<T>;

  bool get isEmpty => this is DataEmpty<T>;

  bool get isError => this is DataError<T>;

  T? get valueOrNull => switch (this) {
        DataLoaded<T>(:final T value) => value,
        DataLoading<T>() || DataEmpty<T>() || DataError<T>() => null,
      };

  DataFailure? get failureOrNull => switch (this) {
        DataError<T>(:final DataFailure failure) => failure,
        DataLoading<T>() || DataEmpty<T>() || DataLoaded<T>() => null,
      };

  /// Folds a list result into a data state, mapping `[]` onto the empty state.
  static DataState<List<T>> fromList<T>(Result<List<T>> result) =>
      switch (result) {
        ResultOk<List<T>>(:final List<T> value) =>
          value.isEmpty ? DataEmpty<List<T>>() : DataLoaded<List<T>>(value),
        ResultErr<List<T>>(:final DataFailure failure) =>
          DataError<List<T>>(failure),
      };

  /// Folds any result into a data state.
  static DataState<T> fromResult<T>(Result<T> result) => switch (result) {
        ResultOk<T>(:final T value) => DataLoaded<T>(value),
        ResultErr<T>(:final DataFailure failure) => DataError<T>(failure),
      };
}

/// Loading [DataState].
final class DataLoading<T> extends DataState<T> {
  DataLoading();
}

/// Empty [DataState].
final class DataEmpty<T> extends DataState<T> {
  DataEmpty();
}

/// Populated [DataState].
final class DataLoaded<T> extends DataState<T> {
  const DataLoaded(this.value);

  final T value;
}

/// Failed [DataState].
final class DataError<T> extends DataState<T> {
  const DataError(this.failure);

  final DataFailure failure;
}