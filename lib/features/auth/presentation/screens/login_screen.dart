import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/auth/presentation/providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() async {
    if (_formKey.currentState!.validate()) {
      final success = await ref.read(authControllerProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      if (success && mounted) {
        // dynamic router provider handles redirecting to /dashboard automatically
      }
    }
  }

  void _fillDeveloperPreset(String email, String password) {
    setState(() {
      _emailController.text = email;
      _passwordController.text = password;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final authRepository = ref.watch(authRepositoryProvider);
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
                    Color(0xFF100E26),
                    AuraColors.background,
                  ],
                ),
              ),
            ),
          ),

          // Deep background glows
          Positioned(
            top: -50,
            left: -50,
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
            bottom: -50,
            right: -50,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AuraColors.accentCyan.withValues(alpha: 0.08),
                    blurRadius: 110,
                    spreadRadius: 35,
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
                        shaderCallback: (bounds) => AuraColors.primaryGradient.createShader(bounds),
                        child: Text(
                          "SYNAPSE LOGIN",
                          style: GoogleFonts.orbitron(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "ESTABLISHING COGNITIVE INTERFACE CONNECTION",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.orbitron(
                          fontSize: 8,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.5,
                          color: AuraColors.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Glowing Mock Indicator Banner
                      if (authRepository.isMockMode)
                        Container(
                          margin: const EdgeInsets.only(bottom: 24),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AuraColors.accentPink.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AuraColors.accentPink.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.terminal,
                                color: AuraColors.accentPink,
                                size: 18,
                              ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1.5.seconds),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "OFFLINE MOCK CONSOLE ACTIVE",
                                      style: GoogleFonts.orbitron(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      "Firebase is not initialised. Tap a preset below for instant access.",
                                      style: GoogleFonts.outfit(
                                        fontSize: 9,
                                        color: AuraColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 600.milliseconds),

                      // Main Glassmorphic Input Panel
                      GlowingGlassContainer(
                        glowColor: AuraColors.accentIndigo,
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

                            // Email Input Label
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

                            // Email Text Field
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
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AuraColors.accentPink, width: 1.2),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AuraColors.accentPink, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Email address is mandatory";
                                }
                                if (!value.contains("@")) {
                                  return "Provide a valid email signature";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Password Input Label & Forgot Password Link
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "SECURE CYPHER (PASSWORD)",
                                  style: GoogleFonts.orbitron(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                    color: AuraColors.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: isLoading ? null : () => context.push('/forgot-password'),
                                  child: Text(
                                    "LOST CYPHER?",
                                    style: GoogleFonts.orbitron(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AuraColors.accentCyan,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Password Input Field
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
                                  borderSide: const BorderSide(color: AuraColors.accentIndigo, width: 1.5),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AuraColors.accentPink, width: 1.2),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: AuraColors.accentPink, width: 1.5),
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password security signature is required";
                                }
                                if (value.length < 6) {
                                  return "Security code must be at least 6 characters";
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 28),

                            // Glowing Synapse Submit Button
                            GestureDetector(
                              onTap: isLoading ? null : _submitLogin,
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
                                          "ESTABLISH INTERFACE LINK",
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

                      // Developer Quick Presets Panel
                      if (authRepository.isMockMode) ...[
                        const SizedBox(height: 24),
                        Text(
                          "SELECT DIAGNOSTIC PRESET NODE",
                          style: GoogleFonts.orbitron(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                            color: AuraColors.textSecondary.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: isLoading ? null : () => _fillDeveloperPreset("scholar@aurastudy.ai", "scholar999"),
                                child: GlassContainer(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  borderColor: AuraColors.accentCyan.withValues(alpha: 0.15),
                                  child: Center(
                                    child: Text(
                                      "STANDARD",
                                      style: GoogleFonts.orbitron(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        color: AuraColors.accentCyan,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: isLoading ? null : () => _fillDeveloperPreset("premium.scholar@aurastudy.ai", "premium999"),
                                child: GlassContainer(
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  borderColor: AuraColors.accentIndigo.withValues(alpha: 0.15),
                                  child: Center(
                                    child: Text(
                                      "PREMIUM DEV",
                                      style: GoogleFonts.orbitron(
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        color: AuraColors.accentIndigo,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ).animate().fadeIn(delay: 200.milliseconds),
                      ],

                      const SizedBox(height: 36),

                      // Switch to Registration portal
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "NEW COGNITIVE CORE? ",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AuraColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: isLoading ? null : () => context.push('/register'),
                            child: Text(
                              "INITIALIZE IDENTITY",
                              style: GoogleFonts.orbitron(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AuraColors.accentCyan,
                                letterSpacing: 1,
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
