// lib/screens/mental_screen.dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:audioplayers/audioplayers.dart';

/// Full-featured MentalScreen:
/// - persistent mood history (shared_preferences)
/// - weekly mood chart (fl_chart)
/// - rule-based offline insights
/// - journaling + sentiment from notes
/// - guided meditation player with timer and optional sound
class MentalScreen extends StatefulWidget {
  const MentalScreen({super.key});

  @override
  State<MentalScreen> createState() => _MentalScreenState();
}

class _MentalScreenState extends State<MentalScreen> {
  // UI state
  String? selectedMood; // e.g. "😊 Happy"
  final TextEditingController noteController = TextEditingController();

  // persistence key
  static const String _prefsKey = 'mh_mood_history_v1';

  // in-memory history
  final List<MoodEntry> moodHistory = [];

  // available moods (with numeric score for chart / analysis)
  final List<MoodOption> moodOptions = const [
    MoodOption('😊', 'Happy', 5),
    MoodOption('🙂', 'Content', 4),
    MoodOption('😐', 'Neutral', 3),
    MoodOption('😔', 'Sad', 2),
    MoodOption('😡', 'Angry', 1),
    MoodOption('😰', 'Anxious', 1),
    MoodOption('😴', 'Tired', 2),
  ];

  // CBT micro tasks
  final List<String> cbtTasks = [
    "Identify one negative thought and reframe it.",
    "Write 3 things you’re grateful for today.",
    "Take a 5–10 minute mindful breathing break.",
    "Go for a short mindful walk (10–15 minutes).",
    "Call or message a supportive friend.",
    "Practice progressive muscle relaxation for 5 minutes."
  ];

  // Audio for meditation
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMeditationPlaying = false;

  // Meditation timer
  Timer? _meditationTimer;
  int _meditationSecondsRemaining = 0;
  int _meditationDurationSeconds = 300; // default 5 minutes

