import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/services.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late String userId;
  int xp = 0;
  int userLevel = 1;

  List<String> categories = [
    "Health", "Study", "Mindfulness", "Productivity", "Personal"
  ];

  List<String> aiSuggestions = [
    "Drink 3L Water",
    "10-minute Meditation",
    "Read 5 Pages",
    "15 Push-ups",
    "No Sugar Today",
    "Gratitude Note",
    "20-minute Walk",
    "Journal for 5 mins"
  ];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    _dailyReset();
  }

  // ============================================================
  // 🔥 DAILY RESET AT MIDNIGHT (Resets completed habits)
  // ============================================================
  Future<void> _dailyReset() async {
    Timer.periodic(const Duration(seconds: 20), (timer) async {
      final now = DateTime.now();
      final midnight = DateTime(now.year, now.month, now.day, 0, 0);

      if (DateTime.now().difference(midnight).inMinutes < 1) {
        final snapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("habit_logs")
            .get();

        for (var doc in snapshot.docs) {
          await doc.reference.update({"completed": false});
        }

        setState(() {});
      }
    });
  }

  // ============================================================
  // 🔥 Reward XP on habit completion
  // ============================================================
  void _addXP() {
    setState(() {
      xp += 10;

      if (xp >= userLevel * 100) {
        xp = 0;
        userLevel++;
      }
    });
    HapticFeedback.mediumImpact();
  }

  // ============================================================
  // 🔥 Build UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple.shade50,
      appBar: AppBar(
        title: const Text("Habit & Focus Center"),
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildUserLevelCard(),
            const SizedBox(height: 20),

            _buildHabitAnalyticsCard(),
            const SizedBox(height: 20),

            _buildCategoriesSection(),
            const SizedBox(height: 20),

            _buildAISuggestions(),
            const SizedBox(height: 20),

            const Text(
              "Your Habits",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            _habitList(),

            const SizedBox(height: 80),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () => _addHabit(context),
      ),
    );
  }

  // ============================================================
  // 🔥 USER LEVEL CARD (XP + Progress Bar)
  // ============================================================
  Widget _buildUserLevelCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Text(
            "Level $userLevel",
            style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          LinearProgressIndicator(
            value: xp / (userLevel * 100),
            backgroundColor: Colors.white24,
            color: Colors.yellowAccent,
            minHeight: 10,
          ),

          const SizedBox(height: 10),
          Text(
            "$xp / ${userLevel * 100} XP",
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // 🔥 HABIT ANALYTICS (CHART)
  // ============================================================
  Widget _buildHabitAnalyticsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Habit Analytics 📊",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      spots: const [
                        FlSpot(0, 2),
                        FlSpot(1, 3),
                        FlSpot(2, 5),
                        FlSpot(3, 2.5),
                        FlSpot(4, 4),
                        FlSpot(5, 5),
                        FlSpot(6, 6)
                      ],
                      color: Colors.deepPurple,
                      dotData: FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepPurple.withOpacity(0.2),
                      ),
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

  // ============================================================
  // 🔥 CATEGORIES SECTION
  // ============================================================
  Widget _buildCategoriesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Categories",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),

        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: categories.map((c) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.deepPurple.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(c, style: const TextStyle(fontWeight: FontWeight.w600)),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // 🔥 AI SUGGESTIONS SECTION
  // ============================================================
  Widget _buildAISuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("AI Suggested Habits 🤖",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),

        Column(
          children: aiSuggestions.map((s) {
            return Card(
              elevation: 3,
              child: ListTile(
                title: Text(s, style: const TextStyle(fontSize: 16)),
                trailing: ElevatedButton(
                  child: const Text("Add"),
                  onPressed: () => _addAIHabit(s),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Future<void> _addAIHabit(String habit) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("habit_logs")
        .add({
      "habit_name": habit,
      "category": "AI Suggestion",
      "completed": false,
      "streak": 0,
      "timestamp": Timestamp.now(),
    });
  }

  // ============================================================
  // 🔥 HABIT LIST
  // ============================================================
  Widget _habitList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("habit_logs")
          .snapshots(),

      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();

        final docs = snapshot.data!.docs;
        if (docs.isEmpty) return const Text("No habits yet.");

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _habitCard(doc.id, data);
          }).toList(),
        );
      },
    );
  }

  // ============================================================
  // 🔥 HABIT CARD (GAMIFIED)
  // ============================================================
  Widget _habitCard(String id, Map<String, dynamic> data) {
    bool completed = data["completed"] ?? false;
    int streak = data["streak"] ?? 0;

    return Card(
      child: ListTile(
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: completed ? Colors.green : Colors.grey.shade300,
          child: Icon(
            completed ? Icons.check : Icons.circle_outlined,
            color: completed ? Colors.white : Colors.grey,
          ),
        ),
        title: Text(
          data["habit_name"],
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("🔥 Streak: $streak days"),

        trailing: ElevatedButton(
          child: Text(completed ? "Done" : "Mark"),
          onPressed: () => _toggleHabit(id, data),
        ),
      ),
    );
  }

  Future<void> _toggleHabit(String id, Map<String, dynamic> data) async {
    bool completed = data["completed"];
    int streak = data["streak"];

    if (!completed) {
      streak++;
      _addXP();
      HapticFeedback.lightImpact();
    }

    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("habit_logs")
        .doc(id)
        .update({
      "completed": !completed,
      "streak": streak,
      "timestamp": Timestamp.now(),
    });
  }

  // ============================================================
  // 🔥 ADD HABIT
  // ============================================================
  void _addHabit(BuildContext context) {
    final habitController = TextEditingController();
    String selectedCategory = categories.first;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Create Habit"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: habitController,
              decoration: const InputDecoration(labelText: "Habit Name"),
            ),
            const SizedBox(height: 10),

            DropdownButton<String>(
              value: selectedCategory,
              items: categories.map((c) {
                return DropdownMenuItem(value: c, child: Text(c));
              }).toList(),
              onChanged: (v) {
                selectedCategory = v!;
                setState(() {});
              },
            ),
          ],
        ),

        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            child: const Text("Save"),
            onPressed: () async {
              final habit = habitController.text.trim();
              if (habit.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(userId)
                  .collection("habit_logs")
                  .add({
                "habit_name": habit,
                "category": selectedCategory,
                "completed": false,
                "streak": 0,
                "timestamp": Timestamp.now(),
              });

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
