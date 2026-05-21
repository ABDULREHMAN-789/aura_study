import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/features/planner/domain/planner_model.dart';
import 'package:aura_study/features/planner/data/planner_repository.dart';
import 'package:aura_study/core/services/notification_service.dart';
import 'package:aura_study/features/ai/presentation/providers/ai_providers.dart';

/// Provider for the PlannerRepository singleton
final plannerRepositoryProvider = Provider<PlannerRepository>((ref) {
  return AuraPlannerRepository();
});

/// Provider for the NotificationService singleton
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// StateProvider holding AI planner synergy activity loading state
final aiPlannerLoadingProvider = StateProvider<bool>((ref) => false);

/// StateNotifierProvider managing active study tasks and notification bindings
final plannerListProvider = StateNotifierProvider<PlannerNotifier, List<StudyTask>>((ref) {
  final repository = ref.watch(plannerRepositoryProvider);
  final notificationService = ref.watch(notificationServiceProvider);
  final aiService = ref.watch(aiServiceProvider);
  return PlannerNotifier(repository, notificationService, aiService)..loadTasks();
});

class PlannerNotifier extends StateNotifier<List<StudyTask>> {
  final PlannerRepository _repository;
  final NotificationService _notificationService;
  final dynamic _aiService; // Using dynamic to bypass strict abstract casting during tests if needed

  PlannerNotifier(
    this._repository,
    this._notificationService,
    this._aiService,
  ) : super([]);

  /// Load tasks from local Hive box and update active state
  Future<void> loadTasks() async {
    try {
      final tasks = await _repository.getTasks();
      state = tasks;
    } catch (e) {
      state = [];
    }
  }

  /// Create and save a new study task, scheduling local notification if enabled
  Future<void> addTask(StudyTask task) async {
    // Generate unique notification ID if reminder is active
    int? notifId = task.notificationId;
    if (task.reminderEnabled && notifId == null) {
      notifId = task.id.hashCode.abs() & 0x7FFFFFFF;
    }

    final savedTask = task.copyWith(notificationId: notifId);

    // Schedule notification if reminder enabled
    if (savedTask.reminderEnabled && notifId != null) {
      await _notificationService.scheduleNotification(
        id: notifId,
        title: "Aura Study Alert: ${savedTask.title}",
        body: "Your study session for ${savedTask.category} is starting now! details: ${savedTask.details}",
        scheduledTime: savedTask.scheduledTime,
      );
    }

    await _repository.saveTask(savedTask);
    await loadTasks();
  }

  /// Toggle task completion, canceling outstanding reminders if completed
  Future<void> toggleTaskCompletion(String id) async {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx == -1) return;

    final originalTask = state[idx];
    final toggledCompleted = !originalTask.isCompleted;
    
    int? notifId = originalTask.notificationId;
    if (originalTask.reminderEnabled && notifId == null) {
      notifId = originalTask.id.hashCode.abs() & 0x7FFFFFFF;
    }

    final updatedTask = originalTask.copyWith(
      isCompleted: toggledCompleted,
      notificationId: notifId,
    );

    if (toggledCompleted && notifId != null) {
      // Cancel outstanding notification if task is marked complete
      await _notificationService.cancelNotification(notifId);
    } else if (!toggledCompleted && updatedTask.reminderEnabled && notifId != null) {
      // Re-schedule notification if task is uncompleted and reminder is active
      if (updatedTask.scheduledTime.isAfter(DateTime.now())) {
        await _notificationService.scheduleNotification(
          id: notifId,
          title: "Aura Study Alert: ${updatedTask.title}",
          body: "Your study session for ${updatedTask.category} is starting now! details: ${updatedTask.details}",
          scheduledTime: updatedTask.scheduledTime,
        );
      }
    }

    await _repository.saveTask(updatedTask);
    await loadTasks();
  }

  /// Delete a study task, canceling any pending scheduled reminders
  Future<void> deleteTask(String id) async {
    final idx = state.indexWhere((t) => t.id == id);
    if (idx != -1) {
      final task = state[idx];
      if (task.notificationId != null) {
        await _notificationService.cancelNotification(task.notificationId!);
      }
    }
    await _repository.deleteTask(id);
    await loadTasks();
  }

  /// Draft automatic study task events based on the core of a note using Gemini
  Future<bool> generateAIStudyPlan(String noteTitle, String noteContent, WidgetRef ref) async {
    ref.read(aiPlannerLoadingProvider.notifier).state = true;
    try {
      final generatedSchedules = await _aiService.generateStudySchedule(noteTitle, noteContent);
      final rand = Random();
      
      for (final item in generatedSchedules) {
        final title = item['title'] as String? ?? 'Review Session';
        final details = item['details'] as String? ?? 'Deep dive note parameters.';
        final category = item['category'] as String? ?? 'General';
        final hoursFromNow = item['hoursFromNow'] as int? ?? 2;
        final reminderEnabled = item['reminderEnabled'] as bool? ?? true;

        final targetTime = DateTime.now().add(Duration(hours: hoursFromNow));
        final uniqueId = 'ai-task-${DateTime.now().millisecondsSinceEpoch}-${rand.nextInt(100000)}';
        final notifId = uniqueId.hashCode.abs() & 0x7FFFFFFF;

        final task = StudyTask(
          id: uniqueId,
          title: title,
          details: details,
          category: category,
          scheduledTime: targetTime,
          isCompleted: false,
          reminderEnabled: reminderEnabled,
          notificationId: notifId,
        );

        if (reminderEnabled) {
          await _notificationService.scheduleNotification(
            id: notifId,
            title: "Aura Study Alert: $title",
            body: "Your study session for $category is starting now! details: $details",
            scheduledTime: targetTime,
          );
        }

        await _repository.saveTask(task);
      }
      
      await loadTasks();
      ref.read(aiPlannerLoadingProvider.notifier).state = false;
      return true;
    } catch (e) {
      ref.read(aiPlannerLoadingProvider.notifier).state = false;
      return false;
    }
  }
}
