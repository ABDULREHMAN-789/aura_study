import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/features/ai/presentation/providers/ai_providers.dart';
import 'package:aura_study/features/notes/presentation/providers/notes_providers.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';

class VoiceRecorderScreen extends ConsumerStatefulWidget {
  const VoiceRecorderScreen({super.key});

  @override
  ConsumerState<VoiceRecorderScreen> createState() => _VoiceRecorderScreenState();
}

class _VoiceRecorderScreenState extends ConsumerState<VoiceRecorderScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _waveController;
  final AudioRecorder _audioRecorder = AudioRecorder();
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  bool _isRecording = false;
  bool _isTranscribing = false;
  bool _speechEnabled = false;
  bool _isSimulatedMode = false;
  
  String _liveText = "Capture standby. Press the neural pulse button to record lecture...";
  String _selectedSubject = "Physics";
  int _secondsRecorded = 0;
  Timer? _timer;
  
  final List<String> _subjects = const ["Physics", "Chemistry", "Mathematics", "Biology", "Computer Science", "General"];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _initSpeech();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _timer?.cancel();
    _audioRecorder.dispose();
    super.dispose();
  }

  /// Initialize real speech-to-text layers
  Future<void> _initSpeech() async {
    try {
      final hasSpeech = await _speechToText.initialize(
        onStatus: (status) {
          debugPrint("AURA SPEECH STATUS: $status");
          if (status == 'done' || status == 'notListening') {
            if (_isRecording && !_isSimulatedMode) {
              // Automatically restart speech recognition for continuous streams if still recording
              _startSpeechListening();
            }
          }
        },
        onError: (errorNotification) {
          debugPrint("AURA SPEECH WARNING: Speech error: $errorNotification");
          setState(() {
            _isSimulatedMode = true;
          });
        },
      );
      setState(() {
        _speechEnabled = hasSpeech;
      });
    } catch (e) {
      debugPrint("AURA SPEECH WARNING: Failed to initialize speech: $e");
      setState(() {
        _speechEnabled = false;
        _isSimulatedMode = true;
      });
    }
  }

  Future<void> _startRecording() async {
    try {
      // 1. Check microphone recording permissions
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        _activateSimulatedMode("MICROPHONE UPLINK DENIED\nSwitched to Simulated Audio Matrix.");
        return;
      }

      // 2. Clear old state
      setState(() {
        _isRecording = true;
        _secondsRecorded = 0;
        _liveText = "";
      });

      _waveController.repeat(reverse: true);

      // Start timer
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) return;
        setState(() {
          _secondsRecorded++;
        });
      });

      // 3. Start local file writer
      // (Using standard local temporary directory parameters)
      final path = 'aura_lecture_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _audioRecorder.start(const RecordConfig(), path: path);

      // 4. Start speech-to-text recognition
      if (_speechEnabled && !_isSimulatedMode) {
        _startSpeechListening();
      } else {
        _startSimulatedTranscription();
      }
    } catch (e) {
      debugPrint("AURA AUDIO WARNING: Failed to start recorder: $e");
      _activateSimulatedMode("DEVICE UPLINK ERROR\nSwitched to Simulated Audio Matrix.");
    }
  }

  void _startSpeechListening() async {
    if (!_speechToText.isListening) {
      await _speechToText.listen(
        onResult: (result) {
          if (!mounted) return;
          setState(() {
            _liveText = result.recognizedWords;
          });
        },
        listenFor: const Duration(minutes: 5),
        pauseFor: const Duration(seconds: 10),
        listenOptions: stt.SpeechListenOptions(
          cancelOnError: false,
          partialResults: true,
        ),
      );
    }
  }

  void _activateSimulatedMode(String notice) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AuraColors.surface,
        duration: const Duration(seconds: 3),
        content: Text(
          notice,
          style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
        ),
      ),
    );
    setState(() {
      _isSimulatedMode = true;
      _isRecording = true;
      _secondsRecorded = 0;
      _liveText = "";
    });

    _waveController.repeat(reverse: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _secondsRecorded++;
      });
    });

    _startSimulatedTranscription();
  }

  /// Periodically adds fake lecture words for a premium mock experience in Simulated Mode
  void _startSimulatedTranscription() {
    final mockLines = {
      "Physics": [
        "Analyzing energy distribution.", "Schrödinger configuration holds.", 
        "Entropy tend to escalate in closed boundaries.", "Quantum coherence active."
      ],
      "Chemistry": [
        "Carboxylic functional groups dominate.", "Esters priority nomenclatures.",
        "Prefix priorities for carbon chains.", "Aqueous molecular reactions."
      ],
      "Mathematics": [
        "Limits approach zero value.", "Instantaneous slope derivations.",
        "Derivatives formulas mapping.", "Differential integration matrices."
      ],
      "General": [
        "Academic study matrices initialized.", "Organizing semantic thoughts.",
        "Study guides synthesis ongoing.", "Learning retention optimization."
      ]
    };

    final lines = mockLines[_selectedSubject] ?? mockLines["General"]!;
    int lineIdx = 0;

    Timer.periodic(const Duration(seconds: 3), (simTimer) {
      if (!_isRecording || !mounted) {
        simTimer.cancel();
        return;
      }
      if (_isSimulatedMode) {
        setState(() {
          final spacer = _liveText.isEmpty ? "" : " ";
          _liveText += "$spacer${lines[lineIdx % lines.length]}";
          lineIdx++;
        });
      }
    });
  }

  Future<void> _stopRecording() async {
    _timer?.cancel();
    _waveController.stop();
    _waveController.reset();

    setState(() {
      _isRecording = false;
      _isTranscribing = true;
    });

    try {
      if (!_isSimulatedMode) {
        final audioPath = await _audioRecorder.stop();
        debugPrint("AURA REC: Stopped audio recorder, saved to $audioPath");
        await _speechToText.stop();
      }
    } catch (e) {
      debugPrint("AURA REC WARNING: Error stopping recorders: $e");
    }

    // Call AI transcription and synthesis service
    final aiService = ref.read(aiServiceProvider);
    
    aiService.transcribeVoice(_liveText, _selectedSubject).then((note) async {
      if (!mounted) return;
      
      // Save newly formulated study note to repositories
      final saved = await ref.read(notesControllerProvider.notifier).saveNote(note);
      if (!mounted) return;
      
      setState(() {
        _isTranscribing = false;
      });

      if (saved) {
        ref.read(activeNoteProvider.notifier).state = note;
        context.push('/notes/editor');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AuraColors.surface,
            content: Text(
              "AUDIO SYNAPSE FORMED: Saved study note in Editor.",
              style: GoogleFonts.outfit(color: AuraColors.accentGreen, fontSize: 13),
            ),
          ),
        );
      }
    }).catchError((e) {
      if (!mounted) return;
      setState(() {
        _isTranscribing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AuraColors.surface,
          content: Text(
            "SYNAPSE ERROR: AI Speech transcription core failed.",
            style: GoogleFonts.outfit(color: AuraColors.accentPink, fontSize: 13),
          ),
        ),
      );
    });
  }

  String _formatTimer(int totalSeconds) {
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AuraColors.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.bottomCenter,
            radius: 1.5,
            colors: [
              AuraColors.accentPink.withValues(alpha: 0.04),
              Colors.transparent,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: _isTranscribing ? _buildHologramLoader() : _buildRecorderConsole(),
          ),
        ),
      ),
    );
  }

  Widget _buildRecorderConsole() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Navigation header
        Padding(
          padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(LucideIcons.arrowLeft, color: Colors.white, size: 20),
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
                    "AUDIO COGNITION",
                    style: GoogleFonts.orbitron(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      color: AuraColors.accentPink,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Voice Capture",
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

        // Subject selector dropdown
        GlassContainer(
          padding: const EdgeInsets.all(14),
          borderColor: Colors.white.withValues(alpha: 0.06),
          child: Row(
            children: [
              const Icon(LucideIcons.graduationCap, color: AuraColors.accentPink, size: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "AI Subject Alignment:",
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
              ),
              DropdownButton<String>(
                value: _selectedSubject,
                dropdownColor: AuraColors.surface,
                underline: const SizedBox(),
                elevation: 4,
                borderRadius: BorderRadius.circular(12),
                style: GoogleFonts.orbitron(
                  color: AuraColors.accentPink,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
                items: _subjects.map((sub) {
                  return DropdownMenuItem(
                    value: sub,
                    child: Text(sub.toUpperCase()),
                  );
                }).toList(),
                onChanged: _isRecording ? null : (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSubject = val;
                    });
                  }
                },
              ),
            ],
          ),
        ).animate().fadeIn(duration: 450.milliseconds),

        const SizedBox(height: 24),

        // Live transcription container
        Expanded(
          child: GlowingGlassContainer(
            glowColor: _isRecording ? AuraColors.accentPink : Colors.transparent,
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.terminal, color: AuraColors.textSecondary, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _isSimulatedMode ? "SIMULATED AUDIO MATRIX" : "LIVE COGNITIVE TRANSCRIBER",
                      style: GoogleFonts.orbitron(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (_isRecording)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AuraColors.accentPink,
                          shape: BoxShape.circle,
                        ),
                      ).animate(onPlay: (c) => c.repeat()).fadeOut(duration: 600.milliseconds, curve: Curves.easeIn),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(color: Colors.white.withValues(alpha: 0.05), height: 1),
                const SizedBox(height: 12),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Text(
                      _liveText,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        color: _isRecording ? Colors.white : AuraColors.textSecondary,
                        height: 1.4,
                        fontStyle: _isRecording ? FontStyle.normal : FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.milliseconds, duration: 400.milliseconds),
        ),

        const SizedBox(height: 32),

        // Pulse visualizer
        Center(
          child: SizedBox(
            height: 60,
            child: _isRecording 
                ? AnimatedBuilder(
                    animation: _waveController,
                    builder: (context, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(24, (index) {
                          // Create dynamic heights utilizing sine frequencies
                          final animationValue = _waveController.value;
                          final factor = (index % 6) + 1;
                          final height = 8.0 + (factor * 8.0) * (0.3 + 0.7 * (1.0 - (animationValue - 0.5).abs() * 2));
                          
                          return Container(
                            width: 3.5,
                            height: height,
                            margin: const EdgeInsets.symmetric(horizontal: 2.5),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: LinearGradient(
                                colors: [
                                  AuraColors.accentPink,
                                  AuraColors.accentIndigo.withValues(alpha: 0.5),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  )
                : Text(
                    "MATRIX STANDBY",
                    style: GoogleFonts.orbitron(
                      fontSize: 11,
                      letterSpacing: 1.5,
                      color: AuraColors.textMuted,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 16),

        // Recorder Controls
        Center(
          child: Column(
            children: [
              Text(
                _formatTimer(_secondsRecorded),
                style: GoogleFonts.orbitron(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 20),
              // Big recording pulse circular FAB
              (() {
                final button = GestureDetector(
                  onTap: () {
                    if (_isRecording) {
                      _stopRecording();
                    } else {
                      _startRecording();
                    }
                  },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isRecording ? Colors.white.withValues(alpha: 0.05) : AuraColors.accentPink.withValues(alpha: 0.12),
                      border: Border.all(
                        color: AuraColors.accentPink.withValues(alpha: _isRecording ? 0.3 : 0.8),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AuraColors.accentPink.withValues(alpha: _isRecording ? 0.05 : 0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        _isRecording ? LucideIcons.square : LucideIcons.mic,
                        color: AuraColors.accentPink,
                        size: 28,
                      ),
                    ),
                  ),
                );
                if (_isRecording) {
                  return button.animate(onPlay: (c) => c.repeat(reverse: true)).scale(
                    begin: const Offset(0.96, 0.96),
                    end: const Offset(1.04, 1.04),
                    duration: 1.2.seconds,
                    curve: Curves.easeInOut,
                  );
                }
                return button;
              })(),
              const SizedBox(height: 12),
              Text(
                _isRecording ? "TAP STOP TO SYNTHESIZE" : "TAP MIC TO ENGAGE UPLINK",
                style: GoogleFonts.orbitron(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AuraColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildHologramLoader() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pink holographic spinner rings
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AuraColors.accentPink.withValues(alpha: 0.3), width: 2),
              ),
              child: Center(
                child: const CircularProgressIndicator(
                  color: AuraColors.accentPink,
                  strokeWidth: 3,
                ).animate(onPlay: (controller) => controller.repeat(reverse: true)).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1.1, 1.1),
                  duration: 1.seconds,
                ),
              ),
            ).animate().scale(begin: const Offset(0.5, 0.5)).fadeIn(),
            const SizedBox(height: 32),
            Text(
              "AUDIO SYNAPSE FORMULATION ACTIVE",
              style: GoogleFonts.orbitron(
                color: AuraColors.accentPink,
                fontWeight: FontWeight.bold,
                fontSize: 12,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Ingesting voice matrices and formulating cognitive structured lecture note...",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
