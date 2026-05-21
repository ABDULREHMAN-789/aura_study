import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:aura_study/core/services/ai_service.dart';
import 'package:aura_study/routes/app_routes.dart';

void main() {
  group('MockAIService Phase 5 Extensions Tests', () {
    final aiService = MockAIService();

    test('analyzePDF returns structured StudyNote guide successfully', () async {
      // 1. Test Physics PDF keyword extraction
      final physicsNote = await aiService.analyzePDF(
        "Quantum_Mechanics_Lecture.pdf", 
        "https://web.mit.edu/8.04/www/syllabus.pdf"
      );

      expect(physicsNote.id, startsWith("pdf-"));
      expect(physicsNote.title, contains("Quantum Mechanics Lecture"));
      expect(physicsNote.category, "Physics");
      expect(physicsNote.tags, contains("physics"));
      expect(physicsNote.tags, contains("quantum"));
      expect(physicsNote.tags, contains("pdf-ingest"));
      expect(physicsNote.content, contains("🌟 AI Cognitive Analysis: Quantum_Mechanics_Lecture.pdf"));
      expect(physicsNote.content, contains("Schrödinger Wave Equation"));
      expect(physicsNote.colorHex, "0xFF00F0FF");

      // 2. Test Linear Algebra Math PDF keyword extraction
      final mathNote = await aiService.analyzePDF(
        "Linear_Algebra_Notes.pdf", 
        "https://www.math.ucdavis.edu/~linear/linear-guest.pdf"
      );
      expect(mathNote.category, "Mathematics");
      expect(mathNote.tags, contains("math"));
      expect(mathNote.content, contains("Eigenvalue Equation"));

      // 3. Test General fallback PDF keyword extraction
      final generalNote = await aiService.analyzePDF(
        "Geography_101.pdf", 
        "https://example.com/geography.pdf"
      );
      expect(generalNote.category, "Study Guide");
      expect(generalNote.tags, contains("general"));
      expect(generalNote.content, contains("Universal Retention Theory"));
    });

    test('transcribeVoice synthesizes raw speech text into detailed StudyNote sheets', () async {
      // 1. Test with empty capture (uses mock defaults for subject area)
      final physicsVoice = await aiService.transcribeVoice("", "Physics");
      expect(physicsVoice.id, startsWith("voice-"));
      expect(physicsVoice.title, contains("Voice Capture: Physics Lecture"));
      expect(physicsVoice.category, "Physics");
      expect(physicsVoice.tags, contains("voice-note"));
      expect(physicsVoice.tags, contains("physics"));
      expect(physicsVoice.content, contains("laws of thermodynamics"));
      expect(physicsVoice.content, contains("entropy"));
      expect(physicsVoice.colorHex, "0xFFFF007A");

      // 2. Test Mathematics default empty capture
      final mathVoice = await aiService.transcribeVoice("", "Mathematics");
      expect(mathVoice.category, "Mathematics");
      expect(mathVoice.content, contains("slope of the tangent line"));

      // 3. Test Chemistry default empty capture
      final chemVoice = await aiService.transcribeVoice("", "Chemistry");
      expect(chemVoice.category, "Chemistry");
      expect(chemVoice.content, contains("IUPAC naming protocols"));

      // 4. Test custom voice capture transcription
      final customVoice = await aiService.transcribeVoice(
        "We are exploring photosynthesis. Chlorophyll absorbs sunlight to convert carbon dioxide and water into glucose.", 
        "Biology"
      );
      expect(customVoice.category, "Biology");
      expect(customVoice.content, contains("photosynthesis"));
      expect(customVoice.content, contains("glucose"));
    });
  });

  group('Phase 5 Route Configuration Verification Tests', () {
    test('Router Provider exposes correct path configurations for PDF and Voice systems', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(routerProvider);
      
      // Verify GoRouter configuration mappings
      final routes = router.configuration.routes;
      
      final pdfSelectRoute = routes.any((route) {
        return route is GoRoute && route.path == '/pdf';
      });
      expect(pdfSelectRoute, isTrue, reason: "PDF Selection route path '/pdf' must be registered");

      final pdfViewerRoute = routes.any((route) {
        return route is GoRoute && route.path == '/pdf/viewer';
      });
      expect(pdfViewerRoute, isTrue, reason: "PDF Viewer route path '/pdf/viewer' must be registered");

      final voiceRoute = routes.any((route) {
        return route is GoRoute && route.path == '/voice';
      });
      expect(voiceRoute, isTrue, reason: "Voice Notes route path '/voice' must be registered");
    });
  });
}
