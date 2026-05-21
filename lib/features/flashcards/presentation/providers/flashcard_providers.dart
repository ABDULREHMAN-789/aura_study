import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/core/services/ai_service.dart';
import 'package:aura_study/features/ai/presentation/providers/ai_providers.dart';
import 'package:aura_study/features/flashcards/data/flashcards_repository.dart';
import 'package:aura_study/features/flashcards/domain/flashcard_model.dart';

/// Provider exposing the concrete FlashcardsRepository
final flashcardsRepositoryProvider = Provider<FlashcardsRepository>((ref) {
  return AuraFlashcardsRepository();
});

/// Reactive StateNotifierProvider tracking available flashcard decks in Hive
final flashcardDeckListProvider = StateNotifierProvider<FlashcardDeckListNotifier, AsyncValue<List<FlashcardDeck>>>((ref) {
  final repo = ref.watch(flashcardsRepositoryProvider);
  return FlashcardDeckListNotifier(repo);
});

class FlashcardDeckListNotifier extends StateNotifier<AsyncValue<List<FlashcardDeck>>> {
  final FlashcardsRepository _repository;

  FlashcardDeckListNotifier(this._repository) : super(const AsyncValue.loading()) {
    loadDecks();
  }

  Future<void> loadDecks() async {
    state = const AsyncValue.loading();
    try {
      final list = await _repository.getDecks();
      state = AsyncValue.data(list);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> saveDeck(FlashcardDeck deck) async {
    try {
      await _repository.saveDeck(deck);
      await loadDecks();
    } catch (e) {
      debugPrint("AURA FLASHCARD PROVIDERS ERROR: Save failed: $e");
    }
  }

  Future<void> deleteDeck(String id) async {
    try {
      await _repository.deleteDeck(id);
      await loadDecks();
    } catch (e) {
      debugPrint("AURA FLASHCARD PROVIDERS ERROR: Delete failed: $e");
    }
  }
}

/// Tracks the active deck currently being reviewed by the scholar
final activeDeckProvider = StateProvider<FlashcardDeck?>((ref) => null);

/// Notifier handling deck modifications, including rating specific flashcards and saving states
final flashcardsControllerProvider = StateNotifierProvider<FlashcardsController, AsyncValue<void>>((ref) {
  final repo = ref.watch(flashcardsRepositoryProvider);
  final listNotifier = ref.watch(flashcardDeckListProvider.notifier);
  final activeDeckController = ref.watch(activeDeckProvider.notifier);
  return FlashcardsController(repo, listNotifier, activeDeckController);
});

class FlashcardsController extends StateNotifier<AsyncValue<void>> {
  final FlashcardsRepository _repository;
  final FlashcardDeckListNotifier _listNotifier;
  final StateController<FlashcardDeck?> _activeDeckController;

  FlashcardsController(
    this._repository,
    this._listNotifier,
    this._activeDeckController,
  ) : super(const AsyncValue.data(null));

  /// Update the difficulty rating of a single flashcard inside a deck and persist it
  Future<void> rateCard(String deckId, String cardId, String difficulty) async {
    final activeDeck = _activeDeckController.state;
    if (activeDeck == null || activeDeck.id != deckId) return;

    final updatedCards = activeDeck.cards.map((card) {
      if (card.id == cardId) {
        return card.copyWith(difficultyRating: difficulty);
      }
      return card;
    }).toList();

    final updatedDeck = activeDeck.copyWith(
      cards: updatedCards,
      updatedAt: DateTime.now(),
    );

    _activeDeckController.state = updatedDeck;
    await _repository.saveDeck(updatedDeck);
    await _listNotifier.loadDecks();
  }
}

/// Handles asynchronous AI flashcard deck synthesizers and saving outputs
final flashcardGeneratorControllerProvider = StateNotifierProvider<FlashcardGeneratorController, AsyncValue<FlashcardDeck?>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  final listNotifier = ref.watch(flashcardDeckListProvider.notifier);
  return FlashcardGeneratorController(aiService, listNotifier);
});

class FlashcardGeneratorController extends StateNotifier<AsyncValue<FlashcardDeck?>> {
  final AIService _aiService;
  final FlashcardDeckListNotifier _listNotifier;

  FlashcardGeneratorController(this._aiService, this._listNotifier) : super(const AsyncValue.data(null));

  Future<FlashcardDeck?> generateDeckFromContent(String title, String content, String category) async {
    state = const AsyncValue.loading();
    try {
      final cards = await _aiService.generateFlashcards(title, content);
      final deck = FlashcardDeck(
        id: 'deck-${DateTime.now().millisecondsSinceEpoch}',
        title: title.startsWith("Deck:") ? title : "Deck: $title",
        category: category,
        cards: cards,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _listNotifier.saveDeck(deck);
      state = AsyncValue.data(deck);
      return deck;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return null;
    }
  }
}
