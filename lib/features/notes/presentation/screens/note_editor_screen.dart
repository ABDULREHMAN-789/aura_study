import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/notes/domain/note_model.dart';
import 'package:aura_study/features/notes/presentation/providers/notes_providers.dart';
import 'package:aura_study/features/ai/presentation/providers/ai_providers.dart';
import 'package:aura_study/features/export/presentation/providers/export_providers.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _tagInputController;

  late String _selectedCategory;
  late List<String> _tags;
  late bool _isPinned;
  late String _selectedColorHex;

  final List<String> _categories = ["Physics", "Chemistry", "AI Summaries", "Math", "History", "General"];

  final List<Map<String, dynamic>> _glowOptions = [
    {"name": "Cyan", "hex": "0xFF00F0FF", "color": AuraColors.accentCyan},
    {"name": "Indigo", "hex": "0xFF8F5BFF", "color": AuraColors.accentIndigo},
    {"name": "Green", "hex": "0xFF00FF87", "color": AuraColors.accentGreen},
    {"name": "Pink", "hex": "0xFFFF007A", "color": AuraColors.accentPink},
    {"name": "Amber", "hex": "0xFFFFB300", "color": const Color(0xFFFFB300)},
  ];

  @override
  void initState() {
    super.initState();
    final activeNote = ref.read(activeNoteProvider);

    _titleController = TextEditingController(text: activeNote?.title ?? "");
    _contentController = TextEditingController(text: activeNote?.content ?? "");
    _tagInputController = TextEditingController();

    _selectedCategory = activeNote?.category ?? "General";
    _tags = List<String>.from(activeNote?.tags ?? []);
    _isPinned = activeNote?.isPinned ?? false;
    _selectedColorHex = activeNote?.colorHex ?? "0xFF00F0FF";
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagInputController.dispose();
    super.dispose();
  }

  Color _getActiveColor() {
    final option = _glowOptions.firstWhere(
      (element) => element['hex'] == _selectedColorHex,
      orElse: () => _glowOptions[0],
    );
    return option['color'] as Color;
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) return;

    final activeNote = ref.read(activeNoteProvider);
    final now = DateTime.now();

    final note = StudyNote(
      id: activeNote?.id ?? "note-${DateTime.now().microsecondsSinceEpoch}",
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      tags: _tags,
      isPinned: _isPinned,
      colorHex: _selectedColorHex,
      createdAt: activeNote?.createdAt ?? now,
      updatedAt: now,
    );

    final success = await ref.read(notesControllerProvider.notifier).saveNote(note);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AuraColors.surface,
          duration: 2.seconds,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(color: _getActiveColor(), width: 0.5),
          ),
          content: Text(
            activeNote == null
                ? "New study record synced successfully."
                : "Study record updated and synchronized.",
            style: GoogleFonts.outfit(color: _getActiveColor(), fontSize: 13),
          ),
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeNote = ref.watch(activeNoteProvider);
    final isEditMode = activeNote != null;
    final activeColor = _getActiveColor();

    return Scaffold(
      backgroundColor: AuraColors.background,
      appBar: AppBar(
        title: Text(
          isEditMode ? "EDIT COGNITIVE NOTE" : "SYNTHESIZE NEW NOTE",
          style: GoogleFonts.orbitron(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: activeColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: _isPinned ? activeColor : AuraColors.textSecondary,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _isPinned = !_isPinned;
              });
            },
          ),
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined, color: AuraColors.accentPink, size: 20),
              onPressed: () => _confirmDelete(activeNote),
            ),
          if (isEditMode)
            IconButton(
              icon: const Icon(Icons.ios_share, color: Color(0xFFFFB300), size: 20),
              tooltip: 'Export Note',
              onPressed: () => _showExportSheet(activeNote),
            ),
        ],
      ),
      body: Stack(
        children: [
          // Ambient Glow Circle
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: activeColor.withValues(alpha: 0.06),
              ),
            ).animate(onPlay: (c) => c.repeat(reverse: true))
             .blur(begin: const Offset(40, 40), end: const Offset(70, 70), duration: 4.seconds),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Glow Profile Selector
                    Text(
                      "AMBIENT GLOW PROFILE",
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildGlowPicker(),
                    const SizedBox(height: 20),

                    // Title Input Box
                    Text(
                      "RECORD TITLE",
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTitleField(activeColor),
                    const SizedBox(height: 20),

                    // Category Selector
                    Text(
                      "COGNITIVE CLASSIFICATION",
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildCategoryPicker(activeColor),
                    const SizedBox(height: 20),

                    // Tags Segment
                    Text(
                      "SYNTAX TAGS",
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildTagsSection(activeColor),
                    const SizedBox(height: 20),

                    // Content Editor Input Box
                    Text(
                      "COGNITIVE BODY CONTENT",
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildContentField(activeColor),
                    const SizedBox(height: 16),

                    // AI Cognitive Assistants Actions
                    Text(
                      "AI COGNITIVE ASSISTANCE",
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildAIAssistantTools(activeColor, ref),
                    const SizedBox(height: 30),

                    // Synchronize/Save Button
                    _buildSaveButton(activeColor),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowPicker() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      borderRadius: BorderRadius.circular(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _glowOptions.map((opt) {
          final color = opt['color'] as Color;
          final hex = opt['hex'] as String;
          final isSelected = _selectedColorHex == hex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedColorHex = hex;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withValues(alpha: isSelected ? 0.25 : 0.05),
                border: Border.all(
                  color: isSelected ? color : Colors.white.withValues(alpha: 0.1),
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.4),
                          blurRadius: 10,
                          spreadRadius: 1,
                        )
                      ]
                    : [],
              ),
              child: Center(
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTitleField(Color activeColor) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      borderRadius: BorderRadius.circular(16),
      borderColor: activeColor.withValues(alpha: 0.2),
      child: TextFormField(
        controller: _titleController,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Enter note title...",
          hintStyle: GoogleFonts.outfit(color: AuraColors.textMuted, fontSize: 15),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Identity title is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategoryPicker(Color activeColor) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = cat;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSelected ? activeColor.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.02),
                border: Border.all(
                  color: isSelected ? activeColor.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  cat,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? activeColor : AuraColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTagsSection(Color activeColor) {
    return GlassContainer(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(16),
      borderColor: activeColor.withValues(alpha: 0.15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Render existing tag chips
          if (_tags.isNotEmpty) ...[
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _tags.map((tag) {
                return Chip(
                  backgroundColor: activeColor.withValues(alpha: 0.08),
                  side: BorderSide(color: activeColor.withValues(alpha: 0.3), width: 0.8),
                  labelPadding: const EdgeInsets.only(left: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  label: Text(
                    "#$tag",
                    style: GoogleFonts.outfit(color: activeColor, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  deleteIcon: Icon(Icons.close, size: 12, color: activeColor),
                  onDeleted: () {
                    setState(() {
                      _tags.remove(tag);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
          ],

          // Tag input row
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _tagInputController,
                  style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: "Add custom tag (e.g. quantum, organic)...",
                    hintStyle: GoogleFonts.outfit(color: AuraColors.textMuted, fontSize: 13),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (val) => _addTag(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add_circle, color: activeColor, size: 22),
                onPressed: _addTag,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addTag() {
    final text = _tagInputController.text.trim();
    if (text.isNotEmpty && !_tags.contains(text)) {
      setState(() {
        _tags.add(text);
        _tagInputController.clear();
      });
    }
  }

  Widget _buildContentField(Color activeColor) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      borderRadius: BorderRadius.circular(16),
      borderColor: activeColor.withValues(alpha: 0.15),
      child: TextFormField(
        controller: _contentController,
        maxLines: 12,
        minLines: 6,
        style: GoogleFonts.outfit(color: Colors.white, fontSize: 14.5, height: 1.5),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Write your intelligent thoughts, summarize lectures, or record knowledge equations...",
          hintStyle: GoogleFonts.outfit(color: AuraColors.textMuted, fontSize: 14),
        ),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Body content is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildAIAssistantTools(Color activeColor, WidgetRef ref) {
    final isSummaryLoading = ref.watch(aiSummaryLoadingProvider);

    return Row(
      children: [
        // AI Summarize Button
        Expanded(
          child: GestureDetector(
            onTap: isSummaryLoading ? null : () => _generateAISummary(ref),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: isSummaryLoading
                    ? AuraColors.accentIndigo.withValues(alpha: 0.08)
                    : AuraColors.accentIndigo.withValues(alpha: 0.04),
                border: Border.all(
                  color: AuraColors.accentIndigo.withValues(alpha: isSummaryLoading ? 0.6 : 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: isSummaryLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AuraColors.accentIndigo),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: AuraColors.accentIndigo, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            "AI COGNITIVE SUMMARY",
                            style: GoogleFonts.orbitron(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // AI Tag Suggester Button
        Expanded(
          child: GestureDetector(
            onTap: () => _suggestAITags(ref),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: AuraColors.accentGreen.withValues(alpha: 0.04),
                border: Border.all(
                  color: AuraColors.accentGreen.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.label_important_outline, color: AuraColors.accentGreen, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      "SUGGEST COGNITIVE TAGS",
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _generateAISummary(WidgetRef ref) async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AuraColors.surface,
          content: Text(
            "COGNITIVE WARNING: Please input note body text to summarize.",
            style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
          ),
        ),
      );
      return;
    }

    ref.read(aiSummaryLoadingProvider.notifier).state = true;
    try {
      final aiService = ref.read(aiServiceProvider);
      final summary = await aiService.summarizeNote(
        title.isEmpty ? "Untitled Concept" : title,
        content,
      );

      setState(() {
        _contentController.text = "$summary\n\n---\n\n$content";
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AuraColors.surface,
            content: Text(
              "AI Cognitive Summary prepended to note body.",
              style: GoogleFonts.outfit(color: AuraColors.accentGreen, fontSize: 13),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AuraColors.surface,
            content: Text(
              "ERROR: Summarization matrix failed.",
              style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
            ),
          ),
        );
      }
    } finally {
      ref.read(aiSummaryLoadingProvider.notifier).state = false;
    }
  }

  Future<void> _suggestAITags(WidgetRef ref) async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (content.isEmpty && title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AuraColors.surface,
          content: Text(
            "COGNITIVE WARNING: Please enter a title or body text to analyze.",
            style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AuraColors.surface,
        duration: const Duration(seconds: 1),
        content: Text(
          "Scanning syntax matrix for tags...",
          style: GoogleFonts.outfit(color: AuraColors.accentCyan, fontSize: 13),
        ),
      ),
    );

    try {
      final aiService = ref.read(aiServiceProvider);
      final suggested = await aiService.suggestTags(
        title.isEmpty ? "Untitled Concept" : title,
        content,
      );

      setState(() {
        for (final tag in suggested) {
          if (!_tags.contains(tag)) {
            _tags.add(tag);
          }
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AuraColors.surface,
            content: Text(
              "AI tags parsed and integrated successfully.",
              style: GoogleFonts.outfit(color: AuraColors.accentGreen, fontSize: 13),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AuraColors.surface,
            content: Text(
              "ERROR: Tag suggest matrix failed.",
              style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
            ),
          ),
        );
      }
    }
  }

  Widget _buildSaveButton(Color activeColor) {
    final status = ref.watch(notesControllerProvider);
    final isLoading = status is AsyncLoading;

    return GestureDetector(
      onTap: isLoading ? null : _saveNote,
      child: GlowingGlassContainer(
        width: double.infinity,
        height: 52,
        padding: EdgeInsets.zero,
        glowColor: activeColor,
        borderRadius: BorderRadius.circular(16),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.cloud_upload_outlined, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "SYNCHRONIZE RECORD",
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(StudyNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: AuraColors.surface.withValues(alpha: 0.92),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: AuraColors.accentPink.withValues(alpha: 0.3), width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AuraColors.accentPink, size: 22),
              const SizedBox(width: 10),
              Text(
                "ARCHIVE PURGE",
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          content: Text(
            "Purge '${note.title}' permanently from study repository? Cloud synchronization logs will be deleted.",
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AuraColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                "CANCEL",
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: AuraColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AuraColors.accentPink.withValues(alpha: 0.12),
                side: const BorderSide(color: AuraColors.accentPink, width: 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                "PURGE RECORD",
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  color: AuraColors.accentPink,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(notesControllerProvider.notifier).deleteNote(note.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AuraColors.surface,
            duration: 2.seconds,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: const BorderSide(color: AuraColors.accentPink, width: 0.5),
            ),
            content: Text(
              "Cognitive record purged.",
              style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
            ),
          ),
        );
        context.pop(); // Close editor
      }
    }
  }
  void _showExportSheet(StudyNote note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "EXPORT NOTE",
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Select a format to export this note and share it.",
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: AuraColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _buildExportFormatOption(
                      title: "PDF",
                      icon: Icons.picture_as_pdf,
                      color: const Color(0xFFFF4444),
                      onTap: () {
                        Navigator.pop(context);
                        _triggerExport(note, "PDF");
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildExportFormatOption(
                      title: "DOCX",
                      icon: Icons.description,
                      color: const Color(0xFF2196F3),
                      onTap: () {
                        Navigator.pop(context);
                        _triggerExport(note, "DOCX");
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportFormatOption({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _triggerExport(StudyNote note, String format) async {
    final controller = ref.read(exportControllerProvider.notifier);
    
    // Show a loading snackbar immediately
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AuraColors.surface,
        duration: const Duration(seconds: 10), // Keep open while loading
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AuraColors.accentCyan),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              "Generating $format...",
              style: GoogleFonts.outfit(color: Colors.white),
            ),
          ],
        ),
      ),
    );

    final success = await controller.exportNote(note, format);
    
    if (mounted) {
      // Clear the loading snackbar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      
      // Show result snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: success 
              ? AuraColors.accentGreen.withValues(alpha: 0.9)
              : AuraColors.accentPink.withValues(alpha: 0.9),
          content: Text(
            success 
                ? "Export completed successfully!"
                : "Failed to export note.",
            style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
