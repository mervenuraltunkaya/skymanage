class UserSurvey {
  final int? id;
  final int userId;
  final int surveyId;
  final bool isCompleted;
  final DateTime assignedAt;
  final DateTime? completedAt;

  UserSurvey({
    this.id,
    required this.userId,
    required this.surveyId,
    required this.isCompleted,
    required this.assignedAt,
    this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'survey_id': surveyId,
      'is_completed': isCompleted ? 1 : 0,
      'assigned_at': assignedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
    };
  }

  factory UserSurvey.fromMap(Map<String, dynamic> map) {
    return UserSurvey(
      id: map['id'],
      userId: map['user_id'],
      surveyId: map['survey_id'],
      isCompleted: map['is_completed'] == 1,
      assignedAt: DateTime.parse(map['assigned_at']),
      completedAt: map['completed_at'] != null ? DateTime.parse(map['completed_at']) : null,
    );
  }
} 