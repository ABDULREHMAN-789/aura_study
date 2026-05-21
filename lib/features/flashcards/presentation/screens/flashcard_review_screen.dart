import 'dart:math' show pi;
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

class FlashcardReviewScreen extends ConsumerStatefulWidget {
  const FlashcardReviewScreen({super.key});

  @override
  ConsumerState<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  
  // Track performance metrics for active session summary
  int _easyCount = 0;
  int _mediumCount = 0;
  int _hardCount = 0;
  bool _isFinished = false;

  @override
  Widget build(BuildContext context) {
    final deck = ref.watch(activeDeckProvider);

    if (deck == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "DECK DE-SYNCHRONIZED",
                style: GoogleFonts.orbitron(color: AuraColors.accentPink, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text("RETURN"),
              ),
            ],
          ),
        ),
      );
    }

    final cards = deck.cards;
    if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(deck.title.toUpperCase())),
        body: Center(
          child: Text(
            "NO COGNITIVE CELLS FOUND IN DECK",
            style: GoogleFonts.orbitron(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    }

    final accentColor = deck.category.toLowerCase() == "physics"
        ? AuraColors.accentIndigo
        : deck.category.toLowerCase() == "chemistry"
            ? AuraColors.accentPink
            : deck.category.toLowerCase() == "mathematics" || deck.category.toLowerCase() == "math"
                ? AuraColors.accentCyan
                : AuraColors.accentGreen;

    if (_isFinished) {
      return _buildFinishedSummary(deck, accentColor);
    }

    final currentCard = cards[_currentIndex];
    final progress = (_currentIndex + 1) / cards.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(deck.category.toUpperCase()),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => _confirmExitDialog(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                "${_currentIndex + 1}/${cards.length}",
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Top Glowing Progress Bar
            _buildProgressBar(progress, _currentIndex + 1, cards.length, accentColor),
            const SizedBox(height: 32),

            // Expanding 3D Tactile Card Space
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 0.72,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _isFlipped = !_isFlipped;
                      });
                    },
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0.0,
                        end: _isFlipped ? pi : 0.0,
                      ),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutBack,
                      builder: (context, angle, child) {
                        final isBack = angle >= pi / 2;
                        final transform = Matrix4.identity()
                          ..setEntry(3, 2, 0.001) // perspective coefficient
                          ..rotateY(angle);

                        return Transform(
                          transform: transform,
                          alignment: Alignment.center,
                          child: isBack
                              ? Transform(
                                  alignment: Alignment.center,
                                  transform: Matrix4.identity()..rotateY(pi),
                                  child: _buildCardFace(
                                    text: currentCard.backText,
                                    isBack: true,
                                    accentColor: accentColor,
                                    rating: currentCard.difficultyRating,
                                  ),
                                )
                              : _buildCardFace(
                                  text: currentCard.frontText,
                                  isBack: false,
                                  accentColor: accentColor,
                                  rating: currentCard.difficultyRating,
                                ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Active Recall Tag Selection Area
            _buildActionButtons(currentCard, deck.id, cards.length),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, int current, int total, Color accentColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "CELL RECALL PROGRESS",
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AuraColors.textSecondary,
              ),
            ),
            Text(
              "${(progress * 100).round()}% SECURED",
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.white.withValues(alpha: 0.05),
          ),
          child: Stack(
            children: [
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    gradient: LinearGradient(
                      colors: [AuraColors.accentIndigo, accentColor],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardFace({
    required String text,
    required bool isBack,
    required Color accentColor,
    required String rating,
  }) {
    return GlowingGlassContainer(
      glowColor: accentColor.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            colors: [
              AuraColors.surface,
              AuraColors.surface.withValues(alpha: 0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Header Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isBack ? LucideIcons.eye : LucideIcons.eyeOff,
                      color: accentColor.withValues(alpha: 0.6),
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isBack ? "RECALL MATRIX BACKCELL" : "RECALL MATRIX FRONTCELL",
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                if (rating != 'unreviewed')
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: rating == 'easy'
                          ? AuraColors.accentGreen.withValues(alpha: 0.1)
                          : rating == 'hard'
                              ? AuraColors.accentPink.withValues(alpha: 0.1)
                              : AuraColors.accentIndigo.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: rating == 'easy'
                            ? AuraColors.accentGreen.withValues(alpha: 0.3)
                            : rating == 'hard'
                                ? AuraColors.accentPink.withValues(alpha: 0.3)
                                : AuraColors.accentIndigo.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      rating.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: rating == 'easy'
                            ? AuraColors.accentGreen
                            : rating == 'hard'
                                ? AuraColors.accentPink
                                : AuraColors.accentIndigo,
                      ),
                    ),
                  ),
              ],
            ),
            
            const Spacer(),

            // Content Text
            Text(
              text,
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: isBack ? 16 : 20,
                fontWeight: isBack ? FontWeight.normal : FontWeight.bold,
                color: Colors.white,
                height: 1.5,
              ),
            ),

            const Spacer(),

            // Tap prompt
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  LucideIcons.repeat,
                  size: 12,
                  color: accentColor.withValues(alpha: 0.5),
                ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),
                const SizedBox(width: 8),
                Text(
                  isBack ? "TAP TO VEIL BACKCELL" : "TAP TO DECRYPT FRONTCELL",
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                    color: accentColor.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(Flashcard currentCard, String deckId, int totalCards) {
    return Column(
      children: [
        Text(
          "RATE YOUR ACTIVE RECALL CELL RETRIEVAL",
          style: GoogleFonts.orbitron(
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: AuraColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // HARD BUTTON
            Expanded(
              child: InkWell(
                onTap: () => _handleRating(deckId, currentCard.id, 'hard', totalCards),
                borderRadius: BorderRadius.circular(12),
                child: GlowingGlassContainer(
                  glowColor: AuraColors.accentPink.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AuraColors.accentPink.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.01),
                    ),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.flame, color: AuraColors.accentPink, size: 20),
                        const SizedBox(height: 6),
                        Text(
                          "HARD",
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AuraColors.accentPink,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // MEDIUM/REVIEW BUTTON
            Expanded(
              child: InkWell(
                onTap: () => _handleRating(deckId, currentCard.id, 'medium', totalCards),
                borderRadius: BorderRadius.circular(12),
                child: GlowingGlassContainer(
                  glowColor: AuraColors.accentIndigo.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AuraColors.accentIndigo.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.01),
                    ),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.refreshCw, color: AuraColors.accentIndigo, size: 20),
                        const SizedBox(height: 6),
                        Text(
                          "REVIEW",
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AuraColors.accentIndigo,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // EASY BUTTON
            Expanded(
              child: InkWell(
                onTap: () => _handleRating(deckId, currentCard.id, 'easy', totalCards),
                borderRadius: BorderRadius.circular(12),
                child: GlowingGlassContainer(
                  glowColor: AuraColors.accentGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      border: Border.all(color: AuraColors.accentGreen.withValues(alpha: 0.2)),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white.withValues(alpha: 0.01),
                    ),
                    child: Column(
                      children: [
                        const Icon(LucideIcons.award, color: AuraColors.accentGreen, size: 20),
                        const SizedBox(height: 6),
                        Text(
                          "EASY",
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AuraColors.accentGreen,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleRating(String deckId, String cardId, String difficulty, int totalCards) async {
    // Save to Hive using controller provider
    await ref.read(flashcardsControllerProvider.notifier).rateCard(deckId, cardId, difficulty);

    // Track active metric counters
    if (difficulty == 'easy') {
      _easyCount++;
    } else if (difficulty == 'medium') {
      _mediumCount++;
    } else {
      _hardCount++;
    }

    if (_currentIndex + 1 >= totalCards) {
      // Completed the active deck review run
      setState(() {
        _isFinished = true;
      });
    } else {
      // Move to next cell card
      setState(() {
        _currentIndex++;
        _isFlipped = false; // Reset card posture to front
      });
    }
  }

  Widget _buildFinishedSummary(FlashcardDeck deck, Color accentColor) {
    return Scaffold(
      body: Stack(
        children: [
          // Futuristic neon grids
          Positioned.fill(
            child: GridPaper(
              color: Colors.white.withValues(alpha: 0.01),
              divisions: 1,
              subdivisions: 1,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Holographic Hexagon Glow Icon
                  GlowingGlassContainer(
                    glowColor: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                        border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 1.5),
                      ),
                      child: Icon(
                        LucideIcons.shieldCheck,
                        color: accentColor,
                        size: 48,
                      ).animate().scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.1, 1.1),
                            duration: 1.seconds,
                            curve: Curves.easeInOutSine,
                          ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Header title
                  Text(
                    "COGNITIVE DECK COMPLETED",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    deck.title.replaceAll("Deck: ", "").toUpperCase(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      color: accentColor,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Score / Metric Matrices
                  GlowingGlassContainer(
                    glowColor: Colors.white.withValues(alpha: 0.01),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      child: Column(
                        children: [
                          _buildSummaryRow(
                            icon: LucideIcons.award,
                            label: "EASY MASTERY CELLS",
                            count: _easyCount,
                            color: AuraColors.accentGreen,
                          ),
                          const Divider(color: AuraColors.border, height: 24),
                          _buildSummaryRow(
                            icon: LucideIcons.refreshCw,
                            label: "REVIEW CHECKPOINT CELLS",
                            count: _mediumCount,
                            color: AuraColors.accentIndigo,
                          ),
                          const Divider(color: AuraColors.border, height: 24),
                          _buildSummaryRow(
                            icon: LucideIcons.flame,
                            label: "CRITICAL HARD CELLS",
                            count: _hardCount,
                            color: AuraColors.accentPink,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Bottom Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AuraColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setState(() {
                              _currentIndex = 0;
                              _isFlipped = false;
                              _easyCount = 0;
                              _mediumCount = 0;
                              _hardCount = 0;
                              _isFinished = false;
                            });
                          },
                          icon: const Icon(LucideIcons.repeat, size: 16, color: Colors.white),
                          label: Text(
                            "RUN DECK AGAIN",
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: accentColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => context.pop(),
                          icon: const Icon(LucideIcons.logOut, size: 16),
                          label: Text(
                            "HUB CONSOLE",
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
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
        ],
      ),
    );
  }

  Widget _buildSummaryRow({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AuraColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Text(
          "$count CELLS",
          style: GoogleFonts.orbitron(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  void _confirmExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AuraColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AuraColors.border, width: 1),
          ),
          title: Text(
            "ABORT RECALL DECK?",
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            "Your active deck review answers will be persisted, but the current run statistics summary will be lost.",
            style: GoogleFonts.outfit(color: AuraColors.textSecondary, fontSize: 13),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "STAY",
                style: GoogleFonts.orbitron(color: AuraColors.textSecondary, fontSize: 11),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Pop dialog
                Navigator.pop(context); // Pop active review screen
              },
              child: Text(
                "ABORT RUN",
                style: GoogleFonts.orbitron(color: AuraColors.accentPink, fontSize: 11),
              ),
            ),
          ],
        );
      },
    );
  }
}
