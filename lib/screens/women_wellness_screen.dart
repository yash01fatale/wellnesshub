// lib/screens/women_wellness_screen.dart
import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart'; // for formatting dates

class WomenWellnessScreen extends StatefulWidget {
  const WomenWellnessScreen({super.key});

  @override
  State<WomenWellnessScreen> createState() => _WomenWellnessScreenState();
}

class _WomenWellnessScreenState extends State<WomenWellnessScreen>
    with TickerProviderStateMixin {
  // --- cycle / profile values (defaults; could be read from Firestore) ---
  int cycleDay = 12;
  int cycleLength = 28;
  String mood = "Calm";
  String phase = "Ovulation"; // Menstrual, Follicular, Ovulation, Luteal
  double symptomLevel = 0.4; // 0..1

  // symptoms / tasks
  final List<String> symptoms = ["Cramps", "Headache", "Fatigue", "Mood Swings"];
  final List<String> dailyTasks = [
    "Drink warm water",
    "Light stretching",
    "Iron + Protein meal",
    "10 min mindfulness"
  ];

  // Persistent logs (date -> {mood, symptoms})
  Map<String, Map<String, dynamic>> _logs = {};

  // Calendar state
  DateTime _visibleMonth = DateTime.now();
  Set<String> _selectedDates = {};

  // Chart / hormonal mock data (weekly)
  List<FlSpot> estrogenSpots = [];
  List<FlSpot> progesteroneSpots = [];
  List<FlSpot> lhSpots = [];

  // Breathing animation
  late AnimationController _breathController;
  String _breathPhase = "Idle";
  int _breathCountdown = 0;
  bool _breathActive = false;
  Timer? _breathTimer;

  // Save/load indicator
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initMockChart();
    _breathController =
        AnimationController(vsync: this, duration: const Duration(seconds: 4));
    _loadLocalData();
    _computePhase();
  }

  @override
  void dispose() {
    _breathController.dispose();
    _breathTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocalData() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final j = prefs.getString('women_logs_v1');
      if (j != null) {
        final m = Map<String, dynamic>.from(jsonDecode(j) as Map);
        _logs = m.map((k, v) => MapEntry(k, Map<String, dynamic>.from(v as Map)));
        _selectedDates = _logs.keys.toSet();
      }
      // optionally load saved cycle values
      cycleDay = prefs.getInt('cycle_day') ?? cycleDay;
      cycleLength = prefs.getInt('cycle_length') ?? cycleLength;
      mood = prefs.getString('women_mood') ?? mood;
      phase = prefs.getString('women_phase') ?? phase;
      symptomLevel = prefs.getDouble('women_symptom') ?? symptomLevel;
    } catch (e) {
      // ignore errors during load
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _saveLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('women_logs_v1', jsonEncode(_logs));
    await prefs.setInt('cycle_day', cycleDay);
    await prefs.setInt('cycle_length', cycleLength);
    await prefs.setString('women_mood', mood);
    await prefs.setString('women_phase', phase);
    await prefs.setDouble('women_symptom', symptomLevel);
  }

  void _initMockChart() {
    // create some mock hormone curves for the month (0..27)
    estrogenSpots = List.generate(28, (i) {
      // estrogen rises toward ovulation (approx day 12-14)
      final val = 0.3 + 0.6 * (1 - ((i - 13) / 10).abs());
      final clamped = (val.clamp(0.0, 1.0) as num).toDouble();
      return FlSpot(i.toDouble(), clamped);
    });
    progesteroneSpots = List.generate(28, (i) {
      // progesterone rises after ovulation (day 14+)
      final val = (i < 14) ? 0.2 : (0.2 + 0.6 * ((i - 14) / 14));
      final clamped = (val.clamp(0.0, 1.0) as num).toDouble();
      return FlSpot(i.toDouble(), clamped);
    });
    lhSpots = List.generate(28, (i) {
      // LH surge near ovulation
      final val = (i == 13 || i == 14) ? 1.0 : 0.1;
      return FlSpot(i.toDouble(), (val as num).toDouble());
    });
  }

  void _computePhase() {
    // simple heuristic: day ranges
    final d = cycleDay;
    if (d <= 5) {
      phase = "Menstrual";
    } else if (d <= 11) {
      phase = "Follicular";
    } else if (d <= 16) {
      phase = "Ovulation";
    } else {
      phase = "Luteal";
    }
    setState(() {});
  }

  // Save log to Firestore if user exists, else local SharedPreferences
  Future<void> _saveLogForDay(DateTime day, Map<String, dynamic> data) async {
    final key = DateFormat('yyyy-MM-dd').format(day);
    _logs[key] = data;
    _selectedDates.add(key);
    await _saveLocalData();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('women_logs')
            .doc(key)
            .set(data, SetOptions(merge: true));
      } catch (e) {
        // ignore firestore write errors here
      }
    }
    if (mounted) setState(() {});
  }

  // --- Breathing logic: 4-7-8 (visual) ---
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
    });
  }

  void _runBreathCycle() {
    if (!_breathActive) return;
    // inhale 4s
    _breathPhase = "Inhale";
    _breathCountdown = 4;
    _breathController.duration = const Duration(seconds: 4);
    _breathController.forward(from: 0.0);
    _breathTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() => _breathCountdown--);
      if (_breathCountdown <= 0) {
        t.cancel();
        if (!_breathActive) return;
        // hold 7s
        _breathPhase = "Hold";
        _breathCountdown = 7;
        _breathTimer = Timer.periodic(const Duration(seconds: 1), (t2) {
          if (!mounted) return;
          setState(() => _breathCountdown--);
          if (_breathCountdown <= 0) {
            t2.cancel();
            if (!_breathActive) return;
            // exhale 8s
            _breathPhase = "Exhale";
            _breathCountdown = 8;
            _breathController.duration = const Duration(seconds: 8);
            _breathController.reverse(from: 1.0);
            _breathTimer = Timer.periodic(const Duration(seconds: 1), (t3) {
              if (!mounted) return;
              setState(() => _breathCountdown--);
              if (_breathCountdown <= 0) {
                t3.cancel();
                if (!_breathActive) return;
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (!_breathActive) return;
                  _runBreathCycle();
                });
              }
            });
          }
        });
      }
    });
  }

  // --- Calendar helpers ---
  // Made nullable-safe: if caller passes null, default to DateTime.now()
  List<DateTime> _daysInMonth(DateTime? month) {
    final m = month ?? DateTime.now();
    final first = DateTime(m.year, m.month, 1);
    final nextMonth = DateTime(m.year, m.month + 1, 1);
    final days = nextMonth.difference(first).inDays;
    return List.generate(days, (i) => DateTime(m.year, m.month, i + 1));
  }

  // OPEN full-screen day editor (replaces bottom sheet)
  Future<void> _openDayEditor(DateTime day) async {
    final key = DateFormat('yyyy-MM-dd').format(day);
    final existing = _logs[key] ?? {};
    // navigate to full screen editor; receive result on pop
    final result = await Navigator.push<Map<String, dynamic>?>(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenDayEditor(
          initialDay: day,
          existingData: Map<String, dynamic>.from(existing),
          symptomsList: symptoms,
        ),
        fullscreenDialog: true,
      ),
    );

    if (result != null) {
      // Save or delete
      if (result['deleted'] == true) {
        _logs.remove(key);
        _selectedDates.remove(key);
        await _saveLocalData();
      } else {
        await _saveLogForDay(day, result);
      }
    }
  }

  // --- Recommendations by phase ---
  List<Widget> _phaseRecommendations(String p) {
    switch (p) {
      case "Menstrual":
        return [
          _recCard("Gentle movement", "Light yoga or walking (10–20 min)"),
          _recCard("Comfort nutrition", "Warm soups, iron-rich foods, hydrate"),
          _recCard("Rest", "Prioritize sleep and small naps"),
        ];
      case "Follicular":
        return [
          _recCard("Strength focus", "Short strength sessions (20–30 min)"),
          _recCard("Protein rich", "Add good protein to support muscle"),
          _recCard("Cognitive boost", "Brain tasks & learning"),
        ];
      case "Ovulation":
        return [
          _recCard("Cardio power", "Short HIIT or sprints (10–15 min)"),
          _recCard("Fertility nutrition", "Zinc, vitamin C, balanced carbs"),
          _recCard("Social energy", "Schedule social activities"),
        ];
      default: // Luteal
        return [
          _recCard("Low impact cardio", "Walking, cycling (20–30 min)"),
          _recCard("Complex carbs", "Stabilize mood with fiber-rich foods"),
          _recCard("Wind-down", "Evening routines & gratitude journaling"),
        ];
    }
  }

  Widget _recCard(String t, String s) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Text(t, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(s),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () {},
      ),
    );
  }

  // --- Dashboard widget to embed ---
  Widget womenWidgetMini() {
    return GestureDetector(
      onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const WomenWellnessScreen())),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: Colors.pink.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          CircleAvatar(
              backgroundColor: Colors.pink.shade100,
              child: const Icon(Icons.female, color: Colors.white)),
          const SizedBox(width: 12),
          Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Cycle Day $cycleDay / $cycleLength",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text("$phase • Mood: $mood",
                style: const TextStyle(color: Colors.black54, fontSize: 12)),
          ])),
          IconButton(onPressed: () => _openDayEditor(DateTime.now()), icon: const Icon(Icons.add_circle)),
        ]),
      ),
    );
  }

  // --- build UI ---
  @override
  Widget build(BuildContext context) {
    final days = _daysInMonth(_visibleMonth);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Women's Wellness"),
        backgroundColor: Colors.pink.shade400,
        actions: [
          IconButton(
              onPressed: () {
                _computePhase();
                setState(() {});
              },
              icon: const Icon(Icons.refresh))
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(builder: (ctx, cons) {
              final isWide = cons.maxWidth > 900;
              final isTablet = cons.maxWidth > 600 && cons.maxWidth <= 900;
              final padding = EdgeInsets.symmetric(horizontal: isWide ? 48 : 16, vertical: 16);
              return SingleChildScrollView(
                padding: padding,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient:
                          const LinearGradient(colors: [Color(0xFFF06292), Color(0xFFE91E63)]),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                            Text("Women’s Wellness",
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Colors.white, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Text("Support for menstrual health, hormones, pregnancy & PCOS.",
                                style: TextStyle(color: Colors.white.withOpacity(0.9))),
                            const SizedBox(height: 8),
                            Row(children: [
                              Chip(label: Text(phase), backgroundColor: Colors.white24),
                              const SizedBox(width: 8),
                              Chip(label: Text("Day $cycleDay"), backgroundColor: Colors.white24),
                            ])
                          ])),
                      // small illustration placeholder
                      CircleAvatar(radius: 36, backgroundColor: Colors.white24, child: const Icon(Icons.favorite, color: Colors.white)),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // calendar + quick stats row
                  isWide
                      ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Expanded(flex: 2, child: _buildCalendarCard(days)),
                          const SizedBox(width: 16),
                          Expanded(
                              flex: 1,
                              child: Column(children: [
                                _buildCycleCard(),
                                const SizedBox(height: 12),
                                _buildBreathCard(),
                                const SizedBox(height: 12),
                                _buildMiniLogsCard(),
                              ])),
                        ])
                      : Column(children: [
                          _buildCalendarCard(days),
                          const SizedBox(height: 12),
                          _buildCycleCard(),
                          const SizedBox(height: 12),
                          _buildBreathCard(),
                          const SizedBox(height: 12),
                          _buildMiniLogsCard(),
                        ]),

                  const SizedBox(height: 16),

                  // hormonal chart
                  _buildHormoneChart(),

                  const SizedBox(height: 16),

                  // PCOS & Pregnancy cards
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text("PCOS & Pregnancy Support",
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        _pcosCard(),
                        const SizedBox(height: 8),
                        _pregnancyCard(),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // recommendations
                  const Text("Phase-based Recommendations",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._phaseRecommendations(phase),

                  const SizedBox(height: 24),

                  // footer
                  womenWidgetMini(),
                  const SizedBox(height: 24),
                ]),
              );
            }),
    );
  }

  Widget _buildCalendarCard(List<DateTime> days) {
    final firstWeekday = DateTime(_visibleMonth.year, _visibleMonth.month, 1).weekday; // 1..7
    final leadingEmpty = firstWeekday - 1;
    final grid = <Widget>[];
    // weekday header
    final wd = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    grid.add(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () => setState(
              () => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1))),
      Text(DateFormat.yMMMM().format(_visibleMonth),
          style: const TextStyle(fontWeight: FontWeight.bold)),
      IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () => setState(
              () => _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1))),
    ]));
    grid.add(const SizedBox(height: 8));
    grid.add(Row(
        children: wd
            .map((d) => Expanded(
                child: Center(
                    child:
                        Text(d, style: const TextStyle(fontSize: 12, color: Colors.black54)))))
            .toList()));

    // calendar grid
    final total = leadingEmpty + days.length;
    final rows = (total / 7).ceil();
    int dayIndex = 0;
    for (var r = 0; r < rows; r++) {
      final rowChildren = <Widget>[];
      for (var c = 0; c < 7; c++) {
        final idx = r * 7 + c;
        if (idx < leadingEmpty || dayIndex >= days.length) {
          rowChildren.add(Expanded(child: Container(height: 48)));
        } else {
          final date = days[dayIndex++];
          final key = DateFormat('yyyy-MM-dd').format(date);
          final selected = _selectedDates.contains(key);
          rowChildren.add(Expanded(
            child: GestureDetector(
              onTap: () => _openDayEditor(date),
              child: Container(
                margin: const EdgeInsets.all(4),
                height: 48,
                decoration: BoxDecoration(
                    color: selected ? Colors.pink.shade100 : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: selected ? Colors.pink : Colors.grey.shade200)),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text("${date.day}", style: const TextStyle(fontWeight: FontWeight.bold)),
                  if (selected)
                    Text((_logs[key]?['mood'] ?? ''),
                        style: const TextStyle(fontSize: 10, color: Colors.black54))
                ]),
              ),
            ),
          ));
        }
      }
      grid.add(Row(children: rowChildren));
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Cycle Calendar", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...grid,
            const SizedBox(height: 8),
            Row(children: [
              ElevatedButton.icon(
                  onPressed: () {
                    // quick log today
                    _openDayEditor(DateTime.now());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Log Today")),
              const SizedBox(width: 8),
              OutlinedButton(
                  onPressed: () {
                    // navigate to previous month
                    setState(() => _visibleMonth =
                        DateTime(_visibleMonth.year, _visibleMonth.month - 1));
                  },
                  child: const Text("Prev month")),
            ])
          ])),
    );
  }

  Widget _buildCycleCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Menstrual Cycle Overview", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(child: _infoBox("Cycle Day", "$cycleDay")),
              const SizedBox(width: 8),
              Expanded(child: _infoBox("Cycle Length", "$cycleLength")),
            ]),
            const SizedBox(height: 12),
            Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.pink.shade50, borderRadius: BorderRadius.circular(10)),
                child: Row(children: [
                  const Icon(Icons.info, color: Colors.pink),
                  const SizedBox(width: 12),
                  Expanded(child: Text("Current Phase: $phase", style: const TextStyle(fontWeight: FontWeight.w600))),
                  const SizedBox(width: 8),
                  IconButton(onPressed: () {
                    // Quick controls to increment day or reset
                    setState(() {
                      cycleDay = (cycleDay % cycleLength) + 1;
                      _computePhase();
                      _saveLocalData();
                    });
                  }, icon: const Icon(Icons.calendar_month)),
                ])),
          ])),
    );
  }

  Widget _infoBox(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration:
          BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ]),
    );
  }

  Widget _buildBreathCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text("Breathing — 4 • 7 • 8", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Center(
              child: AnimatedBuilder(
                animation: _breathController,
                builder: (ctx, child) {
                  final scale = 0.8 + 0.6 * _breathController.value;
                  return Transform.scale(
                      scale: scale,
                      child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(colors: [
                                Colors.pink.shade200.withOpacity(0.6),
                                Colors.pink.shade50
                              ]),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.pink.shade200.withOpacity(0.2),
                                    blurRadius: 8)
                              ]),
                          child: Center(
                              child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(_breathPhase, style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text(_breathCountdown > 0 ? _breathCountdown.toString() : "-",
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                            ],
                          ))));
                },
              ),
            ),
            const SizedBox(height: 12),
            Row(children: [
              ElevatedButton.icon(
                  onPressed: _breathActive ? null : _startBreathwork,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Start')),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                  onPressed: _breathActive ? _stopBreathwork : null,
                  icon: const Icon(Icons.stop),
                  label: const Text('Stop')),
              const SizedBox(width: 12),
              TextButton(
                  onPressed: () {
                    _breathController.stop();
                    _breathActive = false;
                    setState(() {
                      _breathPhase = "Idle";
                      _breathCountdown = 0;
                    });
                  },
                  child: const Text('Reset'))
            ]),
          ])),
    );
  }

  Widget _buildMiniLogsCard() {
    final last3 = _logs.keys.toList()..sort((a, b) => b.compareTo(a));
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Recent Logs", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (last3.isEmpty) const Text("No logs yet — add today's entry."),
            ...last3.take(4).map((k) {
              final v = _logs[k]!;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(k),
                subtitle: Text("${v['mood'] ?? ''} • ${((v['symptoms'] ?? []) as List).join(', ')}"),
                trailing: IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _openDayEditor(DateTime.parse(k));
                    }),
              );
            }).toList(),
          ])),
    );
  }

  Widget _buildHormoneChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Hormonal Chart (mock)",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, meta) {
                          if (v % 7 == 0) return Text("D${v.toInt()}");
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),

                  borderData: FlBorderData(show: false),

                  minY: 0,
                  maxY: 1.1,

                  lineBarsData: [
                    LineChartBarData(
                      spots: estrogenSpots,
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.pink,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: progesteroneSpots,
                      isCurved: true,
                      barWidth: 2,
                      color: Colors.orange,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: lhSpots,
                      isCurved: false,
                      barWidth: 2,
                      color: Colors.deepPurple,
                      dotData: FlDotData(show: false),
                    ),
                  ],

                  betweenBarsData: [
                    BetweenBarsData(
                      fromIndex: 0,
                      toIndex: 1,
                      color: Color.lerp(
                        Colors.pink.withOpacity(0.08),
                        Colors.orange.withOpacity(0.08),
                        0.5,
                      )!,
                    )
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                _legendDot("Estrogen", Colors.pink),
                const SizedBox(width: 10),
                _legendDot("Progesterone", Colors.orange),
                const SizedBox(width: 10),
                _legendDot("LH", Colors.deepPurple),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _legendDot(String label, Color color) {
    return Row(children: [
      Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
      const SizedBox(width: 6),
      Text(label, style: const TextStyle(fontSize: 12)),
    ]);
  }

  Widget _pcosCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.pink.shade50,
      child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("PCOS Support", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text("• Anti-inflammatory foods\n• Regular low impact exercise\n• Low GI diet\n• Track cycles & consult doctor"),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text("Learn more"))),
      ])),
    );
  }

  Widget _pregnancyCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      color: Colors.pink.shade100,
      child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text("Pregnancy Wellness", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text("• Folic acid & prenatal vitamins\n• Gentle exercise & hydration\n• Regular checkups and mental support"),
        Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text("View tips"))),
      ])),
    );
  }
}

