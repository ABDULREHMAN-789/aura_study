import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart' as fs;
import 'package:firebase_core/firebase_core.dart';
import 'package:aura_study/features/notes/domain/note_model.dart';

abstract class NotesRepository {
  Future<void> init();
  Future<List<StudyNote>> getNotes();
  Stream<List<StudyNote>> watchNotes();
  Future<void> saveNote(StudyNote note);
  Future<void> deleteNote(String id);
  bool get isMockMode;
}

class AuraNotesRepository implements NotesRepository {
  final fs.FirebaseFirestore? _firestore;
  final String? _userId;
  late final Box<dynamic> _notesBox;
  bool _isInitialized = false;

  AuraNotesRepository({fs.FirebaseFirestore? firestore, String? userId})
      : _firestore = firestore ?? _getFirestoreInstance(),
        _userId = userId;

  static fs.FirebaseFirestore? _getFirestoreInstance() {
    try {
      if (Firebase.apps.isNotEmpty) {
        return fs.FirebaseFirestore.instance;
      }
    } catch (e) {
      // Firebase core initialized but firestore not ready or skipped
    }
    return null;
  }

  bool get _useFirestore => _firestore != null && _userId != null;

  @override
  bool get isMockMode => !_useFirestore;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    _notesBox = await Hive.openBox<dynamic>('aura_study_notes');
    
    // Seed initial mock notes if the cache box is empty
    if (_notesBox.isEmpty) {
      await _seedMockNotes();
    }
    _isInitialized = true;
  }

  List<StudyNote> _getLocalNotes() {
    final List<StudyNote> notes = [];
    for (final key in _notesBox.keys) {
      final dynamic val = _notesBox.get(key);
      if (val != null) {
        try {
          final Map<String, dynamic> json;
          if (val is Map) {
            json = Map<String, dynamic>.from(val);
          } else {
            continue;
          }
          notes.add(StudyNote.fromJson(json));
        } catch (e) {
          debugPrint("AURA NOTES ERROR: Error parsing study note: $e");
        }
      }
    }
    // Sort pinned notes to the top, and sort by updatedAt descending
    notes.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.updatedAt.compareTo(a.updatedAt);
    });
    return notes;
  }

  @override
  Future<List<StudyNote>> getNotes() async {
    await init();
    return _getLocalNotes();
  }

  @override
  Stream<List<StudyNote>> watchNotes() {
    final controller = StreamController<List<StudyNote>>.broadcast();
    
    // Make sure we are initialized before emitting
    init().then((_) {
      if (controller.isClosed) return;
      controller.add(_getLocalNotes());
      
      // Listen to Hive local changes
      final hiveSubscription = _notesBox.watch().listen((event) {
        if (!controller.isClosed) {
          controller.add(_getLocalNotes());
        }
      });

      // Sync Firestore collection to Hive local if logged in & online
      StreamSubscription<fs.QuerySnapshot<Map<String, dynamic>>>? firestoreSubscription;
      if (_useFirestore) {
        try {
          firestoreSubscription = _firestore!
              .collection('users')
              .doc(_userId)
              .collection('notes')
              .snapshots()
              .listen((snapshot) async {
            for (final doc in snapshot.docs) {
              final data = doc.data();
              // Make sure data contains 'id' matching document id
              data['id'] = doc.id;
              await _notesBox.put(doc.id, data);
            }
            for (final change in snapshot.docChanges) {
              if (change.type == fs.DocumentChangeType.removed) {
                await _notesBox.delete(change.doc.id);
              }
            }
            if (!controller.isClosed) {
              controller.add(_getLocalNotes());
            }
          }, onError: (e) {
            debugPrint("AURA SYNC WARNING: Cloud Firestore notes stream error: $e");
          });
        } catch (e) {
          debugPrint("AURA SYNC WARNING: Failed to attach cloud listener: $e");
        }
      }

      controller.onCancel = () {
        hiveSubscription.cancel();
        firestoreSubscription?.cancel();
      };
    });

    return controller.stream;
  }

  @override
  Future<void> saveNote(StudyNote note) async {
    await init();
    final json = note.toJson();
    
    // 1. Write to local Hive cache immediately for low-latency feedback
    await _notesBox.put(note.id, json);

    // 2. Sync to firestore if active
    if (_useFirestore) {
      try {
        await _firestore!
            .collection('users')
            .doc(_userId)
            .collection('notes')
            .doc(note.id)
            .set(json);
      } catch (e) {
        debugPrint("AURA SYNC WARNING: Firestore cloud save failed (saved offline locally): $e");
      }
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    await init();
    
    // 1. Delete from local cache immediately
    await _notesBox.delete(id);

    // 2. Sync deletion to firestore if active
    if (_useFirestore) {
      try {
        await _firestore!
            .collection('users')
            .doc(_userId)
            .collection('notes')
            .doc(id)
            .delete();
      } catch (e) {
        debugPrint("AURA SYNC WARNING: Firestore cloud delete failed (deleted offline locally): $e");
      }
    }
  }

  Future<void> _seedMockNotes() async {
    final now = DateTime.now();
    final mockNotes = [
      StudyNote(
        id: 'mock-note-quantum',
        title: "Quantum Wave Equations",
        content: "Exploration of Schrödinger's wave equation, wave-particle duality, and particle in a 1D potential box framework. Essential references for standard quantum configurations.",
        category: "Physics",
        tags: ["Physics", "Quantum", "AI-Generated"],
        isPinned: true,
        colorHex: "0xFF3F51B5", // Indigo
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(hours: 4)),
      ),
      StudyNote(
        id: 'mock-note-organic',
        title: "Organic Compounds Nomenclature",
        content: "IUPAC rules for organic compound classification. Essential prefixes, suffixes, and numbering priority schemas for carbon chains.",
        category: "Chemistry",
        tags: ["Chemistry", "Organic"],
        isPinned: true,
        colorHex: "0xFFE91E63", // Pink
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      StudyNote(
        id: 'mock-note-calculus',
        title: "Calculus Limits & Integrals",
        content: "Standard trigonometric limit identities and methods of integration by parts. Quick reference sheet for upcoming midterms.",
        category: "Math",
        tags: ["Math", "Calculus"],
        isPinned: false,
        colorHex: "0xFF00F0FF", // Cyan
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
      ),
      StudyNote(
        id: 'mock-note-thermo',
        title: "Voice Lecture: Thermodynamics",
        content: "Automatic transcript: Heat cannot spontaneously flow from a material at cold temperature to a material at hot temperature under natural conditions.",
        category: "Physics",
        tags: ["Physics", "Voice-Note"],
        isPinned: false,
        colorHex: "0xFF4CAF50", // Green
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(days: 5)),
      ),
    ];

    for (final note in mockNotes) {
      await _notesBox.put(note.id, note.toJson());
    }
  }
}
