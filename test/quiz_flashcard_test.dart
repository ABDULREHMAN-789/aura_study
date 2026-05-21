import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/core/services/ai_service.dart';
import 'package:aura_study/features/quiz/domain/quiz_model.dart';
import 'package:aura_study/features/quiz/data/quiz_repository.dart';
import 'package:aura_study/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:aura_study/features/flashcards/domain/flashcard_model.dart';
import 'package:aura_study/features/flashcards/data/flashcards_repository.dart';
import 'package:aura_study/features/flashcards/presentation/providers/flashcard_providers.dart';

void main() {
  late Directory tempDir;

  setUpAll(() async {
    // Setup temporary local system directory for Hive mocks in unit testing environment
    tempDir = await Directory.systemTemp.createTemp('aura_quiz_flashcard_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Quiz & Flashcard Domain Model Tests', () {
    test('QuizQuestion & QuizSession serialization handles structures correctly', () {
      const question = QuizQuestion(
        question: 'What is Schrödinger equation?',
        options: ['A wave equation', 'A matrix equation', 'An algebraic sum', 'None'],
        correctIndex: 0,
        explanation: 'It describes quantum states over time.',
      );

      final questionJson = question.toJson();
      expect(questionJson['question'], 'What is Schrödinger equation?');
      expect(questionJson['correctIndex'], 0);
      expect(questionJson['explanation'], 'It describes quantum states over time.');

      final parsedQuestion = QuizQuestion.fromJson(questionJson);
      expect(parsedQuestion.question, question.question);
      expect(parsedQuestion.options, question.options);
      expect(parsedQuestion.correctIndex, question.correctIndex);
      expect(parsedQuestion.explanation, question.explanation);

      final now = DateTime(2026, 5, 21);
      final session = QuizSession(
        id: 'session-id',
        title: 'Quantum Checkpoint',
        category: 'Physics',
        questions: [question],
        score: 1,
        completedAt: now,
      );

      final sessionJson = session.toJson();
      expect(sessionJson['id'], 'session-id');
      expect(sessionJson['title'], 'Quantum Checkpoint');
      expect(sessionJson['category'], 'Physics');
      expect(sessionJson['score'], 1);
      expect(sessionJson['completedAt'], '2026-05-21T00:00:00.000');

      final parsedSession = QuizSession.fromJson(sessionJson);
      expect(parsedSession.id, session.id);
      expect(parsedSession.title, session.title);
      expect(parsedSession.category, session.category);
      expect(parsedSession.questions.first.question, question.question);
      expect(parsedSession.score, session.score);
      expect(parsedSession.completedAt, session.completedAt);
    });

    test('Flashcard & FlashcardDeck serialization handles structures correctly', () {
      const flashcard = Flashcard(
        id: 'fc-1',
        frontText: 'Front statement',
        backText: 'Back decryption explanation',
        difficultyRating: 'easy',
        category: 'Chemistry',
      );

      final flashcardJson = flashcard.toJson();
      expect(flashcardJson['id'], 'fc-1');
      expect(flashcardJson['frontText'], 'Front statement');
      expect(flashcardJson['backText'], 'Back decryption explanation');
      expect(flashcardJson['difficultyRating'], 'easy');
      expect(flashcardJson['category'], 'Chemistry');

      final parsedCard = Flashcard.fromJson(flashcardJson);
      expect(parsedCard.id, flashcard.id);
      expect(parsedCard.frontText, flashcard.frontText);
      expect(parsedCard.backText, flashcard.backText);
      expect(parsedCard.difficultyRating, flashcard.difficultyRating);
      expect(parsedCard.category, flashcard.category);

      final now = DateTime(2026, 5, 21);
      final deck = FlashcardDeck(
        id: 'deck-id',
        title: 'Organic Compounds',
        category: 'Chemistry',
        cards: [flashcard],
        createdAt: now,
        updatedAt: now,
      );

      final deckJson = deck.toJson();
      expect(deckJson['id'], 'deck-id');
      expect(deckJson['title'], 'Organic Compounds');
      expect(deckJson['category'], 'Chemistry');
      expect(deckJson['createdAt'], '2026-05-21T00:00:00.000');

      final parsedDeck = FlashcardDeck.fromJson(deckJson);
      expect(parsedDeck.id, deck.id);
      expect(parsedDeck.title, deck.title);
      expect(parsedDeck.category, deck.category);
      expect(parsedDeck.cards.first.frontText, flashcard.frontText);
      expect(parsedDeck.createdAt, deck.createdAt);
      expect(parsedDeck.updatedAt, deck.updatedAt);
    });
  });

  group('MockAIService Extensions Tests', () {
    final aiService = MockAIService();

    test('generateQuiz returns valid mock questions with academic fidelity', () async {
      final questions = await aiService.generateQuiz('Quantum Mechanics', 'Content body');
      expect(questions.isNotEmpty, true);
      expect(questions.first.question.isNotEmpty, true);
      expect(questions.first.options.length, 4);
      expect(questions.first.correctIndex >= 0 && questions.first.correctIndex < 4, true);
      expect(questions.first.explanation.isNotEmpty, true);
    });

    test('generateFlashcards returns valid mock active-recall cards', () async {
      final cards = await aiService.generateFlashcards('Thermodynamics', 'Content body');
      expect(cards.isNotEmpty, true);
      expect(cards.first.frontText.isNotEmpty, true);
      expect(cards.first.backText.isNotEmpty, true);
    });
  });

  group('Hive Local Caching Repository Tests', () {
    late QuizRepository quizRepo;
    late FlashcardsRepository cardsRepo;

    setUp(() async {
      quizRepo = AuraQuizRepository();
      cardsRepo = AuraFlashcardsRepository();
      await quizRepo.init();
      await cardsRepo.init();
    });

    test('QuizRepository saves, retrieves, and deletes quiz sessions cleanly', () async {
      const question = QuizQuestion(
        question: 'Q1',
        options: ['A', 'B'],
        correctIndex: 1,
        explanation: 'E1',
      );
      final session = QuizSession(
        id: 'test-quiz-123',
        title: 'Physics Checkpoint',
        category: 'Physics',
        questions: const [question],
        score: -1,
      );

      // Save
      await quizRepo.saveQuiz(session);

      // Retrieve
      final listBefore = await quizRepo.getQuizzes();
      expect(listBefore.any((q) => q.id == 'test-quiz-123'), true);
      final retrieved = listBefore.firstWhere((q) => q.id == 'test-quiz-123');
      expect(retrieved.title, 'Physics Checkpoint');
      expect(retrieved.questions.first.question, 'Q1');

      // Delete
      await quizRepo.deleteQuiz('test-quiz-123');
      final listAfter = await quizRepo.getQuizzes();
      expect(listAfter.any((q) => q.id == 'test-quiz-123'), false);
    });

    test('FlashcardsRepository saves, retrieves, and deletes decks cleanly', () async {
      const card = Flashcard(
        id: 'fc-test',
        frontText: 'F1',
        backText: 'B1',
        category: 'Mathematics',
      );
      final deck = FlashcardDeck(
        id: 'test-deck-123',
        title: 'Algebra Cells',
        category: 'Mathematics',
        cards: const [card],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Save
      await cardsRepo.saveDeck(deck);

      // Retrieve
      final listBefore = await cardsRepo.getDecks();
      expect(listBefore.any((d) => d.id == 'test-deck-123'), true);
      final retrieved = listBefore.firstWhere((d) => d.id == 'test-deck-123');
      expect(retrieved.title, 'Algebra Cells');
      expect(retrieved.cards.first.frontText, 'F1');

      // Delete
      await cardsRepo.deleteDeck('test-deck-123');
      final listAfter = await cardsRepo.getDecks();
      expect(listAfter.any((d) => d.id == 'test-deck-123'), false);
    });
  });

  group('Quiz Gameplay flow state StateNotifier Tests', () {
    test('Initial gameplay state displays defaults', () {
      final notifier = QuizGamePlayNotifier();
      expect(notifier.state.currentQuestionIndex, 0);
      expect(notifier.state.selectedOptionIndex, -1);
      expect(notifier.state.correctAnswersCount, 0);
      expect(notifier.state.isAnswerSubmitted, false);
      expect(notifier.state.isCompleted, false);
    });

    test('startSession resets state variables', () {
      final notifier = QuizGamePlayNotifier();
      notifier.selectOption(2);
      notifier.submitAnswer(2, 2);
      expect(notifier.state.isAnswerSubmitted, true);

      notifier.startSession();
      expect(notifier.state.selectedOptionIndex, -1);
      expect(notifier.state.isAnswerSubmitted, false);
    });

    test('selectOption updates choice selection correctly', () {
      final notifier = QuizGamePlayNotifier();
      notifier.selectOption(3);
      expect(notifier.state.selectedOptionIndex, 3);
    });

    test('submitAnswer increments scores correctly on match', () {
      final notifier = QuizGamePlayNotifier();
      notifier.submitAnswer(1, 1); // correct answer
      expect(notifier.state.correctAnswersCount, 1);
      expect(notifier.state.isAnswerSubmitted, true);
    });

    test('submitAnswer does not increment scores on incorrect match', () {
      final notifier = QuizGamePlayNotifier();
      notifier.submitAnswer(1, 0); // wrong answer
      expect(notifier.state.correctAnswersCount, 0);
      expect(notifier.state.isAnswerSubmitted, true);
    });

    test('nextQuestion transitions correctly to next item', () {
      final notifier = QuizGamePlayNotifier();
      notifier.submitAnswer(1, 1);
      notifier.nextQuestion(5); // total questions = 5

      expect(notifier.state.currentQuestionIndex, 1);
      expect(notifier.state.selectedOptionIndex, -1);
      expect(notifier.state.isAnswerSubmitted, false);
    });

    test('nextQuestion sets completed flag at boundary', () {
      final notifier = QuizGamePlayNotifier();
      notifier.submitAnswer(1, 1);
      notifier.nextQuestion(1); // total questions = 1

      expect(notifier.state.isCompleted, true);
    });
  });

  group('Flashcards Controller Provider Tests', () {
    test('rateCard correctly updates difficulty rating inside active deck', () async {
      final cardsRepo = AuraFlashcardsRepository();
      await cardsRepo.init();

      const card = Flashcard(
        id: 'fc-rating-test',
        frontText: 'F1',
        backText: 'B1',
        category: 'Mathematics',
      );
      final deck = FlashcardDeck(
        id: 'test-deck-rating',
        title: 'Rating Deck',
        category: 'Mathematics',
        cards: const [card],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final container = ProviderContainer(
        overrides: [
          flashcardsRepositoryProvider.overrideWithValue(cardsRepo),
        ],
      );
      addTearDown(container.dispose);

      // Save deck first
      await cardsRepo.saveDeck(deck);

      // Set as active deck
      container.read(activeDeckProvider.notifier).state = deck;

      // Rate card
      await container.read(flashcardsControllerProvider.notifier).rateCard('test-deck-rating', 'fc-rating-test', 'hard');

      // Verify active deck rating updated
      final updatedActive = container.read(activeDeckProvider);
      expect(updatedActive?.cards.first.difficultyRating, 'hard');

      // Clean up
      await cardsRepo.deleteDeck('test-deck-rating');
    });
  });
}
