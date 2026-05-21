import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/auth/presentation/providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submitRegister() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authControllerProvider.notifier).register(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
          );
      if (success && mounted) {
        // dynamic router provider handles redirecting to /dashboard automatically
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
                    Color(0xFF0C1324),
                    AuraColors.background,
                  ],
                ),
              ),
            ),
          ),

          // Deep background glows
          Positioned(
            top: -80,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentCyan.withValues(alpha: 0.12),
                    blurRadius: 105,
                    spreadRadius: 32,
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            left: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentIndigo.withValues(alpha: 0.08),
                    blurRadius: 95,
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
                        glowColor: AuraColors.accentIndigo,
                        padding: EdgeInsets.zero,
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: AuraColors.pinkGradient,
                            ),
                            child: const Icon(
                              Icons.auto_awesome,
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
                        shaderCallback: (bounds) => AuraColors.pinkGradient.createShader(bounds),
                        child: Text(
                          "IDENTITY SYNTHESIS",
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
                        "CREATING NEW COGNITIVE CORE IDENTITY PATHWAY",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AuraColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Main Glassmorphic Panel
                      GlowingGlassContainer(
                        glowColor: AuraColors.accentPink,
                        borderRadius: BorderRadius.circular(24),
                        padding: const EdgeInsets.all(24),
                        child: Column(
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

                            // Name Label
                            Text(
                              "SCHOLAR IDENTITY (DISPLAY NAME)",
                              style: GoogleFonts.orbitron(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AuraColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Name Field
                            TextFormField(
                              controller: _nameController,
                              keyboardType: TextInputType.name,
                              enabled: !isLoading,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: "enter your name",
                                hintStyle: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AuraColors.textMuted,
                                ),
                                prefixIcon: const Icon(Icons.person_outline, color: AuraColors.textMuted, size: 18),
                                filled: true,
                                fillColor: Colors.white.withValues(alpha: 0.02),
                                contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.06), width: 1.2),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AuraColors.accentPink, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Display name identity is mandatory";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Email Label
                            Text(
                              "COGNITIVE LINK (EMAIL)",
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
                                  borderSide: const BorderSide(color: AuraColors.accentIndigo, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Email signature is required";
                                }
                                if (!value.contains("@")) {
                                  return "Provide a valid email signature";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Password Label
                            Text(
                              "SECURE CYPHER (PASSWORD)",
                              style: GoogleFonts.orbitron(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AuraColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              enabled: !isLoading,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: "enter key password",
                                hintStyle: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AuraColors.textMuted,
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, color: AuraColors.textMuted, size: 18),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AuraColors.textMuted,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
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
                                if (value == null || value.isEmpty) {
                                  return "Security cypher is required";
                                }
                                if (value.length < 6) {
                                  return "Cypher key must be at least 6 characters";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Confirm Password Label
                            Text(
                              "CONFIRM CYPHER (PASSWORD)",
                              style: GoogleFonts.orbitron(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                                color: AuraColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Confirm Password Field
                            TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: _obscurePassword,
                              enabled: !isLoading,
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                hintText: "confirm key password",
                                hintStyle: GoogleFonts.outfit(
                                  fontSize: 13,
                                  color: AuraColors.textMuted,
                                ),
                                prefixIcon: const Icon(Icons.lock_outline, color: AuraColors.textMuted, size: 18),
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
                                if (value == null || value.isEmpty) {
                                  return "Confirming security cypher is mandatory";
                                }
                                if (value != _passwordController.text) {
                                  return "Security cyphers do not match";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 28),

                            // Glowing Synapse Submit Button
                            GestureDetector(
                              onTap: isLoading ? null : _submitRegister,
                              child: GlowingGlassContainer(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                glowColor: isLoading ? AuraColors.textMuted : AuraColors.accentPink,
                                borderRadius: BorderRadius.circular(16),
                                child: Center(
                                  child: isLoading
                                      ? SizedBox(
                                          height: 18,
                                          width: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              AuraColors.accentPink.withValues(alpha: 0.8),
                                            ),
                                          ),
                                        )
                                      : Text(
                                          "SYNTHESIZE IDENTITY",
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
                      ).animate().slideY(begin: 0.1, end: 0, duration: 600.milliseconds, curve: Curves.easeOutCubic),

                      const SizedBox(height: 32),

                      // Switch to Login screen
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "ACTIVE INTERFACE ALREADY EXISTS? ",
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
                                color: AuraColors.accentIndigo,
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
