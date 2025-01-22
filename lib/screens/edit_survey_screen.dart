import 'package:flutter/material.dart';
import '../models/survey.dart';
import '../models/question.dart';
import '../services/database_service.dart';
import 'select_users_screen.dart';

class EditSurveyScreen extends StatefulWidget {
  final Survey survey;

  const EditSurveyScreen({Key? key, required this.survey}) : super(key: key);

  @override
  State<EditSurveyScreen> createState() => _EditSurveyScreenState();
}

class _EditSurveyScreenState extends State<EditSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  List<Question> _questions = [];
  bool _isLoading = true;
  bool _isActive = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.survey.title);
    _descriptionController = TextEditingController(text: widget.survey.description);
    _loadSurveyDetails();
  }

  Future<void> _loadSurveyDetails() async {
    setState(() => _isLoading = true);
    try {
      final questions = await DatabaseService.instance.getQuestionsBySurvey(widget.survey.id);
      final surveyDetails = await DatabaseService.instance.getSurveyById(widget.survey.id);
      setState(() {
        _questions = questions;
        _isActive = surveyDetails.isActive;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Veriler yüklenirken hata oluştu: $e')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteQuestion(int questionId) async {
    try {
      await DatabaseService.instance.deleteQuestion(questionId);
      setState(() {
        _questions.removeWhere((q) => q.id == questionId);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Soru silinirken hata oluştu: $e')),
        );
      }
    }
  }

  Future<void> _addQuestion() async {
    final questionData = QuestionFormData();
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => QuestionDialog(questionData: questionData),
    );

    if (result != null) {
      try {
        final newQuestion = await DatabaseService.instance.createQuestion(
          surveyId: widget.survey.id,
          text: result['text'],
          type: result['type'],
          options: result['options'],
        );
        setState(() {
          _questions.add(newQuestion);
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Soru eklenirken hata oluştu: $e')),
          );
        }
      }
    }
  }

  Future<void> _editQuestion(Question question) async {
    final questionData = QuestionFormData()
      ..textController.text = question.text
      ..type = question.type
      ..options = List.from(question.options);

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => QuestionDialog(questionData: questionData),
    );

    if (result != null) {
      try {
        await DatabaseService.instance.updateQuestion(
          id: question.id,
          text: result['text'],
          type: result['type'],
          options: result['options'],
        );
        setState(() {
          final index = _questions.indexWhere((q) => q.id == question.id);
          if (index != -1) {
            _questions[index] = Question(
              id: question.id,
              surveyId: widget.survey.id,
              text: result['text'],
              type: result['type'],
              options: result['options'],
            );
          }
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Soru güncellenirken hata oluştu: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveSurvey() async {
    if (_formKey.currentState!.validate()) {
      try {
        await DatabaseService.instance.updateSurvey(
          id: widget.survey.id,
          title: _titleController.text,
          description: _descriptionController.text,
          isActive: _isActive,
        );

        if (_isActive) {
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => SelectUsersScreen(surveyId: widget.survey.id),
              ),
            );
          }
        } else {
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Anket güncellenirken hata oluştu: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Anketi Düzenle'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Anket Başlığı',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir başlık girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Anket Açıklaması',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Lütfen bir açıklama girin';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Sorular',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: _addQuestion,
                        icon: const Icon(Icons.add),
                        label: const Text('Yeni Soru'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),
                  ..._questions.map((question) {
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    question.text,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _editQuestion(question),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteQuestion(question.id),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8.0),
                            Text('Tip: ${question.type}'),
                            if (question.options.isNotEmpty) ...[
                              const SizedBox(height: 8.0),
                              Text('Seçenekler: ${question.options.join(", ")}'),
                            ],
                          ],
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 24.0),
                  SwitchListTile(
                    title: const Text('Anketi Aktif Et'),
                    subtitle: const Text('Anketi diğer kullanıcılar için erişilebilir yap'),
                    value: _isActive,
                    onChanged: (bool value) {
                      setState(() {
                        _isActive = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24.0),
                  ElevatedButton(
                    onPressed: _saveSurvey,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Theme.of(context).primaryColor,
                    ),
                    child: Text(
                      _isActive ? 'Kaydet ve Kullanıcı Seç' : 'Değişiklikleri Kaydet',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}

class QuestionFormData {
  final textController = TextEditingController();
  String type = 'text';
  List<String> options = [];

  void dispose() {
    textController.dispose();
  }
}

class QuestionDialog extends StatefulWidget {
  final QuestionFormData questionData;

  const QuestionDialog({Key? key, required this.questionData}) : super(key: key);

  @override
  State<QuestionDialog> createState() => _QuestionDialogState();
}

class _QuestionDialogState extends State<QuestionDialog> {
  late QuestionFormData _questionData;

  @override
  void initState() {
    super.initState();
    _questionData = widget.questionData;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Soru Düzenle'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _questionData.textController,
              decoration: const InputDecoration(
                labelText: 'Soru Metni',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              value: _questionData.type,
              decoration: const InputDecoration(
                labelText: 'Soru Tipi',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'text',
                  child: Text('Açık Uçlu'),
                ),
                DropdownMenuItem(
                  value: 'likert',
                  child: Text('Likert Ölçeği'),
                ),
                DropdownMenuItem(
                  value: 'multiple_choice',
                  child: Text('Çoktan Seçmeli'),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  _questionData.type = value!;
                  if (value == 'likert') {
                    _questionData.options = ['1', '2', '3', '4', '5'];
                  } else if (value == 'multiple_choice' && _questionData.options.isEmpty) {
                    _questionData.options = ['Seçenek 1', 'Seçenek 2'];
                  } else if (value == 'text') {
                    _questionData.options = [];
                  }
                });
              },
            ),
            if (_questionData.type == 'multiple_choice') ...[
              const SizedBox(height: 16.0),
              ..._questionData.options.asMap().entries.map((entry) {
                final optionIndex = entry.key;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: entry.value,
                          decoration: InputDecoration(
                            labelText: 'Seçenek ${optionIndex + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _questionData.options[optionIndex] = value;
                            });
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.remove_circle),
                        onPressed: () {
                          setState(() {
                            _questionData.options.removeAt(optionIndex);
                          });
                        },
                      ),
                    ],
                  ),
                );
              }),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _questionData.options.add('Seçenek ${_questionData.options.length + 1}');
                  });
                },
                icon: const Icon(Icons.add),
                label: const Text('Seçenek Ekle'),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'text': _questionData.textController.text,
              'type': _questionData.type,
              'options': _questionData.options,
            });
          },
          child: const Text('Kaydet'),
        ),
      ],
    );
  }
} 