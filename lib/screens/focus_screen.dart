// lib/screens/focus_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class FocusScreen extends StatefulWidget {
  const FocusScreen({super.key});
  @override
  State<FocusScreen> createState() => _FocusScreenState();
}

class _FocusScreenState extends State<FocusScreen> {
  // Pomodoro timings
  int workSeconds = 25 * 60;
  int shortBreakSeconds = 5 * 60;
  int longBreakSeconds = 15 * 60;
  int sessionsBeforeLongBreak = 4;

  Timer? _timer;
  int _secondsRemaining = 0;
  bool _isRunning = false;
  bool _isWorkPhase = true;
  int _completedSessions = 0;
  final bool _autoStartNext = true;

  // Tracking data
  Map<String, int> _dailyFocusSeconds = {};
  List<Map<String, dynamic>> _tasks = [];
  List<String> _distractions = [];

  bool _ambientOn = false;
  String _ambientTrack = 'Rain';
  double _ambientVolume = 0.5;

  bool _deepFocus = false;

  @override
  void initState() {
    super.initState();
    _loadData();
    _resetTimer();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();

    // Load history
    final hist = prefs.getString("focus_hist");
    if (hist != null) {
      _dailyFocusSeconds = Map<String, int>.from(jsonDecode(hist));
    }

    // Load tasks
    final tasks = prefs.getString("focus_tasks");
    if (tasks != null) {
      _tasks = List<Map<String, dynamic>>.from(jsonDecode(tasks));
    }

    // Load distractions
    final ds = prefs.getString("focus_dist");
    if (ds != null) {
      _distractions = List<String>.from(jsonDecode(ds));
    }

    setState(() {});
  }

