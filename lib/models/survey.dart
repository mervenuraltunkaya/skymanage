class Survey {
  final int id;
  final String title;
  final String description;
  final int adminId;
  final DateTime createdAt;
  final bool isActive;
  DateTime? completedAt;

  Survey({
    required this.id,
    required this.title,
    required this.description,
    required this.adminId,
    required this.createdAt,
    this.isActive = false,
    this.completedAt,
  });

  factory Survey.fromMap(Map<String, dynamic> map) {
    return Survey(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      adminId: map['admin_id'] as int,
      createdAt: DateTime.parse(map['created_at'] as String),
      isActive: (map['is_active'] as int?) == 1,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'admin_id': adminId,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'completed_at': completedAt?.toIso8601String(),
    };
  }
} 