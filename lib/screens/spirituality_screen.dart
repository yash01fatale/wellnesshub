// lib/screens/spirituality_screen.dart
// Upgraded, responsive & interactive Spirituality Screen for startup-level app.
// Features:
// - Affirmation carousel with save/share
// - Gratitude quick-add (persistent)
// - Journal with AI-style summary mock (local heuristic)
// - Breathwork (4-7-8) with animation and countdown
// - Meditation timer with selectable durations and optional calming sounds
// - Daily spiritual challenge (rotating)
// - Compact responsive layout for mobile/tablet/desktop
// - All history persisted via SharedPreferences
//
// Packages required in pubspec.yaml:
//   shared_preferences: ^2.0.15
//   audioplayers: ^2.0.0
//
// Add optional sound files under assets/sounds/ and register them.
// Example assets:
//  - assets/sounds/om_chant.mp3
//  - assets/sounds/tibetan_bowl.mp3

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audioplayers/audioplayers.dart';

class SpiritualityScreen extends StatefulWidget {
  const SpiritualityScreen({super.key});

  @override
  State<SpiritualityScreen> createState() => _SpiritualityScreenState();
}

class _SpiritualityScreenState extends State<SpiritualityScreen>
    with TickerProviderStateMixin {
  // ------------------------------
  // Data / persistence keys
  // ------------------------------
  static const String _kAffKey = 'sp_affirmations_v2';
  static const String _kGratKey = 'sp_gratitude_v2';
  static const String _kJournKey = 'sp_journal_v2';
  static const String _kChallengeKey = 'sp_challenge_v2';
  static const String _kThemeKey = 'sp_theme_v2';

  // ------------------------------
  // Affirmations
  // ------------------------------
  final List<String> _defaultAffirmations = [
    "I am calm, centered, and grounded.",
    "I attract peace and clarity into my life.",
    "My heart is open to love and compassion.",
    "I release what no longer serves me.",
    "I trust the process of life.",
    "I breathe in strength and breathe out tension.",
    "I am guided and supported.",
  ];
  late List<String> _affirmations;
  int _affIndex = 0;

  // ------------------------------
  // Gratitude & Journal history
  // ------------------------------
  List<Map<String, dynamic>> _gratitude = [];
  List<Map<String, dynamic>> _journal = [];

  // Editor controllers
  final TextEditingController _gratCtrl = TextEditingController();
  final TextEditingController _journCtrl = TextEditingController();

  // ------------------------------
  // Breathwork 4-7-8 animation
  // ------------------------------
  late AnimationController _breathController;
  double _breathScale = 1.0;
  String _breathPhase = "Idle";
  Timer? _breathTimer;
  int _breathCountdown = 0;
  bool _breathActive = false;

  // ------------------------------
  // Meditation Timer + Audio
  // ------------------------------
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlayingSound = false;
  String? _currentSoundAsset; // e.g. 'om_chant.mp3'

  Timer? _meditationTimer;
  int _meditationRemaining = 0;
  bool _meditationRunning = false;

  // ------------------------------
  // Daily challenge
  // ------------------------------
  final List<String> _challenges = [
    "5-min morning gratitude",
    "10-min silent walk",
    "Read a short spiritual poem",
    "Do 3 deep-breathing cycles",
    "Sit quietly for 5 minutes",
    "Write a letter of forgiveness",
    "Light a candle and reflect",
  ];
  String? _todayChallenge;
  DateTime? _challengeDate;

  // ------------------------------
  // Theme toggle (light/dark card accent)
  // ------------------------------
  bool _softDark = false;

  // ------------------------------
  // Loading flag
  // ------------------------------
  bool _loading = true;

  // small in-memory history for affirmations
  final List<Map<String, dynamic>> _affHistory = [];

  @override
  void initState() {
    super.initState();
    _affirmations = List.from(_defaultAffirmations);
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
      lowerBound: 0.85,
      upperBound: 1.25,
    )..addListener(() {
        setState(() => _breathScale = _breathController.value);
      });

    // load stored data
    _loadAll();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _breathTimer?.cancel();
    _meditationTimer?.cancel();
    _audioPlayer.dispose();
    _gratCtrl.dispose();
    _journCtrl.dispose();
    super.dispose();
  }

  // ------------------------------
  // Persistence helpers
  // ------------------------------
  Future<void> _loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    // Affirmations (optional custom)
    final rawAff = prefs.getString(_kAffKey);
    if (rawAff != null) {
      try {
        final List decoded = jsonDecode(rawAff);
        _affirmations = List<String>.from(decoded);
      } catch (_) {}
    }

    // gratitude
    final rawG = prefs.getString(_kGratKey);
    if (rawG != null) {
      try {
        _gratitude = List<Map<String, dynamic>>.from(jsonDecode(rawG));
      } catch (_) {}
    }

    // journal
    final rawJ = prefs.getString(_kJournKey);
    if (rawJ != null) {
      try {
        _journal = List<Map<String, dynamic>>.from(jsonDecode(rawJ));
      } catch (_) {}
    }

    // challenge
    final chRaw = prefs.getString(_kChallengeKey);
    if (chRaw != null) {
      try {
        final m = jsonDecode(chRaw) as Map<String, dynamic>;
        _todayChallenge = m['challenge'] as String?;
        _challengeDate = DateTime.tryParse(m['date'] as String? ?? '');
      } catch (_) {}
    }

    // theme
    _softDark = prefs.getBool(_kThemeKey) ?? false;

    // assign today's challenge if needed
    _ensureTodayChallenge();

    setState(() => _loading = false);
  }

  Future<void> _saveLocal(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) await prefs.setString(key, value);
    if (value is bool) await prefs.setBool(key, value);
  }

  Future<void> _persistJson(String key, Object value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonEncode(value));
  }

  // ------------------------------
  // Affirmation interactions
  // ------------------------------
  void _nextAffirmation() {
    setState(() {
      _affIndex = (_affIndex + 1) % _affirmations.length;
    });
  }

  void _prevAffirmation() {
    setState(() {
      _affIndex = (_affIndex - 1) < 0 ? _affirmations.length - 1 : _affIndex - 1;
    });
  }

  Future<void> _saveAffirmationToHistory() async {
    final entry = {"text": _affirmations[_affIndex], "time": DateTime.now().toIso8601String()};
    _affHistory.insert(0, entry);
    // persist a compact history under a dedicated key
    await _persistJson(_kAffKey + '_history', _affHistory);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Affirmation saved to history")));
    setState(() {});
  }

  // ------------------------------
  // Gratitude / Journal operations
  // ------------------------------
  Future<void> _addGratitude() async {
    final text = _gratCtrl.text.trim();
    if (text.isEmpty) return;
    final entry = {"text": text, "time": DateTime.now().toIso8601String()};
    _gratitude.insert(0, entry);
    await _persistJson(_kGratKey, _gratitude);
    _gratCtrl.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Saved gratitude")));
  }

  Future<void> _addJournal() async {
    final text = _journCtrl.text.trim();
    if (text.isEmpty) return;
    final summary = _mockSummarize(text);
    final entry = {"text": text, "summary": summary, "time": DateTime.now().toIso8601String()};
    _journal.insert(0, entry);
    await _persistJson(_kJournKey, _journal);
    _journCtrl.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Journal saved")));
  }

  String _mockSummarize(String text) {
    // Very small heuristic summary — first sentence trimmed
    final first = text.split(RegExp(r'[.!?\n]')).first;
    if (first.length <= 120) return first;
    return "${first.substring(0, 117)}...";
  }

  // ------------------------------
  // Breathwork 4-7-8 control
  // ------------------------------
  void _startBreathwork() {
    if (_breathActive) return;
    _breathActive = true;
    _runBreathCycle();
  }

  void _stopBreathwork() {
    _breathActive = false;
    _breathTimer?.cancel();
    try {
      _breathController.stop();
    } catch (_) {}
    setState(() {
      _breathCountdown = 0;
      _breathPhase = "Idle";
      _breathScale = 1.0;
    });
  }

  void _runBreathCycle() {
    if (!_breathActive) return;
    // inhale 4s
    _breathPhase = "Inhale";
    _animateBreath(to: _breathController.upperBound, sec: 4);
    _countdown(4, () {
      if (!_breathActive) return;
      // hold 7s
      _breathPhase = "Hold";
      _countdown(7, () {
        if (!_breathActive) return;
        // exhale 8s
        _breathPhase = "Exhale";
        _animateBreath(to: _breathController.lowerBound, sec: 8);
        _countdown(8, () {
          if (_breathActive) _runBreathCycle();
        });
      });
    });
  }

  void _animateBreath({required double to, required int sec}) {
    _breathController.duration = Duration(seconds: sec);
    _breathController.animateTo(to);
  }

  void _countdown(int seconds, VoidCallback onComplete) {
    _breathCountdown = seconds;
    _breathTimer?.cancel();
    _breathTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _breathCountdown--);
      if (_breathCountdown <= 0) {
        t.cancel();
        onComplete();
      }
    });
  }

  // ------------------------------
  // Meditation timer and sound
  // ------------------------------
  Future<void> _toggleSound(String asset) async {
    if (_isPlayingSound && _currentSoundAsset == asset) {
      await _audioPlayer.stop();
      _isPlayingSound = false;
      _currentSoundAsset = null;
      setState(() {});
      return;
    }
    try {
      // attempt to play from assets - Add assets to pubspec and path "assets/sounds/<asset>"
      await _audioPlayer.play(AssetSource('sounds/$asset'), volume: 0.8);
      _isPlayingSound = true;
      _currentSoundAsset = asset;
      setState(() {});
    } catch (e) {
      // ignore play errors but show user
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Sound error: $e')));
    }
  }

  void _startMeditation(int seconds) {
    _meditationTimer?.cancel();
    _meditationRemaining = seconds;
    _meditationRunning = true;
    _meditationTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_meditationRemaining <= 1) {
        t.cancel();
        _meditationRunning = false;
        _meditationRemaining = 0;
        _audioPlayer.stop();
        _isPlayingSound = false;
        _currentSoundAsset = null;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Meditation complete')));
        setState(() {});
      } else {
        setState(() => _meditationRemaining--);
      }
    });
    setState(() {});
  }

  void _stopMeditation() {
    _meditationTimer?.cancel();
    _audioPlayer.stop();
    _meditationRunning = false;
    _meditationRemaining = 0;
    _isPlayingSound = false;
    _currentSoundAsset = null;
    setState(() {});
  }

  String _formatTimeLeft(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ------------------------------
  // Daily challenge rotation
  // ------------------------------
  void _ensureTodayChallenge() async {
    if (_challengeDate == null || !_isSameDate(_challengeDate!, DateTime.now())) {
      final rnd = Random();
      _todayChallenge = _challenges[rnd.nextInt(_challenges.length)];
      _challengeDate = DateTime.now();
      await _persistJson(_kChallengeKey, {'challenge': _todayChallenge, 'date': _challengeDate!.toIso8601String()});
      setState(() {});
    }
  }

  bool _isSameDate(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;

  // ------------------------------
  // Utility - delete history items
  // ------------------------------
  Future<void> _clearAllHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kGratKey);
    await prefs.remove(_kJournKey);
    _gratitude.clear();
    _journal.clear();
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cleared history")));
  }

  // ------------------------------
  // UX Widgets / builders
  // ------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _softDark ? Colors.deepPurple.shade50 : Colors.purple.shade50,
      appBar: AppBar(
        title: const Text('Spiritual Wellness ✨'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            tooltip: 'Toggle soft theme',
            icon: Icon(_softDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: () async {
              setState(() => _softDark = !_softDark);
              await _saveLocal(_kThemeKey, _softDark);
            },
          ),
          IconButton(
            tooltip: 'Clear all saved history',
            icon: const Icon(Icons.delete_forever),
            onPressed: () {
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Clear history?'),
                  content: const Text('This will remove saved gratitude & journal history.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
                    TextButton(onPressed: () {
                      Navigator.of(ctx).pop();
                      _clearAllHistory();
                    }, child: const Text('Clear', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
            },
          )
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        final isWide = constraints.maxWidth > 800;
        final padding = EdgeInsets.symmetric(horizontal: isWide ? 20 : 12, vertical: 14);

        return SingleChildScrollView(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header / hero
              _buildHeroCard(context, isWide),
              const SizedBox(height: 14),

              // Responsive two-column layout on wide screens
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 6, child: Column(children: [_buildAffirmationCard(), const SizedBox(height: 12), _buildGratitudeCard(), const SizedBox(height: 12), _buildJournalCard()])),
                    const SizedBox(width: 12),
                    Expanded(flex: 4, child: Column(children: [_buildBreathworkCard(), const SizedBox(height: 12), _buildMeditationCard(), const SizedBox(height: 12), _buildDailyChallengeCard(), const SizedBox(height: 12), _buildCompactHistoryCard()])),
                  ],
                )
              else
                Column(children: [
                  _buildAffirmationCard(),
                  const SizedBox(height: 12),
                  _buildGratitudeCard(),
                  const SizedBox(height: 12),
                  _buildJournalCard(),
                  const SizedBox(height: 12),
                  _buildBreathworkCard(),
                  const SizedBox(height: 12),
                  _buildMeditationCard(),
                  const SizedBox(height: 12),
                  _buildDailyChallengeCard(),
                  const SizedBox(height: 12),
                  _buildCompactHistoryCard(),
                ]),

              const SizedBox(height: 24),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isWide) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.deepPurple.shade400, Colors.purple.shade600]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 6))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              'Find Inner Calm',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
            ),
              const SizedBox(height: 6),
              Text('Daily practices, breathwork & short meditations to center your day.', style: TextStyle(color: Colors.white.withOpacity(0.9))),
            ]),
          ),
          if (isWide)
            const SizedBox(width: 12),
          if (isWide)
            ElevatedButton.icon(
              onPressed: () {
                // Quick start: start 3-min meditation + soft sound if available
                _startMeditation(180);
              },
              icon: const Icon(Icons.self_improvement),
              label: const Text('Quick Meditate'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white24, foregroundColor: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget _buildAffirmationCard() {
    final text = _affirmations.isNotEmpty ? _affirmations[_affIndex] : 'No affirmations';
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: [
            const Icon(Icons.favorite, color: Colors.pink),
            const SizedBox(width: 8),
            const Expanded(child: Text('Daily Affirmation', style: TextStyle(fontWeight: FontWeight.bold))),
            IconButton(onPressed: _prevAffirmation, icon: const Icon(Icons.chevron_left)),
            IconButton(onPressed: _nextAffirmation, icon: const Icon(Icons.chevron_right)),
            IconButton(onPressed: _saveAffirmationToHistory, icon: const Icon(Icons.save)),
          ]),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _nextAffirmation,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.pink.shade50, borderRadius: BorderRadius.circular(10)),
              child: Row(children: [
                Expanded(child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                IconButton(
                  icon: const Icon(Icons.share),
                  onPressed: () {
                    // simple visual feedback — real share integration can be added later
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share not implemented in this demo')));
                  },
                )
              ]),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildGratitudeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: const [Icon(Icons.emoji_events, color: Colors.orange), SizedBox(width: 8), Expanded(child: Text('Gratitude', style: TextStyle(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          TextField(
            controller: _gratCtrl,
            maxLines: 3,
            decoration: const InputDecoration(hintText: 'Write something you are grateful for...', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton.icon(onPressed: _addGratitude, icon: const Icon(Icons.save), label: const Text('Save'), style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple)),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => _gratCtrl.clear(), child: const Text('Clear')),
            const Spacer(),
            PopupMenuButton<int>(
              tooltip: 'Quick add',
              itemBuilder: (ctx) => [
                const PopupMenuItem(value: 1, child: Text('I am grateful for health')),
                const PopupMenuItem(value: 2, child: Text('I am grateful for family')),
                const PopupMenuItem(value: 3, child: Text('I am grateful for today')),
              ],
              onSelected: (v) {
                final map = {1: 'I am grateful for my health', 2: 'I am grateful for my family', 3: 'I am grateful for today'};
                _gratCtrl.text = map[v] ?? '';
              },
              child: const Icon(Icons.more_vert),
            )
          ]),
          const SizedBox(height: 10),
          if (_gratitude.isNotEmpty)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Recent', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ..._gratitude.take(3).map((e) => ListTile(dense: true, title: Text(e['text'] ?? ''), subtitle: Text(_formatTime(e['time'])))).toList(),
              TextButton(onPressed: _openGratitudeFull, child: const Text('View all →'))
            ])
        ]),
      ),
    );
  }

  void _openGratitudeFull() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Gratitude History'), backgroundColor: Colors.deepPurple),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _gratitude.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (ctx, i) {
            final e = _gratitude[i];
            return ListTile(title: Text(e['text'] ?? ''), subtitle: Text(_formatTime(e['time'])));
          },
        ),
      );
    }));
  }

  Widget _buildJournalCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: const [Icon(Icons.edit_note, color: Colors.teal), SizedBox(width: 8), Expanded(child: Text('Journal', style: TextStyle(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          TextField(
            controller: _journCtrl,
            maxLines: 6,
            decoration: const InputDecoration(hintText: 'Write your thoughts...', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton.icon(onPressed: _addJournal, icon: const Icon(Icons.save), label: const Text('Save')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () => _journCtrl.clear(), child: const Text('Clear')),
            const Spacer(),
            IconButton(onPressed: _openJournalFull, icon: const Icon(Icons.history)),
          ]),
          if (_journal.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Divider(),
            ListTile(dense: true, title: Text(_journal.first['summary'] ?? ''), subtitle: Text(_formatTime(_journal.first['time'])))
          ]
        ]),
      ),
    );
  }

  void _openJournalFull() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Journal History'), backgroundColor: Colors.deepPurple),
        body: ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: _journal.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (ctx, i) {
            final e = _journal[i];
            return ListTile(
              title: Text(e['summary'] ?? ''),
              subtitle: Text(_formatTime(e['time'])),
              onTap: () {
                showDialog(context: context, builder: (ctx2) {
                  return AlertDialog(
                    title: const Text('Journal Entry'),
                    content: SingleChildScrollView(child: Text(e['text'] ?? '')),
                    actions: [TextButton(onPressed: () => Navigator.of(ctx2).pop(), child: const Text('Close'))],
                  );
                });
              },
            );
          },
        ),
      );
    }));
  }

  Widget _buildBreathworkCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: const [Icon(Icons.air, color: Colors.purple), SizedBox(width: 8), Expanded(child: Text('Breathwork — 4 • 7 • 8', style: TextStyle(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 12),
          Center(
            child: Stack(alignment: Alignment.center, children: [
              Transform.scale(
                scale: _breathScale,
                child: Container(width: 120, height: 120, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [Colors.purple.shade200, Colors.purple.shade50]), boxShadow: [BoxShadow(color: Colors.purple.withOpacity(0.12), blurRadius: 8)])),
              ),
              Column(mainAxisSize: MainAxisSize.min, children: [
                Text(_breathPhase, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(_breathCountdown > 0 ? _breathCountdown.toString() : '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ]),
            ]),
          ),
          const SizedBox(height: 12),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton.icon(onPressed: _breathActive ? null : _startBreathwork, icon: const Icon(Icons.play_arrow), label: const Text('Start')),
            const SizedBox(width: 12),
            OutlinedButton.icon(onPressed: _breathActive ? _stopBreathwork : null, icon: const Icon(Icons.stop), label: const Text('Stop')),
          ]),
        ]),
      ),
    );
  }

  Widget _buildMeditationCard() {
    final soundOptions = [
      {'label': 'None', 'asset': null},
      {'label': 'Om Chant', 'asset': 'om_chant.mp3'},
      {'label': 'Tibetan Bowl', 'asset': 'tibetan_bowl.mp3'},
    ];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: const [Icon(Icons.self_improvement, color: Colors.blue), SizedBox(width: 8), Expanded(child: Text('Meditation', style: TextStyle(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          if (_meditationRunning)
            Center(child: Text('Time left: ${_formatTimeLeft(_meditationRemaining)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)))
          else
            const Text('Choose a duration and optional sound'),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            ElevatedButton(onPressed: _meditationRunning ? null : () => _startMeditation(180), child: const Text('3 min')),
            ElevatedButton(onPressed: _meditationRunning ? null : () => _startMeditation(300), child: const Text('5 min')),
            ElevatedButton(onPressed: _meditationRunning ? null : () => _startMeditation(600), child: const Text('10 min')),
            OutlinedButton(onPressed: _meditationRunning ? _stopMeditation : null, child: const Text('Stop')),
          ]),
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            value: _currentSoundAsset,
            items: soundOptions.map((s) => DropdownMenuItem(value: s['asset'] as String?, child: Text(s['label'] as String))).toList(),
            onChanged: (v) {
              if (v == null) {
                _audioPlayer.stop();
                setState(() {
                  _isPlayingSound = false;
                  _currentSoundAsset = null;
                });
              } else {
                _toggleSound(v);
              }
            },
            decoration: const InputDecoration(labelText: 'Ambient sound (optional)'),
          ),
        ]),
      ),
    );
  }

  Widget _buildDailyChallengeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: const [Icon(Icons.star, color: Colors.amber), SizedBox(width: 8), Expanded(child: Text('Daily Spiritual Challenge', style: TextStyle(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          Text(_todayChallenge ?? '—', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(children: [
            ElevatedButton(onPressed: () { _ensureTodayChallenge(); }, child: const Text('Refresh')),
            const SizedBox(width: 8),
            OutlinedButton(onPressed: () {
              // mark complete — save to journal as short note
              final note = 'Completed: ${_todayChallenge ?? ''}';
              _journal.insert(0, {'text': note, 'summary': note, 'time': DateTime.now().toIso8601String()});
              _persistJson(_kJournKey, _journal);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked complete and saved to journal')));
              setState(() {});
            }, child: const Text('Mark complete')),
          ])
        ]),
      ),
    );
  }

  Widget _buildCompactHistoryCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Row(children: const [Icon(Icons.history, color: Colors.deepPurple), SizedBox(width: 8), Expanded(child: Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold)))]),
          const SizedBox(height: 8),
          if (_affHistory.isEmpty && _gratitude.isEmpty && _journal.isEmpty)
            const Text('No recent activity. Start a practice to build history.')
          else
            Column(children: [
              if (_affHistory.isNotEmpty) ListTile(leading: const Icon(Icons.favorite, size: 20), title: Text(_affHistory.first['text'] ?? ''), subtitle: Text(_formatTime(_affHistory.first['time']))),
              if (_gratitude.isNotEmpty) ListTile(leading: const Icon(Icons.emoji_emotions, size: 20), title: Text(_gratitude.first['text'] ?? ''), subtitle: Text(_formatTime(_gratitude.first['time']))),
              if (_journal.isNotEmpty) ListTile(leading: const Icon(Icons.edit, size: 20), title: Text(_journal.first['summary'] ?? ''), subtitle: Text(_formatTime(_journal.first['time']))),
              TextButton(onPressed: _openFullHistoryPage, child: const Text('View all →')),
            ])
        ]),
      ),
    );
  }

  void _openFullHistoryPage() {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) {
      return Scaffold(
        appBar: AppBar(title: const Text('Full History'), backgroundColor: Colors.deepPurple),
        body: ListView(padding: const EdgeInsets.all(12), children: [
          const Text('Affirmations', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_affHistory.isEmpty) const Text('No affirmations saved') else ..._affHistory.map((e) => ListTile(title: Text(e['text'] ?? ''), subtitle: Text(_formatTime(e['time'])))).toList(),
          const Divider(),
          const Text('Gratitude', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_gratitude.isEmpty) const Text('No gratitude saved') else ..._gratitude.map((e) => ListTile(title: Text(e['text'] ?? ''), subtitle: Text(_formatTime(e['time'])))).toList(),
          const Divider(),
          const Text('Journal', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_journal.isEmpty) const Text('No journal entries') else ..._journal.map((e) => ListTile(title: Text(e['summary'] ?? ''), subtitle: Text(_formatTime(e['time'])), onTap: () {
            showDialog(context: context, builder: (ctx) => AlertDialog(title: const Text('Journal'), content: SingleChildScrollView(child: Text(e['text'] ?? '')), actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))]));
          })).toList()
        ]),
      );
    }));
  }

  // ------------------------------
  // Utilities
  // ------------------------------
  String _formatTime(String? iso) {
    try {
      if (iso == null) return '';
      final dt = DateTime.parse(iso).toLocal();
      return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
