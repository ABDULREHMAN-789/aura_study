import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _loadingText = "";
  final String _targetText = "SYNTHESIZING COGNITIVE INTERFACE...";
  int _charIndex = 0;
  Timer? _typewriterTimer;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _startTypewriter();
    _navigateToNext();
  }

  void _startTypewriter() {
    _typewriterTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_charIndex < _targetText.length) {
        setState(() {
          _loadingText += _targetText[_charIndex];
          _charIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  void _navigateToNext() {
    _navigationTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _typewriterTimer?.cancel();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Cybernetic space grid/stars style background (simulated via decoration)
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF131131),
                    AuraColors.background,
                  ],
                ),
              ),
            ),
          ),
          
          // Floating glow elements
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentIndigo.withValues(alpha: 0.15),
                    blurRadius: 90,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -150,
            left: -150,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentCyan.withValues(alpha: 0.12),
                    blurRadius: 95,
                    spreadRadius: 45,
                  ),
                ],
              ),
            ),
          ),

          // Central Logo and Branding
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Glowing Sci-Fi Logo Core
                GlowingGlassContainer(
                  width: 130,
                  height: 130,
                  glowColor: AuraColors.accentCyan,
                  padding: EdgeInsets.zero,
                  child: Center(
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: AuraColors.primaryGradient,
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        size: 40,
                        color: Colors.white,
                      ),
                    )
                    .animate(onPlay: (controller) => controller.repeat())
                    .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.3))
                    .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 1.5.seconds, curve: Curves.easeInOutQuad),
                  ),
                )
                .animate()
                .scale(duration: 1.2.seconds, curve: Curves.elasticOut)
                .fadeIn(duration: 800.milliseconds),

                const SizedBox(height: 32),

                // Main Title with Electric Neon Gradient
                ShaderMask(
                  shaderCallback: (bounds) => AuraColors.primaryGradient.createShader(bounds),
                  child: Text(
                    "AURA STUDY",
                    style: GoogleFonts.orbitron(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                      color: Colors.white,
                    ),
                  ),
                )
                .animate()
                .slideY(begin: 0.3, end: 0, duration: 1.seconds, curve: Curves.easeOutCubic)
                .fadeIn(duration: 1.seconds),

                const SizedBox(height: 8),

                // Subtitle
                Text(
                  "NEXT-GEN AI STUDY ASSISTANT",
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: AuraColors.textSecondary,
                  ),
                )
                .animate()
                .fadeIn(delay: 500.milliseconds, duration: 800.milliseconds),

                const SizedBox(height: 80),

                // Sleek tech custom typing loader
                Text(
                  _loadingText,
                  style: GoogleFonts.orbitron(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                    color: AuraColors.accentCyan.withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(height: 16),

                // Horizontal glow progress line
                Container(
                  width: 180,
                  height: 3,
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
                            widthFactor: 1.0,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                gradient: AuraColors.primaryGradient,
                                boxShadow: [
                                  BoxShadow(
                                    color: AuraColors.accentCyan.withValues(alpha: 0.5),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate()
                          .scaleX(begin: 0, end: 1, alignment: Alignment.centerLeft, duration: 3.5.seconds, curve: Curves.easeInOutSine),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
