import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';
import '../models/survey.dart';
import '../models/survey_response.dart';
import '../models/question.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  static DatabaseService get instance => _instance;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'survey_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE,
        password TEXT,
        is_admin INTEGER
      )
    ''');

    await db.execute('''
      CREATE TABLE surveys (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        admin_id INTEGER,
        created_at TEXT,
        is_active INTEGER DEFAULT 0,
        FOREIGN KEY (admin_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE questions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        text TEXT,
        type TEXT,
        options TEXT,
        FOREIGN KEY (survey_id) REFERENCES surveys (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE answers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question_id INTEGER,
        user_id INTEGER,
        answer TEXT,
        created_at TEXT,
        FOREIGN KEY (question_id) REFERENCES questions (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE survey_assignments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        survey_id INTEGER,
        user_id INTEGER,
        assigned_at TEXT,
        completed_at TEXT,
        FOREIGN KEY (survey_id) REFERENCES surveys (id),
        FOREIGN KEY (user_id) REFERENCES users (id)
      )
    ''');

    // Create default admin user
    await db.insert('users', {
      'username': 'admin',
      'password': 'admin123',
      'is_admin': 1,
    });
  }

  // User management methods
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> getUserById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<User> createUser({
    required String username,
    required String password,
    required bool isAdmin,
  }) async {
    final db = await database;
    final id = await db.insert('users', {
      'username': username,
      'password': password,
      'is_admin': isAdmin ? 1 : 0,
    });
    return User(
      id: id,
      username: username,
      isAdmin: isAdmin,
    );
  }

  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Survey response methods
  Future<List<SurveyResponse>> getSurveyResponses(int surveyId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT 
        a.id,
        a.question_id,
        a.user_id,
        u.username as user_name,
        a.answer,
        a.created_at as submitted_at
      FROM answers a
      JOIN users u ON a.user_id = u.id
      WHERE a.question_id IN (
        SELECT id FROM questions WHERE survey_id = ?
      )
      ORDER BY a.user_id, a.created_at
    ''', [surveyId]);

    if (maps.isEmpty) return [];

    final responses = <int, SurveyResponse>{};
    for (final map in maps) {
      final userId = map['user_id'] as int;
      final answer = Answer(
        questionId: map['question_id'] as int,
        answer: map['answer'] as String,
      );

      if (responses.containsKey(userId)) {
        responses[userId]!.answers.add(answer);
      } else {
        responses[userId] = SurveyResponse(
          id: map['id'] as int,
          surveyId: surveyId,
          userId: userId,
          userName: map['user_name'] as String,
          answers: [answer],
          submittedAt: DateTime.parse(map['submitted_at'] as String),
        );
      }
    }

    return responses.values.toList();
  }

  Future<List<Survey>> getCompletedSurveys() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT s.*
      FROM surveys s
      JOIN survey_assignments sa ON s.id = sa.survey_id
      WHERE sa.completed_at IS NOT NULL
      ORDER BY s.created_at DESC
    ''');

    return List.generate(maps.length, (i) => Survey.fromMap(maps[i]));
  }

  Future<void> saveSurveyResponse({
    required int surveyId,
    required int userId,
    required List<Answer> answers,
  }) async {
    final db = await database;
    final batch = db.batch();

    for (final answer in answers) {
      batch.insert('answers', {
        'question_id': answer.questionId,
        'user_id': userId,
        'answer': answer.answer,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    await batch.commit();
  }

  // Survey management methods
  Future<Survey> createSurvey({
    required String title,
    required String description,
    required int adminId,
  }) async {
    final db = await database;
    final id = await db.insert('surveys', {
      'title': title,
      'description': description,
      'admin_id': adminId,
      'created_at': DateTime.now().toIso8601String(),
    });
    return Survey(
      id: id,
      title: title,
      description: description,
      adminId: adminId,
      createdAt: DateTime.now(),
    );
  }

  Future<void> updateSurvey({
    required int id,
    required String title,
    required String description,
    required bool isActive,
  }) async {
    final db = await database;
    await db.update(
      'surveys',
      {
        'title': title,
        'description': description,
        'is_active': isActive ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Survey>> getSurveysByAdmin(int adminId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'surveys',
      where: 'admin_id = ?',
      whereArgs: [adminId],
    );
    return List.generate(maps.length, (i) => Survey.fromMap(maps[i]));
  }

  Future<List<Survey>> getSurveysByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT s.*
      FROM surveys s
      JOIN survey_assignments sa ON s.id = sa.survey_id
      WHERE sa.user_id = ? AND sa.completed_at IS NULL
    ''', [userId]);
    return List.generate(maps.length, (i) => Survey.fromMap(maps[i]));
  }

  Future<void> assignSurveyToUser({
    required int surveyId,
    required int userId,
  }) async {
    final db = await database;
    await db.insert('survey_assignments', {
      'survey_id': surveyId,
      'user_id': userId,
      'assigned_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> markSurveyAsCompleted({
    required int surveyId,
    required int userId,
  }) async {
    final db = await database;
    await db.update(
      'survey_assignments',
      {'completed_at': DateTime.now().toIso8601String()},
      where: 'survey_id = ? AND user_id = ?',
      whereArgs: [surveyId, userId],
    );
  }

  // Question management methods
  Future<Question> createQuestion({
    required int surveyId,
    required String text,
    required String type,
    required List<String> options,
  }) async {
    final db = await database;
    final id = await db.insert('questions', {
      'survey_id': surveyId,
      'text': text,
      'type': type,
      'options': options.join(','),
    });
    return Question(
      id: id,
      surveyId: surveyId,
      text: text,
      type: type,
      options: options,
    );
  }

  Future<void> updateQuestion({
    required int id,
    required String text,
    required String type,
    required List<String> options,
  }) async {
    final db = await database;
    await db.update(
      'questions',
      {
        'text': text,
        'type': type,
        'options': options.join(','),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteQuestion(int id) async {
    final db = await database;
    await db.delete(
      'questions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Question>> getQuestionsBySurvey(int surveyId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'questions',
      where: 'survey_id = ?',
      whereArgs: [surveyId],
    );
    return List.generate(maps.length, (i) => Question.fromMap(maps[i]));
  }

  // Answer management methods
  Future<void> createAnswer({
    required int questionId,
    required int userId,
    required String answer,
  }) async {
    final db = await database;
    await db.insert('answers', {
      'question_id': questionId,
      'user_id': userId,
      'answer': answer,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  Future<Survey> getSurveyById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'surveys',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) {
      throw Exception('Survey not found');
    }
    return Survey.fromMap(maps.first);
  }

  Future<List<Survey>> getCompletedSurveysByUser(int userId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT s.*, sa.completed_at
      FROM surveys s
      JOIN survey_assignments sa ON s.id = sa.survey_id
      WHERE sa.user_id = ? AND sa.completed_at IS NOT NULL
      ORDER BY sa.completed_at DESC
    ''', [userId]);

    return List.generate(maps.length, (i) {
      final survey = Survey.fromMap(maps[i]);
      survey.completedAt = DateTime.parse(maps[i]['completed_at'] as String);
      return survey;
    });
  }
} 