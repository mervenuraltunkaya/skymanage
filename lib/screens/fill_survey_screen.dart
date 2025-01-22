import 'package:flutter/material.dart';
import '../models/survey.dart';
import '../models/question.dart';
import '../models/survey_response.dart' show Answer;
import '../services/database_service.dart';

class FillSurveyScreen extends StatefulWidget {
  final Survey survey;
  final int userId;

  const FillSurveyScreen({
    Key? key,
    required this.survey,
    required this.userId,
  }) : super(key: key);

  @override
  State<FillSurveyScreen> createState() => _FillSurveyScreenState();
}

class _FillSurveyScreenState extends State<FillSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  List<Question> _questions = [];
  final Map<int, String> _answers = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    try {
      final questions =
          await DatabaseService.instance.getQuestionsBySurvey(widget.survey.id);
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sorular yüklenirken hata oluştu: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitSurvey() async {
    if (_formKey.currentState!.validate()) {
      try {
        final answers = _answers.entries.map((entry) {
          return Answer(
            questionId: entry.key,
            answer: entry.value,
          );
        }).toList();

        await DatabaseService.instance.saveSurveyResponse(
          surveyId: widget.survey.id,
          userId: widget.userId,
          answers: answers,
        );

        await DatabaseService.instance.markSurveyAsCompleted(
          surveyId: widget.survey.id,
          userId: widget.userId,
        );

        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Anket gönderilirken hata oluştu: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111827),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            _header(context),
            const SizedBox(height: 50),
            _sectionTitle(widget.survey.title),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF60A5FA)),
                ),
              )
            else
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    Text(
                      widget.survey.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    ..._questions.map(
                        (question) => _buildQuestionCard(context, question)),
                    const SizedBox(height: 30),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitSurvey,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                        child: const Text(
                          'Anketi Gönder',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          'assets/logo.png',
          height: 30,
          width: 30,
          fit: BoxFit.contain,
        ),
        const SizedBox(width: 10),
        const Text(
          'SKYMANAGE',
          style: TextStyle(
            fontSize: 26,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            color: Color(0xFFE5E7EB),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Color(0xFFFDFEFF),
      ),
    );
  }

  Widget _buildQuestionCard(BuildContext context, Question question) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF212A39),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.text,
            style: const TextStyle(
              color: Color(0xFFFDFEFF),
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          _buildQuestionWidget(context, question),
        ],
      ),
    );
  }

  Widget _buildQuestionWidget(BuildContext context, Question question) {
    switch (question.type) {
      case 'text':
        return TextFormField(
          decoration: InputDecoration(
            hintText: 'Cevabınızı buraya yazın...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            filled: true,
            fillColor: const Color(0xFF1E3A8A).withOpacity(0.1),
          ),
          maxLines: 3,
          onChanged: (value) => _answers[question.id] = value,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Lütfen bir cevap girin';
            }
            return null;
          },
        );
      case 'likert':
        return Column(
          children: [
            const Text('1: Kesinlikle Katılmıyorum, 5: Kesinlikle Katılıyorum'),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final value = (index + 1).toString();
                return Column(
                  children: [
                    Radio<String>(
                      value: value,
                      groupValue: _answers[question.id],
                      onChanged: (newValue) {
                        setState(() {
                          _answers[question.id] = newValue!;
                        });
                      },
                    ),
                    Text(value),
                  ],
                );
              }),
            ),
          ],
        );
      case 'multiple_choice':
        return Column(
          children: question.options.map((option) {
            return RadioListTile<String>(
              title: Text(option,
                  style: const TextStyle(color: Color(0xFFFDFEFF))),
              value: option,
              groupValue: _answers[question.id],
              onChanged: (newValue) {
                setState(() {
                  _answers[question.id] = newValue!;
                });
              },
            );
          }).toList(),
        );
      default:
        return const Text('Desteklenmeyen soru tipi');
    }
  }
}
