import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/auth/presentation/providers/auth_providers.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _recoveryDispatched = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submitRecovery() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authControllerProvider.notifier).recoverPassword(
            _emailController.text.trim(),
          );
      if (success) {
        setState(() {
          _recoveryDispatched = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      body: Stack(
        children: [
          // Cyber Space Gradient Grid
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.center,
                  radius: 1.2,
                  colors: [
                    Color(0xFF130A24),
                    AuraColors.background,
                  ],
                ),
              ),
            ),
          ),

          // Deep background glows
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentIndigo.withValues(alpha: 0.12),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            right: -100,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentCyan.withValues(alpha: 0.08),
                    blurRadius: 100,
                    spreadRadius: 30,
                  ),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Sci-fi floating brand emblem
                      GlowingGlassContainer(
                        width: 76,
                        height: 76,
                        glowColor: AuraColors.accentCyan,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AuraColors.primaryGradient,
                            ),
                            child: const Icon(
                              Icons.history_toggle_off,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                      .animate()
                      .scale(duration: 800.milliseconds, curve: Curves.elasticOut)
                      .shimmer(delay: 2.seconds, duration: 1.5.seconds),

                      const SizedBox(height: 20),

                      // Holographic Portal Title
                      ShaderMask(
                        shaderCallback: (bounds) => AuraColors.primaryGradient.createShader(bounds),
                        child: Text(
                          "CYPHER RECOVERY",
                          style: GoogleFonts.orbitron(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "BROADCASTING SECURITY CYPHER RESET SIGNAL",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AuraColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Main Glassmorphic Panel
                      GlowingGlassContainer(
                        glowColor: _recoveryDispatched ? AuraColors.accentGreen : AuraColors.accentCyan,
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(24),
                        child: AnimatedCrossFade(
                          duration: const Duration(milliseconds: 450),
                          firstCurve: Curves.easeOut,
                          secondCurve: Curves.easeIn,
                          crossFadeState: _recoveryDispatched
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // State Controller Error Message Rendering
                              if (authState.hasError) ...[
                                Container(
                                  width: double.infinity,
                                  margin: const EdgeInsets.only(bottom: 20),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AuraColors.accentPink.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: AuraColors.accentPink.withValues(alpha: 0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    authState.error.toString().replaceAll('Exception: ', ''),
                                    style: GoogleFonts.outfit(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                ).animate().shake(duration: 400.milliseconds),
                              ],

                              Text(
                                "Enter your registered cognitive link address. A secure recovery signal will be dispatched instantly.",
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AuraColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),

                              // Email Label
                              Text(
                                "TARGET COMMUNICATION LINK (EMAIL)",
                                style: GoogleFonts.orbitron(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: AuraColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Email Field
                              TextFormField(
                                controller: _emailController,
                                keyboardType: TextInputType.emailAddress,
                                enabled: !isLoading,
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                                decoration: InputDecoration(
                                  hintText: "enter scholar email",
                                  hintStyle: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: AuraColors.textMuted,
                                  ),
                                  prefixIcon: const Icon(Icons.email_outlined, color: AuraColors.textMuted, size: 18),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.02),
                                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1.2),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: AuraColors.accentCyan, width: 1.5),
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return "Email address is required";
                                  }
                                  if (!value.contains("@")) {
                                    return "Provide a valid email signature";
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              // Glowing Submit Button
                              GestureDetector(
                                onTap: isLoading ? null : _submitRecovery,
                                child: GlowingGlassContainer(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  glowColor: isLoading ? AuraColors.textMuted : AuraColors.accentCyan,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: isLoading
                                        ? SizedBox(
                                            height: 18,
                                            width: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(
                                                AuraColors.accentCyan.withValues(alpha: 0.8),
                                              ),
                                            ),
                                          )
                                        : Text(
                                            "DISPATCH RECOVERY SIGNAL",
                                            style: GoogleFonts.orbitron(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AuraColors.accentGreen.withValues(alpha: 0.12),
                                  border: Border.all(
                                    color: AuraColors.accentGreen.withValues(alpha: 0.4),
                                    width: 1.5,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.check_circle_outline,
                                  color: AuraColors.accentGreen,
                                  size: 44,
                                ),
                              )
                              .animate()
                              .scale(duration: 500.milliseconds, curve: Curves.elasticOut),

                              const SizedBox(height: 24),

                              Text(
                                "DISPATCH SUCCESSFUL",
                                style: GoogleFonts.orbitron(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 2,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),

                              Text(
                                "A high-frequency security cypher reset link has been successfully broadcast to:\n\n${_emailController.text}",
                                textAlign: TextAlign.center,
                                style: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AuraColors.textSecondary,
                                  height: 1.5,
                                ),
                              ),

                              const SizedBox(height: 32),

                              // Back button in success page
                              GestureDetector(
                                onTap: () => Navigator.of(context).pop(),
                                child: GlassContainer(
                                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                                  borderColor: AuraColors.accentGreen.withValues(alpha: 0.3),
                                  child: Text(
                                    "RETURN TO ACCESS ENTRY",
                                    style: GoogleFonts.orbitron(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1.5,
                                      color: AuraColors.accentGreen,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate().slideY(begin: 0.1, end: 0, duration: 600.milliseconds, curve: Curves.easeOutCubic),

                      const SizedBox(height: 36),

                      // Return to Login screen
                      if (!_recoveryDispatched)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "REMEMBERED SECURITY KEY? ",
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: AuraColors.textSecondary,
                              ),
                            ),
                            GestureDetector(
                              onTap: isLoading ? null : () => Navigator.of(context).pop(),
                              child: Text(
                                "LOGIN",
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AuraColors.accentCyan,
                                  letterSpacing: 1.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
