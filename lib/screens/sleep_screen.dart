// lib/screens/sleep_screen.dart
import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

/// Responsive, startup-level SleepScreen (web-safe)
/// - Glassmorphism
/// - G3 gradient: #AD1457 -> #6A1B9A
/// - Animated stars & moon
/// - Sleep score, bedtime recommendation, chronotype detection (mock AI)
/// - Wind-down tasks (toggles)
/// - Breathing exercise modal (animated)
/// - Dream journal modal with mock AI summary
/// - Bedtime alarm setter (local only)
///
/// Notes:
/// - Add audioplayers to pubspec.yaml and audio assets under assets/sounds/*
/// - This file is intentionally defensive for Flutter Web DDC.

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> with SingleTickerProviderStateMixin {
  // audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String currentSound = "";

  // UI choices
  String selectedRoutine = "Bedtime Routine";
  final List<String> routines = ["Bedtime Routine", "Sleep Recovery", "Sleep Optimization"];

  // Wind-down task state
  final Map<String, bool> _tasks = {
    "Dim lights 30 min before": false,
    "Avoid screens 30 min before": false,
    "5-min breathing": false,
    "Light stretch": false,
  };

  // Dream journal storage (in-memory)
  final List<_DreamEntry> _journal = [];

  // Sleep data (mocked)
  Duration? lastDuration;
  Duration get safeDuration => lastDuration ?? const Duration(hours: 7, minutes: 40);

  double lastQuality = 0.88; // 0..1
  TimeOfDay lastBedtime = const TimeOfDay(hour: 22, minute: 45);

  // Stars animation for hero
  late AnimationController _starsAnim;
  late List<_Star> _stars;

  // Breathing animation controller
  AnimationController? _breathAnim;

  // Alarm - local setting
  TimeOfDay? _bedReminder;
  TimeOfDay? _wakeAlarm;

  var aiTips = {
    "Bedtime Routine": [
      "Establish a consistent sleep schedule.",
      "Limit caffeine intake after 2 PM.",
      "Create a relaxing pre-sleep ritual.",
    ],
    "Sleep Recovery": [
      "Take short naps (20-30 min) if needed.",
      "Avoid heavy meals before bedtime.",
      "Use blackout curtains to darken your room.",
    ],
    "Sleep Optimization": [
      "Maintain a cool room temperature (60–67°F).",
      "Incorporate regular physical activity.",
      "Limit exposure to blue light in the evening.",
    ],
  };

  @override
  void initState() {
    super.initState();
    // initialize safe defaults (prevents DDC/web hot-reload null issues)
    lastDuration = const Duration(hours: 7, minutes: 40);
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _starsAnim = AnimationController(vsync: this, duration: const Duration(seconds: 6));
    _starsAnim.repeat();
    _initStars();
  }

  void _initStars() {
    final rnd = Random();
    _stars = List.generate(48, (i) {
      return _Star(
        x: rnd.nextDouble(),
        y: rnd.nextDouble() * 0.48,
        size: 0.8 + rnd.nextDouble() * 2.8,
        twinklePhase: rnd.nextDouble(),
      );
    });
  }

  @override
  void dispose() {
    _starsAnim.dispose();
    _breathAnim?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  // -------------------------- Core features (mock AI logic) --------------------------

  /// Compute a mock sleep score using duration & quality (0..100).
  /// This implementation is defensive and web-safe (no .isNaN/.isFinite usage).
  int computeSleepScore() {
    final d = safeDuration;

    // duration hours
    final double durationHours = d.inHours + ((d.inMinutes % 60) / 60.0);

    // duration score (0–60)
    double durationScore = (durationHours / 9.0);
    if (durationScore.isNaN || durationScore.isInfinite) durationScore = 0.0;
    if (durationScore < 0) durationScore = 0;
    if (durationScore > 1) durationScore = 1;
    durationScore *= 60.0;

    // quality (0–1) - clamp manually
    double q = lastQuality;
    if (q.isNaN || q.isInfinite) q = 0.8;
    if (q < 0.0) q = 0.0;
    if (q > 1.0) q = 1.0;

    final double qualityScore = q * 40.0;

    final total = (durationScore + qualityScore).round();

    // final clamp
    final clamped = total.clamp(0, 100);
    return clamped;
  }

  /// Smart bedtime recommendation: wakeTime - 7h30m or based on lastBedtime.
  TimeOfDay recommendedBedtime({TimeOfDay? wake}) {
    final wakeTime = wake ?? _wakeAlarm ?? const TimeOfDay(hour: 7, minute: 0);
    final dt = DateTime(2020, 1, 1, wakeTime.hour, wakeTime.minute).subtract(const Duration(hours: 7, minutes: 30));
    return TimeOfDay(hour: dt.hour, minute: dt.minute);
  }

  /// Chronotype detection (mock)
  String detectChronotype() {
    final hour = lastBedtime.hour;
    if (hour <= 22) return "Early Bird 🌅";
    if (hour >= 0 && hour <= 2) return "Night Owl 🌙";
    return "Hummingbird 🐦";
  }

  /// Simple mock "AI" summary for dream text
  _DreamSummary _mockAiSummarize(String text) {
    final lower = text.toLowerCase();
    String tone = "Neutral";
    if (lower.contains("happy") || lower.contains("joy") || lower.contains("love")) tone = "Positive";
    if (lower.contains("scared") || lower.contains("fear") || lower.contains("angry")) tone = "Anxious";
    final tags = <String>[];
    if (lower.contains("water") || lower.contains("ocean") || lower.contains("rain")) tags.add("Water");
    if (lower.contains("flying")) tags.add("Flying");
    if (lower.contains("teeth")) tags.add("Teeth");
    if (tags.isEmpty) tags.add("General");
    final first = text.split(RegExp(r'[.!?\n]')).first;
    final summary = first.length > 120 ? "${first.substring(0, 117)}..." : first;
    return _DreamSummary(summary: summary, tone: tone, tags: tags);
  }

  // -------------------------- Audio controls --------------------------

  Future<void> _toggleSound(String file) async {
    try {
      if (isPlaying && currentSound == file) {
        await _audioPlayer.stop();
        if (!mounted) return;
        setState(() {
          isPlaying = false;
          currentSound = "";
        });
      } else {
        await _audioPlayer.play(AssetSource('sounds/$file'));
        if (!mounted) return;
        setState(() {
          isPlaying = true;
          currentSound = file;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Audio error: $e")));
      }
    }
  }

  // -------------------------- UI / Interaction helpers --------------------------

  void _openMusicBottomSheet() {
    final sounds = [
      {"title": "Rain Sounds", "file": "rain.mp3"},
      {"title": "Ocean Waves", "file": "waves.mp3"},
      {"title": "Forest Night", "file": "forest.mp3"},
      {"title": "Wind Chimes", "file": "wind.mp3"},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white.withOpacity(0.02),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 10),
            const Text("🎵 Sleep Sounds", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...sounds.map((s) {
              final title = s["title"] as String;
              final file = s["file"] as String;
              final playing = currentSound == file && isPlaying;
              return ListTile(
                leading: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.04), child: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.white)),
                title: Text(title, style: const TextStyle(color: Colors.white)),
                trailing: TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _toggleSound(file);
                  },
                  child: Text(playing ? "Pause" : "Play", style: const TextStyle(color: Colors.white)),
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _toggleSound(file);
                },
              );
            }).toList()
          ]),
        );
      },
    );
  }

  void _openDreamJournalModal() {
    final TextEditingController _ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white.withOpacity(0.02),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 12, right: 12, top: 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.06), borderRadius: BorderRadius.circular(8))),
            const SizedBox(height: 12),
            const Text("📝 Dream Journal", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _ctrl,
              minLines: 4,
              maxLines: 10,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Write your dream here...",
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.02),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final txt = _ctrl.text.trim();
                    if (txt.isEmpty) {
                      Navigator.pop(ctx);
                      return;
                    }
                    final summary = _mockAiSummarize(txt);
                    final entry = _DreamEntry(text: txt, date: DateTime.now(), summary: summary);
                    if (!mounted) return;
                    setState(() => _journal.insert(0, entry));
                    Navigator.pop(ctx);
                    showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                              title: const Text("Saved & Summarized"),
                              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Text("Summary: ${summary.summary}"),
                                const SizedBox(height: 8),
                                Text("Tone: ${summary.tone}"),
                                const SizedBox(height: 8),
                                Text("Tags: ${summary.tags.join(', ')}"),
                              ]),
                              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
                            ));
                  },
                  child: const Text("Save & Summarize"),
                ),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
              ],
            ),
            const SizedBox(height: 12),
          ]),
        );
      },
    );
  }

  void _openBreathingExercise() {
    // breathing sequence: 4s inhale, 4s hold, 6s exhale -> repeat x3
    final total = 14;
    _breathAnim?.dispose();
    _breathAnim = AnimationController(vsync: this, duration: Duration(seconds: total))..repeat();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx2, setState2) {
          // guard: avoid adding multiple listeners by using addListener only once
          _breathAnim!.addListener(() {
            if (mounted) setState2(() {});
          });
          final int t = ((_breathAnim!.value.clamp(0.0, 1.0)) * total).floor();
          String phase = "Inhale";
          int phaseTime = 4;
          if (t < 4) {
            phase = "Inhale";
            phaseTime = 4 - t;
          } else if (t < 8) {
            phase = "Hold";
            phaseTime = 8 - t;
          } else {
            phase = "Exhale";
            phaseTime = 14 - t;
          }
          final prog = ((t % total) / total).clamp(0.0, 1.0);
          return WillPopScope(
            onWillPop: () async {
              _breathAnim?.stop();
              _breathAnim?.dispose();
              _breathAnim = null;
              return true;
            },
            child: AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.02),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: SizedBox(
                height: 260,
                width: 260,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  CustomPaint(
                    painter: _BreathPainter(prog),
                    child: SizedBox(width: 160, height: 160, child: Center(child: Text(phase, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                  ),
                  const SizedBox(height: 16),
                  Text("$phase • $phaseTime s", style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      _breathAnim?.stop();
                      _breathAnim?.dispose();
                      _breathAnim = null;
                      Navigator.pop(ctx);
                    },
                    child: const Text("Stop"),
                  )
                ]),
              ),
            ),
          );
        });
      },
    ).then((_) {
      _breathAnim?.stop();
      _breathAnim?.dispose();
      _breathAnim = null;
    });
  }

  Future<void> _pickBedReminder() async {
    final t = await showTimePicker(context: context, initialTime: _bedReminder ?? recommendedBedtime());
    if (t != null && mounted) setState(() => _bedReminder = t);
  }

  Future<void> _pickWakeAlarm() async {
    final t = await showTimePicker(context: context, initialTime: _wakeAlarm ?? const TimeOfDay(hour: 7, minute: 0));
    if (t != null && mounted) setState(() => _wakeAlarm = t);
  }

  // -------------------------- Build UI --------------------------
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;
    final scale = MediaQuery.of(context).textScaleFactor.clamp(1.0, 1.2);

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text("Sleep Companion"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            tooltip: "Sounds",
            icon: Icon(isPlaying ? Icons.volume_up : Icons.volume_off),
            onPressed: () {
              if (currentSound.isEmpty) _openMusicBottomSheet();
              else _toggleSound(currentSound);
            },
          ),
          IconButton(
            tooltip: "Journal",
            icon: const Icon(Icons.book),
            onPressed: _openDreamJournalModal,
          ),
        ],
      ),
      body: Stack(children: [
        // gradient background (G3)
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFAD1457), Color(0xFF6A1B9A)]),
            ),
          ),
        ),
        // decorative soft shapes
        Positioned(top: -80, left: -60, child: _BlurCircle(size: 220, color: Colors.white.withOpacity(0.03))),
        Positioned(bottom: -80, right: -60, child: _BlurCircle(size: 280, color: Colors.white.withOpacity(0.03))),
        // content
        SafeArea(
            child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: isWide ? 36 : 16, vertical: 18),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: isWide ? 1100 : double.infinity),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // hero
                _buildHero(isWide),
                SizedBox(height: 18 * (isWide ? 1.0 : 0.6)),
                // top row: score + tasks + controls (responsive)
                if (isWide)
                  Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Expanded(child: _buildScoreCard(scale)),
                    const SizedBox(width: 16),
                    SizedBox(width: 420, child: Column(children: [_buildTasksCard(), const SizedBox(height: 12), _buildControlCard()])),
                  ])
                else
                  Column(children: [_buildScoreCard(scale), const SizedBox(height: 12), _buildTasksCard(), const SizedBox(height: 12), _buildControlCard()]),
                const SizedBox(height: 16),
                // routines + tips
                Text("🧠 AI-Based Routine Guidance", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * scale)),
                const SizedBox(height: 10),
                _buildRoutineSelector(),
                const SizedBox(height: 12),
                ...aiTips[selectedRoutine]!.map((t) => _buildTipTile(t)).toList(),
                const SizedBox(height: 20),
                // can't sleep quick actions
                Text("🌙 Can't Fall Asleep?", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16 * scale)),
                const SizedBox(height: 10),
                ..._buildCantSleepOptions(),
                const SizedBox(height: 40),
                // dream journal list preview
                if (_journal.isNotEmpty) ...[
                  Text("Recent Dreams", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._journal.map((e) => _buildJournalTile(e)).toList(),
                  const SizedBox(height: 20),
                ],
              ]),
            ),
          ),
        ))
      ]),
    );
  }

  // ---------------------- Component Builders ----------------------

  Widget _buildHero(bool isWide) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(children: [
        // hero base (glass on gradient)
        Container(
          height: isWide ? 260 : 210,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.03)),
          ),
        ),
        // stars painter
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _starsAnim,
            builder: (context, ch) {
              final progress = (_starsAnim.value.clamp(0.0, 1.0));
              return CustomPaint(
                painter: _StarsPainter(_stars, progress),
              );
            },
          ),
        ),
        // moon + texts
        Positioned(left: 20, bottom: 20, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withOpacity(0.06), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 6))]),
            child: const Icon(Icons.nightlight_round, color: Colors.white, size: 36),
          ),
          const SizedBox(height: 12),
          const Text("💤 Smart Sleep Optimization", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text("Your AI companion for better rest and recovery.", style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton(onPressed: _openBreathingExercise, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.06)), child: const Text("Start Breathing")),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: _openDreamJournalModal, style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.06))), child: const Text("Journal", style: TextStyle(color: Colors.white))),
          ])
        ])),
        // right side small stat card (wide)
        Positioned(right: 18, top: 18, child: GlassCard(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          _heroMiniStat("Sleep Score", "${computeSleepScore()}", icon: Icons.insights, color: Colors.pinkAccent),
          const SizedBox(height: 8),
          _heroMiniStat("Chronotype", detectChronotype(), icon: Icons.schedule, color: Colors.purpleAccent),
          const SizedBox(height: 8),
          _heroMiniStat("Recommended", recommendedBedtime().format(context), icon: Icons.bedtime, color: Colors.orangeAccent),
        ])))),
      ]),
    );
  }

  Widget _heroMiniStat(String label, String value, {required IconData icon, required Color color}) {
    return Row(children: [
      CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 10),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(value, style: const TextStyle(color: Colors.white))]),
    ]);
  }

  Widget _buildScoreCard(double scale) {
    final score = computeSleepScore();
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Last Night", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            // circular score
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(alignment: Alignment.center, children: [
                CircularProgressIndicator(value: (score / 100.0).clamp(0.0, 1.0), strokeWidth: 10, color: Colors.white, backgroundColor: Colors.white.withOpacity(0.06)),
                Column(mainAxisSize: MainAxisSize.min, children: [Text("$score", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22)), const Text("Sleep Score", style: TextStyle(color: Colors.white70))])
              ]),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("${_formatDuration(safeDuration)} • ${(lastQuality * 100).round()}% quality", style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                Text("Bedtime: ${lastBedtime.format(context)}", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 14),
                Row(children: [
                  ElevatedButton(onPressed: _openMusicBottomSheet, style: ElevatedButton.styleFrom(backgroundColor: Colors.white.withOpacity(0.06)), child: const Text("Open Sounds")),
                  const SizedBox(width: 8),
                  OutlinedButton(onPressed: _openDreamJournalModal, style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.06))), child: const Text("Journal", style: TextStyle(color: Colors.white))),
                ])
              ]),
            )
          ])
        ]),
      ),
    );
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return "${h}h ${m}m";
  }

  Widget _buildTasksCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Wind-down Tasks", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ..._tasks.keys.map((k) {
            return CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              activeColor: Colors.pinkAccent,
              value: _tasks[k],
              title: Text(k, style: const TextStyle(color: Colors.white)),
              onChanged: (v) => setState(() => _tasks[k] = v ?? false),
            );
          }).toList(),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton(onPressed: () => setState(() => _tasks.updateAll((key, val) => false)), child: const Text("Reset")),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => setState(() => _tasks.updateAll((key, val) => true)), child: const Text("Mark all")),
          ])
        ]),
      ),
    );
  }

  Widget _buildControlCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Bedtime Reminders & Alarm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.bedtime, color: Colors.white),
            title: Text(_bedReminder == null ? "No Bed Reminder" : "Bed Reminder: ${_bedReminder!.format(context)}", style: const TextStyle(color: Colors.white)),
            trailing: ElevatedButton(onPressed: _pickBedReminder, child: const Text("Set")),
          ),
          const SizedBox(height: 8),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.alarm, color: Colors.white),
            title: Text(_wakeAlarm == null ? "No Wake Alarm" : "Wake Alarm: ${_wakeAlarm!.format(context)}", style: const TextStyle(color: Colors.white)),
            trailing: ElevatedButton(onPressed: _pickWakeAlarm, child: const Text("Set")),
          ),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: () => _showBedtimeRecommendationDialog(), child: const Text("Show Recommended Bedtime")),
        ]),
      ),
    );
  }

  void _showBedtimeRecommendationDialog() {
    final rec = recommendedBedtime();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.02),
        title: const Text("Recommended Bedtime", style: TextStyle(color: Colors.white)),
        content: Text("To get ~7h30m sleep, try sleeping by ${rec.format(context)}.", style: const TextStyle(color: Colors.white70)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
      ),
    );
  }

  Widget _buildRoutineSelector() {
    return Container(
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.03))),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRoutine,
          isExpanded: true,
          dropdownColor: Colors.white.withOpacity(0.04),
          style: const TextStyle(color: Colors.white),
          items: routines.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
          onChanged: (v) => setState(() => selectedRoutine = v ?? selectedRoutine),
        ),
      ),
    );
  }

  Widget _buildTipTile(String tip) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.02), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.03))),
      child: Row(children: [const Icon(Icons.lightbulb_outline, color: Colors.white70), const SizedBox(width: 10), Expanded(child: Text(tip, style: const TextStyle(color: Colors.white70)))]),
    );
  }

  List<Widget> _buildCantSleepOptions() {
    return [
      _simpleActionCard(icon: Icons.music_note, title: "Play Calm Music", subtitle: "Rain, waves, forest", onTap: _openMusicBottomSheet),
      _simpleActionCard(icon: Icons.self_improvement, title: "Breathing Exercise", subtitle: "3-min guided breathing", onTap: _openBreathingExercise),
      _simpleActionCard(icon: Icons.menu_book, title: "Read a Light Book", subtitle: "Calm fiction or poetry", onTap: () {}),
      _simpleActionCard(icon: Icons.note_alt, title: "Write Down Thoughts", subtitle: "Quick journaling", onTap: _openDreamJournalModal),
    ];
  }

  Widget _simpleActionCard({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Card(
      color: Colors.white.withOpacity(0.02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.04), child: Icon(icon, color: Colors.white)),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white70)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 14),
        onTap: onTap,
      ),
    );
  }

  Widget _buildJournalTile(_DreamEntry e) {
    return Card(
      color: Colors.white.withOpacity(0.02),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(e.summary.summary, style: const TextStyle(color: Colors.white)),
        subtitle: Text("${e.summary.tone} • ${e.date.toLocal().toString().split('.')[0]}", style: const TextStyle(color: Colors.white70)),
        trailing: IconButton(icon: const Icon(Icons.delete, color: Colors.white70), onPressed: () => setState(() => _journal.remove(e))),
        onTap: () {
          showDialog(context: context, builder: (_) {
            return AlertDialog(
              backgroundColor: Colors.white.withOpacity(0.02),
              title: Text("Dream • ${e.date.toLocal().toString().split('.')[0]}", style: const TextStyle(color: Colors.white)),
              content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text("Full entry:", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text(e.text, style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 12),
                Text("AI Summary: ${e.summary.summary}", style: const TextStyle(color: Colors.white70)),
                const SizedBox(height: 6),
                Text("Tags: ${e.summary.tags.join(', ')}", style: const TextStyle(color: Colors.white70)),
              ]),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Close"))],
            );
          });
        },
      ),
    );
  }
}

