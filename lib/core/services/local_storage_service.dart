import 'package:hive_flutter/hive_flutter.dart';

class LocalStorageService {
  static const String _boxName = 'aura_study_cache';
  late Box _box;

  // Singleton Instance
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  /// Initialize Hive and open our default cache box
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// Generic write method
  Future<void> write<T>(String key, T value) async {
    await _box.put(key, value);
  }

  /// Generic read method
  T? read<T>(String key) {
    return _box.get(key) as T?;
  }

  /// Delete a key
  Future<void> delete(String key) async {
    await _box.delete(key);
  }

  /// Check if a key exists
  bool hasKey(String key) {
    return _box.containsKey(key);
  }

  /// Core helpers for study assistant states
  Future<void> saveStreak(int streakCount) async {
    await write<int>('daily_streak', streakCount);
  }

  int getStreak() {
    return read<int>('daily_streak') ?? 0;
  }

  Future<void> saveAIUsage(int usageCount) async {
    await write<int>('ai_usage_today', usageCount);
  }

  int getAIUsage() {
    return read<int>('ai_usage_today') ?? 0;
  }

  /// Clean all local caches
  Future<void> clearAll() async {
    await _box.clear();
  }
}
