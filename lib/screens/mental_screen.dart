// NEW INTERACTIVE MENTAL SCREEN — STARTUP LEVEL (G2)
// Fully responsive • Vibrant theme • Navigation grid • Extra interactions

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class MentalScreen extends StatefulWidget {
  const MentalScreen({super.key});

  @override
  State<MentalScreen> createState() => _MentalScreenState();
}

class _MentalScreenState extends State<MentalScreen> {
  String? selectedMood;
  final TextEditingController noteController = TextEditingController();
  static const String _prefsKey = 'mh_mood_history_v1';
  final List<MoodEntry> moodHistory = [];

  final List<MoodOption> moodOptions = const [
    MoodOption('😊', 'Happy', 5),
    MoodOption('🙂', 'Content', 4),
    MoodOption('😐', 'Neutral', 3),
    MoodOption('😔', 'Sad', 2),
    MoodOption('😡', 'Angry', 1),
    MoodOption('😰', 'Anxious', 1),
    MoodOption('😴', 'Tired', 2),
  ];

  final List<String> cbtTasks = [
    "Identify one negative thought and reframe it.",
    "Write 3 things you’re grateful for today.",
    "Take a 5–10 minute mindful breathing break.",
    "Go for a short mindful walk (10–15 minutes).",
    "Call or message a supportive friend.",
    "Practice progressive muscle relaxation for 5 minutes."
  ];

  Timer? _meditationTimer;
  int _meditationSecondsRemaining = 0;
  int _meditationDurationSeconds = 300;

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw != null && raw.isNotEmpty) {
      final List decoded = jsonDecode(raw);
      moodHistory.clear();
      for (final i in decoded) {
        moodHistory.add(MoodEntry.fromMap(i));
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(
        _prefsKey, jsonEncode(moodHistory.map((e) => e.toMap()).toList()));
  }

  void _saveMood() {
    if (selectedMood == null) return;
    final entry = MoodEntry(
      mood: selectedMood!,
      note: noteController.text.trim(),
      time: DateTime.now(),
      score: _score(selectedMood!),
      sentimentScore: 0,
    );
    setState(() {
      moodHistory.insert(0, entry);
      selectedMood = null;
      noteController.clear();
    });
    _saveHistory();
  }

  int _score(String mood) {
    for (final m in moodOptions) {
      if (m.label == mood.split(" ").last) return m.score;
    }
    return 3;
  }

  List<FlSpot> _chartSpots() {
    final entries = moodHistory.take(7).toList().reversed.toList();
    if (entries.isEmpty) return [const FlSpot(0, 3)];

    return List.generate(entries.length,
        (i) => FlSpot(i.toDouble(), entries[i].score.toDouble()));
  }

  void _startMeditation(int sec) {
    _meditationTimer?.cancel();
    setState(() {
      _meditationSecondsRemaining = sec;
    });
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_meditationSecondsRemaining <= 1) {
        t.cancel();
      } else {
        setState(() => _meditationSecondsRemaining--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.teal.shade50,
      appBar: AppBar(
        title: const Text("Mental Wellness 🧠"),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildNavigationGrid(size),
                  const SizedBox(height: 16),
                  _buildMoodChart(),
                  const SizedBox(height: 16),
                  _buildMoodSelector(),
                  const SizedBox(height: 16),
                  _buildCBTTasks(),
                  const SizedBox(height: 16),
                  _buildMeditationCard(),
                  const SizedBox(height: 16),
                  _buildHistoryList(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: const [
          Icon(Icons.self_improvement, size: 70, color: Colors.teal),
          SizedBox(height: 10),
          Text("Your Mind Matters",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNavigationGrid(Size size) {
    final items = [
      _nav("Sleep", Icons.nightlight_round),
      _nav("Nutrition", Icons.food_bank),
      _nav("Water", Icons.water_drop),
      _nav("Steps", Icons.directions_walk),
      _nav("Dashboard", Icons.dashboard),
      _nav("Profile", Icons.person),
    ];

    return GridView.count(
      crossAxisCount: size.width > 600 ? 3 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.2,
      children: items,
    );
  }

  Widget _nav(String label, IconData icon) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.teal),
            const SizedBox(height: 8),
            Text(label,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))
          ],
        ),
      ),
    );
  }

  Widget _buildMoodChart() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Mood Trend",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(
              height: 160,
              child: LineChart(LineChartData(
                minY: 0,
                maxY: 5,
                lineBarsData: [
                  LineChartBarData(
                    spots: _chartSpots(),
                    isCurved: true,
                    color: Colors.teal,
                    barWidth: 3,
                    dotData: FlDotData(show: true),
                  )
                ],
              )),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("How are you feeling?",
                style: TextStyle(fontWeight: FontWeight.bold)),
            Wrap(
              spacing: 8,

            runSpacing: 8,
              children: moodOptions.map((m) {
                final label = "${m.emoji} ${m.label}";
                final isSelected = selectedMood == label;
                return ChoiceChip(
                  label: Text(label),
                  selected: isSelected,
                  selectedColor: Colors.teal.shade300,
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
                hintText: "Add a short note (optional)",
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _saveMood,
              icon: const Icon(Icons.save),
              label: const Text("Save Mood"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildCBTTasks() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("CBT Micro Tasks", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: cbtTasks.map((task) => ActionChip(
                label: Text(task, maxLines: 1, overflow: TextOverflow.ellipsis),
                onPressed: () => _showTaskDialog(task),
              )).toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildMeditationCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Guided Meditation", style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onChanged: (v) => setState(() => _meditationDurationSeconds = v ?? 300),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: () => _startMeditation(_meditationDurationSeconds),
                  icon: const Icon(Icons.play_arrow),
                  label: const Text("Start"),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  onPressed: () => _meditationTimer?.cancel(),
                  icon: const Icon(Icons.stop),
                  label: const Text("Stop"),
                )
              ],
            ),
            if (_meditationSecondsRemaining > 0)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text("Remaining: $_meditationSecondsRemaining sec"),
              )
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryList() {
    if (moodHistory.isEmpty) {
      return const Center(child: Text("No entries yet."));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: moodHistory.length,
      itemBuilder: (c, i) {
        final e = moodHistory[i];
        return Card(
          child: ListTile(
            leading: CircleAvatar(child: Text(e.emojiForMood())),
            title: Text(e.mood),
            subtitle: Text(DateFormat('yyyy-MM-dd hh:mm a').format(e.time)),
          ),
        );
      },
    );
  }
}

void _showTaskDialog(String task) {
}

class MoodOption {
  final String emoji;
  final String label;
  final int score;
  const MoodOption(this.emoji, this.label, this.score);
}

class MoodEntry {
  final String mood;
  final String note;
  final DateTime time;
  final int score;
  final double sentimentScore;
  MoodEntry({required this.mood, required this.note, required this.time, required this.score, required this.sentimentScore});

  Map<String, dynamic> toMap() => {
        'mood': mood,
        'note': note,
        'time': time.toIso8601String(),
        'score': score,
        'sentimentScore': sentimentScore,
      };

  factory MoodEntry.fromMap(Map<String, dynamic> m) => MoodEntry(
        mood: m['mood'],
        note: m['note'],
        time: DateTime.parse(m['time']),
        score: m['score'],
        sentimentScore: m['sentimentScore'],
      );

  String emojiForMood() => mood.split(' ').first;
}