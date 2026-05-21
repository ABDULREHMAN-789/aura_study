import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aura_study/features/quiz/domain/quiz_model.dart';

abstract class QuizRepository {
  Future<void> init();
  Future<List<QuizSession>> getQuizzes();
  Future<void> saveQuiz(QuizSession quiz);
  Future<void> deleteQuiz(String id);
}

class AuraQuizRepository implements QuizRepository {
  late final Box<dynamic> _quizBox;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    _quizBox = await Hive.openBox<dynamic>('aura_study_quizzes');
    _isInitialized = true;
  }

  @override
  Future<List<QuizSession>> getQuizzes() async {
    await init();
    final List<QuizSession> quizzes = [];
    for (final key in _quizBox.keys) {
      final val = _quizBox.get(key);
      if (val != null && val is Map) {
        try {
          quizzes.add(QuizSession.fromJson(Map<String, dynamic>.from(val)));
        } catch (e) {
          debugPrint("AURA QUIZ REPO: Parse error: $e");
        }
      }
    }
    // Sort completed quizzes by completedAt, and uncompleted by ID descending
    quizzes.sort((a, b) {
      if (a.completedAt != null && b.completedAt != null) {
        return b.completedAt!.compareTo(a.completedAt!);
      }
      if (a.completedAt != null) return 1;
      if (b.completedAt != null) return -1;
      return b.id.compareTo(a.id);
    });
    return quizzes;
  }

  @override
  Future<void> saveQuiz(QuizSession quiz) async {
    await init();
    await _quizBox.put(quiz.id, quiz.toJson());
  }

  @override
  Future<void> deleteQuiz(String id) async {
    await init();
    await _quizBox.delete(id);
  }
}