// --------------------------- Utility classes & painters ---------------------------

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.04))),
          child: Padding(padding: padding ?? const EdgeInsets.all(12), child: child),
        ),
      ),
    );
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double twinklePhase;
  _Star({required this.x, required this.y, required this.size, required this.twinklePhase});
}

class _StarsPainter extends CustomPainter {
  final List<_Star> stars;
  final double progress; // 0..1, clamped by caller
  _StarsPainter(this.stars, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final p = progress.clamp(0.0, 1.0);
    for (final s in stars) {
      final dx = s.x * size.width;
      final dy = s.y * size.height;
      // safe twinkle: use phase in [0,1]
      final phase = (p + s.twinklePhase) % 1.0;
      final t = (sin((phase) * 2 * pi) + 1) / 2;
      final alpha = (0.25 + t * 0.75);
      paint.color = Colors.white.withOpacity((alpha * 0.9).clamp(0.0, 1.0));
      canvas.drawCircle(Offset(dx, dy), s.size, paint);
    }
    // occasional shooting star - rendered only if p close to 1
    if (p > 0.95 && stars.isNotEmpty) {
      final idx = ((p * stars.length).floor()) % stars.length;
      final pstar = stars[idx];
      final start = Offset(pstar.x * size.width, pstar.y * size.height);
      final end = Offset(((pstar.x + 0.12) * size.width).clamp(0.0, size.width), ((pstar.y + 0.08) * size.height).clamp(0.0, size.height));
      final shoot = Paint()..color = Colors.white.withOpacity(0.06)..strokeWidth = 2..strokeCap = StrokeCap.round;
      canvas.drawLine(start, end, shoot);
    }
  }

