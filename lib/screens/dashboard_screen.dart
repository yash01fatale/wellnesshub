// lib/screens/dashboard_screen.dart
import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Linked Screens (make sure these files exist in your project)
import 'login_screen.dart';
import 'profile_screen.dart';
import 'ai_chat_screen.dart';
import 'ai_personal_plan_screen.dart';
import 'nutrition_screen.dart';
import 'fitness_screen.dart';
import 'sleep_screen.dart';
import 'mental_screen.dart';
import 'spirituality_screen.dart';
import 'focus_screen.dart';
import 'digital_detox_screen.dart';
import 'habits_screen.dart';
import 'habit_tracker_screen.dart';
import 'addiction_recovery_screen.dart';
import 'women_wellness_screen.dart';
import 'disease_prediction_screen.dart';
import 'disease_risk_screen.dart';
import 'voice_command_screen.dart';
import 'community_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  String userName = "User";
  bool loadingUser = true;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;
  late AnimationController _anim;

  // Hero image (optional). For B1 we use full-screen gradient, but keep this if you want to switch later.
  final String heroImagePath = "/mnt/data/Screenshot 2025-11-19 090159.png";

  // Demo / placeholder stats (map from Firestore when available)
  int steps = 7540;
  int calories = 1850;
  String sleep = "7h 20m";
  int streak = 5;
  List<double> weeklyValues = [2.2, 3.5, 3.8, 5.2, 6.0, 5.4, 7.1];

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 700))..forward();
    _listenUserData();
  }

  @override
  void dispose() {
    _anim.dispose();
    _userSub?.cancel();
    super.dispose();
  }

  void _listenUserData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => loadingUser = false);
      return;
    }

    _userSub = FirebaseFirestore.instance.collection("users").doc(uid).snapshots().listen((doc) {
      if (!mounted) return;
      if (doc.exists) {
        final data = doc.data();
        setState(() {
          userName = (data?['name'] as String?) ?? userName;
          steps = (data?['steps'] as int?) ?? steps;
          calories = (data?['calories'] as int?) ?? calories;
          sleep = (data?['sleep'] as String?) ?? sleep;
          streak = (data?['streak'] as int?) ?? streak;
          // weeklyValues mapping left intentionally (optional)
        });
      }
      if (mounted) setState(() => loadingUser = false);
    }, onError: (_) {
      if (mounted) setState(() => loadingUser = false);
    });
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  void openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // ------ G3 Gradient: Pink -> Purple
  LinearGradient get _backgroundGradient => const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFAD1457), Color(0xFF6A1B9A)],
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // transparent scaffold so we can show the gradient behind
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            tooltip: "Ask AI",
            onPressed: () => openPage(const AIChatScreen()),
            icon: const Icon(Icons.smart_toy_outlined),
          ),
          IconButton(
            tooltip: "Profile",
            onPressed: () => openPage(const ProfileScreen()),
            icon: const Icon(Icons.person),
          ),
          IconButton(
            tooltip: "Logout",
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF6A1B9A),
        onPressed: () => openPage(const AIChatScreen()),
        icon: const Icon(Icons.smart_toy),
        label: const Text("Ask AI"),
      ),
      body: Stack(
        children: [
          // full-screen gradient background
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(gradient: _backgroundGradient),
            ),
          ),

          // subtle decorative blurred circles (adds depth)
          Positioned(
            top: -80,
            left: -60,
            child: _BlurCircle(size: 240, color: Colors.white.withOpacity(0.06)),
          ),
          Positioned(
            bottom: -100,
            right: -80,
            child: _BlurCircle(size: 300, color: Colors.white.withOpacity(0.05)),
          ),

          // Main content with SafeArea
          SafeArea(
            child: loadingUser
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : RefreshIndicator(
                    onRefresh: () async {
                      _listenUserData();
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: LayoutBuilder(builder: (context, constraints) {
                      final isWide = constraints.maxWidth > 900;
                      return SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        child: Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: isWide ? 1200 : constraints.maxWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // top safe spacing for AppBar overlap
                                const SizedBox(height: 8),

                                // HERO (glass on gradient)
                                HeroSection(
                                  userName: userName,
                                  greeting: greeting(),
                                  heroImagePath: heroImagePath,
                                  anim: _anim,
                                  steps: steps,
                                  calories: calories,
                                  sleep: sleep,
                                  streak: streak,
                                  onPrimaryAction: () => openPage(const AIPersonalPlanScreen()),
                                  onSecondaryAction: () => openPage(const AIChatScreen()),
                                ),
                                const SizedBox(height: 18),

                                // Top row: quick actions and wellness rings (responsive)
                                if (isWide)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 2, child: _quickActionsCard()),
                                      const SizedBox(width: 16),
                                      Expanded(flex: 1, child: _wellnessRingsCard()),
                                    ],
                                  )
                                else ...[
                                  _quickActionsCard(),
                                  const SizedBox(height: 12),
                                  _wellnessRingsCard(),
                                ],
                                const SizedBox(height: 16),

                                // AI recommendations
                                _aiRecommendations(),

                                const SizedBox(height: 16),

                                // Active Plans + Weekly Chart
                                if (isWide)
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Expanded(flex: 2, child: _activePlansCard()),
                                      const SizedBox(width: 16),
                                      Expanded(flex: 1, child: _weeklyChartCard()),
                                    ],
                                  )
                                else ...[
                                  _activePlansCard(),
                                  const SizedBox(height: 12),
                                  _weeklyChartCard(),
                                ],

                                const SizedBox(height: 16),

                                // Grid: health features
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: [
                                    SizedBox(
                                        width: isWide ? (constraints.maxWidth - 48) / 3 : constraints.maxWidth,
                                        child: _diseaseCard()),
                                    SizedBox(
                                        width: isWide ? (constraints.maxWidth - 48) / 3 : constraints.maxWidth,
                                        child: _womenWellnessCard()),
                                    SizedBox(
                                        width: isWide ? (constraints.maxWidth - 48) / 3 : constraints.maxWidth,
                                        child: _addictionCard()),
                                    SizedBox(
                                        width: isWide ? (constraints.maxWidth - 48) / 2 : constraints.maxWidth,
                                        child: _habitStreaksCard()),
                                    SizedBox(
                                        width: isWide ? (constraints.maxWidth - 48) / 2 : constraints.maxWidth,
                                        child: _detoxAndFocusCard()),
                                  ],
                                ),

                                const SizedBox(height: 18),

                                // Community section
                                _communityCard(),

                                const SizedBox(height: 40),
                              ],
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
          ),
        ],
      ),
    );
  }

  // ---------------- UI pieces ----------------

  Widget _quickActionsCard() {
    final actions = [
      {"text": "Nutrition", "icon": Icons.restaurant, "page": const NutritionScreen()},
      {"text": "Fitness", "icon": Icons.fitness_center, "page": const FitnessScreen()},
      {"text": "Sleep", "icon": Icons.bedtime, "page": const SleepScreen()},
      {"text": "Mental", "icon": Icons.psychology, "page": const MentalScreen()},
      {"text": "Spiritual", "icon": Icons.spa, "page": const SpiritualityScreen()},
      {"text": "Focus", "icon": Icons.timelapse, "page": const FocusScreen()},
      {"text": "Habits", "icon": Icons.track_changes, "page": const HabitsScreen()},
      {"text": "Detox", "icon": Icons.block, "page": const DigitalDetoxScreen()},
      {"text": "Voice", "icon": Icons.mic, "page": const VoiceCommandScreen()},
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions.map((a) {
            return SizedBox(
              width: 110,
              height: 110,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => openPage(a["page"] as Widget),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.06),
                        child: Icon(a["icon"] as IconData, color: Colors.white),
                      ),
                      const SizedBox(height: 10),
                      Text(a["text"] as String,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _wellnessRingsCard() {
    final rings = [
      {"label": "Mind", "value": 0.78, "col": Colors.purpleAccent},
      {"label": "Body", "value": 0.72, "col": Colors.tealAccent},
      {"label": "Spirit", "value": 0.67, "col": Colors.deepPurpleAccent},
      {"label": "Focus", "value": 0.58, "col": Colors.orangeAccent},
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Wellness", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: rings.map((r) {
                return SizedBox(
                  width: 120,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 86,
                        width: 86,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            CircularProgressIndicator(
                              value: r["value"] as double,
                              strokeWidth: 8,
                              color: r["col"] as Color,
                              backgroundColor: Colors.white.withOpacity(0.06),
                            ),
                            Text("${(((r["value"] as double) * 100)).round()}%",
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(r["label"] as String, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _aiRecommendations() {
    final data = [
      {"title": "Nutrition", "msg": "Try high-fiber breakfast today", "color": Colors.orangeAccent, "page": const NutritionScreen()},
      {"title": "Mindfulness", "msg": "5 mins breathing for stress", "color": Colors.lightBlueAccent, "page": const MentalScreen()},
      {"title": "Movement", "msg": "10 min cardio for energy", "color": Colors.lightGreenAccent, "page": const FitnessScreen()},
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: data.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) {
          final r = data[i];
          return GestureDetector(
            onTap: () => openPage(r["page"] as Widget),
            child: Container(
              width: 280,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white.withOpacity(0.06),
                border: Border.all(color: Colors.white.withOpacity(0.03)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: r["color"] as Color, borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.lightbulb, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r["title"] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 8),
                        Text(r["msg"] as String, style: const TextStyle(fontSize: 13, color: Colors.white70)),
                        const Spacer(),
                        Row(
                          children: const [
                            Icon(Icons.trending_up, size: 14, color: Colors.white54),
                            SizedBox(width: 8),
                            Text("Personalized", style: TextStyle(fontSize: 12, color: Colors.white54)),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _activePlansCard() {
    final plans = [
      {"title": "7-Day Fitness", "sub": "Cardio + Strength", "page": const FitnessScreen()},
      {"title": "Nutrition Plan", "sub": "Balanced + Budget Friendly", "page": const NutritionScreen()},
      {"title": "Sleep Ritual", "sub": "Night Routine", "page": const SleepScreen()},
    ];

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Active Plans", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: plans.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final p = plans[i];
                  return Container(
                    width: 240,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: Colors.white.withOpacity(0.06),
                      border: Border.all(color: Colors.white.withOpacity(0.03)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p["title"] as String, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 6),
                        Text(p["sub"] as String, style: const TextStyle(color: Colors.white70)),
                        const Spacer(),
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A)),
                              onPressed: () => openPage(p["page"] as Widget),
                              child: const Text("Open"),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton(onPressed: () {}, child: const Text("Share", style: TextStyle(color: Colors.white))),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _weeklyChartCard() {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Activity", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 8),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 24,
                        getTitlesWidget: (value, _) {
                          const days = ["M", "T", "W", "T", "F", "S", "S"];
                          final idx = value.toInt().clamp(0, days.length - 1);
                          return Text(days[idx], style: const TextStyle(fontSize: 12, color: Colors.white70));
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 3,
                      spots: weeklyValues.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value)).toList(),
                      belowBarData: BarAreaData(show: true, color: Colors.white.withOpacity(.08)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _diseaseCard() {
    return Card(
      color: Colors.white.withOpacity(0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(backgroundColor: Colors.redAccent.withOpacity(0.9), child: const Icon(Icons.health_and_safety, color: Colors.white)),
              title: const Text("AI Health Predictions", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              subtitle: const Text("Upload reports for an AI-based risk scan", style: TextStyle(color: Colors.white70)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent), onPressed: () => openPage(const DiseasePredictionScreen()), child: const Text("Upload")),
                const SizedBox(width: 8),
                OutlinedButton(onPressed: () => openPage(const DiseaseRiskScreen()), child: const Text("Assess", style: TextStyle(color: Colors.white))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _womenWellnessCard() {
    return Card(
      color: Colors.pink.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: const Text("Women Wellness", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: const Text("PCOS · Hormones · Pregnancy journeys", style: TextStyle(color: Colors.white70)),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
          onPressed: () => openPage(const WomenWellnessScreen()),
          child: const Text("Open"),
        ),
      ),
    );
  }

  Widget _addictionCard() {
    return Card(
      color: Colors.green.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: const Text("Addiction Recovery", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        subtitle: const Text("Smoking · Alcohol · Junk food", style: TextStyle(color: Colors.white70)),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => openPage(const AddictionRecoveryScreen()),
          child: const Text("Start"),
        ),
      ),
    );
  }

  Widget _habitStreaksCard() {
    final habits = [
      {"name": "Hydration", "streak": 9},
      {"name": "Meditation", "streak": 6},
      {"name": "Sleep Early", "streak": 3},
    ];

    return Card(
      color: Colors.white.withOpacity(0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Habit Streaks", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          ...habits.map((h) {
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(backgroundColor: Colors.white.withOpacity(0.06), child: Text("${h["streak"]}", style: const TextStyle(color: Colors.white))),
              title: Text(h["name"] as String, style: const TextStyle(color: Colors.white)),
              trailing: ElevatedButton(onPressed: () => openPage(const HabitTrackerScreen()), child: const Text("Open")),
            );
          }).toList(),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => openPage(const HabitTrackerScreen()), child: const Text("Manage Habits", style: TextStyle(color: Colors.white70)))),
        ]),
      ),
    );
  }

  Widget _detoxAndFocusCard() {
    return Card(
      color: Colors.white.withOpacity(0.04),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.block, color: Colors.deepPurpleAccent),
            title: const Text("Digital Detox", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Reduce screen time & reset focus", style: TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(onPressed: () => openPage(const DigitalDetoxScreen()), child: const Text("Start")),
          ),
          const Divider(color: Colors.white10, height: 1),
          ListTile(
            leading: const Icon(Icons.center_focus_strong, color: Colors.blueAccent),
            title: const Text("Focus Mode", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Start a focused session", style: TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(onPressed: () => openPage(const FocusScreen()), child: const Text("Start")),
          ),
        ],
      ),
    );
  }

  Widget _communityCard() {
    return Card(
      color: Colors.deepPurple.withOpacity(0.06),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Community Challenges", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 8),
          ListTile(
            title: const Text("10K Steps Challenge", style: TextStyle(color: Colors.white)),
            subtitle: const Text("Daily walk goal", style: TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(onPressed: () => openPage(const CommunityScreen()), child: const Text("Join")),
          ),
          ListTile(
            title: const Text("Mindfulness Week", style: TextStyle(color: Colors.white)),
            subtitle: const Text("7-day guided meditations", style: TextStyle(color: Colors.white70)),
            trailing: ElevatedButton(onPressed: () => openPage(const CommunityScreen()), child: const Text("Join")),
          ),
        ]),
      ),
    );
  }
}

// ----------------- Glass Card + Hero widgets -----------------

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const GlassCard({super.key, required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.06)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(padding: padding ?? const EdgeInsets.all(0), child: child),
        ),
      ),
    );
  }
}

class HeroSection extends StatelessWidget {
  final String userName;
  final String greeting;
  final String heroImagePath;
  final AnimationController anim;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  // stats
  final int steps;
  final int calories;
  final String sleep;
  final int streak;

  const HeroSection({
    super.key,
    required this.userName,
    required this.greeting,
    required this.heroImagePath,
    required this.anim,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
    required this.steps,
    required this.calories,
    required this.sleep,
    required this.streak,
  });

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 900;

    return FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, .03), end: Offset.zero)
            .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            children: [
              // For B1 we prefer gradient; allow heroImage if available locally for device builds
              if (!kIsWeb && File(heroImagePath).existsSync())
                SizedBox(height: isWide ? 260 : 220, width: double.infinity, child: Image.file(File(heroImagePath), fit: BoxFit.cover))
              else
                Container(
                  height: isWide ? 260 : 220,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white.withOpacity(0.02), Colors.white.withOpacity(0.01)],
                    ),
                  ),
                ),

              // dark overlay for legibility
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withOpacity(0.25), Colors.transparent],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),

              // content
              Positioned(
                left: 20,
                bottom: 20,
                right: isWide ? 340 : 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("$greeting, $userName 👋", style: const TextStyle(color: Colors.white70, fontSize: 16)),
                    const SizedBox(height: 8),
                    const Text("Your AI Wellness Dashboard",
                        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text("Daily nudges, personalized plans & realtime insights.", style: TextStyle(color: Colors.white70)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: onPrimaryAction,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12), child: Text("Start AI Plan")),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: onSecondaryAction,
                          style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white24), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                          child: const Padding(padding: EdgeInsets.symmetric(horizontal: 18, vertical: 12), child: Text("Chat with AI", style: TextStyle(color: Colors.white))),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              // right stats (wide)
              if (isWide)
                Positioned(
                  right: 22,
                  top: 22,
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _smallStatRow("Steps", steps.toString(), Icons.directions_walk),
                          const SizedBox(height: 8),
                          _smallStatRow("Sleep", sleep, Icons.bedtime),
                          const SizedBox(height: 8),
                          _smallStatRow("Calories", calories.toString(), Icons.local_fire_department),
                          const SizedBox(height: 8),
                          _smallStatRow("Streak", streak.toString(), Icons.whatshot),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallStatRow(String title, String value, IconData icon) {
    return Row(
      children: [
        CircleAvatar(radius: 18, backgroundColor: Colors.white.withOpacity(0.06), child: Icon(icon, color: Colors.white)),
        const SizedBox(width: 10),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
      ],
    );
  }
}

// small blurred decorative circle
class _BlurCircle extends StatelessWidget {
  final double size;
  final Color color;
  const _BlurCircle({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 40, spreadRadius: 10)]),
    );
  }
}
