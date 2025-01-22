import 'package:flutter/material.dart';
import '../models/survey_response.dart';
import '../models/survey.dart';
import '../models/question.dart';
import '../services/database_service.dart';

class SurveyResponseDetailScreen extends StatefulWidget {
  final int surveyId;

  const SurveyResponseDetailScreen({
    Key? key,
    required this.surveyId,
  }) : super(key: key);

  @override
  State<SurveyResponseDetailScreen> createState() => _SurveyResponseDetailScreenState();
}

class _SurveyResponseDetailScreenState extends State<SurveyResponseDetailScreen> {
  bool _isLoading = true;
  Survey? _survey;
  List<Question> _questions = [];
  List<SurveyResponse> _responses = [];

  @override
  void initState() {
    super.initState();
    _loadSurveyDetails();
  }

  Future<void> _loadSurveyDetails() async {
    setState(() => _isLoading = true);
    try {
      final survey = await DatabaseService.instance.getSurveyById(widget.surveyId);
      final questions = await DatabaseService.instance.getQuestionsBySurvey(widget.surveyId);
      final responses = await DatabaseService.instance.getSurveyResponses(widget.surveyId);

      setState(() {
        _survey = survey;
        _questions = questions;
        _responses = responses;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anket detayları yüklenirken hata oluştu: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _survey?.title ?? 'Anket Detayları',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _responses.isEmpty
              ? const Center(child: Text('Bu anket için henüz cevap bulunmamaktadır'))
              : ListView.builder(
                  itemCount: _responses.length,
                  itemBuilder: (context, index) {
                    final response = _responses[index];
                    return Card(
                      margin: const EdgeInsets.all(8),
                      child: ExpansionTile(
                        title: Text('Kullanıcı: ${response.userName}'),
                        subtitle: Text(
                          'Tamamlanma: ${response.submittedAt.toLocal().toString().split('.')[0]}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        children: _questions.map((question) {
                          final answer = response.answers.firstWhere(
                            (a) => a.questionId == question.id,
                            orElse: () => Answer(questionId: question.id, answer: 'Cevap verilmemiş'),
                          );
                          return ListTile(
                            title: Text(question.text),
                            subtitle: Text(
                              answer.answer,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
    );
  }
} 