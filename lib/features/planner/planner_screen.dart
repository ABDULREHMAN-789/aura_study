import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:aura_study/core/themes/aura_theme.dart';
import 'package:aura_study/shared/widgets/glass_container.dart';
import 'package:aura_study/features/planner/domain/planner_model.dart';
import 'package:aura_study/features/planner/presentation/providers/planner_providers.dart';
import 'package:aura_study/features/notes/presentation/providers/notes_providers.dart';

class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  @override
  void initState() {
    super.initState();
    // Request local notification permissions on load
    Future.microtask(() {
      ref.read(notificationServiceProvider).requestPermissions();
    });
  }

  /// Opens the manual task creator modal dialog
  void _openAddTaskDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => const _AddTaskDialog(),
    );
  }

  /// Opens the AI Synergy Bottom Sheet
  void _openAISynergySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => const _AISynergySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(plannerListProvider);
    final isAiLoading = ref.watch(aiPlannerLoadingProvider);

    final completedCount = tasks.where((t) => t.isCompleted).length;
    final totalCount = tasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: AuraColors.background,
          body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Cockpit Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "COGNITIVE COCKPIT",
                            style: GoogleFonts.orbitron(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 2.5,
                              color: AuraColors.accentCyan,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Study Planner",
                            style: GoogleFonts.outfit(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // AI Synergy Quick Action Button
                      GestureDetector(
                        onTap: () => _openAISynergySheet(context),
                        child: GlowingGlassContainer(
                          glowColor: AuraColors.accentPink,
                          borderRadius: BorderRadius.circular(12),
                          padding: const EdgeInsets.all(10),
                          child: const Icon(
                            LucideIcons.sparkles,
                            color: AuraColors.accentPink,
                            size: 20,
                          ),
                        ),
                      ).animate().scale(delay: 200.milliseconds),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Progress Synchronization Panel
                  _buildProgressCard(completedCount, totalCount, progress),
                  const SizedBox(height: 28),

                  // Daily Objectives Checklist Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "DAILY OBJECTIVES",
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AuraColors.textSecondary,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _openAddTaskDialog(context),
                        icon: const Icon(Icons.add, size: 16, color: AuraColors.accentCyan),
                        label: Text(
                          "ADD TASK",
                          style: GoogleFonts.orbitron(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AuraColors.accentCyan,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Study Checklist Dynamic View
                  if (tasks.isEmpty)
                    _buildEmptyState()
                  else
                    _buildTaskChecklist(tasks),
                  
                  const SizedBox(height: 100), // Avoid FAB clipping
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _openAISynergySheet(context),
            backgroundColor: Colors.transparent,
            elevation: 0,
            label: GlowingGlassContainer(
              glowColor: AuraColors.accentPink,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              gradientColors: const [
                AuraColors.accentPink,
                AuraColors.accentIndigo,
              ],
              child: Row(
                children: [
                  const Icon(LucideIcons.sparkles, color: Colors.white, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    "Synergize AI Plan",
                    style: GoogleFonts.orbitron(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        ),

        // Shimmering Scanning AI Overlay
        if (isAiLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.85),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Glowing futuristic scan orb
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AuraColors.accentPink, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AuraColors.accentPink.withValues(alpha: 0.4),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          LucideIcons.cpu,
                          color: AuraColors.accentPink,
                          size: 40,
                        ),
                      ),
                    )
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 1500.milliseconds, color: Colors.white)
                        .scale(
                          begin: const Offset(0.9, 0.9),
                          end: const Offset(1.1, 1.1),
                          duration: 800.milliseconds,
                          curve: Curves.easeInOut,
                        ),
                    const SizedBox(height: 30),
                    Text(
                      "AURA SYSTEM RUNNING",
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        color: AuraColors.accentPink,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Synthesizing study schedule vectors...\nPlease remain sync-locked.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: AuraColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      borderRadius: BorderRadius.circular(16),
      borderColor: Colors.white.withValues(alpha: 0.02),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.calendarDays, color: AuraColors.textMuted, size: 48),
            const SizedBox(height: 16),
            Text(
              "No tasks scheduled yet.",
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              "Add a task manually, or let Aura AI compile an intelligent study blueprint for you.",
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: AuraColors.textMuted,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.milliseconds);
  }

  Widget _buildProgressCard(int completed, int total, double progress) {
    return GlowingGlassContainer(
      glowColor: AuraColors.accentGreen,
      borderRadius: BorderRadius.circular(18),
      child: Row(
        children: [
          // Cybernetic tracker ring
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha: 0.03),
                  valueColor: const AlwaysStoppedAnimation<Color>(AuraColors.accentGreen),
                ),
                Text(
                  "${(progress * 100).toInt()}%",
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          
          // Core Metrics Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sync Accuracy",
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  total == 0 
                      ? "Your scheduler backlog is clean. Synergize notes to plan cognitive sessions."
                      : "You have compiled $completed out of $total tasks scheduled in your queue.",
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    height: 1.35,
                    color: AuraColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.milliseconds).slideY(begin: 0.08, end: 0);
  }

  Widget _buildTaskChecklist(List<StudyTask> tasks) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tasks.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final task = tasks[index];
        
        Color accentColor;
        switch (task.category.toLowerCase()) {
          case 'physics':
            accentColor = AuraColors.accentPink;
            break;
          case 'chemistry':
            accentColor = AuraColors.accentGreen;
            break;
          case 'mathematics':
          case 'math':
            accentColor = AuraColors.accentCyan;
            break;
          default:
            accentColor = AuraColors.accentIndigo;
        }

        final timeFormatted = "${task.scheduledTime.hour.toString().padLeft(2, '0')}:${task.scheduledTime.minute.toString().padLeft(2, '0')}";
        final dayFormatted = "${task.scheduledTime.day}/${task.scheduledTime.month}";

        return Dismissible(
          key: Key(task.id),
          direction: DismissDirection.endToStart,
          onDismissed: (_) {
            ref.read(plannerListProvider.notifier).deleteTask(task.id);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Study objective successfully purged."),
                backgroundColor: AuraColors.surface,
              ),
            );
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AuraColors.accentPink.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(LucideIcons.trash2, color: AuraColors.accentPink),
          ),
          child: GestureDetector(
            onTap: () => ref.read(plannerListProvider.notifier).toggleTaskCompletion(task.id),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              borderColor: task.isCompleted 
                  ? AuraColors.accentGreen.withValues(alpha: 0.2) 
                  : Colors.white.withValues(alpha: 0.04),
              gradientColors: task.isCompleted ? [
                AuraColors.accentGreen.withValues(alpha: 0.04),
                Colors.white.withValues(alpha: 0.01),
              ] : null,
              child: Row(
                children: [
                  // Tactical Sci-Fi Checkbox
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(7),
                      border: Border.all(
                        color: task.isCompleted ? AuraColors.accentGreen : AuraColors.textMuted,
                        width: 1.5,
                      ),
                      color: task.isCompleted ? AuraColors.accentGreen.withValues(alpha: 0.15) : Colors.transparent,
                    ),
                    child: task.isCompleted
                        ? const Icon(Icons.check, size: 15, color: AuraColors.accentGreen)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  
                  // Text and description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                            color: task.isCompleted ? AuraColors.textMuted : Colors.white,
                          ),
                        ),
                        if (task.details.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.details,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: AuraColors.textSecondary,
                              height: 1.3,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        // Clock & reminder badge
                        Row(
                          children: [
                            Icon(LucideIcons.clock, size: 12, color: AuraColors.textMuted),
                            const SizedBox(width: 4),
                            Text(
                              "$dayFormatted at $timeFormatted",
                              style: GoogleFonts.orbitron(
                                fontSize: 10,
                                color: AuraColors.textMuted,
                              ),
                            ),
                            if (task.reminderEnabled) ...[
                              const SizedBox(width: 10),
                              Icon(
                                task.isCompleted 
                                    ? LucideIcons.bellOff 
                                    : LucideIcons.bellRing, 
                                size: 12, 
                                color: task.isCompleted ? AuraColors.textMuted : AuraColors.accentPink
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Scientific discipline badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: accentColor.withValues(alpha: 0.08),
                      border: Border.all(color: accentColor.withValues(alpha: 0.2), width: 0.5),
                    ),
                    child: Text(
                      task.category.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Custom manual StudyTask creation dialog
class _AddTaskDialog extends ConsumerStatefulWidget {
  const _AddTaskDialog();

  @override
  ConsumerState<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends ConsumerState<_AddTaskDialog> {
  final _titleController = TextEditingController();
  final _detailsController = TextEditingController();
  String _selectedCategory = 'General';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _reminderEnabled = true;

  @override
  void dispose() {
    _titleController.dispose();
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AuraColors.accentCyan,
              onPrimary: Colors.black,
              surface: AuraColors.surface,
              onSurface: Colors.white,
            ), dialogTheme: DialogThemeData(backgroundColor: AuraColors.background),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AuraColors.accentCyan,
              onPrimary: Colors.black,
              surface: AuraColors.surface,
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _compileTask() {
    final title = _titleController.text.trim();
    if (title.isEmpty) return;

    final targetDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final uniqueId = 'manual-task-${DateTime.now().millisecondsSinceEpoch}';
    final task = StudyTask(
      id: uniqueId,
      title: title,
      details: _detailsController.text.trim(),
      category: _selectedCategory,
      scheduledTime: targetDateTime,
      isCompleted: false,
      reminderEnabled: _reminderEnabled,
    );

    ref.read(plannerListProvider.notifier).addTask(task);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ['Physics', 'Chemistry', 'Mathematics', 'General'];

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: GlassContainer(
        padding: const EdgeInsets.all(20),
        borderRadius: BorderRadius.circular(20),
        borderColor: Colors.white.withValues(alpha: 0.08),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(LucideIcons.calendarPlus, color: AuraColors.accentCyan, size: 20),
                const SizedBox(width: 10),
                Text(
                  "COMPILE PLAN TARGET",
                  style: GoogleFonts.orbitron(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const Divider(color: AuraColors.border, height: 24),
            
            // Title Input
            Text(
              "Objective Title",
              style: GoogleFonts.orbitron(fontSize: 9, color: AuraColors.textSecondary, letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _titleController,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.02),
                hintText: "Enter study target...",
                hintStyle: GoogleFonts.outfit(color: AuraColors.textMuted, fontSize: 13),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AuraColors.accentCyan, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Details Input
            Text(
              "Execution Details",
              style: GoogleFonts.orbitron(fontSize: 9, color: AuraColors.textSecondary, letterSpacing: 1),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: _detailsController,
              style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
              maxLines: 2,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.02),
                hintText: "Specific pages, formulas, or review steps...",
                hintStyle: GoogleFonts.outfit(color: AuraColors.textMuted, fontSize: 12),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AuraColors.accentCyan, width: 1),
                ),
              ),
            ),
            const SizedBox(height: 14),

            // Subject Area Selector
            Text(
              "Discipline Domain",
              style: GoogleFonts.orbitron(fontSize: 9, color: AuraColors.textSecondary, letterSpacing: 1),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: categories.map((cat) {
                  final isSelected = _selectedCategory == cat;
                  Color catColor;
                  switch (cat.toLowerCase()) {
                    case 'physics': catColor = AuraColors.accentPink; break;
                    case 'chemistry': catColor = AuraColors.accentGreen; break;
                    case 'mathematics': catColor = AuraColors.accentCyan; break;
                    default: catColor = AuraColors.accentIndigo;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(
                        cat,
                        style: GoogleFonts.orbitron(
                          fontSize: 9, 
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.black : catColor
                        ),
                      ),
                      selected: isSelected,
                      selectedColor: catColor,
                      backgroundColor: Colors.white.withValues(alpha: 0.03),
                      checkmarkColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(
                          color: isSelected ? Colors.transparent : catColor.withValues(alpha: 0.3),
                          width: 0.5
                        )
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCategory = cat);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 14),

            // Date & Time pickers
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _selectDate,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      borderRadius: BorderRadius.circular(10),
                      borderColor: Colors.white.withValues(alpha: 0.03),
                      child: Column(
                        children: [
                          Icon(LucideIcons.calendar, color: AuraColors.textSecondary, size: 16),
                          const SizedBox(height: 4),
                          Text(
                            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
                            style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: GlassContainer(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      borderRadius: BorderRadius.circular(10),
                      borderColor: Colors.white.withValues(alpha: 0.03),
                      child: Column(
                        children: [
                          Icon(LucideIcons.alarmClock, color: AuraColors.textSecondary, size: 16),
                          const SizedBox(height: 4),
                          Text(
                            _selectedTime.format(context),
                            style: GoogleFonts.orbitron(fontSize: 10, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Alarms toggle Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.bellRing, color: AuraColors.accentPink, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      "Activate Alarm Reminder",
                      style: GoogleFonts.outfit(color: Colors.white, fontSize: 13),
                    ),
                  ],
                ),
                Switch.adaptive(
                  value: _reminderEnabled,
                  activeColor: AuraColors.accentCyan,
                  onChanged: (val) => setState(() => _reminderEnabled = val),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Controls buttons
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      "ABANDON",
                      style: GoogleFonts.orbitron(color: AuraColors.textMuted, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _compileTask,
                    child: GlowingGlassContainer(
                      glowColor: AuraColors.accentCyan,
                      borderRadius: BorderRadius.circular(10),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      gradientColors: const [AuraColors.accentCyan, AuraColors.accentIndigo],
                      child: Center(
                        child: Text(
                          "COMPILE",
                          style: GoogleFonts.orbitron(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// AI Synergy Note Selector Bottom Sheet
class _AISynergySheet extends ConsumerWidget {
  const _AISynergySheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notesAsync = ref.watch(notesStreamProvider);
    final notes = notesAsync.value ?? [];

    return Container(
      decoration: BoxDecoration(
        color: AuraColors.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08), width: 1),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(LucideIcons.sparkles, color: AuraColors.accentPink, size: 20),
              const SizedBox(width: 10),
              Text(
                "AI COGNITIVE SYNERGY",
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Select an active study note vector. Aura Tutor will automatically extract core theoretical landmarks and synthesize a multi-stage study timeline scheduled with alarms.",
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: AuraColors.textSecondary,
              height: 1.35,
            ),
          ),
          const Divider(color: AuraColors.border, height: 28),
          
          if (notes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Column(
                  children: [
                    Icon(LucideIcons.fileQuestion, color: AuraColors.textMuted, size: 36),
                    const SizedBox(height: 12),
                    Text(
                      "No active study sheets compiled.",
                      style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Compile notes or transcribe lectures first.",
                      style: GoogleFonts.outfit(color: AuraColors.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            )
          else
            Flexible(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: notes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    Color noteColor;
                    switch (note.category.toLowerCase()) {
                      case 'physics': noteColor = AuraColors.accentPink; break;
                      case 'chemistry': noteColor = AuraColors.accentGreen; break;
                      case 'mathematics': case 'math': noteColor = AuraColors.accentCyan; break;
                      default: noteColor = AuraColors.accentIndigo;
                    }

                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                        ref.read(plannerListProvider.notifier).generateAIStudyPlan(
                          note.title,
                          note.content,
                          ref,
                        );
                      },
                      child: GlassContainer(
                        padding: const EdgeInsets.all(14),
                        borderRadius: BorderRadius.circular(12),
                        borderColor: Colors.white.withValues(alpha: 0.03),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: noteColor.withValues(alpha: 0.08),
                              ),
                              child: Icon(LucideIcons.fileText, color: noteColor, size: 18),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "${note.category} • ${note.tags.length} Tags",
                                    style: GoogleFonts.outfit(
                                      fontSize: 11,
                                      color: AuraColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(LucideIcons.chevronRight, color: AuraColors.textMuted, size: 16),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
