import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/core/services/export_service.dart';
import 'package:aura_study/features/notes/domain/note_model.dart';

/// Singleton provider for ExportService
final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportService();
});

/// Selected export format state — defaults to PDF
final exportFormatProvider = StateProvider<String>((ref) => 'PDF');

/// Selected note for export — null until user picks one
final exportSelectedNoteProvider = StateProvider<StudyNote?>((ref) => null);

/// Export controller managing the export pipeline lifecycle
final exportControllerProvider =
    StateNotifierProvider<ExportController, AsyncValue<void>>((ref) {
  final service = ref.watch(exportServiceProvider);
  return ExportController(service);
});

class ExportController extends StateNotifier<AsyncValue<void>> {
  final ExportService _service;

  ExportController(this._service) : super(const AsyncValue.data(null));

  /// Execute full export pipeline: generate → share
  Future<bool> exportNote(StudyNote note, String format) async {
    state = const AsyncValue.loading();
    try {
      final file = format == 'DOCX'
          ? await _service.exportAsDocx(note)
          : await _service.exportAsPdf(note);

      final fileName = _service.getExportFileName(
        note,
        format == 'DOCX' ? 'docx' : 'pdf',
      );

      await _service.shareFile(file, fileName);
      state = const AsyncValue.data(null);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Reset state back to idle
  void reset() {
    state = const AsyncValue.data(null);
  }
}