  @override
  bool shouldRepaint(covariant _StarsPainter oldDelegate) => true;
}

class _BreathPainter extends CustomPainter {
  final double progress; // 0..1
  _BreathPainter(this.progress);

  // safe linear interpolation (no ui.lerpDouble)
  double safeLerp(double a, double b, double t) {
    final tt = t.clamp(0.0, 1.0);
    return a + (b - a) * tt;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxR = min(size.width, size.height) / 2;
    // breathing size oscillation (ease)
    final p = progress.clamp(0.0, 1.0);
    final value = 0.5 + 0.5 * sin(p * 2 * pi); // safe
    final r = safeLerp(maxR * 0.35, maxR * 0.9, value);
    final paint = Paint()..color = Colors.white.withOpacity(0.12);
    canvas.drawCircle(center, r, paint);
    final paint2 = Paint()..color = Colors.white.withOpacity(0.06);
    canvas.drawCircle(center, r * 0.6, paint2);
  }

  @override
  bool shouldRepaint(covariant _BreathPainter oldDelegate) => true;
}

class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurCircle({required this.size, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 40, spreadRadius: 6)]));
  }
}

class _DreamEntry {
  final String text;
  final DateTime date;
  final _DreamSummary summary;
  _DreamEntry({required this.text, required this.date, required this.summary});
}

class _DreamSummary {
  final String summary;
  final String tone;
  final List<String> tags;
  _DreamSummary({required this.summary, required this.tone, required this.tags});
}
