import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aura_study/features/flashcards/domain/flashcard_model.dart';

abstract class FlashcardsRepository {
  Future<void> init();
  Future<List<FlashcardDeck>> getDecks();
  Future<void> saveDeck(FlashcardDeck deck);
  Future<void> deleteDeck(String id);
}

class AuraFlashcardsRepository implements FlashcardsRepository {
  late final Box<dynamic> _decksBox;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    _decksBox = await Hive.openBox<dynamic>('aura_study_flashcards');
    _isInitialized = true;
  }

  @override
  Future<List<FlashcardDeck>> getDecks() async {
    await init();
    final List<FlashcardDeck> decks = [];
    for (final key in _decksBox.keys) {
      final val = _decksBox.get(key);
      if (val != null && val is Map) {
        try {
          decks.add(FlashcardDeck.fromJson(Map<String, dynamic>.from(val)));
        } catch (e) {
          debugPrint("AURA FLASHCARDS REPO: Parse error: $e");
        }
      }
    }
    decks.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return decks;
  }

  @override
  Future<void> saveDeck(FlashcardDeck deck) async {
    await init();
    await _decksBox.put(deck.id, deck.toJson());
  }

  @override
  Future<void> deleteDeck(String id) async {
    await init();
    await _decksBox.delete(id);
  }
}
