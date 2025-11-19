// lib/screens/dashboard_screen.dart
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Linked screens
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
import 'focus_screen.dart';
import 'addiction_recovery_screen.dart';
import 'women_wellness_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "User";
  bool loadingUser = true;

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  // Wellness ring dummy values
  double moodScore = 0.78;
  double stressScore = 0.35;
  double sleepRecovery = 0.72;
  double focusScore = 0.58;
  double spiritualEnergy = 0.67;

  // Active plans
  final List<Map<String, dynamic>> activePlans = [
    {
      "title": "7-Day Fitness",
      "sub": "Cardio + Strength",
      "screen": const FitnessScreen(),
    },
    {
      "title": "Budget Nutrition",
      "sub": "Vegetarian – Moderate",
      "screen": const NutritionScreen(),
    },
    {
      "title": "Sleep Ritual",
      "sub": "Night Routine",
      "screen": const SleepScreen(),
    },
  ];

  @override
  void initState() {
    super.initState();
    _listenUser();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  void _listenUser() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => loadingUser = false);
      return;
    }

    _userSub = FirebaseFirestore.instance.collection('users').doc(uid).snapshots().listen((doc) {
      if (!mounted) return;

      if (doc.exists) {
        userName = doc['name'] ?? "User";
      }
      setState(() => loadingUser = false);
    });
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  void _open(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () => _open(const AIChatScreen()),
        label: const Text("Ask AI"),
        icon: const Icon(Icons.smart_toy),
      ),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("Wellness Dashboard"),
        actions: [
          IconButton(onPressed: () => _open(const ProfileScreen()), icon: const Icon(Icons.person)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),

      body: loadingUser
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => _listenUser(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _topCard(),

                    const SizedBox(height: 16),

                    _recommendations(),

                    const SizedBox(height: 20),

                    _wellnessRings(),

                    const SizedBox(height: 20),

                    _activePlansSection(),

                    const SizedBox(height: 20),

                    _habitStreakCard(),

                    const SizedBox(height: 20),

                    _weeklyChart(),

                    const SizedBox(height: 20),

                    _quickLinks(),

                    const SizedBox(height: 20),

                    _communityChallenges(),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // ------------------------------ TOP SUMMARY ------------------------------

  Widget _topCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)]),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("${greeting()}, $userName",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              const Text("Your AI-powered wellness summary",
                  style: TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _chip("Mood", moodScore),
                  _chip("Stress", 1 - stressScore),
                  _chip("Sleep", sleepRecovery),
                  _chip("Focus", focusScore),
                  _chip("Spirit", spiritualEnergy),
                ],
              )
            ]),
          ),

          const SizedBox(width: 12),

          Column(
            children: [
              _ringSmall("Mind", moodScore),
              const SizedBox(height: 10),
              _ringSmall("Body", sleepRecovery),
            ],
          )
        ],
      ),
    );
  }

  Widget _chip(String title, double value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(10)),
      child: Text("$title ${(value * 100).round()}%",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
    );
  }

  Widget _ringSmall(String title, double value) {
    return Column(
      children: [
        SizedBox(
          width: 70,
          height: 70,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 7,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
              Text("${(value * 100).round()}%",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Text(title, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }

  // ------------------------------ RECOMMENDATIONS ------------------------------

  Widget _recommendations() {
    final data = [
      {"title": "Nutrition", "msg": "Try high-fiber breakfast", "color": Colors.orange, "page": const NutritionScreen()},
      {"title": "Mindfulness", "msg": "5 min deep breathing", "color": Colors.blue, "page": const MentalScreen()},
      {"title": "Movement", "msg": "10 min HIIT suggestion", "color": Colors.green, "page": const FitnessScreen()},
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final r = data[i];
          return GestureDetector(
            onTap: () => _open(r["page"] as Widget),
            child: Container(
              width: 260,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: (r["color"] as Color).withOpacity(.15),
              ),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: r["color"] as Color, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.lightbulb, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r["title"] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(r["msg"] as String, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                )
              ]),
            ),
          );
        },
      ),
    );
  }

  // ------------------------------ WELLNESS RINGS ------------------------------

  Widget _wellnessRings() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Wellness Rings", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _ringLarge("Mind", moodScore, Colors.purple),
              _ringLarge("Body", sleepRecovery, Colors.teal),
              _ringLarge("Spirit", spiritualEnergy, Colors.deepPurple),
              _ringLarge("Focus", focusScore, Colors.orange),
            ],
          ),
        ]),
      ),
    );
  }

  Widget _ringLarge(String title, double value, Color col) {
    return SizedBox(
      width: 150,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            SizedBox(
              width: 90,
              height: 90,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    valueColor: AlwaysStoppedAnimation(col),
                  ),
                  Text("${(value * 100).round()}%", style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.black54)),
          ]),
        ),
      ),
    );
  }

  // ------------------------------ ACTIVE PLANS ------------------------------

  Widget _activePlansSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [Icon(Icons.play_circle_outline), SizedBox(width: 8), Text("Active Plans")]),
          const SizedBox(height: 12),
          SizedBox(
            height: 130,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: activePlans.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final p = activePlans[i];
                return GestureDetector(
                  onTap: () => _open(p["screen"] as Widget),
                  child: Container(
                    width: 225,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p["title"] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(p["sub"] as String, style: const TextStyle(color: Colors.black54)),
                      const Spacer(),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        ElevatedButton(onPressed: () => _open(p["screen"] as Widget), child: const Text("Open")),
                        const Text("3/7", style: TextStyle(color: Colors.black54))
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

  // ------------------------------ HABIT STREAKS ------------------------------

  Widget _habitStreakCard() {
    final streaks = [
      {"h": "Drink Water", "s": 9},
      {"h": "Meditation", "s": 6},
      {"h": "Sleep Early", "s": 3},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Habit Streaks", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...streaks.map((e) {
            return ListTile(
              dense: true,
              leading: CircleAvatar(
                backgroundColor: Colors.deepPurple.shade50,
                child: Text(e["s"].toString()),
              ),
              title: Text(e["h"] as String),
              trailing: ElevatedButton(
                  onPressed: () => _open(const HabitsScreen()), child: const Text("View")),
            );
          }),
          Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                  onPressed: () => _open(const HabitTrackerScreen()),
                  child: const Text("Manage Habits"))),
        ]),
      ),
    );
  }

  // ------------------------------ WEEKLY CHART ------------------------------

  Widget _weeklyChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Weekly Activity", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: LineChart(LineChartData(
              gridData: FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                      const days = ["M", "T", "W", "T", "F", "S", "S"];
                      return Text(days[v.toInt()], style: const TextStyle(fontSize: 11));
                    }),
                  )),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 3.2),
                    FlSpot(1, 3.8),
                    FlSpot(2, 4.0),
                    FlSpot(3, 4.8),
                    FlSpot(4, 6.5),
                    FlSpot(5, 5.4),
                    FlSpot(6, 7.1),
                  ],
                  isCurved: true,
                  color: Colors.deepPurple,
                  belowBarData:
                      BarAreaData(show: true, color: Colors.deepPurple.withOpacity(.12)),
                )
              ],
            )),
          )
        ]),
      ),
    );
  }

  // ------------------------------ QUICK LINKS ------------------------------

  Widget _quickLinks() {
    final items = [
      {"t": "Nutrition", "i": Icons.restaurant, "p": const NutritionScreen()},
      {"t": "Fitness", "i": Icons.fitness_center, "p": const FitnessScreen()},
      {"t": "Sleep", "i": Icons.bedtime, "p": const SleepScreen()},
      {"t": "Mental", "i": Icons.psychology, "p": const MentalScreen()},
      {"t": "Spiritual", "i": Icons.spa, "p": const SpiritualityScreen()},
      {"t": "Focus", "i": Icons.timelapse, "p": const FocusScreen()},
      {"t": "Addiction", "i": Icons.smoke_free, "p": const AddictionRecoveryScreen()},
      {"t": "Women Wellness", "i": Icons.female, "p": const WomenWellnessScreen()},
      {"t": "Habits", "i": Icons.track_changes, "p": const HabitsScreen()},
      {"t": "AI Assistant", "i": Icons.smart_toy, "p": const AIChatScreen()},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Explore Tools", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: items.map((e) {
              return GestureDetector(
                onTap: () => _open(e["p"] as Widget),
                child: Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(e["i"] as IconData, size: 32, color: Colors.deepPurple),
                      const SizedBox(height: 10),
                      Text(e["t"] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }

  // ------------------------------ COMMUNITY ------------------------------

  Widget _communityChallenges() {
    final challenges = [
      {"title": "10K Steps", "desc": "Daily walk target", "joined": true},
      {"title": "Mindful Week", "desc": "7-Day meditation", "joined": false},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.deepPurple.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Community Challenges",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          ...challenges.map((c) {
            final joined = c["joined"] as bool;
            return ListTile(
              title: Text(c["title"] as String),
              subtitle: Text(c["desc"] as String),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: joined ? Colors.green : Colors.deepPurple),
                onPressed: () {},
                child: Text(joined ? "Joined" : "Join"),
              ),
            );
          }),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(onPressed: () {}, child: const Text("View More")),
          )
        ]),
      ),
    );
  }
}
