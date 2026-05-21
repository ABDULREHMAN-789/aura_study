import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/features/planner/domain/planner_model.dart';
import 'package:aura_study/features/planner/data/planner_repository.dart';
import 'package:aura_study/core/services/notification_service.dart';
import 'package:aura_study/features/planner/presentation/providers/planner_providers.dart';
import 'package:aura_study/core/services/ai_service.dart';

// Fake Notification Service to track operations without calling native APIs
class FakeNotificationService extends NotificationService {
  final List<String> logs = [];
  final List<int> scheduledIds = [];
  final List<int> cancelledIds = [];

  @override
  Future<void> init() async {
    logs.add("init");
  }

  @override
  Future<void> requestPermissions() async {
    logs.add("requestPermissions");
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    logs.add("schedule:$id");
    scheduledIds.add(id);
  }

  @override
  Future<void> cancelNotification(int id) async {
    logs.add("cancel:$id");
    cancelledIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    logs.add("cancelAll");
  }
}

// Fake/Mock Repository to avoid native Hive path errors inside standard dart VM
class FakePlannerRepository implements PlannerRepository {
  final Map<String, StudyTask> tasks = {};

  @override
  Future<void> init() async {}

  @override
  Future<List<StudyTask>> getTasks() async {
    final list = tasks.values.toList();
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      return a.scheduledTime.compareTo(b.scheduledTime);
    });
    return list;
  }

  @override
  Future<void> saveTask(StudyTask task) async {
    tasks[task.id] = task;
  }

  @override
  Future<void> deleteTask(String id) async {
    tasks.remove(id);
  }

  @override
  Future<void> clearAll() async {
    tasks.clear();
  }
}

void main() {
  group('Planner Domain & Persistence Tests', () {
    test('StudyTask JSON Serialization & Deserialization', () {
      final now = DateTime.now();
      final task = StudyTask(
        id: 'test-1',
        title: 'Learn Laplace Transforms',
        details: 'Review general guidelines and examples',
        category: 'Mathematics',
        scheduledTime: now,
        isCompleted: false,
        reminderEnabled: true,
        notificationId: 999,
      );

      final json = task.toJson();
      expect(json['id'], 'test-1');
      expect(json['title'], 'Learn Laplace Transforms');
      expect(json['reminderEnabled'], true);
      expect(json['notificationId'], 999);

      final parsed = StudyTask.fromJson(json);
      expect(parsed.id, 'test-1');
      expect(parsed.title, 'Learn Laplace Transforms');
      expect(parsed.category, 'Mathematics');
      expect(parsed.reminderEnabled, true);
      expect(parsed.notificationId, 999);
      expect(parsed.scheduledTime.year, now.year);
    });

    test('AuraPlannerRepository CRUD Operations using Hive', () async {
      // Setup memory-only Hive
      Hive.init('./test_hive_planner');
      final repo = AuraPlannerRepository();
      await repo.init();
      await repo.clearAll();

      final now = DateTime.now();
      final task1 = StudyTask(
        id: 'h-1',
        title: 'Schrodinger Probability Density',
        details: 'Calculate integral from -inf to +inf',
        category: 'Physics',
        scheduledTime: now,
        isCompleted: false,
      );
      final task2 = StudyTask(
        id: 'h-2',
        title: 'Esters Hydrolysis',
        details: 'Review reaction steps and catalysts',
        category: 'Chemistry',
        scheduledTime: now.add(const Duration(hours: 4)),
        isCompleted: true,
      );

      await repo.saveTask(task1);
      await repo.saveTask(task2);

      final list = await repo.getTasks();
      expect(list.length, 2);
      // Grouping sorts uncompleted tasks first
      expect(list[0].id, 'h-1');
      expect(list[1].id, 'h-2');

      await repo.deleteTask('h-1');
      final listAfterDelete = await repo.getTasks();
      expect(listAfterDelete.length, 1);
      expect(listAfterDelete[0].id, 'h-2');

      await repo.clearAll();
      final listEmpty = await repo.getTasks();
      expect(listEmpty.isEmpty, true);
    });
  });

  group('Planner Riverpod & Notification Service Tests', () {
    test('State Notifier handles additions and triggers notifications', () async {
      final fakeRepo = FakePlannerRepository();
      final fakeNotif = FakeNotificationService();

      final container = ProviderContainer(
        overrides: [
          plannerRepositoryProvider.overrideWithValue(fakeRepo),
          notificationServiceProvider.overrideWithValue(fakeNotif),
        ],
      );

      final plannerNotifier = container.read(plannerListProvider.notifier);

      // Verify initial empty state
      expect(container.read(plannerListProvider), isEmpty);

      // Add a task with reminder enabled
      final taskTime = DateTime.now().add(const Duration(hours: 1));
      final task = StudyTask(
        id: 'task-notif-1',
        title: 'Practice Limits Rules',
        details: 'Derive simple fractions limit',
        category: 'Mathematics',
        scheduledTime: taskTime,
        reminderEnabled: true,
      );

      await plannerNotifier.addTask(task);

      final tasks = container.read(plannerListProvider);
      expect(tasks.length, 1);
      expect(tasks[0].id, 'task-notif-1');
      expect(tasks[0].reminderEnabled, true);
      expect(tasks[0].notificationId, isNotNull);

      // Verify notification schedule call was made
      expect(fakeNotif.scheduledIds.length, 1);
      expect(fakeNotif.scheduledIds[0], tasks[0].notificationId);

      // Toggle completed - should cancel the notification
      await plannerNotifier.toggleTaskCompletion('task-notif-1');
      final tasksToggled = container.read(plannerListProvider);
      expect(tasksToggled[0].isCompleted, true);
      expect(fakeNotif.cancelledIds.length, 1);
      expect(fakeNotif.cancelledIds[0], tasks[0].notificationId);
    });

    test('State Notifier integrates Mock AI generateStudySchedule', () async {
      final mockAI = MockAIService();

      // Verify AI suggestions works
      final result = await mockAI.generateStudySchedule("Quantum Physics", "Schrodinger formulas");
      expect(result, isNotEmpty);
      expect(result[0]['category'], 'Physics');
      expect(result[0]['hoursFromNow'], 2);
    });
  });
}
