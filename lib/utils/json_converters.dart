import 'package:json_annotation/json_annotation.dart';

/// Converts an integer timestamp (in milliseconds) to a [DateTime] object.
/// Handles nullable values.
class NullableTimestampConverter implements JsonConverter<DateTime?, int?> {
  const NullableTimestampConverter();

  /// Converts from a JSON integer to a [DateTime].
  @override
  DateTime? fromJson(int? json) {
    if (json == null) return null;
    // Assumes the timestamp is in milliseconds since epoch.
    return DateTime.fromMillisecondsSinceEpoch(json);
  }

  /// Converts from a [DateTime] to a JSON integer.
  @override
  int? toJson(DateTime? object) {
    if (object == null) return null;
    return object.millisecondsSinceEpoch;
  }
}
