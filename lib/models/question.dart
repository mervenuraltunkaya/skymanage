class Question {
  final int id;
  final int surveyId;
  final String text;
  final String type;
  final List<String> options;

  Question({
    required this.id,
    required this.surveyId,
    required this.text,
    required this.type,
    required this.options,
  });

  factory Question.fromMap(Map<String, dynamic> map) {
    return Question(
      id: map['id'] as int,
      surveyId: map['survey_id'] as int,
      text: map['text'] as String,
      type: map['type'] as String,
      options: (map['options'] as String).split(','),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'survey_id': surveyId,
      'text': text,
      'type': type,
      'options': options.join(','),
    };
  }
} 