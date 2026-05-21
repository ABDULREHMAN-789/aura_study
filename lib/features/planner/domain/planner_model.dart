class StudyTask {
  final String id;
  final String title;
  final String details;
  final String category; // 'Physics', 'Chemistry', 'Mathematics', 'General'
  final DateTime scheduledTime;
  final bool isCompleted;
  final bool reminderEnabled;
  final int? notificationId;

  const StudyTask({
    required this.id,
    required this.title,
    required this.details,
    required this.category,
    required this.scheduledTime,
    this.isCompleted = false,
    this.reminderEnabled = false,
    this.notificationId,
  });

  factory StudyTask.fromJson(Map<String, dynamic> json) {
    return StudyTask(
      id: json['id'] as String,
      title: json['title'] as String,
      details: json['details'] as String? ?? '',
      category: json['category'] as String? ?? 'General',
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      isCompleted: json['isCompleted'] as bool? ?? false,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      notificationId: json['notificationId'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'details': details,
      'category': category,
      'scheduledTime': scheduledTime.toIso8601String(),
      'isCompleted': isCompleted,
      'reminderEnabled': reminderEnabled,
      'notificationId': notificationId,
    };
  }

  StudyTask copyWith({
    String? id,
    String? title,
    String? details,
    String? category,
    DateTime? scheduledTime,
    bool? isCompleted,
    bool? reminderEnabled,
    int? notificationId,
  }) {
    return StudyTask(
      id: id ?? this.id,
      title: title ?? this.title,
      details: details ?? this.details,
      category: category ?? this.category,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      notificationId: notificationId ?? this.notificationId,
    );
  }
}
