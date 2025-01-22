class Answer {
  final int questionId;
  final String answer;

  Answer({
    required this.questionId,
    required this.answer,
  });

  Map<String, dynamic> toMap() {
    return {
      'question_id': questionId,
      'answer': answer,
    };
  }

  factory Answer.fromMap(Map<String, dynamic> map) {
    return Answer(
      questionId: map['question_id'] as int,
      answer: map['answer'] as String,
    );
  }
}

class SurveyResponse {
  final int id;
  final int surveyId;
  final int userId;
  final String userName;
  final List<Answer> answers;
  final DateTime submittedAt;

  SurveyResponse({
    required this.id,
    required this.surveyId,
    required this.userId,
    required this.userName,
    required this.answers,
    required this.submittedAt,
  });

  factory SurveyResponse.fromMap(Map<String, dynamic> map) {
    return SurveyResponse(
      id: map['id'] as int,
      surveyId: map['survey_id'] as int,
      userId: map['user_id'] as int,
      userName: map['user_name'] as String,
      answers: (map['answers'] as String)
          .split('|')
          .map((answer) => Answer.fromMap(
              Map<String, dynamic>.from(answer as Map<String, dynamic>)))
          .toList(),
      submittedAt: DateTime.parse(map['submitted_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'user_id': userId,
      'user_name': userName,
      'answers': answers.map((a) => a.toMap()).join('|'),
      'submitted_at': submittedAt.toIso8601String(),
    };
  }
} 