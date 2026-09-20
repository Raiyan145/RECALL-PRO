enum ReminderPriority { normal, emergency }

enum RepeatType { none, daily, weekly, monthly }

class Reminder {
  final int id;
  final String title;
  final String note;
  final DateTime dateTime;
  final ReminderPriority priority;
  final RepeatType repeat;
  final bool completed;

  const Reminder({
    required this.id,
    required this.title,
    required this.note,
    required this.dateTime,
    required this.priority,
    this.repeat = RepeatType.none,
    this.completed = false,
  });

  Reminder copyWith({
    String? title,
    String? note,
    DateTime? dateTime,
    ReminderPriority? priority,
    RepeatType? repeat,
    bool? completed,
  }) => Reminder(
    id: id,
    title: title ?? this.title,
    note: note ?? this.note,
    dateTime: dateTime ?? this.dateTime,
    priority: priority ?? this.priority,
    repeat: repeat ?? this.repeat,
    completed: completed ?? this.completed,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'note': note,
    'dateTime': dateTime.toIso8601String(),
    'priority': priority.name,
    'repeat': repeat.name,
    'completed': completed,
  };

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'] as int,
    title: json['title'] as String,
    note: (json['note'] ?? '') as String,
    dateTime: DateTime.parse(json['dateTime'] as String),
    priority: ReminderPriority.values.byName(json['priority'] as String),
    repeat: RepeatType.values.byName((json['repeat'] ?? 'none') as String),
    completed: (json['completed'] ?? false) as bool,
  );
}
