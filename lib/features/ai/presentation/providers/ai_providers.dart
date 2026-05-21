import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/core/services/ai_service.dart';
import 'package:aura_study/core/services/gemini_ai_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Provider for the abstract AIService layer
final aiServiceProvider = Provider<AIService>((ref) {
  // Reads the API key from environment configuration flags at compile/run time
  const apiKey = String.fromEnvironment('GEMINI_API_KEY');
  if (apiKey.isNotEmpty && apiKey != 'null') {
    return GeminiAIService(apiKey);
  }
  // Bypasses and runs locally with Mock AIService if API key is not supplied
  return MockAIService();
});

/// Tracks summary loading states inside the notes editor
final aiSummaryLoadingProvider = StateProvider<bool>((ref) => false);

/// Tracks chat history state with virtual tutor reactively
final aiChatHistoryProvider = StateNotifierProvider<AIChatHistoryNotifier, List<ChatMessage>>((ref) {
  final aiService = ref.watch(aiServiceProvider);
  return AIChatHistoryNotifier(aiService);
});

class AIChatHistoryNotifier extends StateNotifier<List<ChatMessage>> {
  final AIService _aiService;
  bool _isWriting = false;

  AIChatHistoryNotifier(this._aiService) : super([
    ChatMessage(
      text: "Greetings, scholar! I am Aura Tutor, your intelligent cybernetic study mentor. How may I assist your academic journey today?",
      isUser: false,
    ),
  ]);

  bool get isWriting => _isWriting;

  /// Send message to the virtual tutor with optional contextual study note details
  Future<void> sendMessage(String text, String? contextNote) async {
    if (text.trim().isEmpty || _isWriting) return;

    _isWriting = true;
    
    // 1. Add user inquiry message
    final userMsg = ChatMessage(text: text, isUser: true);
    state = [...state, userMsg];

    // 2. Fetch AI tutor response
    try {
      final responseText = await _aiService.chatWithTutor(text, contextNote);
      final tutorMsg = ChatMessage(text: responseText, isUser: false);
      state = [...state, tutorMsg];
    } catch (e) {
      final errorMsg = ChatMessage(
        text: "CONNECTION WARNING: AI cognitive core failed to link system parameters. Please try again.",
        isUser: false,
      );
      state = [...state, errorMsg];
    } finally {
      _isWriting = false;
      state = [...state];
    }
  }

  /// Purge/Clear entire chat context
  void clearHistory() {
    state = [
      ChatMessage(
        text: "Tutor neural history purged. Ready to accept new scholar questions.",
        isUser: false,
      ),
    ];
  }
}
