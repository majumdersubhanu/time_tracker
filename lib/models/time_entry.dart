class TimeEntry {
  final String id;
  final String projectId;
  final String taskId;
  final Duration totalTime;
  final DateTime date;
  final String notes;

  TimeEntry({
    required this.id,
    required this.projectId,
    required this.taskId,
    required this.totalTime,
    required this.date,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'projectId': projectId,
      'taskId': taskId,
      'totalTimeMinutes': totalTime.inMinutes,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'],
      projectId: json['projectId'],
      taskId: json['taskId'],
      totalTime: Duration(minutes: json['totalTimeMinutes']),
      date: DateTime.parse(json['date']),
      notes: json['notes'],
    );
  }

  TimeEntry copyWith({
    String? id,
    String? projectId,
    String? taskId,
    Duration? totalTime,
    DateTime? date,
    String? notes,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      taskId: taskId ?? this.taskId,
      totalTime: totalTime ?? this.totalTime,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }
}
