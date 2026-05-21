import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:aura_study/features/planner/domain/planner_model.dart';

abstract class PlannerRepository {
  Future<void> init();
  Future<List<StudyTask>> getTasks();
  Future<void> saveTask(StudyTask task);
  Future<void> deleteTask(String id);
  Future<void> clearAll();
}

class AuraPlannerRepository implements PlannerRepository {
  late final Box<dynamic> _plannerBox;
  bool _isInitialized = false;

  @override
  Future<void> init() async {
    if (_isInitialized) return;
    _plannerBox = await Hive.openBox<dynamic>('aura_study_planner');
    _isInitialized = true;
  }

  @override
  Future<List<StudyTask>> getTasks() async {
    await init();
    final List<StudyTask> tasks = [];
    for (final key in _plannerBox.keys) {
      final val = _plannerBox.get(key);
      if (val != null && val is Map) {
        try {
          tasks.add(StudyTask.fromJson(Map<String, dynamic>.from(val)));
        } catch (e) {
          debugPrint("AURA PLANNER REPO: Parse error: $e");
        }
      }
    }
    // Sort tasks: uncompleted first, then by scheduledTime ascending
    tasks.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.scheduledTime.compareTo(b.scheduledTime);
    });
    return tasks;
  }

  @override
  Future<void> saveTask(StudyTask task) async {
    await init();
    await _plannerBox.put(task.id, task.toJson());
  }

  @override
  Future<void> deleteTask(String id) async {
    await init();
    await _plannerBox.delete(id);
  }

  @override
  Future<void> clearAll() async {
    await init();
    await _plannerBox.clear();
  }
}
