import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

// Linked Screens
import 'login_screen.dart';
import 'profile_screen.dart';
import 'ai_chat_screen.dart';
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

class _DashboardScreenState extends State<DashboardScreen> {
  String userName = "User";
  bool loadingUser = true;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _userSub;

  @override
  void initState() {
    super.initState();
    listenUserData();
  }

  @override
  void dispose() {
    _userSub?.cancel();
    super.dispose();
  }

  void listenUserData() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => loadingUser = false);
      return;
    }

    _userSub = FirebaseFirestore.instance.collection("users").doc(uid).snapshots().listen((doc) {
      if (!mounted) return;
      if (doc.exists) userName = doc["name"] ?? "User";
      setState(() => loadingUser = false);
    });
  }

  void openPage(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  String greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("AI Wellness Dashboard"),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => openPage(const ProfileScreen()),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.deepPurple,
        onPressed: () => openPage(const AIChatScreen()),
        label: const Text("Ask AI"),
        icon: const Icon(Icons.smart_toy),
      ),

      body: loadingUser
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async => listenUserData(),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ---------------------------------------------------------------------
                    // 1. HEADER
                    // ---------------------------------------------------------------------
                    headerCard(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 2. QUICK ACTION GRID
                    // ---------------------------------------------------------------------
                    quickActions(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 3. AI SUGGESTIONS
                    // ---------------------------------------------------------------------
                    aiRecommendations(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 4. WELLNESS SCORE RINGS
                    // ---------------------------------------------------------------------
                    wellnessRings(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 5. ACTIVE PLANS
                    // ---------------------------------------------------------------------
                    activePlans(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 6. DISEASE PREDICTION
                    // ---------------------------------------------------------------------
                    diseaseSection(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 7. WOMEN WELLNESS
                    // ---------------------------------------------------------------------
                    womenWellness(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 8. ADDICTION RECOVERY
                    // ---------------------------------------------------------------------
                    addictionCard(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 9. HABIT STREAKS
                    // ---------------------------------------------------------------------
                    habitStreaks(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 10. WEEKLY CHART
                    // ---------------------------------------------------------------------
                    weeklyChart(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 11. DIGITAL DETOX + FOCUS MODE
                    // ---------------------------------------------------------------------
                    digitalDetoxAndFocus(),

                    const SizedBox(height: 20),

                    // ---------------------------------------------------------------------
                    // 12. COMMUNITY CHALLENGES
                    // ---------------------------------------------------------------------
                    communitySection(),

                    const SizedBox(height: 45),
                  ],
                ),
              ),
            ),
    );
  }

  // ---------------------------------------------------------------------
  // 1. HEADER CARD
  // ---------------------------------------------------------------------

  Widget headerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
            colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)], begin: Alignment.topLeft),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("${greeting()}, $userName 👋",
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Your AI-powered lifestyle, wellness & spirituality tracker",
              style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 14),

          // Wellness indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              miniCircle("Mind", 0.78),
              miniCircle("Body", 0.72),
              miniCircle("Focus", 0.58),
              miniCircle("Spirit", 0.67),
            ],
          ),
        ],
      ),
    );
  }

  Widget miniCircle(String label, double value) {
    return Column(
      children: [
        SizedBox(
          width: 55,
          height: 55,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 6,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
              Text("${(value * 100).round()}%",
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        const SizedBox(height: 5),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // 2. QUICK ACTIONS
  // ---------------------------------------------------------------------

  Widget quickActions() {
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

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: actions.map((a) {
            return GestureDetector(
              onTap: () => openPage(a["page"] as Widget),
              child: Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(a["icon"] as IconData, size: 32, color: Colors.deepPurple),
                    const SizedBox(height: 8),
                    Text(a["text"] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 3. AI RECOMMENDATIONS
  // ---------------------------------------------------------------------

  Widget aiRecommendations() {
    final data = [
      {"title": "Nutrition", "msg": "Try high-fiber breakfast today", "color": Colors.orange, "page": const NutritionScreen()},
      {"title": "Mindfulness", "msg": "5 mins breathing for stress", "color": Colors.blue, "page": const MentalScreen()},
      {"title": "Movement", "msg": "10 min cardio for energy", "color": Colors.green, "page": const FitnessScreen()},
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
            onTap: () => openPage(r["page"] as Widget),
            child: Container(
              width: 250,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (r["color"] as Color).withOpacity(.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                        color: r["color"] as Color, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.lightbulb, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(r["title"] as String,
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 5),
                        Text(r["msg"] as String, style: const TextStyle(fontSize: 12)),
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

  // ---------------------------------------------------------------------
  // 4. WELLNESS RINGS
  // ---------------------------------------------------------------------

  Widget wellnessRings() {
    final rings = [
      {"label": "Mind", "value": 0.78, "col": Colors.purple},
      {"label": "Body", "value": 0.72, "col": Colors.teal},
      {"label": "Spirit", "value": 0.67, "col": Colors.deepPurple},
      {"label": "Focus", "value": 0.58, "col": Colors.orange},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Wrap(
          spacing: 16,
          runSpacing: 16,
          children: rings
              .map((r) => ringLarge(r["label"] as String, r["value"] as double, r["col"] as Color))
              .toList(),
        ),
      ),
    );
  }

  Widget ringLarge(String label, double value, Color col) {
    return SizedBox(
      width: 150,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
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
                    Text("${(value * 100).round()}%",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 5. ACTIVE PLANS
  // ---------------------------------------------------------------------

  Widget activePlans() {
    final plans = [
      {"title": "7-Day Fitness", "sub": "Cardio + Strength", "page": const FitnessScreen()},
      {"title": "Nutrition Plan", "sub": "Balanced + Budget Friendly", "page": const NutritionScreen()},
      {"title": "Sleep Ritual", "sub": "Night Routine", "page": const SleepScreen()},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Active Plans", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 130,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: plans.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) {
                  final p = plans[i];
                  return GestureDetector(
                    onTap: () => openPage(p["page"] as Widget),
                    child: Container(
                      width: 225,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p["title"] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 6),
                          Text(p["sub"] as String,
                              style: const TextStyle(color: Colors.black54)),
                          const Spacer(),
                          ElevatedButton(
                              onPressed: () => openPage(p["page"] as Widget),
                              child: const Text("Open")),
                        ],
                      ),
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

  // ---------------------------------------------------------------------
  // 6. DISEASE PREDICTION + RISK
  // ---------------------------------------------------------------------

  Widget diseaseSection() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("AI Health Predictions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 10),

            ListTile(
              leading: const Icon(Icons.health_and_safety, color: Colors.red),
              title: const Text("Disease Prediction"),
              subtitle: const Text("Upload tests to get AI-based prediction"),
              trailing: ElevatedButton(
                onPressed: () => openPage(const DiseasePredictionScreen()),
                child: const Text("Open"),
              ),
            ),

            ListTile(
              leading: const Icon(Icons.warning, color: Colors.orange),
              title: const Text("Risk Assessment"),
              subtitle: const Text("Check your lifestyle disease risk"),
              trailing: ElevatedButton(
                onPressed: () => openPage(const DiseaseRiskScreen()),
                child: const Text("Check"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 7. WOMEN WELLNESS
  // ---------------------------------------------------------------------

  Widget womenWellness() {
    return Card(
      color: Colors.pink.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: const Text("Women Wellness Care",
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("PCOS – Hormonal – Pregnancy Wellness"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
          onPressed: () => openPage(const WomenWellnessScreen()),
          child: const Text("Open"),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 8. ADDICTION RECOVERY
  // ---------------------------------------------------------------------

  Widget addictionCard() {
    return Card(
      color: Colors.green.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        title: const Text("Addiction Recovery",
            style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: const Text("Smoking – Drinking – Junk Food"),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
          onPressed: () => openPage(const AddictionRecoveryScreen()),
          child: const Text("Start"),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 9. HABIT STREAKS
  // ---------------------------------------------------------------------

  Widget habitStreaks() {
    final habits = [
      {"name": "Drink Water", "streak": 9},
      {"name": "Meditation", "streak": 6},
      {"name": "Sleep Early", "streak": 3},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Habit Streaks", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...habits.map(
              (h) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.deepPurple.shade50,
                  child: Text(h["streak"].toString()),
                ),
                title: Text(h["name"] as String),
                trailing: ElevatedButton(
                    onPressed: () => openPage(const HabitsScreen()),
                    child: const Text("Open")),
              ),
            ),
            const SizedBox(height: 8),
            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () => openPage(const HabitTrackerScreen()),
                    child: const Text("Manage Habits")))
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 10. WEEKLY CHART
  // ---------------------------------------------------------------------

  Widget weeklyChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Weekly Activity", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(LineChartData(
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ["M", "T", "W", "T", "F", "S", "S"];
                        return Text(days[v.toInt()]);
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    isCurved: true,
                    color: Colors.deepPurple,
                    barWidth: 4,
                    spots: const [
                      FlSpot(0, 2.2),
                      FlSpot(1, 3.5),
                      FlSpot(2, 3.8),
                      FlSpot(3, 5.2),
                      FlSpot(4, 6.0),
                      FlSpot(5, 5.4),
                      FlSpot(6, 7.1),
                    ],
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.deepPurple.withOpacity(.12),
                    ),
                  ),
                ],
              )),
            )
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 11. DIGITAL DETOX AND FOCUS
  // ---------------------------------------------------------------------

  Widget digitalDetoxAndFocus() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text("Digital Detox Mode"),
            subtitle: const Text("Reduce screen time & reboot your brain"),
            trailing: ElevatedButton(
                onPressed: () => openPage(const DigitalDetoxScreen()),
                child: const Text("Start")),
          ),
          ListTile(
            leading: const Icon(Icons.center_focus_strong, color: Colors.blue),
            title: const Text("Focus Mode"),
            subtitle: const Text("Boost productivity & deep work"),
            trailing: ElevatedButton(
                onPressed: () => openPage(const FocusScreen()),
                child: const Text("Open")),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // 12. COMMUNITY SECTION
  // ---------------------------------------------------------------------

  Widget communitySection() {
    return Card(
      color: Colors.deepPurple.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Community Challenges",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),

            ListTile(
              title: const Text("10K Steps Challenge"),
              subtitle: const Text("Daily walk goal"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Join"),
              ),
            ),

            ListTile(
              title: const Text("Mindfulness Week"),
              subtitle: const Text("7-Day meditation"),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text("Join"),
              ),
            ),

            Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                    onPressed: () => openPage(const CommunityScreen()),
                    child: const Text("Explore More")))
          ],
        ),
      ),
    );
  }
}
