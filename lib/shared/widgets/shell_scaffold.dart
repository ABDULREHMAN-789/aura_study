
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';

class ShellScaffold extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ShellScaffold({
    super.key,
    required this.navigationShell,
  });

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Crucial to let the body render behind the floating nav bar
      body: Stack(
        children: [
          // Base Background with deep ambient glows
          Positioned.fill(
            child: Container(
              color: AuraColors.background,
            ),
          ),
          
          // Universal ambient lighting behind screens
          Positioned(
            top: -150,
            left: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentIndigo.withValues(alpha: 0.06),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: -150,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentCyan.withValues(alpha: 0.04),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),

          // Main Screen Content
          Positioned.fill(
            child: SafeArea(
              bottom: false, // Extend to bottom so content flows behind navigation bar
              child: Padding(
                padding: const EdgeInsets.only(bottom: 90.0), // Padding to avoid clipping key contents
                child: navigationShell,
              ),
            ),
          ),
          
          // Floating Glassmorphic Bottom Navigation Bar
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SafeArea(
              top: false,
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                borderRadius: BorderRadius.circular(30),
                borderColor: Colors.white.withValues(alpha: 0.08),
                blurSigma: 20.0,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(
                      context: context,
                      index: 0,
                      icon: Icons.grid_view_rounded,
                      activeIcon: Icons.grid_view_rounded,
                      label: "Home",
                    ),
                    _buildNavItem(
                      context: context,
                      index: 1,
                      icon: Icons.sticky_note_2_outlined,
                      activeIcon: Icons.sticky_note_2,
                      label: "Notes",
                    ),
                    _buildNavItem(
                      context: context,
                      index: 2,
                      icon: Icons.auto_awesome_outlined,
                      activeIcon: Icons.auto_awesome,
                      label: "Aura AI",
                      isCenterGlow: true,
                    ),
                    _buildNavItem(
                      context: context,
                      index: 3,
                      icon: Icons.calendar_today_outlined,
                      activeIcon: Icons.calendar_today,
                      label: "Planner",
                    ),
                    _buildNavItem(
                      context: context,
                      index: 4,
                      icon: Icons.person_outline_rounded,
                      activeIcon: Icons.person_rounded,
                      label: "Profile",
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    bool isCenterGlow = false,
  }) {
    final bool isActive = navigationShell.currentIndex == index;
    final Color activeColor = isCenterGlow ? AuraColors.accentIndigo : AuraColors.accentCyan;

    if (isCenterGlow) {
      return GestureDetector(
        onTap: () => _onTap(context, index),
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AuraColors.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AuraColors.accentIndigo.withValues(alpha: isActive ? 0.6 : 0.2),
                blurRadius: isActive ? 15 : 6,
                spreadRadius: 1,
              ),
            ],
            border: Border.all(
              color: isActive ? Colors.white.withValues(alpha: 0.4) : Colors.white.withValues(alpha: 0.1),
              width: 1.5,
            ),
          ),
          child: Icon(
            activeIcon,
            color: Colors.white,
            size: 24,
          )
          .animate(target: isActive ? 1 : 0)
          .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.15, 1.15), duration: 200.milliseconds)
          .shimmer(duration: 1.5.seconds, color: Colors.white.withValues(alpha: 0.3)),
        ),
      );
    }

    return InkWell(
      onTap: () => _onTap(context, index),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isActive ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              size: 22,
              color: isActive ? activeColor : AuraColors.textSecondary,
            )
            .animate(target: isActive ? 1 : 0)
            .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.12, 1.12), duration: 200.milliseconds)
            .custom(
              duration: 300.milliseconds,
              builder: (context, value, child) => Container(
                child: child,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                letterSpacing: 0.5,
                color: isActive ? activeColor : AuraColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
