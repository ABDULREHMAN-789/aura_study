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

class QuizArenaScreen extends ConsumerStatefulWidget {
  const QuizArenaScreen({super.key});

  @override
  ConsumerState<QuizArenaScreen> createState() => _QuizArenaScreenState();
}

class _QuizArenaScreenState extends ConsumerState<QuizArenaScreen> {
  @override
  void initState() {
    super.initState();
    // Bootstrap active gameplay variables on widget mounting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(quizGamePlayProvider.notifier).startSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final quiz = ref.watch(activeQuizSessionProvider);
    final gameState = ref.watch(quizGamePlayProvider);

    if (quiz == null) {
      return Scaffold(
        body: Center(
          child: Text(
            "QUIZ DE-SYNCHRONIZED\nReturn to Hub.",
            textAlign: TextAlign.center,
            style: GoogleFonts.orbitron(color: AuraColors.accentPink),
          ),
        ),
      );
    }

    final questions = quiz.questions;
    if (questions.isEmpty) {
      return Scaffold(
        body: Center(
          child: Text(
            "NO QUESTIONS DETECTED",
            style: GoogleFonts.orbitron(color: Colors.white),
          ),
        ),
      );
    }

    // Handle completed quiz execution
    if (gameState.isCompleted) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final completedQuiz = quiz.copyWith(
          score: gameState.correctAnswersCount,
          completedAt: DateTime.now(),
        );
        await ref.read(quizListProvider.notifier).saveQuiz(completedQuiz);
        ref.read(activeQuizSessionProvider.notifier).state = completedQuiz;
        if (context.mounted) {
          context.pushReplacement('/quiz/summary');
        }
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AuraColors.accentCyan),
        ),
      );
    }

    final currentQuestion = questions[gameState.currentQuestionIndex];
    final progress = (gameState.currentQuestionIndex + 1) / questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(quiz.category.toUpperCase()),
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => _confirmExitDialog(context),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: Center(
              child: Text(
                "SCORE: ${gameState.correctAnswersCount}/${questions.length}",
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AuraColors.accentGreen,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Glowing Progress Bar
            _buildProgressBar(progress, gameState.currentQuestionIndex + 1, questions.length),
            const SizedBox(height: 16),

            // Timed progress bar
            _buildTimerProgress(gameState.timerValue),
            const SizedBox(height: 24),

            // Question Container Card
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  children: [
                    _buildQuestionBox(currentQuestion.question),
                    const SizedBox(height: 24),

                    // Options List
                    ...List.generate(currentQuestion.options.length, (index) {
                      final option = currentQuestion.options[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildOptionButton(
                          index: index,
                          optionText: option,
                          correctIndex: currentQuestion.correctIndex,
                          gameState: gameState,
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Explanation Drawer if answer submitted
            if (gameState.isAnswerSubmitted)
              _buildExplanationDrawer(currentQuestion, gameState, questions.length)
                .animate()
                .slideY(begin: 0.3, end: 0, duration: 300.milliseconds, curve: Curves.easeOutQuad),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress, int current, int total) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "QUESTION $current OF $total",
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
                color: AuraColors.textSecondary,
              ),
            ),
            Text(
              "${(progress * 100).round()}% COMPLETE",
              style: GoogleFonts.orbitron(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AuraColors.accentCyan,
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
                    gradient: AuraColors.primaryGradient,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimerProgress(int timerValue) {
    final double percent = timerValue / 15.0;
    final timerColor = timerValue <= 5 ? AuraColors.accentPink : AuraColors.accentCyan;

    return Row(
      children: [
        Icon(LucideIcons.clock, color: timerColor, size: 14)
            .animate(target: timerValue <= 5 ? 1 : 0)
            .shake(duration: 500.milliseconds),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Stack(
              children: [
                FractionallySizedBox(
                  widthFactor: percent,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1),
                      color: timerColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          "${timerValue}s",
          style: GoogleFonts.orbitron(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: timerColor,
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionBox(String question) {
    return GlowingGlassContainer(
      glowColor: AuraColors.accentCyan.withValues(alpha: 0.04),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Text(
          question,
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton({
    required int index,
    required String optionText,
    required int correctIndex,
    required QuizPlayState gameState,
  }) {
    final isSelected = gameState.selectedOptionIndex == index;
    final isAnswered = gameState.isAnswerSubmitted;
    
    Color borderColor = AuraColors.border;
    Color glowColor = Colors.transparent;
    Color textPrefixColor = AuraColors.accentCyan;

    if (isAnswered) {
      if (index == correctIndex) {
        borderColor = AuraColors.accentGreen;
        glowColor = AuraColors.accentGreen.withValues(alpha: 0.12);
        textPrefixColor = AuraColors.accentGreen;
      } else if (isSelected) {
        borderColor = AuraColors.accentPink;
        glowColor = AuraColors.accentPink.withValues(alpha: 0.12);
        textPrefixColor = AuraColors.accentPink;
      }
    } else if (isSelected) {
      borderColor = AuraColors.accentIndigo;
      glowColor = AuraColors.accentIndigo.withValues(alpha: 0.1);
      textPrefixColor = AuraColors.accentIndigo;
    }

    final String prefixChar = String.fromCharCode(65 + index); // A, B, C, D

    return InkWell(
      onTap: () {
        if (isAnswered) return;
        ref.read(quizGamePlayProvider.notifier).selectOption(index);
        ref.read(quizGamePlayProvider.notifier).submitAnswer(correctIndex, index);
      },
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isSelected || (isAnswered && index == correctIndex) ? 1.5 : 1),
          color: glowColor.value != 0 ? glowColor : Colors.white.withValues(alpha: 0.02),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: textPrefixColor.withValues(alpha: 0.3), width: 1),
                borderRadius: BorderRadius.circular(6),
                color: textPrefixColor.withValues(alpha: 0.05),
              ),
              child: Text(
                prefixChar,
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: textPrefixColor,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                optionText,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isAnswered 
                      ? (index == correctIndex ? Colors.white : AuraColors.textSecondary)
                      : Colors.white,
                ),
              ),
            ),
            if (isAnswered && index == correctIndex)
              const Icon(LucideIcons.checkCircle, color: AuraColors.accentGreen, size: 18)
            else if (isAnswered && isSelected)
              const Icon(LucideIcons.alertCircle, color: AuraColors.accentPink, size: 18),
          ],
        ),
      ),
    ).animate(target: isSelected && !isAnswered ? 1 : 0)
     .scale(begin: const Offset(1.0, 1.0), end: const Offset(0.98, 0.98), duration: 150.milliseconds);
  }

  Widget _buildExplanationDrawer(QuizQuestion currentQuestion, QuizPlayState gameState, int totalQuestions) {
    final isCorrect = gameState.selectedOptionIndex == currentQuestion.correctIndex;

    return GlowingGlassContainer(
      glowColor: isCorrect ? AuraColors.accentGreen.withValues(alpha: 0.08) : AuraColors.accentPink.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(
                  isCorrect ? LucideIcons.checkCircle2 : LucideIcons.xCircle,
                  color: isCorrect ? AuraColors.accentGreen : AuraColors.accentPink,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? "CORRECT MATRIX" : "DE-SYNCHRONIZED ANSWER",
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: isCorrect ? AuraColors.accentGreen : AuraColors.accentPink,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              currentQuestion.explanation,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: AuraColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCorrect ? AuraColors.accentGreen : AuraColors.accentPink,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () {
                  ref.read(quizGamePlayProvider.notifier).nextQuestion(totalQuestions);
                },
                icon: const Icon(LucideIcons.zap, size: 14),
                label: Text(
                  gameState.currentQuestionIndex + 1 == totalQuestions 
                      ? "COMPLETE COGNITIVE CHECKOUT 🏁" 
                      : "NEXT QUESTION ⚡",
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
      ),
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
            "ABORT COGNITIVE CHECKPOINT?",
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          content: Text(
            "Your active run will be purged, and stats will not be recorded in Hive local caches.",
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
                Navigator.pop(context); // Pop arena
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
