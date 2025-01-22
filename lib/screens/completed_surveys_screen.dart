import 'package:flutter/material.dart';
import '../models/survey.dart';
import '../services/database_service.dart';
import 'survey_response_detail_screen.dart';

class CompletedSurveysScreen extends StatefulWidget {
  final int userId;

  const CompletedSurveysScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  State<CompletedSurveysScreen> createState() => _CompletedSurveysScreenState();
}

class _CompletedSurveysScreenState extends State<CompletedSurveysScreen> {
  List<Survey> _completedSurveys = [];
  bool _isLoading = true;
  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = await DatabaseService.instance.getUserById(widget.userId);
    if (user != null) {
      setState(() {
        _isAdmin = user.isAdmin;
      });
      _loadCompletedSurveys();
    }
  }

  Future<void> _loadCompletedSurveys() async {
    setState(() => _isLoading = true);
    try {
      final surveys = _isAdmin
          ? await DatabaseService.instance.getCompletedSurveys()
          : await DatabaseService.instance
              .getCompletedSurveysByUser(widget.userId);
      setState(() {
        _completedSurveys = surveys;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Tamamlanan anketler yüklenirken hata oluştu: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tamamlanan Değerlendirmeler',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _completedSurveys.isEmpty
              ? const Center(
                  child:
                      Text('Henüz tamamlanmış değerlendirme bulunmamaktadır'),
                )
              : ListView.builder(
                  itemCount: _completedSurveys.length,
                  itemBuilder: (context, index) {
                    final survey = _completedSurveys[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(survey.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(survey.description),
                            const SizedBox(height: 4),
                            Text(
                              'Tamamlanma Tarihi: ${survey.completedAt?.toLocal().toString().split('.')[0] ?? 'Belirtilmemiş'}',
                              style: TextStyle(
                                color: Colors.grey[400],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        trailing: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        onTap: _isAdmin
                            ? () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SurveyResponseDetailScreen(
                                      surveyId: survey.id,
                                    ),
                                  ),
                                );
                              }
                            : null,
                      ),
                    );
                  },
                ),
    );
  }
}
