import 'package:flutter/material.dart';
import 'nutrition_screen.dart';

class FitnessScreen extends StatefulWidget {
  const FitnessScreen({super.key});

  @override
  State<FitnessScreen> createState() => _FitnessScreenState();
}

class _FitnessScreenState extends State<FitnessScreen> {
  String selectedPlan = "Day"; // Day / Week / Month
  String selectedAge = "Adult"; // Child, Young, Adult, Older
  String selectedGoal = "Muscle Building"; // Muscle Building, Fat Loss, Maintenance

  double progress = 0.4; // Example tracker

  // Base exercises
  final Map<String, List<Map<String, dynamic>>> exercisesByGoal = {
    "Muscle Building": [
      {"name": "Push-ups", "reps": "3x15", "icon": Icons.fitness_center},
      {"name": "Squats", "reps": "3x20", "icon": Icons.accessibility_new},
      {"name": "Plank", "reps": "3x60s", "icon": Icons.self_improvement},
      {"name": "Bicep Curl", "reps": "3x12", "icon": Icons.sports_mma},
    ],
    "Fat Loss": [
      {"name": "Jumping Jacks", "reps": "3x25", "icon": Icons.directions_run},
      {"name": "Burpees", "reps": "3x12", "icon": Icons.fitness_center},
      {"name": "Mountain Climbers", "reps": "3x20", "icon": Icons.terrain},
      {"name": "High Knees", "reps": "3x30s", "icon": Icons.directions_walk},
    ],
    "Maintenance": [
      {"name": "Yoga", "reps": "15min", "icon": Icons.self_improvement},
      {"name": "Walking", "reps": "30min", "icon": Icons.directions_walk},
      {"name": "Stretching", "reps": "10min", "icon": Icons.accessibility},
      {"name": "Plank", "reps": "3x60s", "icon": Icons.sports_gymnastics},
    ],
  };

  final List<String> nutritionTips = [
    "🥗 Eat balanced meals with protein, carbs, and fats.",
    "💧 Drink at least 2 liters of water daily.",
    "🍎 Include fruits, vegetables, and whole grains.",
    "🥜 Snack on nuts instead of junk food.",
  ];

  // Algorithm to generate the plan dynamically
  List<Map<String, dynamic>> generatePlan() {
    List<Map<String, dynamic>> baseExercises = exercisesByGoal[selectedGoal]!;

    // Adjust intensity by age
    if (selectedAge == "Child") {
      baseExercises = baseExercises.map((e) {
        return {...e, "reps": "Low intensity for children"};
      }).toList();
    } else if (selectedAge == "Older") {
      baseExercises = baseExercises.map((e) {
        return {...e, "reps": "Gentle version for seniors"};
      }).toList();
    }

    // Adjust duration by plan
    switch (selectedPlan) {
      case "Day":
        return baseExercises.take(3).toList();
      case "Week":
        return List.generate(7, (i) => baseExercises[i % baseExercises.length]);
      case "Month":
        return List.generate(30, (i) => baseExercises[i % baseExercises.length]);
      default:
        return baseExercises;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> currentPlan = generatePlan();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("AI Fitness Planner"),
        backgroundColor: Colors.green[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.local_dining),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NutritionScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Tip Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.green.shade400, Colors.green.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.white, size: 40),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "AI Tip 💡: Maintain proper breathing and posture to get maximum results!",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Goal Selector
            const Text(
              "🎯 Select Goal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: ["Muscle Building", "Fat Loss", "Maintenance"]
                  .map((goal) => ChoiceChip(
                        label: Text(goal),
                        selected: selectedGoal == goal,
                        onSelected: (_) {
                          setState(() => selectedGoal = goal);
                        },
                        selectedColor: Colors.green[400],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Age Selector
            const Text(
              "👥 Select Age Group",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: ["Child", "Young", "Adult", "Older"]
                  .map((age) => ChoiceChip(
                        label: Text(age),
                        selected: selectedAge == age,
                        onSelected: (_) {
                          setState(() => selectedAge = age);
                        },
                        selectedColor: Colors.green[400],
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Plan Selector
            const Text(
              "📅 Select Plan Duration",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["7 days", "15 days", "30 days "]
                  .map((plan) => ElevatedButton(
                        onPressed: () {
                          setState(() => selectedPlan = plan);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: selectedPlan == plan
                                ? Colors.green[600]
                                : Colors.green[300],
                            shape: const StadiumBorder()),
                        child: Text(plan),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            // Progress Tracker
            const Text(
              "📈 Progress Tracker",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.green[100],
              color: Colors.green[700],
              minHeight: 10,
              borderRadius: BorderRadius.circular(10),
            ),
            const SizedBox(height: 10),
            Text(
              "Your progress: ${(progress * 100).toStringAsFixed(0)}%",
              style: TextStyle(color: Colors.grey[800]),
            ),
            const SizedBox(height: 20),

            // Exercise Plan
            const Text(
              "🏋️‍♂️ Your Exercise Plan",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: currentPlan.length,
              itemBuilder: (context, index) {
                var exercise = currentPlan[index];
                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  child: ExpansionTile(
                    leading: Icon(exercise["icon"], color: Colors.green[700]),
                    title: Text(
                      exercise["name"],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(exercise["reps"]),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Text(
                          "✔️ Instructions: Focus on proper form and control. Rest 30-60 seconds between sets.\n💪 Benefit: Improves strength and endurance.",
                          style: TextStyle(color: Colors.grey[800]),
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 20),

            // Nutrition Section
            const Text(
              "🍎 Nutrition Tips",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...nutritionTips.map((tip) => Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15)),
                  color: Colors.orange[100],
                  child: ListTile(
                    leading: Icon(Icons.restaurant_menu,
                        color: Colors.orange[700]),
                    title: Text(tip),
                  ),
                )),
            const SizedBox(height: 40),

            // Completion Tracker Button
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    progress = (progress + 0.1).clamp(0.0, 1.0);
                  });
                },
                icon: const Icon(Icons.check_circle_outline),
                label: const Text("Mark Today's Progress"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  shape: const StadiumBorder(),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
