import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';

class PdfDocumentItem {
  final String title;
  final String description;
  final String url;
  final String size;
  final String subject;

  const PdfDocumentItem({
    required this.title,
    required this.description,
    required this.url,
    required this.size,
    required this.subject,
  });
}

class PdfSelectScreen extends StatefulWidget {
  const PdfSelectScreen({super.key});

  @override
  State<PdfSelectScreen> createState() => _PdfSelectScreenState();
}

class _PdfSelectScreenState extends State<PdfSelectScreen> {
  final TextEditingController _urlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<PdfDocumentItem> _preloadedDocs = const [
    PdfDocumentItem(
      title: "Linear Algebra Syllabus & Notes",
      description: "Vector spaces, matrices, linear transformations, and eigensystems.",
      url: "https://www.math.ucdavis.edu/~linear/linear-guest.pdf",
      size: "1.4 MB",
      subject: "Mathematics",
    ),
    PdfDocumentItem(
      title: "Quantum Physics Chapter 1",
      description: "Schrödinger wave mechanics, potential wells, and quantum nodes.",
      url: "https://web.mit.edu/8.04/www/syllabus.pdf",
      size: "820 KB",
      subject: "Physics",
    ),
    PdfDocumentItem(
      title: "Organic Compounds Guide",
      description: "Functional IUPAC rules, naming hierarchy, and priority schemes.",
      url: "https://www.w3.org/WAI/ER/tests/xhtml/testfiles/resources/pdf/dummy.pdf",
      size: "120 KB",
      subject: "Chemistry",
    ),
  ];

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _loadPdf(String title, String url) {
    if (url.trim().isEmpty) return;
    
    // Navigate to the PDF viewer screen passing query parameters
    context.push(
      Uri(
        path: '/pdf/viewer',
        queryParameters: {
          'title': title,
          'url': url.trim(),
        },
      ).toString(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topRight,
            radius: 1.5,
            colors: [
              AuraColors.accentCyan.withValues(alpha: 0.05),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Back Button & Screen Title
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => context.pop(),
                          icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 22),
                          style: IconButton.styleFrom(
                            backgroundColor: AuraColors.surface,
                            padding: const EdgeInsets.all(12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: AuraColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "CYBERNETIC FILES",
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                color: AuraColors.accentCyan,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Select Study PDF",
                              style: GoogleFonts.outfit(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Section 1: Ingest Custom PDF URL
                SliverToBoxAdapter(
                  child: GlowingGlassContainer(
                    glowColor: AuraColors.accentCyan,
                    padding: const EdgeInsets.all(16.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(LucideIcons.link, color: AuraColors.accentCyan, size: 18),
                              const SizedBox(width: 8),
                              Text(
                                "LINK REMOTE STUDY NODE",
                                style: GoogleFonts.orbitron(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "Provide an external HTTPS PDF document URL to launch cognitive analysis.",
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: AuraColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _urlController,
                            style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Uplink URL required";
                              }
                              if (!value.trim().toLowerCase().startsWith("http")) {
                                return "Invalid URL scheme (must be https://)";
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "https://example.com/study_guide.pdf",
                              hintStyle: GoogleFonts.outfit(color: AuraColors.textMuted, fontSize: 14),
                              filled: true,
                              fillColor: Colors.black.withValues(alpha: 0.3),
                              prefixIcon: const Icon(LucideIcons.globe, color: AuraColors.textSecondary, size: 16),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AuraColors.accentCyan, width: 1.5),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(color: AuraColors.accentPink, width: 1),
                              ),
                              errorStyle: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 11),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  final uri = Uri.parse(_urlController.text.trim());
                                  final name = uri.pathSegments.isNotEmpty 
                                      ? uri.pathSegments.last 
                                      : "Remote_Study_Document.pdf";
                                  _loadPdf(name, _urlController.text);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AuraColors.accentCyan.withValues(alpha: 0.12),
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(color: AuraColors.accentCyan, width: 1),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "INGEST PDF NODE",
                                    style: GoogleFonts.orbitron(
                                      color: AuraColors.accentCyan,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      letterSpacing: 1.2,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(LucideIcons.arrowRight, color: AuraColors.accentCyan, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 400.milliseconds).slideY(begin: 0.1),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // Curated Preloaded Documents Header
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      const Icon(LucideIcons.fileText, color: AuraColors.textSecondary, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        "COGNITIVE DATABASE FILES",
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: AuraColors.textSecondary,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 150.milliseconds),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 16)),

                // Preloaded PDF list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final doc = _preloadedDocs[index];
                      Color subjColor = AuraColors.accentCyan;
                      if (doc.subject == "Physics") subjColor = AuraColors.accentIndigo;
                      if (doc.subject == "Chemistry") subjColor = AuraColors.accentPink;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: InkWell(
                          onTap: () => _loadPdf(doc.title, doc.url),
                          borderRadius: BorderRadius.circular(16),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                // File Icon glowing based on subject
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: subjColor.withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                    border: Border.all(color: subjColor.withValues(alpha: 0.2), width: 1.5),
                                  ),
                                  child: Icon(Icons.picture_as_pdf_outlined, color: subjColor, size: 24),
                                ),
                                const SizedBox(width: 16),
                                // Text parameters
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: subjColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(4),
                                              border: Border.all(color: subjColor.withValues(alpha: 0.3), width: 0.5),
                                            ),
                                            child: Text(
                                              doc.subject.toUpperCase(),
                                              style: GoogleFonts.orbitron(
                                                fontSize: 8,
                                                fontWeight: FontWeight.bold,
                                                color: subjColor,
                                              ),
                                            ),
                                          ),
                                          const Spacer(),
                                          Text(
                                            doc.size,
                                            style: GoogleFonts.orbitron(
                                              fontSize: 9,
                                              color: AuraColors.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        doc.title,
                                        style: GoogleFonts.outfit(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        doc.description,
                                        style: GoogleFonts.outfit(
                                          fontSize: 13,
                                          color: AuraColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  LucideIcons.chevronRight, 
                                  color: Colors.white.withValues(alpha: 0.3), 
                                  size: 18
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(
                        delay: (200 + index * 100).milliseconds,
                        duration: 400.milliseconds,
                      ).slideX(begin: 0.05);
                    },
                    childCount: _preloadedDocs.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