/// Full-screen editor (Layout B - Aesthetic Wellness Style)
class FullScreenDayEditor extends StatefulWidget {
  final DateTime initialDay;
  final Map<String, dynamic> existingData;
  final List<String> symptomsList;

  const FullScreenDayEditor({
    super.key,
    required this.initialDay,
    required this.existingData,
    required this.symptomsList,
  });

  @override
  State<FullScreenDayEditor> createState() => _FullScreenDayEditorState();
}

class _FullScreenDayEditorState extends State<FullScreenDayEditor> {
  late TextEditingController _notesCtl;
  late TextEditingController _moodCtl;
  late Set<String> _pickedSymptoms;
  String _selectedMoodEmoji = "🙂"; // default
  bool _saving = false;

  final List<Map<String, String>> moodOptions = [
    {"emoji": "🙂", "label": "Happy"},
    {"emoji": "😐", "label": "Neutral"},
    {"emoji": "😣", "label": "Pain"},
    {"emoji": "😭", "label": "Sad"},
    {"emoji": "😡", "label": "Angry"},
    {"emoji": "😍", "label": "Energetic"},
  ];

  @override
  void initState() {
    super.initState();
    final exists = widget.existingData;
    _notesCtl = TextEditingController(text: exists['notes']?.toString() ?? "");
    _moodCtl = TextEditingController(text: exists['mood']?.toString() ?? "");
    final picked = exists['symptoms'] ?? [];
    _pickedSymptoms = Set<String>.from((picked is List) ? picked.cast<String>() : []);
    // if the existing mood matches a mood emoji label, pick it
    final moodText = (exists['mood'] ?? "").toString();
    final found = moodOptions.firstWhere(
        (m) => m['label']!.toLowerCase() == moodText.toLowerCase(),
        orElse: () => moodOptions.first);
    _selectedMoodEmoji = found['emoji']!;
  }

