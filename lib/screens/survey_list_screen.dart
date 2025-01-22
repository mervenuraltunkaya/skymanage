import 'package:flutter/material.dart';
import '../models/survey.dart';
import '../services/database_service.dart';
import 'create_survey_screen.dart';
import 'edit_survey_screen.dart';
import 'survey_results_screen.dart';

class SurveyListScreen extends StatefulWidget {
  final int adminId;

  const SurveyListScreen({Key? key, required this.adminId}) : super(key: key);

  @override
  State<SurveyListScreen> createState() => _SurveyListScreenState();
}

class _SurveyListScreenState extends State<SurveyListScreen> {
  List<Survey> _surveys = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSurveys();
  }

  Future<void> _loadSurveys() async {
    setState(() => _isLoading = true);
    try {
      final surveys = await DatabaseService.instance.getSurveysByAdmin(widget.adminId);
      setState(() {
        _surveys = surveys;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Anketler yüklenirken hata oluştu: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anketlerim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateSurveyScreen(adminId: widget.adminId),
                ),
              );
              _loadSurveys();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _surveys.isEmpty
              ? const Center(
                  child: Text('Henüz anket oluşturmadınız'),
                )
              : ListView.builder(
                  itemCount: _surveys.length,
                  itemBuilder: (context, index) {
                    final survey = _surveys[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        title: Text(survey.title),
                        subtitle: Text(survey.description),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        EditSurveyScreen(survey: survey),
                                  ),
                                );
                                _loadSurveys();
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.bar_chart),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SurveyResultsScreen(survey: survey),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
} 