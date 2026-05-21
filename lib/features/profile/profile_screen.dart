import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/auth/presentation/providers/auth_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authRepositoryProvider).currentUser;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // User Avatar Section
            _buildAvatarSection(user),
            const SizedBox(height: 24),

            // Premium Upgrade Promotion Banner (Hide if already premium!)
            if (user == null || !user.isPremium) ...[
              _buildPremiumBanner(),
              const SizedBox(height: 24),
            ],

            // Statistics Overview
            _buildStatsGrid(),
            const SizedBox(height: 24),

            // System Configurations
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "SYSTEM CONFIGURATIONS",
                style: GoogleFonts.orbitron(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: AuraColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _buildSettingsList(context, ref),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection(dynamic user) {
    final displayName = user?.displayName ?? "Aura Scholar";
    final email = user?.email ?? "scholar@aurastudy.ai";
    final isPremium = user?.isPremium ?? false;

    return Column(
      children: [
        // Glowing Avatar Frame
        GlowingGlassContainer(
          width: 96,
          height: 96,
          glowColor: isPremium ? AuraColors.accentIndigo : AuraColors.accentCyan,
          padding: EdgeInsets.zero,
          borderRadius: BorderRadius.circular(50),
          child: Center(
            child: Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isPremium ? AuraColors.pinkGradient : AuraColors.primaryGradient,
              ),
              child: const Icon(
                Icons.face_retouching_natural_rounded,
                size: 42,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Name & Email
        Text(
          displayName,
          style: GoogleFonts.outfit(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: GoogleFonts.outfit(
            fontSize: 13,
            color: AuraColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Badge Level
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (isPremium ? AuraColors.accentIndigo : AuraColors.accentCyan).withValues(alpha: 0.08),
            border: Border.all(
              color: (isPremium ? AuraColors.accentIndigo : AuraColors.accentCyan).withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Text(
            isPremium ? "PREMIUM SCHOLAR • LEVEL 89" : "COGNITIVE SCHOLAR • LEVEL 8",
            style: GoogleFonts.orbitron(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: isPremium ? AuraColors.accentIndigo : AuraColors.accentCyan,
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.milliseconds).scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutCubic);
  }

  Widget _buildPremiumBanner() {
    return GlowingGlassContainer(
      glowColor: AuraColors.accentIndigo,
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: AuraColors.accentIndigo, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    "UPGRADE TO AURA PREMIUM",
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Unlock infinite AI queries, offline cloud synchronization, support for larger PDFs up to 50MB, and high-fidelity text-to-speech options.",
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  height: 1.45,
                  color: AuraColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: Text(
                  "Get Premium Access",
                  style: GoogleFonts.orbitron(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.milliseconds, duration: 600.milliseconds);
  }

  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard(
          label: "Quizzes Solved",
          val: "24",
          color: AuraColors.accentGreen,
          icon: Icons.check_circle_outline,
        ),
        const SizedBox(width: 14),
        _buildStatCard(
          label: "Study Hours",
          val: "38.5",
          color: AuraColors.accentCyan,
          icon: Icons.av_timer,
        ),
        const SizedBox(width: 14),
        _buildStatCard(
          label: "Smart Notes",
          val: "18",
          color: AuraColors.accentIndigo,
          icon: Icons.description_outlined,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String val,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
        borderColor: color.withValues(alpha: 0.12),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              val,
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
                fontSize: 10.5,
                fontWeight: FontWeight.w500,
                color: AuraColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsList(BuildContext context, WidgetRef ref) {
    final settings = [
      SettingItem(
        title: "Intelligent Cloud Sync",
        subtitle: "Sync notes to Firestore database",
        icon: Icons.sync,
        isToggle: true,
        val: true,
      ),
      SettingItem(
        title: "Offline Storage Cache",
        subtitle: "Keep recent notes accessible locally",
        icon: Icons.folder_open_outlined,
        isToggle: true,
        val: true,
      ),
      SettingItem(
        title: "AI Security Limit Guard",
        subtitle: "Max 20 requests/day warnings",
        icon: Icons.shield_outlined,
        isToggle: true,
        val: false,
      ),
      SettingItem(
        title: "Purge System Credentials",
        subtitle: "Terminate current authenticated session",
        icon: Icons.logout_outlined,
        isToggle: false,
        val: false,
        onTap: () {
          ref.read(authControllerProvider.notifier).logout();
        },
      ),
    ];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: settings.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = settings[index];
        final isLogout = item.icon == Icons.logout_outlined;

        return GestureDetector(
          onTap: item.onTap,
          child: GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            borderColor: isLogout
                ? AuraColors.accentPink.withValues(alpha: 0.15)
                : Colors.white.withValues(alpha: 0.03),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      item.icon,
                      color: isLogout ? AuraColors.accentPink : AuraColors.accentCyan,
                      size: 20,
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isLogout ? AuraColors.accentPink : Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            color: AuraColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (item.isToggle)
                  Switch.adaptive(
                    value: item.val,
                    onChanged: (v) {},
                    activeColor: AuraColors.accentCyan,
                  )
                else
                  Icon(
                    Icons.chevron_right,
                    color: isLogout ? AuraColors.accentPink : AuraColors.textMuted,
                    size: 20,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class SettingItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isToggle;
  final bool val;
  final VoidCallback? onTap;

  SettingItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isToggle,
    required this.val,
    this.onTap,
  });
}
