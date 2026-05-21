import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/core/services/ai_service.dart';
import 'package:aura_study/core/services/gemini_ai_service.dart';
import 'package:aura_study/features/ai/presentation/providers/ai_providers.dart';

void main() {
  group('MockAIService Tests', () {
    final aiService = MockAIService();

    test('isMockMode is true', () {
      expect(aiService.isMockMode, true);
    });

    test('summarizeNote returns valid sci-fi structured markdown summary', () async {
      final summary = await aiService.summarizeNote("Quantum Electrodynamics", "Feynman diagrams govern calculations...");
      
      expect(summary, contains("AI Cognitive Summary"));
      expect(summary, contains("Quantum Electrodynamics"));
      expect(summary, contains("Core Focus"));
      expect(summary, contains("Key Synthesized Findings"));
    });

    test('suggestTags returns tags based on subject keyword matching', () async {
      // Physics content
      final physicsTags = await aiService.suggestTags("Quantum Theory", "Exploring wave particles");
      expect(physicsTags, contains("physics"));
      expect(physicsTags, contains("quantum"));
      expect(physicsTags, contains("equations"));

      // Chemistry content
      final chemistryTags = await aiService.suggestTags("Organic Compounds", "Nomenclature of benzene rings");
      expect(chemistryTags, contains("chemistry"));
      expect(chemistryTags, contains("organic"));
      expect(chemistryTags, contains("nomenclature"));

      // Math content
      final mathTags = await aiService.suggestTags("Limits and Derivations", "Basic calculus exploration");
      expect(mathTags, contains("math"));
      expect(mathTags, contains("calculus"));
      expect(mathTags, contains("limits"));

      // General fallback content
      final generalTags = await aiService.suggestTags("Philosophy lecture notes", "Thoughts on ethics");
      expect(generalTags, contains("general"));
      expect(generalTags, contains("recall"));
    });

    test('chatWithTutor responds correctly based on query subjects', () async {
      // Physics query
      final physicsResponse = await aiService.chatWithTutor("Tell me about thermodynamics", null);
      expect(physicsResponse, contains("rules of physics"));
      expect(physicsResponse, contains("thermodynamics"));

      // Chemistry query
      final chemistryResponse = await aiService.chatWithTutor("Explain organic IUPAC nomenclature", null);
      expect(chemistryResponse, contains("Organic Chemistry"));
      expect(chemistryResponse, contains("nomenclature"));

      // Quiz request
      final quizResponse = await aiService.chatWithTutor("Give me a quiz question", null);
      expect(quizResponse, contains("diagnostic check"));
      expect(quizResponse, contains("identical fermions"));

      // Default fallback query
      final defaultResponse = await aiService.chatWithTutor("Describe photosynthesis reaction", null);
      expect(defaultResponse, contains("synthesized your query"));
      expect(defaultResponse, contains("Describe photosynthesis reaction"));
    });

    test('chatWithTutor integrates study note context contextNote when supplied', () async {
      final contextResponse = await aiService.chatWithTutor(
        "Is this correct?", 
        "Note Title\n\nNote Content here"
      );
      expect(contextResponse, contains("Analyzing your active study note context"));
    });
  });

  group('GeminiAIService Fallback Tests', () {
    test('GeminiAIService defaults to Mock fallback when executing with inactive API Key', () async {
      final geminiService = GeminiAIService("invalid_dummy_key");
      expect(geminiService.isMockMode, false);

      // Summarize Note execution should trigger fallback handling and return successfully
      final summary = await geminiService.summarizeNote("Physics", "F=ma");
      expect(summary, contains("AI Cognitive Summary: Physics"));

      // Suggest Tags should successfully return fallback tags
      final tags = await geminiService.suggestTags("Physics", "F=ma");
      expect(tags, contains("physics"));

      // Chat with Tutor should successfully return fallback tutor response
      final chat = await geminiService.chatWithTutor("thermodynamics", null);
      expect(chat, contains("thermodynamics"));
    });
  });

  group('AIChatHistoryNotifier State and Riverpod Integration Tests', () {
    test('Initial State consists of the standard AI Tutor welcome greeting', () {
      final mockService = MockAIService();
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final messages = container.read(aiChatHistoryProvider);
      expect(messages.length, 1);
      expect(messages.first.isUser, false);
      expect(messages.first.text, contains("Aura Tutor"));
      expect(messages.first.text, contains("cybernetic study mentor"));
    });

    test('sendMessage appends user query and AI response sequentially to history', () async {
      final mockService = MockAIService();
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(aiChatHistoryProvider.notifier);
      
      // Trigger tutor request
      final chatFuture = notifier.sendMessage("organic chemistry", null);

      // Verify intermediate loading status
      expect(notifier.isWriting, true);

      // Await future to complete
      await chatFuture;

      // Verify completed loading status
      expect(notifier.isWriting, false);

      // Fetch dynamic messages
      final messages = container.read(aiChatHistoryProvider);
      expect(messages.length, 3);

      // Second message (Index 1) must be user input query
      expect(messages[1].isUser, true);
      expect(messages[1].text, "organic chemistry");

      // Third message (Index 2) must be tutor synthesized response
      expect(messages[2].isUser, false);
      expect(messages[2].text, contains("Organic Chemistry"));
    });

    test('clearHistory purges entire chat history and displays a reset greeting', () {
      final mockService = MockAIService();
      final container = ProviderContainer(
        overrides: [
          aiServiceProvider.overrideWithValue(mockService),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(aiChatHistoryProvider.notifier);

      // Purge chat log memory
      notifier.clearHistory();

      final messages = container.read(aiChatHistoryProvider);
      expect(messages.length, 1);
      expect(messages.first.isUser, false);
      expect(messages.first.text, contains("history purged"));
    });
  });
}
