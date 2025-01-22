import 'package:flutter/material.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import '../services/database_service.dart';

class SurveyResultsScreen extends StatefulWidget {
  final Survey survey;

  const SurveyResultsScreen({Key? key, required this.survey}) : super(key: key);

  @override
  State<SurveyResultsScreen> createState() => _SurveyResultsScreenState();
}

class _SurveyResultsScreenState extends State<SurveyResultsScreen> {
  List<SurveyResponse> _responses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResponses();
  }

  Future<void> _loadResponses() async {
    setState(() => _isLoading = true);
    try {
      final responses = await DatabaseService.instance.getSurveyResponses(widget.survey.id);
      setState(() {
        _responses = responses;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Yanıtlar yüklenirken hata oluştu: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.survey.title} - Sonuçlar'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _responses.isEmpty
              ? const Center(
                  child: Text('Henüz yanıt yok'),
                )
              : ListView.builder(
                  itemCount: _responses.length,
                  itemBuilder: (context, index) {
                    final response = _responses[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Yanıtlayan: ${response.userName}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tarih: ${response.submittedAt.toLocal().toString().split('.')[0]}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            const Divider(),
                            ...response.answers.map((answer) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Text('${answer.questionId}: ${answer.answer}'),
                              );
                            }),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 