import 'package:flutter/material.dart';
import '../services/database_service.dart';
import 'select_users_screen.dart';

class CreateSurveyScreen extends StatefulWidget {
  final int adminId;

  const CreateSurveyScreen({Key? key, required this.adminId}) : super(key: key);

  @override
  State<CreateSurveyScreen> createState() => _CreateSurveyScreenState();
}

class _CreateSurveyScreenState extends State<CreateSurveyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final List<QuestionFormData> _questions = [];

  void _addQuestion() {
    setState(() {
      _questions.add(QuestionFormData());
    });
  }

  Future<void> _saveSurvey() async {
    if (_formKey.currentState!.validate()) {
      try {
        final createdSurvey = await DatabaseService.instance.createSurvey(
          title: _titleController.text,
          description: _descriptionController.text,
          adminId: widget.adminId,
        );

        for (int i = 0; i < _questions.length; i++) {
          final questionData = _questions[i];
          await DatabaseService.instance.createQuestion(
            surveyId: createdSurvey.id,
            text: questionData.textController.text,
            type: questionData.type,
            options: questionData.options,
          );
        }

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SelectUsersScreen(surveyId: createdSurvey.id),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Hata oluştu: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Anket Oluştur'),
      ),
      body: Form(
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
            const Text(
              'Sorular',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            ..._questions.asMap().entries.map((entry) {
              final index = entry.key;
              final questionData = entry.value;
              return QuestionFormField(
                key: ValueKey(index),
                index: index,
                questionData: questionData,
                onDelete: () {
                  setState(() {
                    _questions.removeAt(index);
                  });
                },
              );
            }),
            const SizedBox(height: 16.0),
            ElevatedButton.icon(
              onPressed: _addQuestion,
              icon: const Icon(Icons.add),
              label: const Text('Soru Ekle'),
            ),
            const SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: _questions.isEmpty ? null : _saveSurvey,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(20),
                backgroundColor: Theme.of(context).primaryColor,
              ),
              child: const Text(
                'Anketi Kaydet ve Kullanıcı Seç',
                style: TextStyle(fontSize: 16, color: Colors.white),
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
    for (final question in _questions) {
      question.dispose();
    }
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

class QuestionFormField extends StatelessWidget {
  final int index;
  final QuestionFormData questionData;
  final VoidCallback onDelete;

  const QuestionFormField({
    Key? key,
    required this.index,
    required this.questionData,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                    'Soru ${index + 1}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            TextFormField(
              controller: questionData.textController,
              decoration: const InputDecoration(
                labelText: 'Soru Metni',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen soru metnini girin';
                }
                return null;
              },
            ),
            const SizedBox(height: 16.0),
            StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    DropdownButtonFormField<String>(
                      value: questionData.type,
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
                          questionData.type = value!;
                          if (value == 'likert') {
                            questionData.options = ['1', '2', '3', '4', '5'];
                          } else if (value == 'multiple_choice') {
                            questionData.options = ['Seçenek 1', 'Seçenek 2'];
                          } else {
                            questionData.options = [];
                          }
                        });
                      },
                    ),
                    if (questionData.type == 'multiple_choice') ...[
                      const SizedBox(height: 16.0),
                      ...questionData.options.asMap().entries.map((entry) {
                        final optionIndex = entry.key;
                        final option = entry.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: option,
                                  decoration: InputDecoration(
                                    labelText: 'Seçenek ${optionIndex + 1}',
                                    border: const OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      questionData.options[optionIndex] = value;
                                    });
                                  },
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle),
                                onPressed: () {
                                  setState(() {
                                    questionData.options.removeAt(optionIndex);
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
                            questionData.options.add(
                                'Seçenek ${questionData.options.length + 1}');
                          });
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Seçenek Ekle'),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
} 