import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/flashcards/domain/flashcard_model.dart';
import 'package:aura_study/features/flashcards/presentation/providers/flashcard_providers.dart';
import 'package:aura_study/features/notes/presentation/providers/notes_providers.dart';

class FlashcardHubScreen extends ConsumerStatefulWidget {
  const FlashcardHubScreen({super.key});

  @override
  ConsumerState<FlashcardHubScreen> createState() => _FlashcardHubScreenState();
}

class _FlashcardHubScreenState extends ConsumerState<FlashcardHubScreen> {
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final decksAsync = ref.watch(flashcardDeckListProvider);
    final generatorState = ref.watch(flashcardGeneratorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("FLASHCARD COGNITIONS"),
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Subject Quick Filters
                _buildCategoryFilters(),
                const SizedBox(height: 20),

                // Section title
                Text(
                  "ACTIVE RECALL CELLS",
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AuraColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Decks list
                Expanded(
                  child: decksAsync.when(
                    data: (decks) {
                      final filtered = decks.where((d) {
                        return _selectedCategory == 'All' ||
                            d.category.trim().toLowerCase() == _selectedCategory.trim().toLowerCase();
                      }).toList();

                      if (filtered.isEmpty) {
                        return _buildEmptyState();
                      }

                      return GridView.builder(
                        physics: const BouncingScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.88,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final deck = filtered[index];
                          return _buildDeckCard(deck);
                        },
                      );
                    },
                    loading: () => _buildShimmerGrid(),
                    error: (err, stack) => _buildErrorState(err.toString()),
                  ),
                ),
              ],
            ),
          ),

          // Loader overlay when synthesizing
          if (generatorState is AsyncLoading) _buildScannerLoader(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteSelectionSheet(context),
        label: Text(
          "⚡ SYNERGIZE NEW DECK",
          style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        icon: const Icon(LucideIcons.zap, size: 16),
        backgroundColor: AuraColors.accentPink,
        foregroundColor: Colors.white,
      ).animate().scale(delay: 400.milliseconds, duration: 400.milliseconds),
    );
  }

  Widget _buildCategoryFilters() {
    final categories = ["All", "Physics", "Chemistry", "Mathematics", "General"];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: categories.map((cat) {
          final isSelected = _selectedCategory.toLowerCase() == cat.toLowerCase();
          final accentColor = cat == "Physics"
              ? AuraColors.accentIndigo
              : cat == "Chemistry"
                  ? AuraColors.accentPink
                  : cat == "Mathematics"
                      ? AuraColors.accentCyan
                      : AuraColors.accentGreen;

          return Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedCategory = cat;
                });
              },
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? accentColor : AuraColors.border,
                    width: 1,
                  ),
                  color: isSelected ? accentColor.withValues(alpha: 0.12) : Colors.transparent,
                ),
                child: Text(
                  cat.toUpperCase(),
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: isSelected ? Colors.white : AuraColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDeckCard(FlashcardDeck deck) {
    final accentColor = deck.category.toLowerCase() == "physics"
        ? AuraColors.accentIndigo
        : deck.category.toLowerCase() == "chemistry"
            ? AuraColors.accentPink
            : deck.category.toLowerCase() == "mathematics" || deck.category.toLowerCase() == "math"
                ? AuraColors.accentCyan
                : AuraColors.accentGreen;

    final int unreviewed = deck.cards.where((c) => c.difficultyRating == 'unreviewed').length;
    final int mastered = deck.cards.where((c) => c.difficultyRating == 'easy').length;

    return InkWell(
      onTap: () {
        ref.read(activeDeckProvider.notifier).state = deck;
        context.push('/flashcards/review');
      },
      borderRadius: BorderRadius.circular(16),
      child: GlowingGlassContainer(
        glowColor: accentColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(LucideIcons.layers, color: accentColor, size: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      deck.category.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deck.title.replaceAll("Deck: ", "").toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${deck.cards.length} COGNITIVE CARDS",
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AuraColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Progress metrics
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AuraColors.accentGreen, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$mastered Mastered",
                        style: GoogleFonts.outfit(fontSize: 9, color: AuraColors.textMuted),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(color: AuraColors.accentCyan, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "$unreviewed New",
                        style: GoogleFonts.outfit(fontSize: 9, color: AuraColors.textMuted),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ).animate().fadeIn(duration: 350.milliseconds).scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1), curve: Curves.easeOutBack);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.layers, color: AuraColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            "NO COGNITIVE DECKS SYNTHESIZED",
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AuraColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Synthesize customized flashcard decks from study notes below.",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 12,
              color: AuraColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Text(
        "COGNITIVE INTERFERENCE DETECTED:\n$error",
        textAlign: TextAlign.center,
        style: GoogleFonts.orbitron(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AuraColors.accentPink,
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.88,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return GlassContainer(
          borderColor: AuraColors.border,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const CircleAvatar(backgroundColor: AuraColors.cardBg, radius: 10),
                    Container(height: 12, width: 40, color: AuraColors.cardBg),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 12, width: 100, color: AuraColors.cardBg),
                    const SizedBox(height: 6),
                    Container(height: 10, width: 60, color: AuraColors.cardBg),
                  ],
                ),
              ],
            ),
          ),
        ).animate(onPlay: (controller) => controller.repeat())
         .shimmer(duration: 1500.milliseconds, color: Colors.white.withValues(alpha: 0.04));
      },
    );
  }

  Widget _buildScannerLoader() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(LucideIcons.zap, size: 60, color: AuraColors.accentPink)
                .animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 800.milliseconds, curve: Curves.easeInOutSine),
            const SizedBox(height: 24),
            Text(
              "STRUCTURING ACTIVE-RECALL CELLS...",
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Formulating custom question-and-answer neural flashcards",
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AuraColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: 200,
              height: 4,
              child: LinearProgressIndicator(
                backgroundColor: Colors.white.withValues(alpha: 0.05),
                color: AuraColors.accentPink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteSelectionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AuraColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final notes = ref.watch(filteredNotesProvider);

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AuraColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "SELECT KNOWLEDGE VECTOR",
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: AuraColors.accentPink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "AI will formulate targeted active-recall cards from your study note content.",
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      color: AuraColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (notes.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(
                          "No study notes available. Create some notes first!",
                          style: GoogleFonts.outfit(color: AuraColors.textMuted),
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const BouncingScrollPhysics(),
                        itemCount: notes.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          final noteColor = note.colorHex.startsWith("0x")
                              ? Color(int.parse(note.colorHex))
                              : AuraColors.accentCyan;

                          return InkWell(
                            onTap: () async {
                              Navigator.pop(context);
                              // Trigger AI synthesis
                              final deck = await ref
                                  .read(flashcardGeneratorControllerProvider.notifier)
                                  .generateDeckFromContent(
                                    note.title,
                                    note.content,
                                    note.category,
                                  );

                              if (deck != null && context.mounted) {
                                ref.read(activeDeckProvider.notifier).state = deck;
                                context.push('/flashcards/review');
                              }
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: GlassContainer(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              borderColor: Colors.white.withValues(alpha: 0.04),
                              child: Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: noteColor,
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          note.title,
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          note.category.toUpperCase(),
                                          style: GoogleFonts.orbitron(
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                            color: AuraColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Icon(LucideIcons.chevronRight, color: AuraColors.textMuted, size: 16),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
