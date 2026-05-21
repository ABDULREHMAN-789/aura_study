import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/quiz/domain/quiz_model.dart';
import 'package:aura_study/features/quiz/presentation/providers/quiz_providers.dart';
import 'package:aura_study/features/notes/presentation/providers/notes_providers.dart';

class QuizHubScreen extends ConsumerStatefulWidget {
  const QuizHubScreen({super.key});

  @override
  ConsumerState<QuizHubScreen> createState() => _QuizHubScreenState();
}

class _QuizHubScreenState extends ConsumerState<QuizHubScreen> {
  String _selectedCategory = "All";

  @override
  Widget build(BuildContext context) {
    final quizzesAsync = ref.watch(quizListProvider);
    final generatorState = ref.watch(quizGeneratorControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("QUIZ NEURAL HUB"),
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
                  "AVAILABLE KNOWLEDGE COGNITIONS",
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: AuraColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 12),

                // Main Quiz List
                Expanded(
                  child: quizzesAsync.when(
                    data: (quizzes) {
                      final filtered = quizzes.where((q) {
                        return _selectedCategory == 'All' ||
                            q.category.trim().toLowerCase() == _selectedCategory.trim().toLowerCase();
                      }).toList();

                      if (filtered.isEmpty) {
                        return _buildEmptyState();
                      }

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: filtered.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final quiz = filtered[index];
                          return _buildQuizCard(quiz);
                        },
                      );
                    },
                    loading: () => _buildShimmerList(),
                    error: (err, stack) => _buildErrorState(err.toString()),
                  ),
                ),
              ],
            ),
          ),
          
          // Full-screen Scanner overlay while generating AI quizzes
          if (generatorState is AsyncLoading) _buildScannerLoader(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNoteSelectionSheet(context),
        label: Text(
          "🧠 SYNERGIZE NEW QUIZ",
          style: GoogleFonts.orbitron(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
        ),
        icon: const Icon(LucideIcons.brainCircuit, size: 16),
        backgroundColor: AuraColors.accentIndigo,
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

  Widget _buildQuizCard(QuizSession quiz) {
    final accentColor = quiz.category.toLowerCase() == "physics"
        ? AuraColors.accentIndigo
        : quiz.category.toLowerCase() == "chemistry"
            ? AuraColors.accentPink
            : quiz.category.toLowerCase() == "mathematics" || quiz.category.toLowerCase() == "math"
                ? AuraColors.accentCyan
                : AuraColors.accentGreen;

    return GlowingGlassContainer(
      glowColor: accentColor.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1),
              ),
              child: Icon(
                quiz.isAttempted ? LucideIcons.trophy : LucideIcons.helpCircle,
                color: accentColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    quiz.title.replaceAll("Quiz: ", "").toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          quiz.category.toUpperCase(),
                          style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: accentColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${quiz.questions.length} QUESTIONS",
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          color: AuraColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  if (quiz.isAttempted) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(LucideIcons.checkSquare, color: AuraColors.accentGreen, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          "HIGH SCORE: ${(quiz.score / quiz.questions.length * 100).round()}% (${quiz.score}/${quiz.questions.length})",
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AuraColors.accentGreen,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            IconButton(
              icon: const Icon(LucideIcons.playCircle, size: 36, color: Colors.white),
              onPressed: () {
                ref.read(activeQuizSessionProvider.notifier).state = quiz;
                context.push('/quiz/play');
              },
            ),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.1, end: 0, duration: 400.milliseconds, curve: Curves.easeOutQuad);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(LucideIcons.brainCircuit, color: AuraColors.textMuted, size: 48),
          const SizedBox(height: 16),
          Text(
            "NO NEURAL COGNITIONS SYNTHESIZED",
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AuraColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the button below to generate a new custom quiz using AI.",
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

  Widget _buildShimmerList() {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 4,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        return GlassContainer(
          height: 90,
          borderColor: AuraColors.border,
          child: Row(
            children: [
              const SizedBox(width: 16),
              const CircleAvatar(backgroundColor: AuraColors.cardBg, radius: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(height: 14, width: 140, color: AuraColors.cardBg),
                    const SizedBox(height: 8),
                    Container(height: 10, width: 80, color: AuraColors.cardBg),
                  ],
                ),
              ),
            ],
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
            const Icon(LucideIcons.brainCircuit, size: 60, color: AuraColors.accentIndigo)
                .animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1.seconds, curve: Curves.easeInOutQuad)
                .then()
                .rotate(duration: 800.milliseconds),
            const SizedBox(height: 24),
            Text(
              "FORMULATING NEURAL MATRIX...",
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Synthesizing structured multi-choice checkpoints using AI",
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
                color: AuraColors.accentIndigo,
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
                      color: AuraColors.accentCyan,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "AI will ingest your selected study note to generate targeted quiz questions.",
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
                              final session = await ref
                                  .read(quizGeneratorControllerProvider.notifier)
                                  .generateQuizFromContent(
                                    note.title,
                                    note.content,
                                    note.category,
                                  );

                              if (session != null && context.mounted) {
                                ref.read(activeQuizSessionProvider.notifier).state = session;
                                context.push('/quiz/play');
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
