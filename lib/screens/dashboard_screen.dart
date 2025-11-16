// lib/screens/dashboard_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Local imports - ensure these screens exist in your project
import 'login_screen.dart';
import 'profile_screen.dart';
import 'habit_tracker_screen.dart';
import 'daily_stats_screen.dart';
import 'ai_chat_screen.dart';
import 'nutrition_screen.dart';
import 'fitness_screen.dart';
import 'sleep_screen.dart';
import 'mental_screen.dart';
import 'spirituality_screen.dart';
import 'habits_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "User";
  bool loadingUser = true;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  // Demo "AI" values (replace with real model outputs later)
  double moodScore = 0.78; // 0..1
  double stressScore = 0.35; // 0..1 (lower = better)
  double sleepRecovery = 0.72;
  double focusScore = 0.6;
  double spiritualEnergy = 0.65;

  final List<Map<String, String>> _activePlans = [
    {"title": "7-Day Fitness", "subtitle": "Cardio + Strength", "screen": "fitness"},
    {"title": "Budget Diet", "subtitle": "Vegetarian - Moderate", "screen": "nutrition"},
    {"title": "Sleep Ritual", "subtitle": "Bedtime routine", "screen": "sleep"},
  ];

  @override
  void initState() {
    super.initState();
    _subscribeToUserDoc();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  void _subscribeToUserDoc() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => loadingUser = false);
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      _userSub = docRef.snapshots().listen((snapshot) {
        if (!mounted) return;
        if (snapshot.exists) {
          final data = snapshot.data();
          setState(() {
            userName = (data?['name']?.toString() ?? 'User');
            loadingUser = false;
          });
        } else {
          setState(() {
            userName = 'User';
            loadingUser = false;
          });
        }
      }, onError: (err) {
        if (mounted) setState(() => loadingUser = false);
      });
    } catch (e) {
      if (mounted) setState(() => loadingUser = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  Future<void> _onRefresh() async {
    _userSub?.cancel();
    if (mounted) setState(() => loadingUser = true);
    await Future.delayed(const Duration(milliseconds: 200));
    _subscribeToUserDoc();
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // Helper to navigate to a screen by name
  void _openScreenByKey(String key) {
    switch (key) {
      case "profile":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
        break;
      case "habits":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HabitTrackerScreen()));
        break;
      case "today":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyStatsScreen()));
        break;
      case "assistant":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen()));
        break;
      case "nutrition":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionScreen()));
        break;
      case "fitness":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const FitnessScreen()));
        break;
      case "sleep":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen()));
        break;
      case "mental":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MentalScreen()));
        break;
      case "spiritual":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const SpiritualityScreen()));
        break;
      case "habits_list":
        Navigator.push(context, MaterialPageRoute(builder: (_) => const HabitsScreen()));
        break;
      default:
        // fallback - open assistant
        Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("WellnessHub — Co-Pilot"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh', onPressed: _onRefresh),
          IconButton(icon: const Icon(Icons.person), tooltip: 'Profile', onPressed: () => _openScreenByKey("profile")),
          IconButton(icon: const Icon(Icons.logout), tooltip: 'Logout', onPressed: _logout),
        ],
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: loadingUser
            ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
            : _buildContent(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openScreenByKey("assistant"),
        label: const Text("Ask AI Coach"),
        icon: const Icon(Icons.smart_toy),
        backgroundColor: const Color(0xFF6A1B9A),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final isWide = width > 900;

      return RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - kToolbarHeight - 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _buildTopSummaryCard(),
              const SizedBox(height: 16),
              _buildRecommendationsRow(),
              const SizedBox(height: 20),
              isWide ? _buildWideBody() : _buildNarrowBody(),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      );
    });
  }

  Widget _buildTopSummaryCard() {
    // Big AI Daily Summary
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)]),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.deepPurple.withOpacity(0.12), blurRadius: 8)],
      ),
      padding: const EdgeInsets.all(18),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("${getGreeting()}, $userName", style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            const Text("Here's your AI-powered daily brief", style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _miniChip("Mood: ${(moodScore * 100).round()}%"),
              _miniChip("Stress: ${(100 - (stressScore * 100)).round()}%"),
              _miniChip("Sleep: ${(sleepRecovery * 100).round()}%"),
              _miniChip("Focus: ${(focusScore * 100).round()}%"),
              _miniChip("Spirit: ${(spiritualEnergy * 100).round()}%"),
            ]),
          ]),
        ),

        // Quick rings summary to the right
        SizedBox(
          width: 140,
          child: Column(children: [
            _smallRing("Mind", moodScore),
            const SizedBox(height: 8),
            _smallRing("Body", sleepRecovery),
          ]),
        ),
      ]),
    );
  }

  Widget _miniChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _smallRing(String label, double percent) {
    return Column(children: [
      Stack(alignment: Alignment.center, children: [
        SizedBox(
          width: 72,
          height: 72,
          child: CircularProgressIndicator(value: percent, strokeWidth: 7, color: Colors.white),
        ),
        Text("${(percent * 100).round()}%", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ]),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(color: Colors.white70)),
    ]);
  }

  Widget _buildRecommendationsRow() {
    // 3 cards with quick suggestions. Tapping will navigate to related screens
    final List<Map<String, dynamic>> recs = [
      {"title": "Nutrition", "msg": "Try a high-fiber breakfast", "action": () => _openScreenByKey("nutrition"), "color": Colors.orange},
      {"title": "Mind", "msg": "5 min breathing to reduce stress", "action": () => _openScreenByKey("mental"), "color": Colors.indigo},
      {"title": "Move", "msg": "Short HIIT — 10 min", "action": () => _openScreenByKey("fitness"), "color": Colors.green},
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: recs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final r = recs[i];
          return GestureDetector(
            onTap: r["action"] as VoidCallback,
            child: Container(
              width: 250,
              decoration: BoxDecoration(color: r["color"].withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(12),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: r["color"], borderRadius: BorderRadius.circular(10)),
                  child: Icon(i == 0 ? Icons.restaurant : (i == 1 ? Icons.self_improvement : Icons.fitness_center), color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(r["title"], style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(r["msg"], style: const TextStyle(fontSize: 12, color: Colors.black87)),
                ])),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _buildWideBody() {
    // Two-column layout for large screens
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Expanded(flex: 2, child: Column(children: [
        _buildWellnessRingsCard(),
        const SizedBox(height: 16),
        _buildActivePlansCard(),
        const SizedBox(height: 16),
        _weeklyChartCard(),
      ])),
      const SizedBox(width: 16),
      Expanded(flex: 1, child: Column(children: [
        _habitStreaksCard(),
        const SizedBox(height: 16),
        _dailyStatsCard(),
        const SizedBox(height: 16),
        _communityCard(),
      ])),
    ]);
  }

  Widget _buildNarrowBody() {
    // Single column for mobile
    return Column(children: [
      _buildWellnessRingsCard(),
      const SizedBox(height: 12),
      _buildActivePlansCard(),
      const SizedBox(height: 12),
      _habitStreaksCard(),
      const SizedBox(height: 12),
      _weeklyChartCard(),
      const SizedBox(height: 12),
      _dailyStatsCard(),
      const SizedBox(height: 12),
      _communityCard(),
    ]);
  }

  Widget _buildWellnessRingsCard() {
    // Larger rings: Mind / Body / Soul / Focus
    final rings = [
      {"label": "Mind", "value": moodScore, "color": Colors.purple},
      {"label": "Body", "value": sleepRecovery, "color": Colors.teal},
      {"label": "Soul", "value": spiritualEnergy, "color": Colors.deepPurple},
      {"label": "Focus", "value": focusScore, "color": Colors.orange},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Wellness Rings", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(spacing: 12, runSpacing: 12, children: rings.map((r) {
            return _ringCard(r['label'] as String, r['value'] as double, r['color'] as Color);
          }).toList()),
        ]),
      ),
    );
  }

  Widget _ringCard(String title, double percent, Color color) {
    return SizedBox(
      width: 160,
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(children: [
            Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 84,
                height: 84,
                child: CircularProgressIndicator(value: percent, strokeWidth: 8, color: color),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("${(percent * 100).round()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
                ],
              )
            ]),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: percent, color: color, backgroundColor: color.withOpacity(0.12)),
          ]),
        ),
      ),
    );
  }

  Widget _buildActivePlansCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Icon(Icons.play_circle_outline), SizedBox(width: 8), Text("Active Plans", style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _activePlans.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final p = _activePlans[i];
                return GestureDetector(
                  onTap: () {
                    // navigate depending on plan key
                    _openScreenByKey(p['screen']!);
                  },
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)
                    ]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(p['subtitle']!, style: const TextStyle(color: Colors.black54)),
                      const Spacer(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        ElevatedButton(onPressed: () => _openScreenByKey(p['screen']!), child: const Text("Open")),
                        const Text("3/7", style: TextStyle(color: Colors.black54)), // progress placeholder
                      ])
                    ]),
                  ),
                );
              },
            ),
          ),
        ]),
      ),
    );
  }

  Widget _habitStreaksCard() {
    // Demo top habit streaks
    final streaks = [
      {"habit": "Drink Water", "streak": 12},
      {"habit": "Meditation", "streak": 8},
      {"habit": "No Sugar", "streak": 4},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Icon(Icons.star), SizedBox(width: 8), Text("Habit Streaks", style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          ...streaks.map((s) => ListTile(
  dense: true,
  contentPadding: EdgeInsets.zero,
  leading: CircleAvatar(
      child: Text((s['streak'] as int).toString()),
      backgroundColor: Colors.deepPurple.shade50),
  title: Text(s['habit'] as String),
  trailing: ElevatedButton(
      onPressed: () => _openScreenByKey("habits"),
      child: const Text("View")),
)),

          const SizedBox(height: 4),
          TextButton(onPressed: () => _openScreenByKey("habits_list"), child: const Text("Manage habits")),
        ]),
      ),
    );
  }

  Widget _weeklyChartCard() {
    // Reuse fl_chart (simple mock)
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Weekly Activity", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(height: 140, child: LineChart(LineChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
                final idx = v.toInt();
                if (idx >= 0 && idx < days.length) return Text(days[idx], style: const TextStyle(fontSize: 10));
                return const SizedBox.shrink();
              })),
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [LineChartBarData(spots: const [
              FlSpot(0, 3),
              FlSpot(1, 4.5),
              FlSpot(2, 3.7),
              FlSpot(3, 5.0),
              FlSpot(4, 6.0),
              FlSpot(5, 5.4),
              FlSpot(6, 6.8),
            ], isCurved: true, color: Colors.deepPurple, belowBarData: BarAreaData(show: true, color: Colors.deepPurple.withOpacity(0.08)))]
          ))),
        ]),
      ),
    );
  }

  Widget _dailyStatsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Icon(Icons.insights), SizedBox(width: 8), Text("Today's Quick Stats", style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _tinyStat("Steps", "6,542", Icons.directions_walk),
            _tinyStat("Calories", "1,850", Icons.local_fire_department),
            _tinyStat("Sleep", "7h 20m", Icons.bedtime),
          ]),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => _openScreenByKey("today"), child: const Text("View details"))),
        ]),
      ),
    );
  }

  Widget _tinyStat(String title, String value, IconData icon) {
    return Column(children: [
      CircleAvatar(backgroundColor: Colors.deepPurple.shade50, child: Icon(icon, color: Colors.deepPurple, size: 18)),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      const SizedBox(height: 2),
      Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
    ]);
  }

  Widget _communityCard() {
    final List<Map<String, Object>> challenges = [
      {'title': "10k Steps", 'desc': "Daily 10,000 steps", 'participants': 52, 'joined': true},
      {'title': "7-Day Mindful", 'desc': "Daily meditation", 'participants': 32, 'joined': false},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.deepPurple.shade50,
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Icon(Icons.group), SizedBox(width: 8), Text("Community Challenges", style: TextStyle(fontWeight: FontWeight.bold))]),
          const SizedBox(height: 8),
          ...challenges.map((c) {
            final joined = c['joined'] as bool;
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(c['title'] as String),
              subtitle: Text("${c['desc']} • ${c['participants']} participants"),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: joined ? Colors.green : Colors.deepPurple),
                onPressed: () {},
                child: Text(joined ? "Joined" : "Join"),
              ),
            );
          }).toList(),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () {}, child: const Text("Explore community"))),
        ]),
      ),
    );
  }
}
