import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: "SMART AI NOTES",
      description: "Create notes that write themselves. Generate instant summaries, core insights, and automatic smart tags from your lectures.",
      icon: Icons.note_alt_outlined,
      accentColor: AuraColors.accentIndigo,
      featureName: "INTELLIGENT INTEGRATION",
    ),
    OnboardingItem(
      title: "PDF ANALYSIS",
      description: "Upload study files up to 20MB. Extract text instantly, highlight essential concepts, and generate structured summaries.",
      icon: Icons.picture_as_pdf_outlined,
      accentColor: AuraColors.accentCyan,
      featureName: "DEEP COGNITION",
    ),
    OnboardingItem(
      title: "AI GENERATED QUIZZES",
      description: "Transform your notes and PDFs into smart interactive quizzes and matching flashcards. Select your difficulty and track performance.",
      icon: Icons.psychology_outlined,
      accentColor: AuraColors.accentGreen,
      featureName: "RETENTION GENERATION",
    ),
    OnboardingItem(
      title: "VOICE NOTES & PLANNER",
      description: "Record classes or dictations and transcribe them instantly. Plan your targets, maintain active streaks, and accelerate learning.",
      icon: Icons.mic_none_outlined,
      accentColor: AuraColors.accentPink,
      featureName: "ORGANIZED ASCENSION",
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Deep space radial mesh background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF060814),
                    Color(0xFF0F0E28),
                    Color(0xFF05060D),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          
          // Floating background ambient glowing circles
          AnimatedPositioned(
            duration: 1.seconds,
            top: _currentPage == 0 ? 100 : (_currentPage == 1 ? -100 : 200),
            left: _currentPage == 0 ? -100 : 150,
            child: AnimatedContainer(
              duration: 1.seconds,
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _items[_currentPage].accentColor.withValues(alpha: 0.12),
                    blurRadius: 100,
                    spreadRadius: 40,
                  ),
                ],
              ),
            ),
          ),
          AnimatedPositioned(
            duration: 1.seconds,
            bottom: _currentPage == 2 ? 100 : -150,
            right: _currentPage == 3 ? -100 : 200,
            child: AnimatedContainer(
              duration: 1.seconds,
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentCyan.withValues(alpha: 0.08),
                    blurRadius: 95,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                children: [
                  // App branding header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.auto_awesome, color: AuraColors.accentCyan, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "AURA STUDY",
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      TextButton(
                        onPressed: () => context.go('/dashboard'),
                        child: Text(
                          "SKIP",
                          style: GoogleFonts.orbitron(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AuraColors.textSecondary,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const Spacer(),

                  // Dynamic Sliders
                  SizedBox(
                    height: 480,
                    child: PageView.builder(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return _buildOnboardingPage(item);
                      },
                    ),
                  ),

                  const Spacer(),

                  // Bottom Controls Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Indicators
                      Row(
                        children: List.generate(
                          _items.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(right: 8.0),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: _currentPage == index
                                  ? _items[_currentPage].accentColor
                                  : AuraColors.textMuted.withValues(alpha: 0.4),
                              boxShadow: _currentPage == index ? [
                                BoxShadow(
                                  color: _items[_currentPage].accentColor.withValues(alpha: 0.4),
                                  blurRadius: 8,
                                )
                              ] : [],
                            ),
                          ),
                        ),
                      ),

                      // Next/Get Started Button
                      GestureDetector(
                        onTap: () {
                          if (_currentPage < _items.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOutCubic,
                            );
                          } else {
                            context.go('/dashboard');
                          }
                        },
                        child: GlowingGlassContainer(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          glowColor: _items[_currentPage].accentColor,
                          borderRadius: BorderRadius.circular(30),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _currentPage == _items.length - 1 ? "ENTER SYSTEM" : "NEXT SYSTEM",
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.5,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Icon(
                                _currentPage == _items.length - 1 ? Icons.login : Icons.arrow_forward,
                                size: 16,
                                color: Colors.white,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingItem item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Premium Animated Tech Card Visual
        GlowingGlassContainer(
          width: 260,
          height: 230,
          glowColor: item.accentColor,
          padding: EdgeInsets.zero,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Rotating outer tech circles
              Container(
                width: 170,
                height: 170,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: item.accentColor.withValues(alpha: 0.15), width: 1.5),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
              .rotate(begin: 0, end: 1, duration: 8.seconds),

              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: item.accentColor.withValues(alpha: 0.2), width: 1, style: BorderStyle.solid),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
              .rotate(begin: 1, end: 0, duration: 6.seconds),

              // Glowing icon core
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      item.accentColor,
                      item.accentColor.withValues(alpha: 0.6),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: item.accentColor.withValues(alpha: 0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  item.icon,
                  size: 38,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ).animate(key: ValueKey(item.title))
        .scale(duration: 800.milliseconds, curve: Curves.elasticOut)
        .fadeIn(duration: 500.milliseconds),

        const SizedBox(height: 32),

        // Glowing mini tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: item.accentColor.withValues(alpha: 0.12),
            border: Border.all(color: item.accentColor.withValues(alpha: 0.3), width: 1),
          ),
          child: Text(
            item.featureName.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: item.accentColor,
            ),
          ),
        ).animate(key: ValueKey("tag_${item.title}"))
        .fadeIn(delay: 200.milliseconds, duration: 400.milliseconds),

        const SizedBox(height: 16),

        // Core Title
        Text(
          item.title,
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ).animate(key: ValueKey("title_${item.title}"))
        .slideY(begin: 0.2, end: 0, duration: 600.milliseconds, curve: Curves.easeOutQuad)
        .fadeIn(duration: 500.milliseconds),

        const SizedBox(height: 12),

        // Description Body
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            item.description,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AuraColors.textSecondary,
            ),
          ),
        ).animate(key: ValueKey("desc_${item.title}"))
        .fadeIn(delay: 300.milliseconds, duration: 500.milliseconds),
      ],
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color accentColor;
  final String featureName;

  OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.accentColor,
    required this.featureName,
  });
}