  // Loading flag
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    noteController.dispose();
    _audioPlayer.dispose();
    _meditationTimer?.cancel();
    super.dispose();
  }

  // -------------------------
  // Persistence
  // -------------------------
  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> decoded = jsonDecode(raw);
        moodHistory.clear();
        for (final item in decoded) {
          moodHistory.add(MoodEntry.fromMap(Map<String, dynamic>.from(item)));
        }
      } catch (e) {
        // ignore parse errors, start fresh
        moodHistory.clear();
      }
    }
    setState(() {
      _loading = false;
    });
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(moodHistory.map((e) => e.toMap()).toList());
    await prefs.setString(_prefsKey, encoded);
  }

  // -------------------------
  // Add / Delete Entry
  // -------------------------
  void _saveMoodEntry() {
    if (selectedMood == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a mood before saving.')),
      );
      return;
    }
    final entry = MoodEntry(
      mood: selectedMood!,
      note: noteController.text.trim(),
      time: DateTime.now(),
      score: _moodScoreFromLabel(selectedMood!),
      sentimentScore: _inferSentimentScore(noteController.text.trim()),
    );
    setState(() {
      moodHistory.insert(0, entry); // newest first
      selectedMood = null;
      noteController.clear();
    });
    _saveHistory();
    // show insight immediately
    final insight = _generateInsight(entry);
    _showInsightSheet(insight);
  }

  void _deleteEntry(int index) {
    setState(() {
      moodHistory.removeAt(index);
    });
    _saveHistory();
  }

  // -------------------------
  // Rule-based sentiment (offline)
  // Returns -1..1 sentiment based on keywords
  // -------------------------
  double _inferSentimentScore(String text) {
    if (text.isEmpty) return 0.0;
    final lower = text.toLowerCase();
    int score = 0;
    final positive = ['good', 'great', 'happy', 'relaxed', 'calm', 'grateful', 'better'];
    final negative = ['sad', 'anxious', 'depressed', 'angry', 'stressed', 'worried', 'tired', 'bad'];
    for (final p in positive) {
      if (lower.contains(p)) score += 1;
    }
    for (final n in negative) {
      if (lower.contains(n)) score -= 1;
    }
    if (score == 0) return 0.0;
    // normalize to -1..1
    final normalized = score / (score.abs() + 1);
    return normalized.clamp(-1.0, 1.0);
  }

  // Map selected mood label to numeric score (1..5)
  int _moodScoreFromLabel(String labelWithEmoji) {
    // labelWithEmoji like "😊 Happy"
    for (final mo in moodOptions) {
      if (labelWithEmoji.contains(mo.label)) return mo.score;
    }
    return 3;
  }

  // -------------------------
  // Offline "AI" insight generator (rule-based)
  // -------------------------
  MoodInsight _generateInsight(MoodEntry entry) {
    // analyze recent 7 entries
    final recent = moodHistory.take(7).toList();
    final negativeCount = recent.where((e) => e.score <= 2).length;
    final total = recent.length;

    if (entry.score >= 4) {
      return MoodInsight(
        title: "You're doing well — keep it up!",
        detail:
            "You reported feeling ${entry.mood}. Keep doing what supports your well-being. Small routines (sleep, hydration, breaks) help maintain momentum.",
        recommendedTask: "Reflect: what helped you feel this way? Note it down.",
      );
    }

    if (entry.score <= 2) {
      if (negativeCount >= 3 && total >= 3) {
        return MoodInsight(
          title: "Multiple low mood entries detected",
          detail:
              "In the last $total entries, $negativeCount were low. Consider trying a CBT micro-task below or contact someone you trust. If this continues, seek a professional.",
          recommendedTask: cbtTasks[0], // identify & reframe
        );
      } else {
        // single negative
        final fromNote = entry.note.isNotEmpty ? " Note: \"${entry.note}\"" : "";
        return MoodInsight(
          title: "I hear you — a short step can help",
          detail:
              "You reported ${entry.mood}.$fromNote Try a 5-minute breathing exercise or a short journaling prompt to process this.",
          recommendedTask: cbtTasks[2],
        );
      }
    }

    // Neutral fallback
    return MoodInsight(
      title: "Neutral mood — try a small uplift",
      detail:
          "You're feeling ${entry.mood}. A simple gratitude exercise or a short walk may boost your mood.",
      recommendedTask: cbtTasks[1],
    );
  }

  // Quick UI for showing generated insight
  void _showInsightSheet(MoodInsight insight) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(18))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(18),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(insight.title,
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.indigo[800])),
            const SizedBox(height: 12),
            Text(insight.detail),
            const SizedBox(height: 12),
            if (insight.recommendedTask != null)
              ElevatedButton.icon(
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Try recommended task'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                onPressed: () {
                  Navigator.of(ctx).pop();
                  _showTaskDialog(insight.recommendedTask!);
                },
              ),
            const SizedBox(height: 8),
          ]),
        );
      },
    );
  }

  // -------------------------
  // Meditation player + timer
  // -------------------------
  Future<void> _toggleMeditationPlay(String assetFile) async {
    if (_isMeditationPlaying) {
      await _audioPlayer.stop();
      setState(() => _isMeditationPlaying = false);
    } else {
      try {
        await _audioPlayer.play(AssetSource('sounds/$assetFile'));
      } catch (e) {
        // If asset doesn't exist or audio API changed, ignore but not crash.
      }
      setState(() => _isMeditationPlaying = true);
    }
  }

  void _startMeditationTimer(int seconds) {
    _meditationTimer?.cancel();
    setState(() {
      _meditationDurationSeconds = seconds;
      _meditationSecondsRemaining = seconds;
    });
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_meditationSecondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _meditationSecondsRemaining = 0;
          _isMeditationPlaying = false;
        });
        _audioPlayer.stop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meditation finished.')));
      } else {
        setState(() => _meditationSecondsRemaining -= 1);
      }
    });
  }

  void _stopMeditationTimer() {
    _meditationTimer?.cancel();
    setState(() {
      _meditationSecondsRemaining = 0;
      _isMeditationPlaying = false;
    });
    _audioPlayer.stop();
  }

  // -------------------------
  // Chart data (last 7 days)
  // -------------------------
  // Produce last 7 numeric scores (0-5)
  List<FlSpot> _chartSpots() {
    final spots = <FlSpot>[];
    // we want oldest->newest across x axis 0..n-1
    final last7 = moodHistory.take(7).toList().reversed.toList();
    for (var i = 0; i < last7.length; i++) {
      final e = last7[i];
      spots.add(FlSpot(i.toDouble(), e.score.toDouble()));
    }
    if (spots.isEmpty) {
      // placeholder 1 point to avoid chart errors
      spots.add(const FlSpot(0, 3));
    }
    return spots;
  }

  // -------------------------
  // UI build
  // -------------------------
  @override
  Widget build(BuildContext context) {
    final recent = moodHistory.take(7).toList();
    final negativeCount = recent.where((e) => e.score <= 2).length;

    return Scaffold(
      backgroundColor: Colors.indigo.shade50,
      appBar: AppBar(
        title: const Text('Mental Wellness 🧠'),
        backgroundColor: Colors.indigo,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Center(
                      child: Column(
                        children: const [
                          Icon(Icons.self_improvement, size: 72, color: Colors.indigo),
                          SizedBox(height: 10),
                          Text("Your Mind Matters",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo)),
                          SizedBox(height: 6),
                          Text("Track mood • meditate • journal • CBT micro tasks"),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Dashboard summary
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                const Text("Recent Mood Summary", style: TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 6),
                                Text("Entries saved: ${moodHistory.length}"),
                                Text("Negative moods (last 7): $negativeCount"),
                              ]),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                if (moodHistory.isNotEmpty) {
                                  final insight = _generateInsight(moodHistory.first);
                                  _showInsightSheet(insight);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text("No entries yet — add one below.")));
                                }
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                              child: const Text("Get Insight"),
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Chart
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Weekly Mood Trend", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: 160,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: LineChart(
                                  LineChartData(
                                    lineTouchData: LineTouchData(enabled: true),
                                    gridData: FlGridData(show: true, horizontalInterval: 1),
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(showTitles: true, interval: 1),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          getTitlesWidget: (v, meta) {
                                            // label using index to day short name
                                            final idx = v.toInt();
                                            final reversed = moodHistory.take(7).toList().reversed.toList();
                                            if (idx >= 0 && idx < reversed.length) {
                                              final dt = reversed[idx].time;
                                              return Text(DateFormat('E').format(dt), style: const TextStyle(fontSize: 10));
                                            }
                                            return const Text('');
                                          },
                                          reservedSize: 28,
                                          interval: 1,
                                        ),
                                      ),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    minY: 0,
                                    maxY: 5,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: _chartSpots(),
                                        isCurved: true,
                                        dotData: FlDotData(show: true),
                                        belowBarData: BarAreaData(show: true),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mood selector + note
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text("How are you feeling right now?", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: moodOptions.map((m) {
                              final label = "${m.emoji} ${m.label}";
                              final isSelected = selectedMood == label;
                              return ChoiceChip(
                                label: Text(label),
                                selected: isSelected,
                                selectedColor: Colors.indigo.shade300,
                                onSelected: (_) {
                                  setState(() => selectedMood = label);
                                },
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: noteController,
                            decoration: InputDecoration(
                              hintText: "Optional: add a short note (triggers, thoughts...)",
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 10),
                          Row(children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _saveMoodEntry,
                                icon: const Icon(Icons.save),
                                label: const Text("Save Mood"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              onPressed: () {
                                setState(() {
                                  selectedMood = null;
                                  noteController.clear();
                                });
                              },
                              icon: const Icon(Icons.clear),
                              label: const Text("Clear"),
                            ),
                          ])
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CBT tasks + journaling
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text("CBT Micro Tasks", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: cbtTasks.map((task) {
                              return ActionChip(
                                label: Text(task, maxLines: 1, overflow: TextOverflow.ellipsis),
                                onPressed: () => _showTaskDialog(task),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 12),
                          const Divider(),
                          const SizedBox(height: 8),
                          const Text("Journaling", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text("Quick prompt: What is one thing that would make today better?",
                              style: TextStyle(color: Colors.grey[700])),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _openQuickJournal,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                            child: const Text("Open Journal"),
                          )
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Guided Meditation card
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text("Guided Meditation", style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text("Choose a duration and press start. Optionally play a calm sound."),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              DropdownButton<int>(
                                value: _meditationDurationSeconds,
                                items: const [
                                  DropdownMenuItem(value: 120, child: Text("2 min")),
                                  DropdownMenuItem(value: 300, child: Text("5 min")),
                                  DropdownMenuItem(value: 600, child: Text("10 min")),
                                ],
                                onChanged: (v) {
                                  if (v != null) setState(() => _meditationDurationSeconds = v);
                                },
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  // start timer and optionally play sound if asset exists
                                  _startMeditationTimer(_meditationDurationSeconds);
                                  _toggleMeditationPlay('meditation_bell.mp3');
                                },
                                icon: const Icon(Icons.play_arrow),
                                label: const Text("Start"),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                  onPressed: () {
                                    _stopMeditationTimer();
                                  },
                                  icon: const Icon(Icons.stop),
                                  label: const Text("Stop")),
                            ],
                          ),
                          const SizedBox(height: 12),
                          if (_meditationSecondsRemaining > 0)
                            Text("Time remaining: ${_formatDuration(_meditationSecondsRemaining)}"),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Mood history
                    Text("Mood History", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo[800])),
                    const SizedBox(height: 8),
                    moodHistory.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            child: Center(
                                child: Text("No entries yet. Save your mood to build insights.",
                                    style: TextStyle(color: Colors.grey[700]))),
                          )
                        : ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: moodHistory.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final e = moodHistory[index];
                              return Dismissible(
                                key: ValueKey(e.time.toIso8601String()),
                                direction: DismissDirection.endToStart,
                                onDismissed: (_) => _deleteEntry(index),
                                background: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  alignment: Alignment.centerRight,
                                  color: Colors.redAccent,
                                  child: const Icon(Icons.delete, color: Colors.white),
                                ),
                                child: Card(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.indigo.shade100,
                                      child: Text(e.emojiForMood(), style: const TextStyle(fontSize: 20)),
                                    ),
                                    title: Text(e.mood),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (e.note.isNotEmpty) Text(e.note),
                                        Text(DateFormat('yyyy-MM-dd • hh:mm a').format(e.time),
                                            style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                      ],
                                    ),
                                    trailing: IconButton(
                                      icon: const Icon(Icons.more_horiz),
                                      onPressed: () {
                                        final insight = _generateInsight(e);
                                        showDialog(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                                  title: const Text('Insight for this entry'),
                                                  content: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      Text(insight.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                                      const SizedBox(height: 8),
                                                      Text(insight.detail),
                                                    ],
                                                  ),
                                                  actions: [
                                                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
                                                    if (insight.recommendedTask != null)
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.of(ctx).pop();
                                                          _showTaskDialog(insight.recommendedTask!);
                                                        },
                                                        style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                                                        child: const Text('Try task'),
                                                      )
                                                  ],
                                                ));
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
    );
  }

  // small helpers
  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final mm = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final ss = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$mm:$ss";
  }

  void _showTaskDialog(String task) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('CBT Micro Task'),
        content: Text(task),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Great — try to complete the task!")));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text("I'll try it"),
          ),
        ],
      ),
    );
  }

  void _openQuickJournal() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Quick Journal'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Write a short reflection...'),
          maxLines: 4,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  moodHistory.insert(0, MoodEntry(mood: 'Journal', note: text, time: DateTime.now(), score: 3, sentimentScore: _inferSentimentScore(text)));
                });
                _saveHistory();
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text('Save'),
          )
        ],
      ),
    );
  }
}

