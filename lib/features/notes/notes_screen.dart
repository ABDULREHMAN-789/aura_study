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

class NotesScreen extends ConsumerStatefulWidget {
  const NotesScreen({super.key});

  @override
  ConsumerState<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends ConsumerState<NotesScreen> {
  late final TextEditingController _searchController;
  final List<String> _categories = ["All", "Physics", "Chemistry", "AI Summaries", "Math", "History"];

  @override
  void initState() {
    super.initState();
    final currentQuery = ref.read(notesSearchQueryProvider);
    _searchController = TextEditingController(text: currentQuery);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex));
    } catch (e) {
      return AuraColors.accentCyan;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = ref.watch(filteredNotesProvider);
    final selectedCategory = ref.watch(notesSelectedCategoryProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header Title
            Text(
              "STUDY REPOSITORY",
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
                color: AuraColors.accentCyan,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "My Smart Notes",
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 20),

            // Horizontal Categories Scroll
            _buildCategoriesScroll(selectedCategory),
            const SizedBox(height: 20),

            // Notes List/Grid
            Expanded(
              child: filteredNotes.isEmpty
                  ? _buildEmptyState()
                  : _buildNotesGrid(filteredNotes),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 90.0), // Raise above floating tab bar
        child: GestureDetector(
          onTap: () {
            ref.read(activeNoteProvider.notifier).state = null;
            context.push('/notes/editor');
          },
          child: GlowingGlassContainer(
            width: 220,
            height: 48,
            padding: EdgeInsets.zero,
            glowColor: AuraColors.accentCyan,
            borderRadius: BorderRadius.circular(30),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.add, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "NEW INTELLIGENT NOTE",
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        )
            .animate(onPlay: (controller) => controller.repeat(reverse: true))
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.03, 1.03),
              duration: 2.seconds,
              curve: Curves.easeInOutSine,
            ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      borderRadius: BorderRadius.circular(20),
      borderColor: Colors.white.withValues(alpha: 0.06),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          ref.read(notesSearchQueryProvider.notifier).state = val;
        },
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Search notes, concepts, tags...",
          hintStyle: GoogleFonts.outfit(
            color: AuraColors.textMuted,
            fontSize: 14,
          ),
          icon: const Icon(Icons.search, color: AuraColors.textSecondary, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    ref.read(notesSearchQueryProvider.notifier).state = "";
                  },
                  child: const Icon(Icons.clear, color: AuraColors.textSecondary, size: 18),
                )
              : const Icon(Icons.tune_outlined, color: AuraColors.accentCyan, size: 18),
        ),
        style: GoogleFonts.outfit(
          color: Colors.white,
          fontSize: 15,
        ),
      ),
    );
  }

  Widget _buildCategoriesScroll(String selectedCategory) {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final categoryName = _categories[index];
          final isSelected = selectedCategory.toLowerCase() == categoryName.toLowerCase();
          
          return GestureDetector(
            onTap: () {
              ref.read(notesSelectedCategoryProvider.notifier).state = categoryName;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: isSelected
                    ? AuraColors.accentCyan.withValues(alpha: 0.12)
                    : Colors.white.withValues(alpha: 0.02),
                border: Border.all(
                  color: isSelected
                      ? AuraColors.accentCyan.withValues(alpha: 0.4)
                      : Colors.white.withValues(alpha: 0.05),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  categoryName,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AuraColors.accentCyan : AuraColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: GlassContainer(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          borderColor: AuraColors.accentCyan.withValues(alpha: 0.08),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.query_stats_rounded,
                color: AuraColors.accentCyan.withValues(alpha: 0.4),
                size: 48,
              ).animate(onPlay: (c) => c.repeat())
               .shimmer(duration: 3.seconds, color: AuraColors.accentCyan.withValues(alpha: 0.2)),
              const SizedBox(height: 16),
              Text(
                "NO COGNITIVE RECORDS",
                style: GoogleFonts.orbitron(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "No notes found aligning with coordinates. Create a new record or adjust parameters.",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  color: AuraColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotesGrid(List<StudyNote> notes) {
    return GridView.builder(
      physics: const BouncingScrollPhysics(),
      itemCount: notes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.82,
      ),
      itemBuilder: (context, index) {
        final note = notes[index];
        final noteColor = _parseColor(note.colorHex);
        
        // Simple human friendly formatted date
        final formattedDate = "${note.updatedAt.day}/${note.updatedAt.month}/${note.updatedAt.year}";

        return GestureDetector(
          onTap: () {
            ref.read(activeNoteProvider.notifier).state = note;
            context.push('/notes/editor');
          },
          child: GlassContainer(
            padding: const EdgeInsets.all(14),
            borderColor: noteColor.withValues(alpha: 0.2),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Pin Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          formattedDate,
                          style: GoogleFonts.outfit(
                            fontSize: 10,
                            color: AuraColors.textMuted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (note.isPinned)
                          Icon(Icons.push_pin, color: noteColor, size: 14)
                        else
                          const Icon(Icons.push_pin_outlined, color: Colors.transparent, size: 14),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Note Title
                    Text(
                      note.title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),

                    // Snippet Preview
                    Expanded(
                      child: Text(
                        note.snippet,
                        style: GoogleFonts.outfit(
                          fontSize: 11.5,
                          height: 1.4,
                          color: AuraColors.textSecondary,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tags Row
                    SizedBox(
                      height: 18,
                      child: note.tags.isEmpty
                          ? Text(
                              "#${note.category}",
                              style: GoogleFonts.outfit(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: noteColor,
                              ),
                            )
                          : ListView.separated(
                              scrollDirection: Axis.horizontal,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: note.tags.length > 2 ? 2 : note.tags.length,
                              separatorBuilder: (context, idx) => const SizedBox(width: 4),
                              itemBuilder: (context, idx) => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  color: noteColor.withValues(alpha: 0.08),
                                ),
                                child: Text(
                                  "#${note.tags[idx]}",
                                  style: GoogleFonts.outfit(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: noteColor,
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
                
                // Small overlay hover delete trigger in corner
                Positioned(
                  bottom: -6,
                  right: -6,
                  child: IconButton(
                    icon: Icon(Icons.delete_sweep_outlined, color: AuraColors.textMuted.withValues(alpha: 0.5), size: 16),
                    onPressed: () => _confirmDelete(context, note),
                  ),
                ),
              ],
            ),
          ).animate().scale(
                delay: (index * 80).milliseconds,
                duration: 350.milliseconds,
                curve: Curves.easeOutBack,
              ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, StudyNote note) async {
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

    if (confirmed == true) {
      await ref.read(notesControllerProvider.notifier).deleteNote(note.id);
      if (context.mounted) {
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
      }
    }
  }
}