  Future<void> _saveHistory() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("focus_hist", jsonEncode(_dailyFocusSeconds));
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("focus_tasks", jsonEncode(_tasks));
  }

  Future<void> _saveDistract() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("focus_dist", jsonEncode(_distractions));
  }

  void _resetTimer() {
    setState(() {
      _isWorkPhase = true;
      _secondsRemaining = workSeconds;
      _isRunning = false;
    });
  }

  void _startTimer() {
    if (_isRunning) return;
    setState(() => _isRunning = true);

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        _secondsRemaining--;
        if (_isWorkPhase) _addSecond();

        if (_secondsRemaining <= 0) {
          t.cancel();
          _onPhaseEnd();
        }
      });
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _onPhaseEnd() {
    if (_isWorkPhase) {
      _completedSessions++;
      bool longBreak = _completedSessions % sessionsBeforeLongBreak == 0;

      _isWorkPhase = false;
      _secondsRemaining = longBreak ? longBreakSeconds : shortBreakSeconds;
    } else {
      _isWorkPhase = true;
      _secondsRemaining = workSeconds;
    }

    if (_autoStartNext) {
      _startTimer();
    } else {
      setState(() {});
    }
  }

  void _addSecond() {
    final key = DateTime.now().toIso8601String().split('T').first;
    _dailyFocusSeconds[key] = (_dailyFocusSeconds[key] ?? 0) + 1;

    if (_dailyFocusSeconds[key]! % 60 == 0) {
      _saveHistory();
    }
  }

  // Tasks
  void _addTask(String text) {
    _tasks.add({"id": DateTime.now().millisecondsSinceEpoch, "text": text, "done": false});
    _saveTasks();
    setState(() {});
  }

  void _toggleTask(int id) {
    final t = _tasks.firstWhere((e) => e["id"] == id);
    t["done"] = !t["done"];
    _saveTasks();
    setState(() {});
  }

  void _removeTask(int id) {
    _tasks.removeWhere((e) => e["id"] == id);
    _saveTasks();
    setState(() {});
  }

  // Distraction log
  void _logDistract() {
    _distractions.add(DateTime.now().toIso8601String());
    _saveDistract();
    setState(() {});
  }

  List<BarChartGroupData> _buildWeeklyBars() {
    final now = DateTime.now();
    List<BarChartGroupData> list = [];

    for (int i = 6; i >= 0; i--) {
      final d = now.subtract(Duration(days: i));
      final key = d.toIso8601String().split('T').first;
      final mins = ((_dailyFocusSeconds[key] ?? 0) ~/ 60).toDouble();

      list.add(
        BarChartGroupData(
          x: 6 - i,
          barRods: [
            BarChartRodData(toY: mins, color: Colors.deepPurple, width: 14, borderRadius: BorderRadius.circular(6)),
          ],
        ),
      );
    }
    return list;
  }

  String _format(int s) {
    int m = s ~/ 60;
    int sec = s % 60;
    return "${m.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !_deepFocus,
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text("Focus Mode"),
          actions: [
            if (_deepFocus)
              GestureDetector(
                onLongPress: () => setState(() => _deepFocus = false),
                child: const Icon(Icons.lock_open),
              ),
            if (!_deepFocus)
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showHelp(),
              )
          ],
        ),

        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            _buildTimerCard(),
            const SizedBox(height: 18),
            _buildQuickStats(),
            const SizedBox(height: 16),
            _buildTasksCard(),
            const SizedBox(height: 16),
            _buildAmbientCard(),
            const SizedBox(height: 16),
            _buildChartCard(),
            const SizedBox(height: 16),
            _buildDistractionCard(),
            const SizedBox(height: 32),
          ]),
        ),
      ),
    );
  }

  Widget _buildTimerCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(
            _isWorkPhase ? "Focus Time" : "Break Time",
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(_format(_secondsRemaining), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),

          // Buttons
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            ElevatedButton(
              onPressed: _isRunning ? _pauseTimer : _startTimer,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: Icon(_isRunning ? Icons.pause : Icons.play_arrow, size: 30),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                _resetTimer();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Icon(Icons.stop),
            ),
            const SizedBox(width: 16),
            ElevatedButton(
              onPressed: () {
                _timer?.cancel();
                _onPhaseEnd();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Icon(Icons.skip_next),
            ),
          ]),
        ]),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Row(children: [
      Expanded(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(children: [
              const Text("Sessions", style: TextStyle(color: Colors.black54)),
              const SizedBox(height: 4),
              Text("$_completedSessions", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: InkWell(
          onTap: () => setState(() => _deepFocus = !_deepFocus),
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                const Text("Deep Focus", style: TextStyle(color: Colors.black54)),
                const SizedBox(height: 4),
                Icon(_deepFocus ? Icons.lock : Icons.lock_open, size: 26, color: Colors.deepPurple),
              ]),
            ),
          ),
        ),
      )
    ]);
  }

  Widget _buildTasksCard() {
    final controller = TextEditingController();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Tasks", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          // Tasks list
          ..._tasks.map((t) {
            return ListTile(
              title: Text(t["text"], style: TextStyle(decoration: t["done"] ? TextDecoration.lineThrough : null)),
              leading: Checkbox(
                value: t["done"],
                onChanged: (_) => _toggleTask(t["id"]),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _removeTask(t["id"]),
              ),
            );
          }),

          const Divider(),
          Row(children: [
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(hintText: "Add task"),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Colors.deepPurple),
              onPressed: () {
                if (controller.text.trim().isEmpty) return;
                _addTask(controller.text.trim());
                controller.clear();
              },
            )
          ])
        ]),
      ),
    );
  }

  Widget _buildAmbientCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Ambient Sounds", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
              child: DropdownButton<String>(
                value: _ambientTrack,
                items: ["Rain", "Ocean", "Wind", "Chant", "Forest"]
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _ambientTrack = v ?? _ambientTrack),
              ),
            ),
            IconButton(
              icon: Icon(_ambientOn ? Icons.pause_circle : Icons.play_circle, size: 32),
              color: Colors.deepPurple,
              onPressed: () {
                setState(() => _ambientOn = !_ambientOn);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(_ambientOn ? "Ambient (mock) started" : "Ambient stopped")),
                );
              },
            )
          ]),
          Slider(
            value: _ambientVolume,
            min: 0,
            max: 1,
            divisions: 10,
            activeColor: Colors.deepPurple,
            onChanged: (v) => setState(() => _ambientVolume = v),
          ),
        ]),
      ),
    );
  }

  Widget _buildChartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Weekly Focus", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                barGroups: _buildWeeklyBars(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  rightTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                        return Text(days[v.toInt()], style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildDistractionCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Distractions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: _logDistract,
            icon: const Icon(Icons.add_alert),
            label: const Text("Log distraction"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
          ),
          const SizedBox(height: 10),
          ..._distractions.take(5).map((d) {
            final t = DateTime.parse(d).toLocal().toString().split(".").first;
            return Text("• $t", style: const TextStyle(color: Colors.black54));
          })
        ]),
      ),
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Focus Mode Help"),
        content: const Text(
          "- Use start/pause to control the timer\n"
          "- Short breaks and long breaks come automatically\n"
          "- Tasks help you stay structured\n"
          "- Ambient sounds are placeholders\n"
          "- Deep focus blocks back navigation",
        ),
      ),
    );
  }
}
