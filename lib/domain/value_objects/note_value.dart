import 'package:meta/meta.dart';
import '../../core/utils/result.dart';
import '../../core/errors/failures.dart';

/// Value Object representing an optional note/description
///
/// Immutable and self-validating. Handles null values and
/// automatically converts empty strings to null.
///
/// Example:
/// ```dart
/// final noteResult = NoteValue.create('Payment for groceries');
/// if (noteResult is Success<NoteValue>) {
///   print(noteResult.value.value); // 'Payment for groceries'
/// }
///
/// final emptyNote = NoteValue.create('   ');
/// // Returns Success with null value
/// ```
@immutable
class NoteValue {
  final String? value;

  static const int maxLen = 200;

  const NoteValue._(this.value);

  /// Factory that performs validation and returns Result<NoteValue>
  ///
  /// [note] - Optional note text. Can be null or empty.
  ///
  /// Returns [ValidationFailure] if note exceeds maximum length.
  /// Empty strings after trimming are converted to null.
  static Result<NoteValue> create(String? note) {
    if (note == null) {
      return const Success(NoteValue._(null));
    }

    final trimmed = note.trim();

    if (trimmed.length > maxLen) {
      return const Fail(
        ValidationFailure(
          'Note is too long (max $maxLen characters)',
          code: 'note_too_long',
        ),
      );
    }

    // Convert empty string to null
    return Success(NoteValue._(trimmed.isEmpty ? null : trimmed));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is NoteValue && other.value == value);

  @override
  int get hashCode => value?.hashCode ?? 0;

  @override
  String toString() => value ?? '';
}
