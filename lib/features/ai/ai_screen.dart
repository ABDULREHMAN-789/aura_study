import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/ai/presentation/providers/ai_providers.dart';
import 'package:aura_study/features/notes/presentation/providers/notes_providers.dart';

class AIScreen extends ConsumerStatefulWidget {
  const AIScreen({super.key});

  @override
  ConsumerState<AIScreen> createState() => _AIScreenState();
}

class _AIScreenState extends ConsumerState<AIScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _promptSuggestions = [
    "Explain Schrödinger's Cat simply",
    "Generate 5 Chemistry MCQs",
    "Summarize my voice note on Gravity",
    "Parse complex math equations",
  ];

  @override
  void initState() {
    super.initState();
    _scrollToBottom();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _sendMessageWithText(String text) {
    if (text.trim().isEmpty) return;
    
    // Auto-extract note context if there's an active study note selected
    final activeNote = ref.read(activeNoteProvider);
    final contextNote = activeNote != null ? "${activeNote.title}\n\n${activeNote.content}" : null;
    
    ref.read(aiChatHistoryProvider.notifier).sendMessage(text, contextNote);
    _scrollToBottom();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    _sendMessageWithText(text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(aiChatHistoryProvider);

    // Reactively scroll to bottom when new messages arrive
    ref.listen<List<ChatMessage>>(aiChatHistoryProvider, (previous, next) {
      _scrollToBottom();
    });

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Cybernetic Top Header
          _buildAIHeader(),
          
          // Messages Container
          Expanded(
            child: messages.isEmpty ? _buildEmptySuggestions() : _buildMessageList(messages),
          ),

          // Horizontal Suggestions row above keyboard (if only 1 prompt or greeting)
          if (messages.length == 1) _buildSuggestionsRow(),

          // Tech Input Bar
          _buildInputBar(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildAIHeader() {
    final isMock = ref.watch(aiServiceProvider).isMockMode;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: GlassContainer(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        borderColor: AuraColors.accentIndigo.withValues(alpha: 0.18),
        child: Row(
          children: [
            // Glowing AI Core icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AuraColors.primaryGradient,
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
            ).animate(onPlay: (controller) => controller.repeat())
             .shimmer(duration: 2.seconds, color: Colors.white.withValues(alpha: 0.4)),
            const SizedBox(width: 14),
            
            // Text Header
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isMock ? "AURA LOCAL CORE" : "AURA GEMINI CORE",
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Latency/Active indicator dot
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isMock ? AuraColors.accentCyan : AuraColors.accentGreen,
                        ),
                      ).animate(onPlay: (controller) => controller.repeat())
                       .scale(begin: const Offset(0.7, 0.7), end: const Offset(1.3, 1.3), duration: 1.seconds, curve: Curves.easeInOutBack),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isMock ? "Offline Fallback • Zero Latency Sandbox" : "Online • Secure Gemini Engine",
                    style: GoogleFonts.outfit(
                      fontSize: 10,
                      color: AuraColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Quota limit badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withValues(alpha: 0.04),
              ),
              child: Text(
                isMock ? "SANDBOX" : "12 / 20 LEFT",
                style: GoogleFonts.orbitron(
                  fontSize: 8,
                  fontWeight: FontWeight.bold,
                  color: AuraColors.accentCyan,
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Purge memory button
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: AuraColors.accentPink, size: 20),
              tooltip: "Purge Neural Memory",
              onPressed: () {
                ref.read(aiChatHistoryProvider.notifier).clearHistory();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    backgroundColor: AuraColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: const BorderSide(color: AuraColors.accentPink, width: 0.5),
                    ),
                    content: Text(
                      "Tutor neural history purged. Memory caches cleared.",
                      style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySuggestions() {
    return Center(
      child: Text(
        "Initiating Cognitive Synergy...",
        style: GoogleFonts.orbitron(
          color: AuraColors.textMuted,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages) {
    final isWriting = ref.watch(aiChatHistoryProvider.notifier).isWriting;

    return ListView.builder(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: messages.length + (isWriting ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          return _buildScanningLoader();
        }

        final msg = messages[index];
        final isMe = msg.isUser;

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AuraColors.greenGradient,
                    ),
                    child: const Icon(Icons.psychology, size: 16, color: Colors.black),
                  ),
                  const SizedBox(width: 10),
                ],
                
                Flexible(
                  child: GlassContainer(
                    padding: const EdgeInsets.all(14),
                    borderColor: isMe 
                        ? Colors.white.withValues(alpha: 0.04)
                        : AuraColors.accentIndigo.withValues(alpha: 0.12),
                    gradientColors: isMe ? [
                      Colors.white.withValues(alpha: 0.05),
                      Colors.white.withValues(alpha: 0.02),
                    ] : [
                      AuraColors.accentIndigo.withValues(alpha: 0.06),
                      AuraColors.accentCyan.withValues(alpha: 0.02),
                    ],
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe ? 16 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 16),
                    ),
                    child: _buildFormattedText(msg.text, Colors.white),
                  ),
                ),
                
                if (isMe) ...[
                  const SizedBox(width: 10),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AuraColors.accentCyan.withValues(alpha: 0.2),
                      border: Border.all(color: AuraColors.accentCyan.withValues(alpha: 0.4)),
                    ),
                    child: const Icon(Icons.person, size: 16, color: Colors.white),
                  ),
                ],
              ],
            ),
          ).animate().slideY(begin: 0.1, end: 0, duration: 300.milliseconds, curve: Curves.easeOut),
        );
      },
    );
  }

  Widget _buildScanningLoader() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: AuraColors.greenGradient,
              ),
              child: const Icon(Icons.psychology, size: 16, color: Colors.black),
            ).animate(onPlay: (c) => c.repeat())
             .rotate(duration: 3.seconds),
            const SizedBox(width: 10),
            Flexible(
              child: GlassContainer(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                borderColor: AuraColors.accentGreen.withValues(alpha: 0.2),
                gradientColors: [
                  AuraColors.accentGreen.withValues(alpha: 0.06),
                  AuraColors.accentCyan.withValues(alpha: 0.02),
                ],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(4),
                  bottomRight: Radius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "COGNITIVE SYNAPSE TRANSMISSION...",
                      style: GoogleFonts.orbitron(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: AuraColors.accentGreen,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 1.5,
                        color: AuraColors.accentGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().slideY(begin: 0.1, end: 0, duration: 300.milliseconds, curve: Curves.easeOut),
    );
  }

  Widget _buildFormattedText(String text, Color defaultColor) {
    final lines = text.split('\n');
    final List<Widget> children = [];

    for (final line in lines) {
      if (line.trim().isEmpty) {
        children.add(const SizedBox(height: 6));
        continue;
      }

      if (line.startsWith('## ') || line.startsWith('### ')) {
        final headerText = line.replaceFirst(RegExp(r'^###?\s+'), '');
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
            child: Text(
              headerText,
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                color: AuraColors.accentCyan,
              ),
            ),
          ),
        );
        continue;
      }

      if (line.trim().startsWith('* ') || line.trim().startsWith('- ')) {
        final itemText = line.trim().replaceFirst(RegExp(r'^[\*\-]\s+'), '');
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 4.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: AuraColors.accentCyan,
                    shape: BoxShape.rectangle,
                  ),
                ),
                Expanded(
                  child: RichText(
                    text: _parseInlineBold(itemText, defaultColor),
                  ),
                ),
              ],
            ),
          ),
        );
        continue;
      }

      // Normal line
      children.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: RichText(
            text: _parseInlineBold(line, defaultColor),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  TextSpan _parseInlineBold(String text, Color defaultColor) {
    final List<TextSpan> spans = [];
    final RegExp regex = RegExp(r'\*\*(.*?)\*\*');
    int start = 0;

    for (final match in regex.allMatches(text)) {
      if (match.start > start) {
        spans.add(TextSpan(
          text: text.substring(start, match.start),
          style: GoogleFonts.outfit(
            fontSize: 14,
            height: 1.45,
            color: defaultColor,
          ),
        ));
      }
      spans.add(TextSpan(
        text: match.group(1),
        style: GoogleFonts.outfit(
          fontSize: 14,
          height: 1.45,
          fontWeight: FontWeight.bold,
          color: AuraColors.accentIndigo,
        ),
      ));
      start = match.end;
    }

    if (start < text.length) {
      spans.add(TextSpan(
        text: text.substring(start),
        style: GoogleFonts.outfit(
          fontSize: 14,
          height: 1.45,
          color: defaultColor,
        ),
      ));
    }

    return TextSpan(children: spans);
  }

  Widget _buildSuggestionsRow() {
    return Container(
      height: 38,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const BouncingScrollPhysics(),
        itemCount: _promptSuggestions.length,
        itemBuilder: (context, index) {
          final prompt = _promptSuggestions[index];
          return GestureDetector(
            onTap: () {
              _sendMessageWithText(prompt);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white.withValues(alpha: 0.02),
                border: Border.all(color: AuraColors.border, width: 1),
              ),
              child: Center(
                child: Text(
                  prompt,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AuraColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInputBar() {
    // Read the active note state to show context badge if a note is selected
    final activeNote = ref.watch(activeNoteProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (activeNote != null) ...[
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: AuraColors.accentCyan.withValues(alpha: 0.08),
                      border: Border.all(color: AuraColors.accentCyan.withValues(alpha: 0.3), width: 0.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.description, size: 10, color: AuraColors.accentCyan),
                        const SizedBox(width: 4),
                        Text(
                          "CONTEXT: ${activeNote.title.toUpperCase()}",
                          style: GoogleFonts.orbitron(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: AuraColors.accentCyan,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            ref.read(activeNoteProvider.notifier).state = null;
                          },
                          child: const Icon(Icons.cancel, size: 12, color: AuraColors.accentPink),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          GlassContainer(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            borderRadius: BorderRadius.circular(30),
            borderColor: Colors.white.withValues(alpha: 0.08),
            child: Row(
              children: [
                // Attach Files Button (PDF)
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AuraColors.surface,
                        content: Text(
                          "COGNITIVE INTERACTION: Document scanning matrix online.",
                          style: GoogleFonts.outfit(color: AuraColors.accentCyan, fontSize: 13),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, color: AuraColors.accentCyan, size: 22),
                ),
                
                // Microphone Button
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AuraColors.surface,
                        content: Text(
                          "AUDIO COGNITION: Voice summarization interface active.",
                          style: GoogleFonts.outfit(color: AuraColors.accentGreen, fontSize: 13),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.mic_none_rounded, color: AuraColors.textSecondary, size: 22),
                ),
                
                const SizedBox(width: 4),
                
                // Text Input Field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Ask Aura Gemini anything...",
                      hintStyle: GoogleFonts.outfit(
                        color: AuraColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 14.5,
                    ),
                  ),
                ),
                
                // Send Button
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AuraColors.primaryGradient,
                    ),
                    child: const Icon(Icons.arrow_upward, color: Colors.white, size: 18),
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
