// lib/screens/dashboard_screen.dart
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'habit_tracker_screen.dart';
import 'daily_stats_screen.dart';
import 'ai_chat_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "User";
  bool loadingUser = true;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

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
      // No logged-in user — stop loading and do nothing
      if (mounted) setState(() => loadingUser = false);
      return;
    }

    try {
      final docRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
      // realtime listener - updates UI whenever profile changes
      _userSub = docRef.snapshots().listen((snapshot) {
        if (!mounted) return;
        if (snapshot.exists) {
          final data = snapshot.data();
          setState(() {
            userName = (data?['name']?.toString() ?? 'User');
            loadingUser = false;
          });
        } else {
          // document missing -> show default name but stop loading
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
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  Future<void> _onRefresh() async {
    // manual refresh: re-subscribe quickly to force update
    _userSub?.cancel();
    if (mounted) setState(() => loadingUser = true);
    await Future.delayed(const Duration(milliseconds: 200));
    _subscribeToUserDoc();
    // small delay for UX
    await Future.delayed(const Duration(milliseconds: 300));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("WellnessHub Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => _onRefresh(),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          )
        ],
        elevation: 0,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: loadingUser
            ? const Center(key: ValueKey('loading'), child: CircularProgressIndicator())
            : RefreshIndicator(
                key: const ValueKey('content'),
                onRefresh: _onRefresh,
                child: LayoutBuilder(builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final isWide = width > 800; // breakpoint for responsive layout

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _welcomeSection(userName, getGreeting()),

                        const SizedBox(height: 20),

                        // Action row — quick navigation buttons
                        _actionRow(context, isWide),

                        const SizedBox(height: 20),

                        // Grid or Column for cards
                        isWide ? _twoColumnGrid() : Column(
                          children: [
                            _quickHealthOverview(),
                            const SizedBox(height: 20),
                            _weeklyHealthChart(),
                            const SizedBox(height: 20),
                            _mindBodyCards(),
                            const SizedBox(height: 20),
                            _nutritionTipCard(),
                            const SizedBox(height: 20),
                            _aiHealthAssistant(),
                            const SizedBox(height: 20),
                            _habitTracker(),
                            const SizedBox(height: 20),
                            _communitySection(),
                          ],
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  );
                }),
              ),
      ),
    );
  }

  Widget _actionRow(BuildContext context, bool isWide) {
    // Use icon buttons with labels — tappable
    final btnStyle = ElevatedButton.styleFrom(
      backgroundColor: const Color.fromARGB(255, 187, 81, 230),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
    );

    // keep consistent spacing for narrow/wide
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          icon: const Icon(Icons.person_outline),
          label: const Text("Profile"),
        ),
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HabitTrackerScreen())),
          icon: const Icon(Icons.checklist_rounded),
          label: const Text("Habits"),
        ),
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DailyStatsScreen())),
          icon: const Icon(Icons.bar_chart),
          label: const Text("Today"),
        ),
        ElevatedButton.icon(
          style: btnStyle,
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
          icon: const Icon(Icons.smart_toy),
          label: const Text("Assistant"),
        ),
      ],
    );
  }

  Widget _twoColumnGrid() {
    // Layout for wide screens: left column big, right column stacked cards
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left column (main content)
        Expanded(
          flex: 2,
          child: Column(
            children: [
              _quickHealthOverview(),
              const SizedBox(height: 20),
              _weeklyHealthChart(),
              const SizedBox(height: 20),
              _mindBodyCards(),
            ],
          ),
        ),

        const SizedBox(width: 18),

        // Right column (side content)
        Expanded(
          flex: 1,
          child: Column(
            children: [
              _nutritionTipCard(),
              const SizedBox(height: 16),
              _aiHealthAssistant(),
              const SizedBox(height: 16),
              _habitTracker(),
              const SizedBox(height: 16),
              _communitySection(),
            ],
          ),
        )
      ],
    );
  }

  Widget _welcomeSection(String name, String greet) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(
                "$greet, $name 👋",
                style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text("Your daily health summary is ready!", style: TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),
          const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 58),
        ],
      ),
    );
  }

  // =========================
  // Below: Cards and widgets
  // =========================

  static Widget _quickHealthOverview() {
    // Responsive two-by-two cards using Wrap
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSmallInfoCard("Heart Rate", "78 bpm", Icons.favorite, Colors.redAccent),
            _buildSmallInfoCard("Steps", "6,542", Icons.directions_walk, Colors.orange),
            _buildSmallInfoCard("Calories", "1,850", Icons.local_fire_department, Colors.teal),
            _buildSmallInfoCard("Sleep", "7h 20m", Icons.bedtime, Colors.indigo),
          ],
        ),
      ),
    );
  }

  static Widget _buildSmallInfoCard(String title, String value, IconData icon, Color color) {
    return SizedBox(
      width: 160,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Column(children: [
            Row(children: [
              Icon(icon, color: color, size: 26),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
            ]),
            const SizedBox(height: 10),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ]),
        ),
      ),
    );
  }

  static Widget _weeklyHealthChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Weekly Health Overview", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        const days = ['Mon','Tue','Wed','Thu','Fri','Sat','Sun'];
                        final idx = value.toInt();
                        if (idx >= 0 && idx < days.length) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 6.0),
                            child: Text(days[idx], style: const TextStyle(fontSize: 10)),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minY: 0,
                maxY: 8,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 4),
                      FlSpot(1, 5.2),
                      FlSpot(2, 4.8),
                      FlSpot(3, 6),
                      FlSpot(4, 7.2),
                      FlSpot(5, 6.8),
                      FlSpot(6, 7.5)
                    ],
                    isCurved: true,
                    color: Colors.deepPurple,
                    belowBarData: BarAreaData(show: true, color: Colors.deepPurpleAccent.withOpacity(0.12)),
                    dotData: FlDotData(show: true),
                  )
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }

  static Widget _mindBodyCards() {
    return Row(
      children: [
        Expanded(
          child: _buildWellnessCard(
              title: "Meditation",
              desc: "15 min mindfulness session",
              buttonText: "Start",
              color: Colors.purple,
              icon: Icons.self_improvement),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildWellnessCard(
              title: "Workout Plan",
              desc: "Custom daily exercises",
              buttonText: "View",
              color: Colors.green,
              icon: Icons.fitness_center),
        ),
      ],
    );
  }

  static Widget _nutritionTipCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: const [
          Icon(Icons.restaurant_menu, color: Colors.deepOrange, size: 56),
          SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Nutrition Tip 🍎", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text("Add more fiber-rich foods to your diet — they help digestion and energy levels!", style: TextStyle(color: Colors.black87)),
            ]),
          )
        ]),
      ),
    );
  }

  static Widget _aiHealthAssistant() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: const [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Your AI Health Assistant 🤖", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
            SizedBox(height: 8),
            Text("Ask me anything about your health goals, workouts, or nutrition plans.", style: TextStyle(color: Colors.black87)),
          ])),
          Icon(Icons.smart_toy, color: Colors.deepPurple, size: 48),
        ]),
      ),
    );
  }

  static Widget _habitTracker() {
    final Map<String, Map<String, dynamic>> dummyHabits = {
      'Drink Water': {'streak': 3, 'completedToday': false},
      'Morning Walk': {'streak': 5, 'completedToday': true},
      'Read Book': {'streak': 2, 'completedToday': false},
    };

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Habit Tracker 🗓️", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Column(children: dummyHabits.keys.map<Widget>((habit) {
            final data = dummyHabits[habit]!;
            final bool completed = data['completedToday'];
            final int streak = data['streak'];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: completed ? Colors.deepPurple : Colors.grey[300],
                child: completed ? const Icon(Icons.check, color: Colors.white) : null,
              ),
              title: Text(habit),
              subtitle: Text("Streak: $streak days"),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: completed ? Colors.green : Colors.deepPurple),
                onPressed: () {},
                child: Text(completed ? "Done" : "Mark"),
              ),
            );
          }).toList()),
        ]),
      ),
    );
  }

  static Widget _communitySection() {
    final List<Map<String, Object>> dummyChallenges = [
      {'title': "10k Steps Challenge", 'description': "Walk 10,000 steps daily", 'participants': 23, 'completed': true},
      {'title': "No Sugar Week", 'description': "Avoid sugar for 7 days", 'participants': 12, 'completed': false},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.deepPurple[50],
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Community Challenges 🤝", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
          const SizedBox(height: 12),
          ...dummyChallenges.map((challenge) {
            final bool completed = challenge['completed'] as bool;
            final String title = challenge['title'] as String;
            final String description = challenge['description'] as String;
            final int participants = challenge['participants'] as int;

            return ListTile(
              title: Text(title),
              subtitle: Text("$description\nParticipants: $participants"),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: completed ? Colors.green : Colors.deepPurple),
                onPressed: () {},
                child: Text(completed ? "Completed" : "Join"),
              ),
            );
          }),
        ]),
      ),
    );
  }

  static Widget _buildWellnessCard({
    required String title,
    required String desc,
    required String buttonText,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Icon(icon, color: color, size: 48),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(desc, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12)),
          const SizedBox(height: 10),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: color), onPressed: () {}, child: Text(buttonText)),
        ]),
      ),
    );
  }
}