// -------------------------
// Helper classes
// -------------------------
class MoodOption {
  final String emoji;
  final String label;
  final int score;
  const MoodOption(this.emoji, this.label, this.score);
}

class MoodEntry {
  final String mood; // e.g. "😊 Happy"
  final String note;
  final DateTime time;
  final int score; // 1..5
  final double sentimentScore; // -1..1

  MoodEntry({required this.mood, required this.note, required this.time, required this.score, required this.sentimentScore});

  Map<String, dynamic> toMap() => {
        'mood': mood,
        'note': note,
        'time': time.toIso8601String(),
        'score': score,
        'sentimentScore': sentimentScore,
      };

  factory MoodEntry.fromMap(Map<String, dynamic> m) {
    return MoodEntry(
      mood: m['mood'] ?? 'Neutral',
      note: m['note'] ?? '',
      time: DateTime.tryParse(m['time'] ?? '') ?? DateTime.now(),
      score: (m['score'] is int) ? m['score'] : int.tryParse('${m['score']}') ?? 3,
      sentimentScore: (m['sentimentScore'] is double) ? m['sentimentScore'] : double.tryParse('${m['sentimentScore']}') ?? 0.0,
    );
  }

  String emojiForMood() {
    if (mood.isEmpty) return '🙂';
    return mood.split(' ').first;
  }
}

class MoodInsight {
  final String title;
  final String detail;
  final String? recommendedTask;
  MoodInsight({required this.title, required this.detail, this.recommendedTask});
}
