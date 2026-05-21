import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:aura_study/features/notes/domain/note_model.dart';
import 'package:aura_study/features/notes/data/notes_repository.dart';

void main() {
  late Directory tempDir;
  
  setUpAll(() async {
    // Setup temporary local system directory for Hive mocks in unit testing environment
    tempDir = await Directory.systemTemp.createTemp('aura_notes_test_');
    Hive.init(tempDir.path);
  });

  tearDownAll(() async {
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('StudyNote Model Tests', () {
    test('StudyNote serialization and deserialization maps correctly', () {
      final now = DateTime(2026, 5, 21);
      final note = StudyNote(
        id: 'test-id',
        title: 'Test Note',
        content: 'Test content',
        category: 'Physics',
        tags: ['physics', 'study'],
        isPinned: true,
        colorHex: '0xFF00F0FF',
        createdAt: now,
        updatedAt: now,
      );

      final json = note.toJson();
      expect(json['id'], 'test-id');
      expect(json['title'], 'Test Note');
      expect(json['content'], 'Test content');
      expect(json['category'], 'Physics');
      expect(json['tags'], ['physics', 'study']);
      expect(json['isPinned'], true);
      expect(json['colorHex'], '0xFF00F0FF');
      expect(json['createdAt'], '2026-05-21T00:00:00.000');
      expect(json['updatedAt'], '2026-05-21T00:00:00.000');

      final parsed = StudyNote.fromJson(json);
      expect(parsed.id, note.id);
      expect(parsed.title, note.title);
      expect(parsed.content, note.content);
      expect(parsed.category, note.category);
      expect(parsed.tags, note.tags);
      expect(parsed.isPinned, note.isPinned);
      expect(parsed.colorHex, note.colorHex);
      expect(parsed.createdAt, note.createdAt);
      expect(parsed.updatedAt, note.updatedAt);
    });

    test('StudyNote snippet truncates content limits correctly', () {
      const shortContent = "Short note content.";
      final shortNote = StudyNote(
        id: '1',
        title: 'Title',
        content: shortContent,
        category: 'Physics',
        tags: [],
        isPinned: false,
        colorHex: '0xFF00F0FF',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      expect(shortNote.snippet, shortContent);

      final longContent = "A" * 150;
      final longNote = shortNote.copyWith(content: longContent);
      expect(longNote.snippet.length, 120);
      expect(longNote.snippet.endsWith("..."), true);
    });

    test('StudyNote copyWith overrides target parameters correctly', () {
      final note = StudyNote(
        id: '1',
        title: 'Original',
        content: 'Original Content',
        category: 'Physics',
        tags: [],
        isPinned: false,
        colorHex: '0xFF00F0FF',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final updated = note.copyWith(
        title: 'Updated Title',
        isPinned: true,
      );

      expect(updated.title, 'Updated Title');
      expect(updated.isPinned, true);
      expect(updated.id, note.id); 
    });
  });

  group('AuraNotesRepository Hive CRUD Tests', () {
    late AuraNotesRepository repository;

    setUp(() async {
      await Hive.deleteBoxFromDisk('aura_study_notes');
      repository = AuraNotesRepository();
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk('aura_study_notes');
    });

    test('Repository initialization seeds mock repository database when empty', () async {
      expect(repository.isMockMode, true);
      
      final notes = await repository.getNotes();
      expect(notes.isNotEmpty, true);
      
      expect(notes.any((n) => n.title.contains('Quantum')), true);
      expect(notes.any((n) => n.title.contains('Organic')), true);
    });

    test('Repository saves custom notes locally and retrieves perfectly', () async {
      await repository.init();
      
      final newNote = StudyNote(
        id: 'custom-note-1',
        title: 'Dynamic Equations',
        content: 'Newtonian mechanics exploration',
        category: 'Physics',
        tags: ['physics'],
        isPinned: true,
        colorHex: '0xFF00F0FF',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.saveNote(newNote);

      final notes = await repository.getNotes();
      expect(notes.any((n) => n.id == 'custom-note-1'), true);

      final fetchedNote = notes.firstWhere((n) => n.id == 'custom-note-1');
      expect(fetchedNote.title, 'Dynamic Equations');
      expect(fetchedNote.content, 'Newtonian mechanics exploration');
    });

    test('Repository deletes target custom note successfully', () async {
      await repository.init();
      final notesBefore = await repository.getNotes();
      final targetId = notesBefore.first.id;

      await repository.deleteNote(targetId);

      final notesAfter = await repository.getNotes();
      expect(notesAfter.any((n) => n.id == targetId), false);
      expect(notesAfter.length, notesBefore.length - 1);
    });
  });
}
