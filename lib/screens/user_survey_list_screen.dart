import 'package:flutter/material.dart';
import '../models/survey.dart';
import '../services/database_service.dart';
import 'fill_survey_screen.dart';

class UserSurveyListScreen extends StatefulWidget {
  final int userId;

  const UserSurveyListScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  State<UserSurveyListScreen> createState() => _UserSurveyListScreenState();
}

class _UserSurveyListScreenState extends State<UserSurveyListScreen> {
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
      final surveys =
          await DatabaseService.instance.getSurveysByUser(widget.userId);
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
      backgroundColor: const Color(0xFF111827),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık kısmı
            Padding(
              padding: const EdgeInsets.only(bottom: 20.0),
              child: Text(
                'ANKETLERİM',
                style: const TextStyle(
                  color: Color(0xFFE5E7EB),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Neo Sans',
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Color(0xFF60A5FA)),
                      ),
                    )
                  : _surveys.isEmpty
                      ? const Center(
                          child: Text(
                            'Atanmış anket bulunmamaktadır',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _surveys.length,
                          itemBuilder: (context, index) {
                            final survey = _surveys[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: GestureDetector(
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FillSurveyScreen(
                                        survey: survey,
                                        userId: widget.userId,
                                      ),
                                    ),
                                  );
                                  _loadSurveys();
                                },
                                child: Container(
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
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 20.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                survey.title,
                                                style: const TextStyle(
                                                  color: Color(0xFFFDFEFF),
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                survey.description,
                                                style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF60A5FA),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    FillSurveyScreen(
                                                  survey: survey,
                                                  userId: widget.userId,
                                                ),
                                              ),
                                            );
                                            _loadSurveys();
                                          },
                                          child: const Text(
                                            'Doldur',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
