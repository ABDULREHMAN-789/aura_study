import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/features/auth/presentation/providers/auth_providers.dart';
import 'package:aura_study/features/notes/domain/note_model.dart';
import 'package:aura_study/features/notes/data/notes_repository.dart';

/// Provider for the NotesRepository layer
final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final authState = ref.watch(authStateProvider).value;
  final userId = authState?.uid;
  return AuraNotesRepository(userId: userId);
});

/// StreamProvider listening to live notes cache and cloud synchronization
final notesStreamProvider = StreamProvider<List<StudyNote>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return repo.watchNotes();
});

/// Reactive Search Query Provider
final notesSearchQueryProvider = StateProvider<String>((ref) => "");

/// Reactive Selected Category Provider
final notesSelectedCategoryProvider = StateProvider<String>((ref) => "All");

/// StateProvider holding the active note currently being created or edited
final activeNoteProvider = StateProvider<StudyNote?>((ref) => null);

/// Selector provider combining search queries, category selections, and streaming notes
final filteredNotesProvider = Provider<List<StudyNote>>((ref) {
  final notesAsyncValue = ref.watch(notesStreamProvider);
  final notes = notesAsyncValue.value ?? [];
  final searchQuery = ref.watch(notesSearchQueryProvider).trim().toLowerCase();
  final selectedCategory = ref.watch(notesSelectedCategoryProvider);

  return notes.where((note) {
    // 1. Category selection match
    final matchesCategory = selectedCategory == 'All' ||
        note.category.trim().toLowerCase() == selectedCategory.trim().toLowerCase();

    // 2. Search query matches title, content, or tags
    final matchesSearch = searchQuery.isEmpty ||
        note.title.toLowerCase().contains(searchQuery) ||
        note.content.toLowerCase().contains(searchQuery) ||
        note.tags.any((tag) => tag.toLowerCase().contains(searchQuery));

    return matchesCategory && matchesSearch;
  }).toList();
});

/// StateNotifier handling CRUD operations reactively with visual load state indicators
final notesControllerProvider = StateNotifierProvider<NotesController, AsyncValue<void>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return NotesController(repo);
});

class NotesController extends StateNotifier<AsyncValue<void>> {
  final NotesRepository _repository;
  NotesController(this._repository) : super(const AsyncValue.data(null));

  /// Save or update a study note in Hive cache and Cloud Firestore
  Future<bool> saveNote(StudyNote note) async {
    state = const AsyncValue.loading();
    try {
      await _repository.saveNote(note);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Delete a study note from Hive cache and Cloud Firestore
  Future<bool> deleteNote(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repository.deleteNote(id);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }
}
