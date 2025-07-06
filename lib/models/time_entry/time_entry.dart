import 'package:freezed_annotation/freezed_annotation.dart';

part 'time_entry.freezed.dart';
part 'time_entry.g.dart';

@freezed
abstract class TimeEntry with _$TimeEntry {
  const factory TimeEntry({
    String? id,
    String? projectId,
    String? taskId,
    String? date,
    double? duration,
    String? note,
  }) = _TimeEntry;

  factory TimeEntry.fromJson(Map<String, Object?> json) =>
      _$TimeEntryFromJson(json);
}