  @override
  void dispose() {
    _notesCtl.dispose();
    _moodCtl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    setState(() => _saving = true);
    final data = {
      'mood': _moodCtl.text.trim().isNotEmpty ? _moodCtl.text.trim() : _moodLabelFromEmoji(_selectedMoodEmoji),
      'symptoms': _pickedSymptoms.toList(),
      'notes': _notesCtl.text.trim(),
      'ts': DateTime.now().toIso8601String(),
    };
    // return the data to the previous screen (which handles saving)
    Navigator.of(context).pop(data);
  }

  void _onDelete() {
    Navigator.of(context).pop({'deleted': true});
  }

  String _moodLabelFromEmoji(String e) {
    return moodOptions.firstWhere((m) => m['emoji'] == e, orElse: () => moodOptions.first)['label']!;
  }

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat.yMMMMd().format(widget.initialDay);
    return Scaffold(
      backgroundColor: Colors.pink.shade50,
      appBar: AppBar(
        title: Text("Log — $dayLabel"),
        backgroundColor: Colors.pink.shade400,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _onDelete,
            tooltip: "Delete entry",
          )
        ],
      ),
      body: LayoutBuilder(builder: (ctx, cons) {
        final isWide = cons.maxWidth > 700;
        final content = Card(
          margin: EdgeInsets.symmetric(horizontal: isWide ? 80 : 12, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // header viz
              Row(children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color: Colors.pink.shade100, borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(_selectedMoodEmoji, style: const TextStyle(fontSize: 32))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(dayLabel, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text("Quick mood & symptom log", style: TextStyle(color: Colors.grey.shade600)),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),

              // mood selector (emoji + label grid) — Option 2
              const Text("Mood", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: moodOptions.map((m) {
                  final emoji = m['emoji']!;
                  final label = m['label']!;
                  final selected = emoji == _selectedMoodEmoji;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedMoodEmoji = emoji;
                        _moodCtl.text = label;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected ? Colors.pink.shade200 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: selected ? Colors.pink : Colors.grey.shade200),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(emoji, style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(label),
                      ]),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // symptoms chips
              const Text("Symptoms", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.symptomsList.map((s) {
                  final sel = _pickedSymptoms.contains(s);
                  return FilterChip(
                    label: Text(s),
                    selected: sel,
                    selectedColor: Colors.pink.shade100,
                    onSelected: (v) {
                      setState(() {
                        if (v) _pickedSymptoms.add(s); else _pickedSymptoms.remove(s);
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // notes
              const Text("Notes", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                controller: _notesCtl,
                maxLines: 6,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  hintText: "Write anything about today...",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),

              const SizedBox(height: 8),
              // custom mood text (optional)
              TextField(
                controller: _moodCtl,
                decoration: InputDecoration(
                  hintText: "Custom mood label (optional)",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => setState(() => _moodCtl.clear()),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ]),
          ),
        );

        if (isWide) {
          // two-column layout for wide screens: center the content and make it narrower
          return SingleChildScrollView(
            child: Column(children: [content, const SizedBox(height: 96)]),
          );
        } else {
          return SingleChildScrollView(child: Column(children: [content, const SizedBox(height: 96)]));
        }
      }),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _saving ? null : _onSave,
                icon: _saving ? const SizedBox.shrink() : const Icon(Icons.save),
                label: Text(_saving ? 'Saving...' : 'Save'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pink.shade400,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton(
              onPressed: _onDelete,
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Text("Delete"),
              ),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
