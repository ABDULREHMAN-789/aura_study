import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/core/services/local_storage_service.dart';
import 'package:aura_study/routes/app_routes.dart';

void main() async {
  // Ensure Flutter engine bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase core (wrapped in a try-catch to support elegant mock offline consoles)
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("AURA PLATFORM WARNING: Firebase initialization bypassed. Activating Offline Mock Console.");
  }

  // Initialize Hive local caching database
  final localStorage = LocalStorageService();
  await localStorage.init();

  // Boot standard mock preferences if none exist
  if (!localStorage.hasKey('daily_streak')) {
    await localStorage.saveStreak(5);
  }
  if (!localStorage.hasKey('ai_usage_today')) {
    await localStorage.saveAIUsage(8);
  }

  runApp(
    const ProviderScope(
      child: AuraStudyApp(),
    ),
  );
}

class AuraStudyApp extends ConsumerWidget {
  const AuraStudyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Aura Study',
      debugShowCheckedModeBanner: false,
      theme: AuraTheme.darkTheme,
      routerConfig: router,
    );
  }
}
