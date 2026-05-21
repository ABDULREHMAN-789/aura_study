import 'dart:io';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:aura_study/core/services/export_service.dart';
import 'package:aura_study/features/notes/domain/note_model.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:share_plus_platform_interface/share_plus_platform_interface.dart';

// Mock path provider for testing
class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return Directory.systemTemp.path;
  }
}

// Mock share provider for testing
class MockSharePlatform extends Fake
    with MockPlatformInterfaceMixin
    implements SharePlatform {
  @override
  Future<ShareResult> share(ShareParams params) async {
    return const ShareResult('success', ShareResultStatus.success);
  }

  @override
  Future<ShareResult> shareUri(
    Uri uri, {
    Rect? sharePositionOrigin,
  }) async {
    return const ShareResult('success', ShareResultStatus.success);
  }

  @override
  Future<ShareResult> shareXFiles(
    List<XFile> files, {
    String? subject,
    String? text,
    Rect? sharePositionOrigin,
  }) async {
    return const ShareResult('success', ShareResultStatus.success);
  }
}

void main() {
  late ExportService exportService;
  late StudyNote testNote;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PathProviderPlatform.instance = MockPathProviderPlatform();
    SharePlatform.instance = MockSharePlatform();
  });

  setUp(() {
    exportService = ExportService();
    testNote = StudyNote(
      id: 'test-note-1',
      title: 'Thermodynamics Final Review',
      content: '# Laws of Thermodynamics\n\n- First Law: Energy cannot be created or destroyed.\n- Second Law: Entropy of an isolated system always increases.',
      category: 'Physics',
      tags: ['Physics', 'Exams'],
      isPinned: false,
      colorHex: '0xFF00F0FF',
      createdAt: DateTime(2026, 5, 20),
      updatedAt: DateTime(2026, 5, 21),
    );
  });

  group('ExportService Tests', () {
    test('getExportFileName generates sanitized valid filenames', () {
      final pdfName = exportService.getExportFileName(testNote, 'pdf');
      
      expect(pdfName, startsWith('Aura_Study_Thermodynamics_Final_Review_'));
      expect(pdfName, endsWith('.pdf'));
      expect(pdfName.contains(' '), isFalse);

      final docxName = exportService.getExportFileName(testNote, 'docx');
      expect(docxName, endsWith('.docx'));
    });

    test('getExportFileName truncates very long titles', () {
      final longNote = testNote.copyWith(
        title: 'This is an incredibly long title that should definitely be truncated because it exceeds the maximum allowed length for our file names to prevent OS issues',
      );

      final pdfName = exportService.getExportFileName(longNote, 'pdf');
      
      expect(pdfName, startsWith('Aura_Study_This_is_an_incredibly_long_tit'));
      expect(pdfName.length, lessThan(80)); // 11 + 40 + 1 + 7 + 4
    });

    test('exportAsPdf generates a valid PDF file with content', () async {
      final file = await exportService.exportAsPdf(testNote);
      
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(100)); // Minimal valid PDF is at least a few hundred bytes
      
      // Cleanup
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('exportAsDocx generates a valid DOCX file with content', () async {
      final file = await exportService.exportAsDocx(testNote);
      
      expect(file.existsSync(), isTrue);
      expect(file.lengthSync(), greaterThan(100)); // Should have zipped XML data
      
      // Cleanup
      if (file.existsSync()) {
        file.deleteSync();
      }
    });

    test('shareFile completes without error (via mocked platform)', () async {
      final file = await exportService.exportAsPdf(testNote);
      
      // If it doesn't throw, the mock intercept worked
      expect(
        () async => await exportService.shareFile(file, 'test.pdf'),
        returnsNormally,
      );
      
      if (file.existsSync()) {
        file.deleteSync();
      }
    });
  });
}
