import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  // ---------------- FILTERS ----------------
  String selectedDay = "Monday";
  String selectedDiet = "Vegetarian";
  String selectedBudget = "Moderate";
  String selectedAgeGroup = "Young Adult (20-30)";

  final List<String> days = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  final List<String> diets = ["Vegetarian", "Non-Vegetarian"];

  final List<String> budgets = ["Poor", "Moderate", "Rich"];

  final List<String> ageGroups = [
    "Child (7-12)",
    "Teen (13-19)",
    "Young Adult (20-30)",
    "Adult (31-50)",
    "Senior (51+)",
  ];

  // ---------------- 7-DAY MEAL DATA ----------------
  // Base vegetarian weekly plan (Moderate budget)
  final Map<String, List<Map<String, String>>> vegModeratePlan = {
    "Monday": [
      {
        "meal": "Breakfast",
        "menu": "Veg poha with peanuts + chai",
        "calories": "320 kcal",
        "portion": "1 medium plate",
      },
      {
        "meal": "Lunch",
        "menu": "2 chapatis, dal tadka, mix veg sabzi, salad",
        "calories": "520 kcal",
        "portion": "Standard thali",
      },
      {
        "meal": "Snack",
        "menu": "1 apple + handful roasted chana",
        "calories": "180 kcal",
        "portion": "1 apple + 1/4 cup",
      },
      {
        "meal": "Dinner",
        "menu": "Jeera rice, rajma, cucumber raita",
        "calories": "480 kcal",
        "portion": "1 plate",
      },
    ],
    "Tuesday": [
      {
        "meal": "Breakfast",
        "menu": "Oats porridge with banana & nuts",
        "calories": "350 kcal",
        "portion": "1 bowl",
      },
      {
        "meal": "Lunch",
        "menu": "Veg pulao with curd & salad",
        "calories": "500 kcal",
        "portion": "1 plate",
      },
      {
        "meal": "Snack",
        "menu": "Buttermilk + 2 khakhra",
        "calories": "160 kcal",
        "portion": "1 glass + 2 pcs",
      },
      {
        "meal": "Dinner",
        "menu": "2 chapatis, chole, onion salad",
        "calories": "470 kcal",
        "portion": "Standard plate",
      },
    ],
    "Wednesday": [
      {
        "meal": "Breakfast",
        "menu": "2 besan chilla + green chutney",
        "calories": "340 kcal",
        "portion": "2 pieces",
      },
      {
        "meal": "Lunch",
        "menu": "Lemon rice + veg raita",
        "calories": "480 kcal",
        "portion": "1 plate",
      },
      {
        "meal": "Snack",
        "menu": "Sprout chaat with onion & tomato",
        "calories": "190 kcal",
        "portion": "1 bowl",
      },
      {
        "meal": "Dinner",
        "menu": "2 chapatis, palak paneer, salad",
        "calories": "500 kcal",
        "portion": "Standard plate",
      },
    ],
    "Thursday": [
      {
        "meal": "Breakfast",
        "menu": "Idli sambar with coconut chutney",
        "calories": "330 kcal",
        "portion": "3 idlis",
      },
      {
        "meal": "Lunch",
        "menu": "Veg biryani + onion raita",
        "calories": "520 kcal",
        "portion": "1 plate",
      },
      {
        "meal": "Snack",
        "menu": "Fruit bowl (seasonal fruits)",
        "calories": "170 kcal",
        "portion": "1 bowl",
      },
      {
        "meal": "Dinner",
        "menu": "2 chapatis, dal fry, bhindi sabzi",
        "calories": "460 kcal",
        "portion": "Standard plate",
      },
    ],
    "Friday": [
      {
        "meal": "Breakfast",
        "menu": "Stuffed aloo paratha + curd",
        "calories": "380 kcal",
        "portion": "1 large paratha",
      },
      {
        "meal": "Lunch",
        "menu": "2 chapatis, methi aloo, dal, salad",
        "calories": "510 kcal",
        "portion": "Standard thali",
      },
      {
        "meal": "Snack",
        "menu": "Masala chai + 4 marie biscuits",
        "calories": "150 kcal",
        "portion": "1 cup + 4 biscuits",
      },
      {
        "meal": "Dinner",
        "menu": "Khichdi + kadhi + papad",
        "calories": "450 kcal",
        "portion": "1 plate",
      },
    ],
    "Saturday": [
      {
        "meal": "Breakfast",
        "menu": "Vegetable upma + chutney",
        "calories": "340 kcal",
        "portion": "1 bowl",
      },
      {
        "meal": "Lunch",
        "menu": "Curd rice + veg poriyal",
        "calories": "480 kcal",
        "portion": "1 plate",
      },
      {
        "meal": "Snack",
        "menu": "Coconut water + handful peanuts",
        "calories": "160 kcal",
        "portion": "1 glass + 1/4 cup",
      },
      {
        "meal": "Dinner",
        "menu": "Grilled veg sandwich + tomato soup",
        "calories": "430 kcal",
        "portion": "2 triangles + 1 bowl",
      },
    ],
    "Sunday": [
      {
        "meal": "Breakfast",
        "menu": "Paneer bhurji toast",
        "calories": "360 kcal",
        "portion": "2 slices",
      },
      {
        "meal": "Lunch",
        "menu": "Paneer tikka, 2 chapatis, salad",
        "calories": "520 kcal",
        "portion": "Standard plate",
      },
      {
        "meal": "Snack",
        "menu": "Bhel (with less sev)",
        "calories": "190 kcal",
        "portion": "1 bowl",
      },
      {
        "meal": "Dinner",
        "menu": "Veg noodles (less oil) + sautéed veggies",
        "calories": "460 kcal",
        "portion": "1 plate",
      },
    ],
  };

  // Base non-veg weekly plan (Moderate budget)
  final Map<String, List<Map<String, String>>> nonVegModeratePlan = {
    "Monday": [
      {
        "meal": "Breakfast",
        "menu": "Boiled eggs (2) + toast + chai",
        "calories": "340 kcal",
        "portion": "2 eggs + 2 slices",
      },
      {
        "meal": "Lunch",
        "menu": "Chicken curry, 2 chapatis, salad",
        "calories": "540 kcal",
        "portion": "Standard plate",
      },
      {
        "meal": "Snack",
        "menu": "Yogurt + fruit bowl",
        "calories": "180 kcal",
        "portion": "1 small bowl",
      },
      {
        "meal": "Dinner",
        "menu": "Grilled fish + sautéed veggies + rice",
        "calories": "500 kcal",
        "portion": "1 fillet + 1/2 plate rice",
      },
    ],
    "Tuesday": [
      {
        "meal": "Breakfast",
        "menu": "Egg bhurji + 2 chapatis",
        "calories": "360 kcal",
        "portion": "1 serving",
      },
      {
        "meal": "Lunch",
        "menu": "Egg curry, 2 chapatis, salad",
        "calories": "520 kcal",
        "portion": "Standard plate",
      },
      {
        "meal": "Snack",
        "menu": "Buttermilk + roasted peanuts",
        "calories": "170 kcal",
        "portion": "1 glass + 1/4 cup",
      },
      {
        "meal": "Dinner",
        "menu": "Chicken rice bowl (less oil)",
        "calories": "490 kcal",
        "portion": "1 bowl",
      },
    ],
    "Wednesday": [
      {
        "meal": "Breakfast",
        "menu": "Omelette (2 egg) + toast",
        "calories": "350 kcal",
        "portion": "1 omelette + 2 slices",
      },
      {
        "meal": "Lunch",
        "menu": "Fish curry + steamed rice + salad",
        "calories": "530 kcal",
        "portion": "1 plate",
      },
      {
        "meal": "Snack",
        "menu": "Sprouts + boiled egg",
        "calories": "200 kcal",
        "portion": "1 bowl + 1 egg",
      },
      {
        "meal": "Dinner",
        "menu": "Grilled chicken wrap + salad",
        "calories": "480 kcal",
        "portion": "1 wrap",
      },
    ],
    "Thursday": [
      {
        "meal": "Breakfast",
        "menu": "Paneer & egg sandwich",
        "calories": "360 kcal",
        "portion": "2 triangles",
      },
      {
        "meal": "Lunch",
        "menu": "Chicken biryani + raita",
        "calories": "550 kcal",
        "portion": "1 plate",
      },
      {
        "meal": "Snack",
        "menu": "Fruit salad with curd",
        "calories": "180 kcal",
        "portion": "1 bowl",
      },
      {
        "meal": "Dinner",
        "menu": "Egg fried rice (less oil) + veggies",
        "calories": "470 kcal",
        "portion": "1 plate",
      },
    ],
    "Friday": [
      {
        "meal": "Breakfast",
        "menu": "Idli, sambar + boiled egg",
        "calories": "340 kcal",
        "portion": "3 idlis + 1 egg",
      },
      {
        "meal": "Lunch",
        "menu": "Egg pulao + salad",
        "calories": "510 kcal",
        "portion": "1 plate",
      },
      {
        "meal": "Snack",
        "menu": "Masala chai + boiled chana",
        "calories": "160 kcal",
        "portion": "1 cup + 1/4 cup",
      },
      {
        "meal": "Dinner",
        "menu": "Fish tikka, 2 chapatis, salad",
        "calories": "490 kcal",
        "portion": "Standard plate",
      },
    ],
    "Saturday": [
      {
        "meal": "Breakfast",
        "menu": "Chicken sandwich (grilled)",
        "calories": "360 kcal",
        "portion": "1 sandwich",
      },
      {
        "meal": "Lunch",
        "menu": "Chicken curry + jeera rice",
        "calories": "540 kcal",
        "portion": "1 plate",
      },
      {
        "meal": "Snack",
        "menu": "Coconut water + handful nuts",
        "calories": "170 kcal",
        "portion": "1 glass + 1/4 cup",
      },
      {
        "meal": "Dinner",
        "menu": "Egg curry + 2 chapatis",
        "calories": "480 kcal",
        "portion": "Standard plate",
      },
    ],
    "Sunday": [
      {
        "meal": "Breakfast",
        "menu": "Cheese omelette + toast",
        "calories": "380 kcal",
        "portion": "1 omelette + 2 slices",
      },
      {
        "meal": "Lunch",
        "menu": "Tandoori chicken + salad + 1 roti",
        "calories": "530 kcal",
        "portion": "1 plate",
      },
      {
        "meal": "Snack",
        "menu": "Chicken soup",
        "calories": "150 kcal",
        "portion": "1 bowl",
      },
      {
        "meal": "Dinner",
        "menu": "Fish curry + rice + salad",
        "calories": "500 kcal",
        "portion": "1 plate",
      },
    ],
  };

  // Diet → Budget → Day → Meals
  final Map<String,
      Map<String, Map<String, List<Map<String, String>>>>> mealPlan = {};

  // ---------------- AI ALTERNATIVES ----------------
  final Map<String, List<String>> aiAlternatives = {
    "Breakfast": [
      "Try adding chia or flax seeds for extra Omega-3.",
      "Swap white bread for multigrain or millet roti.",
      "Add a handful of nuts or seeds for a protein boost.",
    ],
    "Lunch": [
      "Add a bowl of curd or chaas for better digestion.",
      "Replace fried papad with salad or cucumber slices.",
      "Use less oil and include at least 1 katori salad.",
    ],
    "Snack": [
      "Try fruits instead of processed snacks or chips.",
      "Roasted chana or makhana is a great protein snack.",
      "Avoid sugary drinks; choose buttermilk or lemon water.",
    ],
    "Dinner": [
      "Keep dinner lighter for better sleep and digestion.",
      "Add a warm soup or salad before your main meal.",
      "Finish dinner at least 2 hours before sleeping.",
    ],
  };

  // ---------------- GET CURRENT MEALS ----------------
  List<Map<String, String>> get currentMeals {
    return mealPlan[selectedDiet]?[selectedBudget]?[selectedDay] ?? [];
  }

  @override
  void initState() {
    super.initState();

    // Initialize mealPlan structure using base plans
    mealPlan["Vegetarian"] = {
      "Poor": vegModeratePlan,
      "Moderate": vegModeratePlan,
      "Rich": vegModeratePlan,
    };
    mealPlan["Non-Vegetarian"] = {
      "Poor": nonVegModeratePlan,
      "Moderate": nonVegModeratePlan,
      "Rich": nonVegModeratePlan,
    };
  }

  // ---------------- SIMPLE HOVER SCALE ----------------
  Widget hoverScale({required Widget child}) {
    if (!kIsWeb) return child;
    return AnimatedScale(
      scale: 1.02,
      duration: const Duration(milliseconds: 150),
      child: child,
    );
  }

  // ---------------- MEAL DETAIL DIALOG ----------------
  void _showMealDetails(Map<String, String> meal) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                meal["meal"] ?? "",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                meal["menu"] ?? "",
                style: const TextStyle(fontSize: 17),
              ),
              const SizedBox(height: 10),
              Text("Calories: ${meal["calories"] ?? "-"}"),
              Text("Portion: ${meal["portion"] ?? "-"}"),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              )
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- NUTRITION SUMMARY LOGIC ----------------
  Map<String, String> _getNutritionSummary() {
    int calories;
    int protein;
    int carbs;
    int fats;

    // Base calories by age group
    switch (selectedAgeGroup) {
      case "Child (7-12)":
        calories = 1400;
        protein = 40;
        carbs = 170;
        fats = 45;
        break;
      case "Teen (13-19)":
        calories = 1800;
        protein = 55;
        carbs = 220;
        fats = 55;
        break;
      case "Young Adult (20-30)":
        calories = 2000;
        protein = 65;
        carbs = 240;
        fats = 60;
        break;
      case "Adult (31-50)":
        calories = 1900;
        protein = 60;
        carbs = 230;
        fats = 58;
        break;
      case "Senior (51+)":
      default:
        calories = 1700;
        protein = 55;
        carbs = 210;
        fats = 52;
        break;
    }

    // Adjustment by diet type
    if (selectedDiet == "Non-Vegetarian") {
      protein += 10;
      calories += 80;
    }

    // Adjustment by budget (approx food richness / portion variation)
    if (selectedBudget == "Poor") {
      calories -= 100;
      protein -= 5;
    } else if (selectedBudget == "Rich") {
      calories += 100;
      fats += 5;
    }

    return {
      "calories": "$calories kcal",
      "protein": "${protein}g",
      "carbs": "${carbs}g",
      "fats": "${fats}g",
    };
  }

  // ---------------- BUILD ----------------
  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;
    final summary = _getNutritionSummary();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 164, 40),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.deepOrange,
        title: const Text(
          "AI Diet Coach",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------- HERO (N2) ----------------
                Container(
                  height: isWide ? 260 : 230,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade700, Colors.deepOrange],
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Your AI Diet Coach",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "7-day meal planning tuned to your age, diet style and budget.\n"
                              "Healthy eating made simple, local and realistic.",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 12,
                              runSpacing: 8,
                              children: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 255, 255, 255),
                                  ),
                                  onPressed: () {
                                    // Later: connect to AI plan screen
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "AI meal plan generator coming soon."),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    "Generate AI Meal Plan",
                                    style: TextStyle(color: Colors.orange),
                                  ),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    side:
                                        const BorderSide(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    // Jump to current weekday
                                    final weekday =
                                        DateTime.now().weekday; // 1=Mon..7=Sun
                                    setState(() {
                                      selectedDay = days[weekday - 1];
                                    });
                                  },
                                  child: const Text(
                                    "View Today’s Meals",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Plan for: $selectedAgeGroup • $selectedDiet • $selectedBudget budget",
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      if (isWide)
                        SizedBox(
                          width: 200,
                          child: Image.asset(
                            "assets/images/nutrition_banner.png",
                            fit: BoxFit.contain,
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------- FILTERS ----------------
                const Text(
                  "Personalize Your Plan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _labeledFilter(
                      "Day",
                      _chipFilter(days, selectedDay, (v) {
                        setState(() => selectedDay = v);
                      }),
                    ),
                    _labeledFilter(
                      "Age Group",
                      _chipFilter(ageGroups, selectedAgeGroup, (v) {
                        setState(() => selectedAgeGroup = v);
                      }),
                    ),
                    _labeledFilter(
                      "Diet Type",
                      _chipFilter(diets, selectedDiet, (v) {
                        setState(() => selectedDiet = v);
                      }),
                    ),
                    _labeledFilter(
                      "Budget",
                      _chipFilter(budgets, selectedBudget, (v) {
                        setState(() => selectedBudget = v);
                      }),
                    ),
                  ],
                ),

                const SizedBox(height: 26),

                // ---------------- NUTRITION SUMMARY ----------------
                const Text(
                  "Nutrition Summary (Approx for the Day)",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 14),
                _nutritionSummary(summary),

                const SizedBox(height: 30),

                // ---------------- MEAL PLANNER ----------------
                Text(
                  "Today's Meal Plan - $selectedDay",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  "Balanced meals planned for $selectedAgeGroup, $selectedDiet and $selectedBudget budget.",
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
                const SizedBox(height: 14),

                if (currentMeals.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).cardColor,
                    ),
                    child: const Text(
                      "No meals found for this combination. Try another day or change filters.",
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: currentMeals.length,
                    itemBuilder: (_, i) {
                      final meal = currentMeals[i];
                      return hoverScale(
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            onTap: () => _showMealDetails(meal),
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.orange.shade200,
                              child: Text(
                                (meal["meal"] ?? "?").substring(0, 1),
                              ),
                            ),
                            title: Text(
                              meal["meal"] ?? "",
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "${meal['menu']} • ${meal['calories']} • Portion: ${meal['portion']}",
                            ),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 14),
                          ),
                        ),
                      );
                    },
                  ),

                const SizedBox(height: 32),

                // ---------------- AI ALTERNATIVES ----------------
                const Text(
                  "AI Suggested Alternatives",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: aiAlternatives.entries.map((entry) {
                    return hoverScale(
                      child: Container(
                        width: isWide ? 330 : double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Theme.of(context).cardColor,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              entry.key,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 6),
                            for (final tip in entry.value)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text("• $tip"),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 30),

                // ---------------- SMART TOOLS ----------------
                const Text(
                  "Smart Nutrition Tools",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),

                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _toolCard(
                        icon: Icons.smart_toy,
                        title: "AI Coach",
                        desc: "Ask any food or habit question instantly.",
                      ),
                      _toolCard(
                        icon: Icons.water_drop,
                        title: "Hydration Guide",
                        desc:
                            "Daily water goal based on your weight & activity.",
                      ),
                      _toolCard(
                        icon: Icons.monitor_weight,
                        title: "Calorie Calculator",
                        desc: "Estimate maintenance and fat-loss calories.",
                      ),
                      _toolCard(
                        icon: Icons.bar_chart,
                        title: "Weight Tracker",
                        desc: "Log progress weekly and see trends.",
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- FILTER CHIP HELPERS ----------------
  Widget _chipFilter(
    List<String> options,
    String selected,
    Function(String) onSelect,
  ) {
    return Wrap(
      children: [
        for (final opt in options)
          Padding(
            padding: const EdgeInsets.only(right: 8, bottom: 8),
            child: ChoiceChip(
              label: Text(opt),
              selected: selected == opt,
              selectedColor: Colors.orange.shade300,
              onSelected: (_) => onSelect(opt),
            ),
          ),
      ],
    );
  }

  Widget _labeledFilter(String label, Widget child) {
    return SizedBox(
      width: 260,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style:
                const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          child,
        ],
      ),
    );
  }

  // ---------------- NUTRITION SUMMARY WIDGET ----------------
  Widget _nutritionSummary(Map<String, String> summary) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Theme.of(context).cardColor,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NutriItem("Calories", summary["calories"] ?? "-"),
          _NutriItem("Protein", summary["protein"] ?? "-"),
          _NutriItem("Carbs", summary["carbs"] ?? "-"),
          _NutriItem("Fats", summary["fats"] ?? "-"),
        ],
      ),
    );
  }

  // ---------------- TOOL CARD ----------------
  Widget _toolCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return hoverScale(
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 34, color: Colors.orange),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- SMALL REUSABLE ----------------
class _NutriItem extends StatelessWidget {
  final String label;
  final String value;

  const _NutriItem(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
      ],
    );
  }
}
