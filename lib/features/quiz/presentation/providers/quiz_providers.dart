import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/core/services/ai_service.dart';
import 'package:aura_study/features/ai/presentation/providers/ai_providers.dart';
import 'package:aura_study/features/quiz/data/quiz_repository.dart';
import 'package:aura_study/features/quiz/domain/quiz_model.dart';

/// Provider exposing the concrete QuizRepository
final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return AuraQuizRepository();
});

/// Reactive StateNotifierProvider tracking available quizzes in local Hive database
final quizListProvider = StateNotifierProvider<QuizListNotifier, AsyncValue<List<QuizSession>>>((ref) {
  final repo = ref.watch(quizRepositoryProvider);
  return QuizListNotifier(repo);
});

class QuizListNotifier extends StateNotifier<AsyncValue<List<QuizSession>>> {
  final QuizRepository _repository;

  QuizListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadQuizzes();
  }

  Future<void> loadQuizzes() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getQuizzes();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> saveQuiz(QuizSession quiz) async {
    try {
      await _repository.saveQuiz(quiz);
      await loadQuizzes();
    } catch (e) {
      debugPrint("AURA QUIZ PROVIDERS ERROR: Save failed: $e");
    }
  }

  Future<void> deleteQuiz(String id) async {
    try {
      await _repository.deleteQuiz(id);
      await loadQuizzes();
    } catch (e) {
      debugPrint("AURA QUIZ PROVIDERS ERROR: Delete failed: $e");
    }
  }
}

/// Tracks the active quiz session object that is currently selected to play
final activeQuizSessionProvider = StateProvider<QuizSession?>((ref) => null);

/// Represents the immutable state of a live Quiz Arena gameplay session
class QuizPlayState {
  final int currentQuestionIndex;
  final int selectedOptionIndex; // -1 if no option selected yet
  final int timerValue; // countdown timer from 15 to 0
  final int correctAnswersCount;
  final bool isAnswerSubmitted; // true once the answer is checked and drawer explanation shown
  final bool isCompleted;

  const QuizPlayState({
    this.currentQuestionIndex = 0,
    this.selectedOptionIndex = -1,
    this.timerValue = 15,
    this.correctAnswersCount = 0,
    this.isAnswerSubmitted = false,
    this.isCompleted = false,
  });

  QuizPlayState copyWith({
    int? currentQuestionIndex,
    int? selectedOptionIndex,
    int? timerValue,
    int? correctAnswersCount,
    bool? isAnswerSubmitted,
    bool? isCompleted,
  }) {
    return QuizPlayState(
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      selectedOptionIndex: selectedOptionIndex ?? this.selectedOptionIndex,
      timerValue: timerValue ?? this.timerValue,
      correctAnswersCount: correctAnswersCount ?? this.correctAnswersCount,
      isAnswerSubmitted: isAnswerSubmitted ?? this.isAnswerSubmitted,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

/// StateNotifier handling live game loop interactions, timed counts, and option evaluations
class QuizGamePlayNotifier extends StateNotifier<QuizPlayState> {
  Timer? _timer;

  QuizGamePlayNotifier() : super(const QuizPlayState());

  void startSession() {
    _timer?.cancel();
    state = const QuizPlayState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    state = state.copyWith(timerValue: 15, selectedOptionIndex: -1, isAnswerSubmitted: false);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timerValue > 0) {
        state = state.copyWith(timerValue: state.timerValue - 1);
      } else {
        // Time expired! Automatically check answer as incorrect and submit
        _timer?.cancel();
        submitAnswer(-1, -1); // Submit -1 to denote timeout
      }
    });
  }

  void selectOption(int optionIndex) {
    if (state.isAnswerSubmitted) return;
    state = state.copyWith(selectedOptionIndex: optionIndex);
  }

  void submitAnswer(int correctIndex, int selectedIndex) {
    if (state.isAnswerSubmitted) return;
    _timer?.cancel();
    
    final isCorrect = selectedIndex == correctIndex;
    final newCorrectCount = isCorrect 
        ? state.correctAnswersCount + 1 
        : state.correctAnswersCount;

    state = state.copyWith(
      selectedOptionIndex: selectedIndex,
      correctAnswersCount: newCorrectCount,
      isAnswerSubmitted: true,
    );
  }

  void nextQuestion(int totalQuestions) {
    if (state.currentQuestionIndex + 1 >= totalQuestions) {
      state = state.copyWith(isCompleted: true);
    } else {
      state = state.copyWith(
        currentQuestionIndex: state.currentQuestionIndex + 1,
        selectedOptionIndex: -1,
        isAnswerSubmitted: false,
      );
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Reactive gameplay provider
final quizGamePlayProvider = StateNotifierProvider.autoDispose<QuizGamePlayNotifier, QuizPlayState>((ref) {
  return QuizGamePlayNotifier();
});

/// Handles asynchronous AI quiz synthesizers and saving outputs to the database
final quizGeneratorControllerProvider = StateNotifierProvider<QuizGeneratorController, AsyncValue<QuizSession?>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final listNotifier = ref.watch(quizListProvider.notifier);
  return QuizGeneratorController(aiService, listNotifier);
});

class QuizGeneratorController extends StateNotifier<AsyncValue<QuizSession?>> {
  final AIService _aiService;
  final QuizListNotifier _listNotifier;

  QuizGeneratorController(this._aiService, this._listNotifier) : super(const AsyncValue.data(null));

  Future<QuizSession?> generateQuizFromContent(String title, String content, String category) async {
    state = const AsyncValue.loading();
    try {
      final questions = await _aiService.generateQuiz(title, content);
      final session = QuizSession(
        id: 'quiz-${DateTime.now().millisecondsSinceEpoch}',
        title: title.startsWith("Quiz:") ? title : "Quiz: $title",
        category: category,
        questions: questions,
        score: -1,
      );
      
      await _listNotifier.saveQuiz(session);
      state = AsyncValue.data(session);
      return session;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
}
