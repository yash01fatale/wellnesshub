// lib/screens/spirituality_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpiritualityScreen extends StatefulWidget {
  const SpiritualityScreen({super.key});

  @override
  State<SpiritualityScreen> createState() => _SpiritualityScreenState();
}

class _SpiritualityScreenState extends State<SpiritualityScreen>
    with TickerProviderStateMixin {
  // -------------------------------------------------
  // AFFIRMATIONS
  // -------------------------------------------------
  final List<String> _affirmations = [
    "I am calm, centered, and grounded.",
    "I attract peace and harmony into my life.",
    "I am grateful for the love within me.",
    "My mind is clear, my heart is open.",
    "I am aligned with my highest purpose.",
    "I let go of what I cannot control.",
    "I breathe in calm and breathe out tension.",
  ];
  late String _currentAffirmation;

  // -------------------------------------------------
  // HISTORY KEYS
  // -------------------------------------------------
  static const String kAffirmationHistoryKey = 'sp_affirmation_history';
  static const String kGratitudeHistoryKey = 'sp_gratitude_history';
  static const String kJournalHistoryKey = 'sp_journal_history';

  List<Map<String, dynamic>> _affirmationHistory = [];
  List<Map<String, dynamic>> _gratitudeHistory = [];
  List<Map<String, dynamic>> _journalHistory = [];

  // -------------------------------------------------
  // BREATHWORK (4-7-8)
  // -------------------------------------------------
  late AnimationController _breathController;
  double _breathScale = 1.0;
  String _breathPhase = "Idle";
  Timer? _breathTimer;
  int _breathCountdown = 0;
  bool _breathActive = false;

  // -------------------------------------------------
  // MEDITATION TIMER
  // -------------------------------------------------
  Timer? _meditationTimer;
  int _meditationSecondsRemaining = 0;
  bool _meditationRunning = false;

  // -------------------------------------------------
  // CONTROLLERS
  // -------------------------------------------------
  final TextEditingController _gratitudeCtl = TextEditingController();
  final TextEditingController _journalCtl = TextEditingController();

  // -------------------------------------------------
  // INIT
  // -------------------------------------------------
  @override
  void initState() {
    super.initState();
    _currentAffirmation = (_affirmations..shuffle()).first;
    _loadHistories();

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
      lowerBound: 0.8,
      upperBound: 1.4,
    )..addListener(() {
        setState(() => _breathScale = _breathController.value);
      });
  }

  @override
  void dispose() {
    _breathController.dispose();
    _gratitudeCtl.dispose();
    _journalCtl.dispose();
    _breathTimer?.cancel();
    _meditationTimer?.cancel();
    super.dispose();
  }

  // -------------------------------------------------
  // LOCAL STORAGE
  // -------------------------------------------------
  Future<void> _loadHistories() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _affirmationHistory = prefs.getString(kAffirmationHistoryKey) == null
          ? []
          : List<Map<String, dynamic>>.from(
              jsonDecode(prefs.getString(kAffirmationHistoryKey)!));

      _gratitudeHistory = prefs.getString(kGratitudeHistoryKey) == null
          ? []
          : List<Map<String, dynamic>>.from(
              jsonDecode(prefs.getString(kGratitudeHistoryKey)!));

      _journalHistory = prefs.getString(kJournalHistoryKey) == null
          ? []
          : List<Map<String, dynamic>>.from(
              jsonDecode(prefs.getString(kJournalHistoryKey)!));
    });
  }

  Future<void> _saveHistory(String key, List<Map<String, dynamic>> list) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(key, jsonEncode(list));
  }

  // -------------------------------------------------
  // AFFIRMATIONS
  // -------------------------------------------------
  void _nextAffirmation() {
    setState(() {
      _affirmations.shuffle();
      _currentAffirmation = _affirmations.first;
    });
  }

  Future<void> _saveAffirmation() async {
    final entry = {
      "text": _currentAffirmation,
      "time": DateTime.now().toIso8601String(),
    };
    _affirmationHistory.insert(0, entry);
    await _saveHistory(kAffirmationHistoryKey, _affirmationHistory);

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Affirmation saved")));
    setState(() {});
  }

  // -------------------------------------------------
  // GRATITUDE
  // -------------------------------------------------
  Future<void> _saveGratitude() async {
    final text = _gratitudeCtl.text.trim();
    if (text.isEmpty) return;

    final entry = {
      "text": text,
      "time": DateTime.now().toIso8601String(),
    };
    _gratitudeHistory.insert(0, entry);
    await _saveHistory(kGratitudeHistoryKey, _gratitudeHistory);
    _gratitudeCtl.clear();

    setState(() {});
  }

  // -------------------------------------------------
  // JOURNAL
  // -------------------------------------------------
  Future<void> _saveJournal() async {
    final text = _journalCtl.text.trim();
    if (text.isEmpty) return;

    final entry = {
      "text": text,
      "time": DateTime.now().toIso8601String(),
    };
    _journalHistory.insert(0, entry);
    await _saveHistory(kJournalHistoryKey, _journalHistory);
    _journalCtl.clear();

    setState(() {});
  }

  // -------------------------------------------------
  // BREATHWORK 4-7-8
  // -------------------------------------------------
  void _startBreathwork() {
    if (_breathActive) return;

    _breathActive = true;
    _runBreathCycle();
  }

  void _stopBreathwork() {
    _breathActive = false;
    _breathTimer?.cancel();
    _breathController.stop();

    setState(() {
      _breathPhase = "Idle";
      _breathCountdown = 0;
      _breathScale = 1.0;
    });
  }

  void _runBreathCycle() {
    if (!_breathActive) return;

    // inhale 4 seconds
    _breathPhase = "Inhale";
    _animateBreath(to: _breathController.upperBound, duration: 4);
    _countdown(4, () {
      if (!_breathActive) return;

      // hold 7 seconds
      _breathPhase = "Hold";
      _countdown(7, () {
        if (!_breathActive) return;

        // exhale 8 seconds
        _breathPhase = "Exhale";
        _animateBreath(to: _breathController.lowerBound, duration: 8);
        _countdown(8, () {
          if (_breathActive) _runBreathCycle();
        });
      });
    });
  }

  void _countdown(int seconds, VoidCallback onComplete) {
    _breathCountdown = seconds;
    _breathTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _breathCountdown--);
      if (_breathCountdown <= 0) {
        timer.cancel();
        onComplete();
      }
    });
  }

  void _animateBreath({required double to, required int duration}) {
    _breathController.duration = Duration(seconds: duration);
    _breathController.animateTo(to);
  }

  // MEDITATION TIMER
  void _startMeditationTimer(int seconds) {
    _meditationSecondsRemaining = seconds;
    _meditationRunning = true;

    _meditationTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _meditationSecondsRemaining--);

      if (_meditationSecondsRemaining <= 0) {
        timer.cancel();
        _meditationRunning = false;

        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Meditation complete")));
      }
    });

    setState(() {});
  }

  void _stopMeditationTimer() {
    _meditationTimer?.cancel();
    setState(() => _meditationRunning = false);
  }

  void _resetMeditationTimer() {
    _meditationTimer?.cancel();
    setState(() {
      _meditationRunning = false;
      _meditationSecondsRemaining = 0;
    });
  }

  // -------------------------------------------------
  // UI BUILD
  // -------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        title: const Text("Spiritual Wellness"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 700;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  _header(),
                  const SizedBox(height: 16),

                  _affirmationCard(),
                  const SizedBox(height: 16),

                  if (isWide)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              _gratitudeCard(),
                              const SizedBox(height: 16),
                              _journalCard(),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              _breathworkCard(),
                              const SizedBox(height: 16),
                              _meditationCard(),
                              const SizedBox(height: 16),
                              _historyCard(),
                            ],
                          ),
                        ),
                      ],
                    )
                  else ...[
                    _gratitudeCard(),
                    const SizedBox(height: 16),
                    _journalCard(),
                    const SizedBox(height: 16),
                    _breathworkCard(),
                    const SizedBox(height: 16),
                    _meditationCard(),
                    const SizedBox(height: 16),
                    _historyCard(),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // -------------------------------------------------
  // INDIVIDUAL UI SECTIONS
  // -------------------------------------------------

  Widget _header() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF7B1FA2), Color(0xFF9C27B0)],
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.self_improvement,
              size: 56, color: Colors.white),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Find Inner Peace ✨",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(
                  "Daily practices, breathwork and journaling to support your spiritual wellbeing.",
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _affirmationCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.pink),
                const SizedBox(width: 8),
                const Text(
                  "Daily Affirmation",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _nextAffirmation,
                ),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: _saveAffirmation,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentAffirmation,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _gratitudeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.emoji_emotions, color: Colors.orange),
                SizedBox(width: 8),
                Text("Gratitude",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _gratitudeCtl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: "Write something you are grateful for...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                    onPressed: _saveGratitude,
                    icon: const Icon(Icons.save),
                    label: const Text("Save")),
                const SizedBox(width: 10),
                TextButton(
                    onPressed: () => _gratitudeCtl.clear(),
                    child: const Text("Clear")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _journalCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.edit_note, color: Colors.teal),
                SizedBox(width: 8),
                Text("Journal",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _journalCtl,
              maxLines: 6,
              decoration: const InputDecoration(
                hintText: "Write your thoughts...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _saveJournal,
                  icon: const Icon(Icons.save),
                  label: const Text("Save"),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => _journalCtl.clear(),
                  child: const Text("Clear"),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _breathworkCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.air, color: Colors.purple),
                SizedBox(width: 8),
                Text("Breathwork — 4 • 7 • 8",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 12),

            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Transform.scale(
                    scale: _breathScale,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.purple.shade200,
                            Colors.purple.shade50
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                              color: Colors.purple.withOpacity(0.2),
                              blurRadius: 10)
                        ],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Text(_breathPhase,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        _breathCountdown > 0
                            ? _breathCountdown.toString()
                            : "-",
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            ),

            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                    onPressed:
                        _breathActive ? null : _startBreathwork,
                    icon: const Icon(Icons.play_arrow),
                    label: const Text("Start")),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                    onPressed:
                        _breathActive ? _stopBreathwork : null,
                    icon: const Icon(Icons.stop),
                    label: const Text("Stop")),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _meditationCard() {
    String timer() {
      final m = _meditationSecondsRemaining ~/ 60;
      final s = _meditationSecondsRemaining % 60;
      return "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.self_improvement, color: Colors.blue),
                SizedBox(width: 8),
                Text("Meditation",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 10),
            Center(
                child: Text(
              timer(),
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold),
            )),

            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: _meditationRunning
                        ? null
                        : () => _startMeditationTimer(180),
                    child: const Text("3 min")),
                ElevatedButton(
                    onPressed: _meditationRunning
                        ? null
                        : () => _startMeditationTimer(300),
                    child: const Text("5 min")),
                ElevatedButton(
                    onPressed: _meditationRunning
                        ? null
                        : () => _startMeditationTimer(600),
                    child: const Text("10 min")),
                ElevatedButton.icon(
                  icon: Icon(_meditationRunning
                      ? Icons.stop
                      : Icons.refresh),
                  label: Text(
                      _meditationRunning ? "Stop" : "Reset"),
                  onPressed: _meditationRunning
                      ? _stopMeditationTimer
                      : _resetMeditationTimer,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _historyCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: const [
                Icon(Icons.history, color: Colors.deepPurple),
                SizedBox(width: 8),
                Text("History",
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),

            const SizedBox(height: 12),

            if (_affirmationHistory.isEmpty &&
                _gratitudeHistory.isEmpty &&
                _journalHistory.isEmpty)
              const Padding(
                padding: EdgeInsets.all(14),
                child: Center(
                    child: Text("No history yet.",
                        style: TextStyle(fontSize: 14))),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_affirmationHistory.isNotEmpty) ...[
                    const Text("Affirmations",
                        style: TextStyle(
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ..._affirmationHistory
                        .take(3)
                        .map((e) => _historyTile(e)),
                    const SizedBox(height: 10),
                  ],
                  if (_gratitudeHistory.isNotEmpty) ...[
                    const Text("Gratitude",
                        style: TextStyle(
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ..._gratitudeHistory
                        .take(3)
                        .map((e) => _historyTile(e)),
                    const SizedBox(height: 10),
                  ],
                  if (_journalHistory.isNotEmpty) ...[
                    const Text("Journal",
                        style: TextStyle(
                            fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    ..._journalHistory
                        .take(3)
                        .map((e) => _historyTile(e)),
                  ],
                ],
              ),

            const SizedBox(height: 10),
            TextButton(
                onPressed: _openFullHistoryPage,
                child: const Text("View all →"))
          ],
        ),
      ),
    );
  }

  Widget _historyTile(Map<String, dynamic> entry) {
    final time = DateTime.tryParse(entry["time"]) ?? DateTime.now();
    final formatted =
        "${time.year}-${time.month}-${time.day}  ${time.hour}:${time.minute.toString().padLeft(2, '0')}";

    return ListTile(
      dense: true,
      title: Text(entry["text"] ?? ""),
      subtitle: Text(
        formatted,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  void _openFullHistoryPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Full History"),
          backgroundColor: Colors.deepPurple,
        ),
        body: ListView(
          children: [
            if (_affirmationHistory.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child:
                    Text("Affirmations", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ..._affirmationHistory.map(_historyTile),

            if (_gratitudeHistory.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child:
                    Text("Gratitude", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ..._gratitudeHistory.map(_historyTile),

            if (_journalHistory.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(8),
                child:
                    Text("Journal", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ..._journalHistory.map(_historyTile),
          ],
        ),
      );
    }));
  }
}
