import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:go_router/go_router.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/notes/domain/note_model.dart';
import 'package:aura_study/features/notes/presentation/providers/notes_providers.dart';
import 'package:aura_study/features/export/presentation/providers/export_providers.dart';

class ExportScreen extends ConsumerStatefulWidget {
  const ExportScreen({super.key});

  @override
  ConsumerState<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends ConsumerState<ExportScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedFormat = ref.watch(exportFormatProvider);
    final selectedNote = ref.watch(exportSelectedNoteProvider);
    final exportState = ref.watch(exportControllerProvider);
    final notes = ref.watch(filteredNotesProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // App Bar
            _buildAppBar(context),

            // Scrollable content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Header section
                    _buildHeader(),
                    const SizedBox(height: 24),

                    // Format selector
                    _buildSectionLabel("EXPORT FORMAT"),
                    const SizedBox(height: 12),
                    _buildFormatSelector(selectedFormat),
                    const SizedBox(height: 28),

                    // Note selector
                    _buildSectionLabel("SELECT STUDY NOTE"),
                    const SizedBox(height: 12),
                    if (notes.isEmpty)
                      _buildEmptyState()
                    else
                      _buildNotesList(notes, selectedNote),

                    const SizedBox(height: 28),

                    // Export action button
                    _buildExportButton(selectedNote, selectedFormat, exportState),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 8),
          Text(
            "EXPORT CENTER",
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Icon(LucideIcons.fileOutput, color: AuraColors.accentCyan, size: 20),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gradient accent line
        Container(
          width: 80,
          height: 3,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFFB300), AuraColors.accentCyan],
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ).animate().scaleX(begin: 0, end: 1, duration: 500.milliseconds, curve: Curves.easeOut),
        const SizedBox(height: 16),
        Text(
          "Document Export Pipeline",
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          "Generate professional PDF or DOCX documents from your study notes and share them instantly.",
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: AuraColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.milliseconds).slideY(begin: 0.1, end: 0);
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.orbitron(
        fontSize: 10,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
        color: AuraColors.textMuted,
      ),
    );
  }

  Widget _buildFormatSelector(String selectedFormat) {
    return Row(
      children: [
        Expanded(
          child: _buildFormatCard(
            format: 'PDF',
            icon: LucideIcons.fileText,
            subtitle: 'Professional Document',
            accentColor: const Color(0xFFFF4444),
            isSelected: selectedFormat == 'PDF',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildFormatCard(
            format: 'DOCX',
            icon: LucideIcons.fileEdit,
            subtitle: 'Editable Word File',
            accentColor: const Color(0xFF2196F3),
            isSelected: selectedFormat == 'DOCX',
          ),
        ),
      ],
    ).animate().fadeIn(delay: 200.milliseconds, duration: 400.milliseconds);
  }

  Widget _buildFormatCard({
    required String format,
    required IconData icon,
    required String subtitle,
    required Color accentColor,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => ref.read(exportFormatProvider.notifier).state = format,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor.withValues(alpha: 0.6)
                : AuraColors.border,
            width: isSelected ? 1.5 : 1,
          ),
          color: isSelected
              ? accentColor.withValues(alpha: 0.08)
              : AuraColors.cardBg,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.15),
                    blurRadius: 20,
                    spreadRadius: 2,
                  )
                ]
              : [],
        ),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? accentColor.withValues(alpha: 0.15)
                    : Colors.white.withValues(alpha: 0.04),
              ),
              child: Icon(
                icon,
                color: isSelected ? accentColor : AuraColors.textMuted,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              format,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: isSelected ? Colors.white : AuraColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 10,
                color: isSelected
                    ? accentColor.withValues(alpha: 0.8)
                    : AuraColors.textMuted,
              ),
            ),
            const SizedBox(height: 10),
            // Selection indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? accentColor : AuraColors.border,
                  width: 2,
                ),
                color: isSelected
                    ? accentColor
                    : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesList(List<StudyNote> notes, StudyNote? selectedNote) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final note = notes[index];
        final isSelected = selectedNote?.id == note.id;
        final noteColor = _parseColor(note.colorHex);

        return GestureDetector(
          onTap: () {
            ref.read(exportSelectedNoteProvider.notifier).state = note;
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isSelected
                    ? noteColor.withValues(alpha: 0.5)
                    : AuraColors.border,
                width: isSelected ? 1.5 : 1,
              ),
              color: isSelected
                  ? noteColor.withValues(alpha: 0.06)
                  : AuraColors.cardBg,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: noteColor.withValues(alpha: 0.1),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Color accent bar
                Container(
                  width: 4,
                  height: 48,
                  decoration: BoxDecoration(
                    color: noteColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),
                // Note info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        note.title,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: noteColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              note.category,
                              style: GoogleFonts.outfit(
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                                color: noteColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              note.snippet,
                              style: GoogleFonts.outfit(
                                fontSize: 10,
                                color: AuraColors.textMuted,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Selection indicator
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? noteColor : AuraColors.border,
                      width: 2,
                    ),
                    color: isSelected ? noteColor : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              ],
            ),
          ),
        ).animate().fadeIn(
              delay: (100 + index * 60).milliseconds,
              duration: 400.milliseconds,
            );
      },
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        children: [
          Icon(
            LucideIcons.fileQuestion,
            size: 48,
            color: AuraColors.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            "NO STUDY NOTES FOUND",
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: AuraColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Create a study note first, then come back to export it as a professional document.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AuraColors.textMuted,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/notes/editor'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AuraColors.accentCyan,
                side: const BorderSide(color: AuraColors.accentCyan),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(LucideIcons.plus, size: 16),
              label: Text(
                "CREATE NOTE",
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.milliseconds);
  }

  Widget _buildExportButton(
    StudyNote? selectedNote,
    String format,
    AsyncValue<void> exportState,
  ) {
    final isLoading = exportState is AsyncLoading;
    final isReady = selectedNote != null && !isLoading;

    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          height: 56,
          decoration: isReady
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFB300).withValues(
                        alpha: 0.1 + (_pulseController.value * 0.12),
                      ),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                  ],
                )
              : null,
          child: ElevatedButton(
            onPressed: isReady
                ? () async {
                    final controller =
                        ref.read(exportControllerProvider.notifier);
                    final success =
                        await controller.exportNote(selectedNote, format);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: success
                              ? AuraColors.accentGreen.withValues(alpha: 0.9)
                              : AuraColors.accentPink.withValues(alpha: 0.9),
                          content: Row(
                            children: [
                              Icon(
                                success
                                    ? LucideIcons.checkCircle
                                    : LucideIcons.alertCircle,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  success
                                      ? "Document exported successfully!"
                                      : "Export failed. Please try again.",
                                  style: GoogleFonts.outfit(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isReady
                  ? const Color(0xFFFFB300)
                  : AuraColors.surface,
              foregroundColor: isReady ? Colors.black : AuraColors.textMuted,
              disabledBackgroundColor: AuraColors.surface,
              disabledForegroundColor: AuraColors.textMuted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: isReady
                      ? const Color(0xFFFFB300).withValues(alpha: 0.4)
                      : AuraColors.border,
                ),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AuraColors.accentCyan,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "GENERATING...",
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AuraColors.accentCyan,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.zap,
                        size: 18,
                        color: isReady ? Colors.black : AuraColors.textMuted,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        selectedNote == null
                            ? "SELECT A NOTE FIRST"
                            : "EXPORT & SHARE",
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    ).animate().fadeIn(delay: 400.milliseconds, duration: 400.milliseconds);
  }

  Color _parseColor(String hexStr) {
    try {
      return Color(int.parse(hexStr));
    } catch (e) {
      return AuraColors.accentCyan;
    }
  }
}
