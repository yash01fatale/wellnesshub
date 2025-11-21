import 'package:flutter/material.dart';
import 'nutrition_screen.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  String selectedPlan = "7 Days";
  String selectedAge = "Adult";
  String selectedGoal = "Muscle Building";
  double progress = 0.45;
  int streakDays = 3;
  int waterGlasses = 4; // out of 8

  // For expanding exercise cards
  int? expandedExerciseIndex;

  final List<String> planTypes = ["7 Days", "15 Days", "30 Days"];
  final List<String> ageGroups = ["Child", "Young", "Adult", "Older"];
  final List<String> goals = ["Muscle Building", "Fat Loss", "Maintenance"];

  // Weekly activity in minutes (mock data for mini chart)
  final List<int> weeklyMinutes = [20, 35, 0, 40, 25, 30, 10];

  final Map<String, List<Map<String, dynamic>>> exercisesByGoal = {
    "Muscle Building": [
      {"name": "Push-ups", "reps": "3×15", "icon": Icons.fitness_center},
      {"name": "Squats", "reps": "3×20", "icon": Icons.accessibility_new},
      {"name": "Plank", "reps": "3×60s", "icon": Icons.self_improvement},
      {"name": "Dumbbell Curl", "reps": "3×12", "icon": Icons.sports_mma},
    ],
    "Fat Loss": [
      {"name": "Jumping Jacks", "reps": "3×25", "icon": Icons.directions_run},
      {"name": "Burpees", "reps": "3×12", "icon": Icons.fitness_center},
      {"name": "Mountain Climbers", "reps": "3×20", "icon": Icons.terrain},
      {"name": "High Knees", "reps": "3×40s", "icon": Icons.directions_walk},
    ],
    "Maintenance": [
      {"name": "Yoga", "reps": "15 min", "icon": Icons.self_improvement},
      {"name": "Walking", "reps": "30 min", "icon": Icons.directions_walk},
      {"name": "Stretching", "reps": "10 min", "icon": Icons.accessibility},
      {"name": "Plank", "reps": "3×45s", "icon": Icons.sports_gymnastics},
    ],
  };

  final List<String> nutritionTips = [
    "🥗 Add protein to every meal for recovery.",
    "💧 Drink 2–3 liters of water daily.",
    "🍎 Eat 2 fruits + 3 veggies per day.",
    "🥜 Snack on nuts instead of fried snacks.",
  ];

  // --------- PLAN GENERATION ----------

  List<Map<String, dynamic>> generatePlan() {
    List<Map<String, dynamic>> base = exercisesByGoal[selectedGoal]!;

    if (selectedAge == "Child" || selectedAge == "Older") {
      base = base.map((e) {
        return {...e, "reps": "Low–Intensity Version"};
      }).toList();
    }

    switch (selectedPlan) {
      case "7 Days":
        return List.generate(7, (i) => base[i % base.length]);
      case "15 Days":
        return List.generate(15, (i) => base[i % base.length]);
      case "30 Days":
        return List.generate(30, (i) => base[i % base.length]);
      default:
        return base;
    }
  }

  String generateAIRecommendation() {
    String base;
    switch (selectedGoal) {
      case "Muscle Building":
        base =
            "Focus on controlled strength sessions 3–4x/week with enough protein and rest days.";
        break;
      case "Fat Loss":
        base =
            "Mix short high-intensity circuits with daily walking and a calorie-aware, high-protein diet.";
        break;
      case "Maintenance":
      default:
        base =
            "Keep moving daily with light strength, stretching and regular walks to maintain energy.";
        break;
    }

    String ageAdvice;
    switch (selectedAge) {
      case "Child":
        ageAdvice = "Use playful, low-impact movements. Focus on fun over volume.";
        break;
      case "Older":
        ageAdvice =
            "Prioritize joint-friendly moves, balance work and slower progressions.";
        break;
      case "Young":
        ageAdvice =
            "You can handle moderate–high intensity if healthy. Always warm up first.";
        break;
      case "Adult":
      default:
        ageAdvice =
            "Aim for at least 150 active minutes per week with mix of strength and cardio.";
        break;
    }

    return "$base\n\nAge focus: $ageAdvice";
  }

  int estimateTotalCalories() {
    final plan = generatePlan();
    int perSession;
    switch (selectedGoal) {
      case "Muscle Building":
        perSession = 180;
        break;
      case "Fat Loss":
        perSession = 220;
        break;
      case "Maintenance":
      default:
        perSession = 140;
        break;
    }

    if (selectedAge == "Child" || selectedAge == "Older") {
      perSession = (perSession * 0.7).round();
    }

    return plan.length * perSession;
  }

  // -------------------- UI BUILD ----------------------

  @override
  Widget build(BuildContext context) {
    final plan = generatePlan();
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 63, 88, 37),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          setState(() {
            progress = (progress + 0.1).clamp(0, 1);
            if (progress == 1.0) {
              streakDays += 1;
              progress = 0.2; // restart for next cycle
            }
          });
        },
        backgroundColor: Colors.greenAccent.shade700,
        icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        label: const Text(
          "Mark Today's Progress",
          style: TextStyle(color: Colors.white),
        ),
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: const Text(
          "AI Fitness Coach",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            tooltip: "Open Nutrition",
            icon: const Icon(Icons.local_dining),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NutritionScreen()),
              );
            },
          )
        ],
      ),

      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth > 600;

          return SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(size),

                const SizedBox(height: 18),

                _sectionTitle("🤖 AI Recommendation"),
                _aiRecommendationCard(),

                _sectionTitle("🎯 Your Fitness Goal"),
                _chipSelector(goals, selectedGoal, (v) {
                  setState(() {
                    selectedGoal = v;
                  });
                }),

                _sectionTitle("👥 Age Category"),
                _chipSelector(ageGroups, selectedAge, (v) {
                  setState(() {
                    selectedAge = v;
                  });
                }),

                _sectionTitle("📅 Workout Duration"),
                _planSelector(planTypes),

                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            _sectionTitle("📈 Progress & Streak"),
                            _progressAndStreak(),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            _sectionTitle("📊 Weekly Activity"),
                            _weeklyChart(),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  _sectionTitle("📈 Progress & Streak"),
                  _progressAndStreak(),
                  _sectionTitle("📊 Weekly Activity"),
                  _weeklyChart(),
                ],

                _sectionTitle("🔥 Estimated Burn"),
                _caloriesCard(),

                _sectionTitle("🏋️ Exercise Plan"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children: plan.asMap().entries.map((entry) {
                      return _exerciseCard(entry.key, entry.key + 1, entry.value);
                    }).toList(),
                  ),
                ),

                _sectionTitle("🍎 Nutrition Tips"),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: Column(
                    children:
                        nutritionTips.map((tip) => _nutritionTile(tip)).toList(),
                  ),
                ),

                _sectionTitle("💧 Water Tracker"),
                _waterTracker(),

                const SizedBox(height: 90),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------- HEADER ----------------
  Widget _buildHeader(Size size) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 22,
        vertical: size.height * 0.03,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade900,
            Colors.green.shade700,
            Colors.green.shade600
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius:
            const BorderRadius.vertical(bottom: Radius.circular(40)),
      ),
      child: Row(
        children: [
          const Icon(Icons.fitness_center,
              color: Colors.white, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "AI Tip 💡\nControl your reps, breathe out on effort, and keep a steady pace for better results.",
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  // ---------------- SECTION TITLE ----------------
  Widget _sectionTitle(String title) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ---------------- AI RECOMMENDATION CARD ----------------
  Widget _aiRecommendationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          // just for interaction feel – could show a snackbar or dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("AI plan is personalized from your goal & age."),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withOpacity(0.55),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.greenAccent.withOpacity(0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.smart_toy_outlined,
                  color: Colors.greenAccent, size: 26),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  generateAIRecommendation(),
                  style: const TextStyle(color: Colors.white, height: 1.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- CHIP SELECTOR ----------------
  Widget _chipSelector(
      List<String> list, String selected, Function(String) onTap) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        spacing: 10,
        runSpacing: 8,
        children: list
            .map(
              (item) => ChoiceChip(
                label: Text(item),
                selected: selected == item,
                onSelected: (_) => onTap(item),
                selectedColor: Colors.greenAccent.shade700,
                backgroundColor: Colors.green.shade300,
                labelStyle: const TextStyle(color: Colors.white),
              ),
            )
            .toList(),
      ),
    );
  }

  // ---------------- PLAN SELECTOR ----------------
  Widget _planSelector(List<String> plans) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: plans.map((plan) {
        final bool active = selectedPlan == plan;

        return GestureDetector(
          onTap: () {
            setState(() => selectedPlan = plan);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding:
                const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: active
                  ? Colors.greenAccent.shade700
                  : Colors.greenAccent.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.greenAccent.shade100),
            ),
            child: Text(
              plan,
              style: TextStyle(
                color: active ? Colors.white : Colors.greenAccent.shade100,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ---------------- PROGRESS + STREAK ----------------
  Widget _progressAndStreak() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.shade900.withOpacity(0.45),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                color: Colors.greenAccent.shade400,
                backgroundColor: Colors.white24,
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    "${(progress * 100).toStringAsFixed(0)}% of current cycle",
                    style: const TextStyle(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        fontSize: 13),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.local_fire_department,
                        color: Colors.orangeAccent, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      "Streak: $streakDays days",
                      style: const TextStyle(
                          color: Colors.orangeAccent, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- WEEKLY MINI CHART ----------------
  Widget _weeklyChart() {
    final int maxMinutes =
        weeklyMinutes.isEmpty ? 1 : weeklyMinutes.reduce((a, b) => a > b ? a : b);
    final days = ["M", "T", "W", "T", "F", "S", "S"];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(7, (i) {
            final value = i < weeklyMinutes.length ? weeklyMinutes[i] : 0;
            final heightFactor = value == 0 ? 0.02 : value / maxMinutes;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value == 0 ? "-" : "${value}m",
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 11),
                ),
                const SizedBox(height: 4),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 70 * heightFactor,
                  width: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent,
                        Colors.green.shade700,
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  days[i],
                  style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // ---------------- CALORIES CARD ----------------
  Widget _caloriesCard() {
    final total = estimateTotalCalories();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.redAccent.withOpacity(0.22),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.local_fire_department,
                color: Colors.orangeAccent, size: 30),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                "Estimated total burn for this plan:\n≈ $total kcal (rough estimate).",
                style: const TextStyle(color: Colors.white, height: 1.3),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- EXERCISE CARD ----------------
  Widget _exerciseCard(int index, int day, Map<String, dynamic> exercise) {
    final isExpanded = expandedExerciseIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        setState(() {
          if (expandedExerciseIndex == index) {
            expandedExerciseIndex = null;
          } else {
            expandedExerciseIndex = index;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(isExpanded ? 0.12 : 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.greenAccent.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              color: Colors.greenAccent.withOpacity(0.12),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.greenAccent.shade700,
                  child: Icon(exercise["icon"], color: Colors.white),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Day $day · ${exercise['name']}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise["reps"],
                        style: const TextStyle(color: Colors.greenAccent),
                      ),
                    ],
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: Colors.white70,
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "Focus on form, stable breathing and control. "
                  "Rest 30–60 seconds between sets. Stop if you feel pain or dizziness.",
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              crossFadeState: isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- NUTRITION TILE ----------------
  Widget _nutritionTile(String tip) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade700.withOpacity(0.35),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu, color: Colors.orangeAccent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  // ---------------- WATER TRACKER ----------------
  Widget _waterTracker() {
    const int goal = 8;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.blue.shade900.withOpacity(0.4),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            const Icon(Icons.opacity, color: Colors.lightBlueAccent),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Water: $waterGlasses / $goal glasses",
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: List.generate(goal, (i) {
                      final filled = i < waterGlasses;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Icon(
                          Icons.local_drink,
                          size: 18,
                          color: filled
                              ? Colors.lightBlueAccent
                              : Colors.white24,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: "Add 1 glass",
              onPressed: () {
                setState(() {
                  if (waterGlasses < goal) waterGlasses++;
                });
              },
              icon: const Icon(Icons.add_circle_outline,
                  color: Colors.lightBlueAccent),
            )
          ],
        ),
      ),
    );
  }
}
