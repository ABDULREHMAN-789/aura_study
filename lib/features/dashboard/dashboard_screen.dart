import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/auth/presentation/providers/auth_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildWelcomeHeader(user),
            const SizedBox(height: 24),
            
            // Analytics Row
            _buildStreakAndAnalyticsGrid(),
            const SizedBox(height: 24),

            // AI Quota & Limits
            _buildAIQuotaTracker(),
            const SizedBox(height: 28),

            // Section Title: Quick Operations
            _buildSectionTitle("INTELLIGENT OPERATIONS"),
            const SizedBox(height: 12),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 28),

            // Section Title: Recent Activity
            _buildSectionTitle("RECENT COGNITIVE ACTIVITIES"),
            const SizedBox(height: 12),
            _buildRecentActivityList(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeHeader(dynamic user) {
    final displayName = user?.displayName ?? "Aura Scholar";

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "WELCOME BACK,",
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
                color: AuraColors.accentCyan,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayName,
              style: GoogleFonts.outfit(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        // Gamified Streak Status
        GlowingGlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          glowColor: AuraColors.accentPink,
          borderRadius: BorderRadius.circular(20),
          child: Row(
            children: [
              const Icon(Icons.local_fire_department, color: AuraColors.accentPink, size: 20)
                .animate(onPlay: (controller) => controller.repeat())
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 800.milliseconds, curve: Curves.easeInOutSine),
              const SizedBox(width: 4),
              Text(
                "5 DAYS STREAK",
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
      ],
    );
  }

  Widget _buildStreakAndAnalyticsGrid() {
    return Row(
      children: [
        // Target Tracker
        Expanded(
          child: GlassContainer(
            height: 130,
            borderColor: AuraColors.border,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.donut_large_rounded, color: AuraColors.accentCyan, size: 22),
                    Text(
                      "75%",
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AuraColors.accentCyan,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Study Target",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "3 / 4 tasks completed",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().slideY(begin: 0.15, end: 0, duration: 600.milliseconds, curve: Curves.easeOutQuad),
        ),
        const SizedBox(width: 16),
        // Study Duration Analytics
        Expanded(
          child: GlassContainer(
            height: 130,
            borderColor: AuraColors.border,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.timer_outlined, color: AuraColors.accentGreen, size: 22),
                    Text(
                      "2.4 Hrs",
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AuraColors.accentGreen,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Focus Time",
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Daily goal: 3 hours",
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ).animate().slideY(begin: 0.15, end: 0, delay: 100.milliseconds, duration: 600.milliseconds, curve: Curves.easeOutQuad),
        ),
      ],
    );
  }

  Widget _buildAIQuotaTracker() {
    return GlowingGlassContainer(
      glowColor: AuraColors.accentIndigo,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.auto_awesome, color: AuraColors.accentIndigo, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "AI COGNITIVE SYNERGY QUOTA",
                        style: GoogleFonts.orbitron(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                "8 / 20 REQUESTS USED",
                style: GoogleFonts.orbitron(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AuraColors.accentIndigo,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Quota Bar
          Container(
            height: 6,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white.withValues(alpha: 0.05),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: 8 / 20,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: AuraColors.primaryGradient,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Resets in 11 hours 42 minutes. Upgrade to Premium for infinite quota.",
            style: GoogleFonts.outfit(
              fontSize: 10,
              color: AuraColors.textMuted,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.milliseconds, duration: 600.milliseconds);
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.orbitron(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: AuraColors.textSecondary,
      ),
    );
  }

  Widget _buildQuickActionsGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildActionButton(
              label: "Upload PDF",
              icon: Icons.upload_file_rounded,
              color: AuraColors.accentCyan,
              onTap: () => context.push('/pdf'),
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              label: "Voice Rec",
              icon: Icons.mic,
              color: AuraColors.accentPink,
              onTap: () => context.push('/voice'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildActionButton(
              label: "Quiz Gen",
              icon: Icons.psychology,
              color: AuraColors.accentIndigo,
              onTap: () => context.push('/quiz'),
            ),
            const SizedBox(width: 12),
            _buildActionButton(
              label: "Flashcards",
              icon: Icons.layers_rounded,
              color: AuraColors.accentGreen,
              onTap: () => context.push('/flashcards'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildActionButton(
              label: "Export",
              icon: Icons.ios_share,
              color: const Color(0xFFFFB300),
              onTap: () => context.push('/export'),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(vertical: 14),
            borderColor: color.withValues(alpha: 0.15),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color.withValues(alpha: 0.1),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivityList() {
    final activities = [
      ActivityItem(
        title: "Quantum Physics Chapter 2 Summary",
        subtitle: "AI Summarization completed successfully",
        time: "12m ago",
        icon: Icons.auto_awesome,
        color: AuraColors.accentIndigo,
      ),
      ActivityItem(
        title: "Biochemical Pathways Quiz",
        subtitle: "Score: 80% • Hard • 10 Questions",
        time: "2h ago",
        icon: Icons.quiz_outlined,
        color: AuraColors.accentGreen,
      ),
      ActivityItem(
        title: "Linear_Algebra_Notes.pdf",
        subtitle: "Document ingested (14.2 MB)",
        time: "Yesterday",
        icon: Icons.file_present_rounded,
        color: AuraColors.accentCyan,
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: activities.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final activity = activities[index];
        return GlassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          borderColor: Colors.white.withValues(alpha: 0.04),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: activity.color.withValues(alpha: 0.1),
                  border: Border.all(color: activity.color.withValues(alpha: 0.2), width: 1),
                ),
                child: Icon(activity.icon, color: activity.color, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.title,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.subtitle,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: AuraColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                activity.time,
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  color: AuraColors.textMuted,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: (300 + index * 100).milliseconds, duration: 500.milliseconds);
      },
    );
  }
}

class ActivityItem {
  final String title;
  final String subtitle;
  final String time;
  final IconData icon;
  final Color color;

  ActivityItem({
    required this.title,
    required this.subtitle,
    required this.time,
    required this.icon,
    required this.color,
  });
}
