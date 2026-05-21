import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/quiz/presentation/providers/quiz_providers.dart';

class QuizSummaryScreen extends ConsumerWidget {
  const QuizSummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quiz = ref.watch(activeQuizSessionProvider);

    if (quiz == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "QUIZ DATA PURGED",
                style: GoogleFonts.orbitron(color: AuraColors.accentPink),
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => context.go('/dashboard'),
                child: const Text("DASHBOARD"),
              ),
            ],
          ),
        ),
      );
    }

    final double percentage = quiz.questions.isNotEmpty 
        ? quiz.score / quiz.questions.length 
        : 0;
    
    final isPassing = percentage >= 0.7;
    final themeColor = isPassing ? AuraColors.accentGreen : AuraColors.accentPink;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 24),
              // Header title
              Text(
                "COGNITIVE PERFORMANCE SUMMARY",
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: AuraColors.textSecondary,
                ),
              ),
              const SizedBox(height: 36),

              // Glowing Circle Score Ring
              Center(
                child: _buildGlowRing(percentage, themeColor)
                    .animate()
                    .scale(duration: 600.milliseconds, curve: Curves.easeOutBack)
                    .fadeIn(duration: 400.milliseconds),
              ),
              const SizedBox(height: 32),

              // Title checklist details
              Text(
                quiz.title.replaceAll("Quiz: ", "").toUpperCase(),
                textAlign: TextAlign.center,
                style: GoogleFonts.orbitron(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                "CATEGORY: ${quiz.category.toUpperCase()}",
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 40),

              // Stats Cards Row
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: "Accuracy Rate",
                      value: "${(percentage * 100).round()}%",
                      icon: LucideIcons.target,
                      color: themeColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      label: "Questions Hit",
                      value: "${quiz.score} / ${quiz.questions.length}",
                      icon: LucideIcons.checkCircle2,
                      color: AuraColors.accentCyan,
                    ),
                  ),
                ],
              ).animate().slideY(begin: 0.15, end: 0, delay: 200.milliseconds, duration: 500.milliseconds),
              
              const SizedBox(height: 16),
              
              // Encouraging evaluation text
              _buildFeedbackCard(isPassing, themeColor)
                  .animate()
                  .slideY(begin: 0.15, end: 0, delay: 300.milliseconds, duration: 500.milliseconds),

              const Spacer(),

              // Action buttons console
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AuraColors.accentIndigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        // Reset session and play again
                        ref.read(activeQuizSessionProvider.notifier).state = quiz.copyWith(score: -1);
                        context.pushReplacement('/quiz/play');
                      },
                      icon: const Icon(LucideIcons.repeat, size: 16),
                      label: Text(
                        "RETRY RUN ⚡",
                        style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: AuraColors.border),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        context.go('/quiz');
                      },
                      icon: const Icon(LucideIcons.arrowLeft, size: 16),
                      label: Text(
                        "RETURN TO HUB 🧠",
                        style: GoogleFonts.orbitron(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 500.milliseconds, duration: 400.milliseconds),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGlowRing(double scorePercentage, Color ringColor) {
    return GlowingGlassContainer(
      glowColor: ringColor.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(100),
      child: Container(
        width: 160,
        height: 160,
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 140,
              height: 140,
              child: CircularProgressIndicator(
                value: scorePercentage,
                strokeWidth: 8,
                backgroundColor: Colors.white.withValues(alpha: 0.04),
                color: ringColor,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${(scorePercentage * 100).round()}%",
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  scorePercentage >= 0.7 ? "PASSED" : "FAILED",
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: ringColor,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      borderColor: Colors.white.withValues(alpha: 0.04),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.outfit(
              fontSize: 11,
              color: AuraColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(bool isPassing, Color themeColor) {
    return GlassContainer(
      borderColor: themeColor.withValues(alpha: 0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(
            isPassing ? LucideIcons.sparkles : LucideIcons.terminal,
            color: themeColor,
            size: 20,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              isPassing 
                  ? "EXCELLENT ACADEMIC LINK! Neural networks successfully mapped this knowledge index. Ready for next academic operations."
                  : "COGNITIVE LOSS REGISTERED. Review your generated summary sheet inside Notes and trigger a retry to recover accuracy parameters.",
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: Colors.white,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
