// lib/screens/home_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'dashboard_screen.dart';
import 'nutrition_screen.dart';
import 'fitness_screen.dart';
import 'sleep_screen.dart';
import 'mental_screen.dart';
import 'spirituality_screen.dart';
import 'habits_screen.dart';
import 'daily_stats_screen.dart';
import 'ai_chat_screen.dart';
import 'focus_screen.dart';
import 'profile_screen.dart';
import 'addiction_recovery_screen.dart';
import 'women_wellness_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String displayName = "User";
  bool loading = true;

  int steps = 5432;
  int calories = 1750;
  String heartRate = "77";
  String mood = "Relaxed";
  String sleep = "7h 10m";

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          displayName = doc['name'] ?? displayName;
        });
      }
    } catch (e) {
      // ignore
    }

    setState(() => loading = false);
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
  }

  Widget _quick(String title, IconData icon, Widget page) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => page)),
      child: Container(
        width: 110,
        height: 110,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 34, color: Colors.deepPurple),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        title: const Text("WellnessHub"),
        actions: [
          IconButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
              icon: const Icon(Icons.person)),
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),

      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUser,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)]),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Hello, $displayName",
                                      style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  const Text("Here is your daily wellness snapshot",
                                      style: TextStyle(color: Colors.white70))
                                ]),
                          ),
                          const Icon(Icons.self_improvement, color: Colors.white, size: 48)
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // VITALS
                    Row(children: [
                      Expanded(child: _vital("Heart Rate", "$heartRate bpm", Icons.favorite, Colors.red)),
                      const SizedBox(width: 12),
                      Expanded(child: _vital("Steps", "$steps", Icons.directions_walk, Colors.orange)),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: _vital("Calories", "$calories kcal", Icons.local_fire_department, Colors.teal)),
                      const SizedBox(width: 12),
                      Expanded(child: _vital("Sleep", sleep, Icons.bedtime, Colors.blue)),
                    ]),

                    const SizedBox(height: 20),

                    // QUICK ACTIONS GRID
                    const Text("Quick Actions", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 14,
                      runSpacing: 14,
                      children: [
                        _quick("Nutrition", Icons.restaurant, const NutritionScreen()),
                        _quick("Fitness", Icons.fitness_center, const FitnessScreen()),
                        _quick("Sleep", Icons.bedtime, const SleepScreen()),
                        _quick("Mental", Icons.psychology, const MentalScreen()),
                        _quick("Spiritual", Icons.spa, const SpiritualityScreen()),
                        _quick("Habits", Icons.track_changes, const HabitsScreen()),
                        _quick("Focus Mode", Icons.timelapse, const FocusScreen()),
                        _quick("AI Assistant", Icons.smart_toy, const AIChatScreen()),

                        // NEW FEATURES
                        _quick("Addiction Help", Icons.smoke_free, const AddictionRecoveryScreen()),
                        _quick("Women Wellness", Icons.female, const WomenWellnessScreen()),

                        _quick("Dashboard", Icons.dashboard, const DashboardScreen()),
                        _quick("Today", Icons.bar_chart, const DailyStatsScreen()),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // INSIGHTS CARD
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Personalized Insights", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            const Text("• Your sleep is improving.\n• Add more protein for balanced energy.\n• Great job staying active!"),
                            Align(
                                alignment: Alignment.bottomRight,
                                child: TextButton(
                                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
                                    child: const Text("More"))),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30)
                  ],
                ),
              ),
            ),
    );
  }

  Widget _vital(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          CircleAvatar(radius: 24, backgroundColor: color.withOpacity(.15), child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.black54)),
            Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ])
        ]),
      ),
    );
  }
}
