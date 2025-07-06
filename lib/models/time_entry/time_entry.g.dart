// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'time_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TimeEntry _$TimeEntryFromJson(Map<String, dynamic> json) => _TimeEntry(
  id: json['id'] as String?,
  projectId: json['projectId'] as String?,
  taskId: json['taskId'] as String?,
  date: json['date'] as String?,
  duration: (json['duration'] as num?)?.toDouble(),
  note: json['note'] as String?,
);

Map<String, dynamic> _$TimeEntryToJson(_TimeEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'projectId': instance.projectId,
      'taskId': instance.taskId,
      'date': instance.date,
      'duration': instance.duration,
      'note': instance.note,
    };
