class Answer {
  final int? id;
  final int questionId;
  final int userId;
  final String? textAnswer; // Açık uçlu sorular için
  final int? likertValue; // Likert ölçeği için
  final DateTime answeredAt;

  Answer({
    this.id,
    required this.questionId,
    required this.userId,
    this.textAnswer,
    this.likertValue,
    required this.answeredAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question_id': questionId,
      'user_id': userId,
      'text_answer': textAnswer,
      'likert_value': likertValue,
      'answered_at': answeredAt.toIso8601String(),
    };
  }

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      id: map['id'],
      questionId: map['question_id'],
      userId: map['user_id'],
      textAnswer: map['text_answer'],
      likertValue: map['likert_value'],
      answeredAt: DateTime.parse(map['answered_at']),
    );
  }
} 