import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/features/ai/presentation/providers/ai_providers.dart';
import 'package:aura_study/features/notes/presentation/providers/notes_providers.dart';
import 'package:aura_study/features/notes/domain/note_model.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';

class PdfViewerScreen extends ConsumerStatefulWidget {
  final String title;
  final String url;

  const PdfViewerScreen({
    super.key,
    required this.title,
    required this.url,
  });

  @override
  ConsumerState<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends ConsumerState<PdfViewerScreen> {
  final PdfViewerController _pdfViewerController = PdfViewerController();
  bool _isLoadingPdf = true;
  bool _isAnalyzing = false;
  String _analysisStatus = "INITIALIZING MATRIX...";
  Timer? _statusTimer;

  @override
  void dispose() {
    _statusTimer?.cancel();
    _pdfViewerController.dispose();
    super.dispose();
  }

  void _startAnalysisFlow() {
    setState(() {
      _isAnalyzing = true;
      _analysisStatus = "CONNECTING COGNITIVE NODES...";
    });

    int ticks = 0;
    _statusTimer = Timer.periodic(const Duration(milliseconds: 1200), (timer) {
      ticks++;
      if (!mounted) return;
      setState(() {
        if (ticks == 1) {
          _analysisStatus = "INGESTING DOCUMENT CHARACTERS...";
        } else if (ticks == 2) {
          _analysisStatus = "SYNTHESIZING MATRIX VECTORS...";
        } else if (ticks == 3) {
          _analysisStatus = "AURA AI: WRITING COGNITIVE STUDY GUIDE...";
        } else if (ticks >= 4) {
          _analysisStatus = "FINALIZING SYNAPSE CHANNELS...";
        }
      });
    });

    final aiService = ref.read(aiServiceProvider);
    
    aiService.analyzePDF(widget.title, widget.url).then((note) async {
      _statusTimer?.cancel();
      if (!mounted) return;

      // Save note inside Hive & Cloud repository
      final saved = await ref.read(notesControllerProvider.notifier).saveNote(note);
      if (!mounted) return;

      setState(() {
        _isAnalyzing = false;
      });

      if (saved) {
        _showSuccessDialog(note);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AuraColors.surface,
            content: Text(
              "WARNING: Document ingested offline locally due to connection interruptions.",
              style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
            ),
          ),
        );
      }
    }).catchError((e) {
      _statusTimer?.cancel();
      if (!mounted) return;
      setState(() {
        _isAnalyzing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AuraColors.surface,
          content: Text(
            "SCAN MATRIX OFFLINE: AI node connection failed.",
            style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
          ),
        ),
      );
    });
  }

  void _showSuccessDialog(StudyNote note) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Center(
          child: GlowingGlassContainer(
            glowColor: AuraColors.accentCyan,
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.all(24),
            child: Material(
              color: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AuraColors.accentCyan.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(color: AuraColors.accentCyan.withValues(alpha: 0.2), width: 1.5),
                    ),
                    child: const Icon(LucideIcons.sparkles, color: AuraColors.accentCyan, size: 28),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Cognitive Synapse Formed",
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Aura AI has successfully ingested '${widget.title}' and formulated a comprehensive study guide.",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      color: AuraColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.fileText, color: AuraColors.accentCyan, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            note.title,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            "DISMISS",
                            style: GoogleFonts.orbitron(
                              color: AuraColors.textSecondary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context); // close dialog
                            ref.read(activeNoteProvider.notifier).state = note;
                            context.push('/notes/editor');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AuraColors.accentCyan.withValues(alpha: 0.15),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: const BorderSide(color: AuraColors.accentCyan, width: 1),
                            ),
                          ),
                          child: Text(
                            "STUDY GUIDE",
                            style: GoogleFonts.orbitron(
                              color: AuraColors.accentCyan,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ).animate().scale(
          begin: const Offset(0.9, 0.9),
          duration: 300.milliseconds,
          curve: Curves.easeOutBack,
        ).fadeIn();
      },
    );
  }

  void _showScannerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(left: 18, right: 18, top: 16, bottom: 32),
          decoration: BoxDecoration(
            color: AuraColors.surface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(LucideIcons.sparkles, color: AuraColors.accentCyan, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "AURA COGNITIVE CORE",
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Unlock intelligent cognitive analysis vectors for this PDF.",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AuraColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              
              // Option 1: Full Study Guide note
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _startAnalysisFlow();
                },
                borderRadius: BorderRadius.circular(12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AuraColors.accentCyan.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.brain, color: AuraColors.accentCyan, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Formulate Master Study Guide",
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Full textual scan, extracting theoretical pillars & schedules.",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AuraColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary, size: 16),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Option 2: Extract Formulas & Rules
              InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _startAnalysisFlow();
                },
                borderRadius: BorderRadius.circular(12),
                child: GlassContainer(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AuraColors.accentIndigo.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.functionSquare, color: AuraColors.accentIndigo, size: 18),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Isolate Formulas & Axioms",
                              style: GoogleFonts.outfit(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              "Filters the document matrices specifically to list equations.",
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                color: AuraColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(LucideIcons.chevronRight, color: AuraColors.textSecondary, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.background,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
        ),
        title: Text(
          widget.title.length > 22 
              ? '${widget.title.substring(0, 19)}...' 
              : widget.title,
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _pdfViewerController.zoomLevel = 1.0;
            },
            icon: const Icon(LucideIcons.zoomOut, color: AuraColors.textSecondary, size: 20),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.white.withValues(alpha: 0.05),
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 1. PDF rendering layer
          SfPdfViewer.network(
            widget.url,
            controller: _pdfViewerController,
            onDocumentLoaded: (details) {
              setState(() {
                _isLoadingPdf = false;
              });
            },
            onDocumentLoadFailed: (details) {
              setState(() {
                _isLoadingPdf = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: AuraColors.surface,
                  content: Text(
                    "CONNECTION WARNING: Failed to stream document. Verify network link.",
                    style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
                  ),
                ),
              );
            },
          ),

          // 2. Loading overlay for PDF fetching
          if (_isLoadingPdf)
            Container(
              color: AuraColors.background.withValues(alpha: 0.8),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: AuraColors.accentCyan),
                    const SizedBox(height: 16),
                    Text(
                      "STREAMING FILE CHUNKS...",
                      style: GoogleFonts.orbitron(
                        fontSize: 11,
                        color: AuraColors.accentCyan,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Shimmer Cognitive Scanner overlay
          if (_isAnalyzing)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Hologram pulsing scanner ring
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AuraColors.accentCyan.withValues(alpha: 0.3), width: 2),
                        ),
                        child: Center(
                          child: const CircularProgressIndicator(
                            color: AuraColors.accentCyan,
                            strokeWidth: 3,
                          ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                            begin: const Offset(0.9, 0.9),
                            end: const Offset(1.1, 1.1),
                            duration: 1.seconds,
                          ),
                        ),
                      ).animate().scale(begin: const Offset(0.5, 0.5)).fadeIn(),
                      const SizedBox(height: 32),
                      // Progress tag
                      Text(
                        "COGNITIVE DEEP INGESTION ACTIVE",
                        style: GoogleFonts.orbitron(
                          color: AuraColors.accentCyan,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Changing status text
                      Text(
                        _analysisStatus,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_isLoadingPdf && !_isAnalyzing
          ? Padding(
              padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
              child: FloatingActionButton.extended(
                onPressed: _showScannerOptions,
                backgroundColor: Colors.transparent,
                elevation: 0,
                label: GlassContainer(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  borderRadius: BorderRadius.circular(30),
                  borderColor: AuraColors.accentCyan.withValues(alpha: 0.4),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.sparkles, color: AuraColors.accentCyan, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        "AI COGNITIVE SCANNER",
                        style: GoogleFonts.orbitron(
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                          letterSpacing: 1.2,
                          color: AuraColors.accentCyan,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().scale(
              delay: 800.milliseconds,
              duration: 500.milliseconds,
              curve: Curves.easeOutBack,
            )
          : null,
    );
  }
}
