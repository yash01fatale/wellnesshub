import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  // Filters
  String selectedDay = "Monday";
  String selectedDiet = "Vegetarian";
  String selectedBudget = "Moderate";

  final List<String> days = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"];
  final List<String> diets = ["Vegetarian", "Non-Vegetarian"];
  final List<String> budgets = ["Poor", "Moderate", "Rich"];

  // Offline Meals Data for all 7 days
  final Map<String, Map<String, Map<String, List<Map<String, String>>>>> mealPlan = {
    "Vegetarian": {
      "Poor": {
        "Monday": [
          {"meal": "Breakfast", "menu": "Oatmeal + Banana", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Rice + Dal + Veggies", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Peanut Chikki", "calories": "150 kcal", "portion": "2 pieces"},
          {"meal": "Dinner", "menu": "Roti + Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Tuesday": [
          {"meal": "Breakfast", "menu": "Poha + Green Tea", "calories": "250 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Chapati + Sabzi + Salad", "calories": "550 kcal", "portion": "2 chapati + 1 bowl sabzi"},
          {"meal": "Snack", "menu": "Fruit Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Vegetable Pulao + Raita", "calories": "450 kcal", "portion": "1 plate"},
        ],
        "Wednesday": [
          {"meal": "Breakfast", "menu": "Upma + Coconut Chutney", "calories": "300 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Veg Sandwich + Soup", "calories": "500 kcal", "portion": "1 sandwich + 1 bowl soup"},
          {"meal": "Snack", "menu": "Roasted Chickpeas", "calories": "200 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Paneer Curry + Roti", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Thursday": [
          {"meal": "Breakfast", "menu": "Dalia + Milk", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Veg Biryani + Raita", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts Mix", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Friday": [
          {"meal": "Breakfast", "menu": "Idli + Sambar", "calories": "300 kcal", "portion": "2 idlis + 1 bowl sambar"},
          {"meal": "Lunch", "menu": "Chole + Rice", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Sprouts Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Roti + Bhindi Sabzi", "calories": "400 kcal", "portion": "2 rotis + 1 bowl bhindi"},
        ],
        "Saturday": [
          {"meal": "Breakfast", "menu": "Bread + Peanut Butter + Banana", "calories": "350 kcal", "portion": "2 slices"},
          {"meal": "Lunch", "menu": "Veg Pasta", "calories": "550 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Fruit Smoothie", "calories": "200 kcal", "portion": "1 glass"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Sunday": [
          {"meal": "Breakfast", "menu": "Pancakes + Honey", "calories": "350 kcal", "portion": "2 pancakes"},
          {"meal": "Lunch", "menu": "Vegetable Khichdi", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts + Dates", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Paneer Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
      },
      "Moderate": {
        "Monday": [
          {"meal": "Breakfast", "menu": "Oatmeal + Banana", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Rice + Dal + Veggies", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Peanut Chikki", "calories": "150 kcal", "portion": "2 pieces"},
          {"meal": "Dinner", "menu": "Roti + Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Tuesday": [
          {"meal": "Breakfast", "menu": "Poha + Green Tea", "calories": "250 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Chapati + Sabzi + Salad", "calories": "550 kcal", "portion": "2 chapati + 1 bowl sabzi"},
          {"meal": "Snack", "menu": "Fruit Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Vegetable Pulao + Raita", "calories": "450 kcal", "portion": "1 plate"},
        ],
        "Wednesday": [
          {"meal": "Breakfast", "menu": "Upma + Coconut Chutney", "calories": "300 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Veg Sandwich + Soup", "calories": "500 kcal", "portion": "1 sandwich + 1 bowl soup"},
          {"meal": "Snack", "menu": "Roasted Chickpeas", "calories": "200 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Paneer Curry + Roti", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Thursday": [
          {"meal": "Breakfast", "menu": "Dalia + Milk", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Veg Biryani + Raita", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts Mix", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Friday": [
          {"meal": "Breakfast", "menu": "Idli + Sambar", "calories": "300 kcal", "portion": "2 idlis + 1 bowl sambar"},
          {"meal": "Lunch", "menu": "Chole + Rice", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Sprouts Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Roti + Bhindi Sabzi", "calories": "400 kcal", "portion": "2 rotis + 1 bowl bhindi"},
        ],
        "Saturday": [
          {"meal": "Breakfast", "menu": "Bread + Peanut Butter + Banana", "calories": "350 kcal", "portion": "2 slices"},
          {"meal": "Lunch", "menu": "Veg Pasta", "calories": "550 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Fruit Smoothie", "calories": "200 kcal", "portion": "1 glass"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Sunday": [
          {"meal": "Breakfast", "menu": "Pancakes + Honey", "calories": "350 kcal", "portion": "2 pancakes"},
          {"meal": "Lunch", "menu": "Vegetable Khichdi", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts + Dates", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Paneer Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        // Add similar structure for all 7 days...
      },
      "Rich": {
        "Monday": [
          {"meal": "Breakfast", "menu": "Oatmeal + Banana", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Rice + Dal + Veggies", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Peanut Chikki", "calories": "150 kcal", "portion": "2 pieces"},
          {"meal": "Dinner", "menu": "Roti + Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Tuesday": [
          {"meal": "Breakfast", "menu": "Poha + Green Tea", "calories": "250 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Chapati + Sabzi + Salad", "calories": "550 kcal", "portion": "2 chapati + 1 bowl sabzi"},
          {"meal": "Snack", "menu": "Fruit Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Vegetable Pulao + Raita", "calories": "450 kcal", "portion": "1 plate"},
        ],
        "Wednesday": [
          {"meal": "Breakfast", "menu": "Upma + Coconut Chutney", "calories": "300 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Veg Sandwich + Soup", "calories": "500 kcal", "portion": "1 sandwich + 1 bowl soup"},
          {"meal": "Snack", "menu": "Roasted Chickpeas", "calories": "200 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Paneer Curry + Roti", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Thursday": [
          {"meal": "Breakfast", "menu": "Dalia + Milk", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Veg Biryani + Raita", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts Mix", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Friday": [
          {"meal": "Breakfast", "menu": "Idli + Sambar", "calories": "300 kcal", "portion": "2 idlis + 1 bowl sambar"},
          {"meal": "Lunch", "menu": "Chole + Rice", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Sprouts Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Roti + Bhindi Sabzi", "calories": "400 kcal", "portion": "2 rotis + 1 bowl bhindi"},
        ],
        "Saturday": [
          {"meal": "Breakfast", "menu": "Bread + Peanut Butter + Banana", "calories": "350 kcal", "portion": "2 slices"},
          {"meal": "Lunch", "menu": "Veg Pasta", "calories": "550 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Fruit Smoothie", "calories": "200 kcal", "portion": "1 glass"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Sunday": [
          {"meal": "Breakfast", "menu": "Pancakes + Honey", "calories": "350 kcal", "portion": "2 pancakes"},
          {"meal": "Lunch", "menu": "Vegetable Khichdi", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts + Dates", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Paneer Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        // Add similar structure for all 7 days...
      },
    },
    "Non-Vegetarian": {
      "Poor": {
        "Monday": [
          {"meal": "Breakfast", "menu": "Oatmeal + Banana", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Rice + Dal + Veggies", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Peanut Chikki", "calories": "150 kcal", "portion": "2 pieces"},
          {"meal": "Dinner", "menu": "Roti + Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Tuesday": [
          {"meal": "Breakfast", "menu": "Poha + Green Tea", "calories": "250 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Chapati + Sabzi + Salad", "calories": "550 kcal", "portion": "2 chapati + 1 bowl sabzi"},
          {"meal": "Snack", "menu": "Fruit Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Vegetable Pulao + Raita", "calories": "450 kcal", "portion": "1 plate"},
        ],
        "Wednesday": [
          {"meal": "Breakfast", "menu": "Upma + Coconut Chutney", "calories": "300 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Veg Sandwich + Soup", "calories": "500 kcal", "portion": "1 sandwich + 1 bowl soup"},
          {"meal": "Snack", "menu": "Roasted Chickpeas", "calories": "200 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Paneer Curry + Roti", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Thursday": [
          {"meal": "Breakfast", "menu": "Dalia + Milk", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Veg Biryani + Raita", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts Mix", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Friday": [
          {"meal": "Breakfast", "menu": "Idli + Sambar", "calories": "300 kcal", "portion": "2 idlis + 1 bowl sambar"},
          {"meal": "Lunch", "menu": "Chole + Rice", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Sprouts Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Roti + Bhindi Sabzi", "calories": "400 kcal", "portion": "2 rotis + 1 bowl bhindi"},
        ],
        "Saturday": [
          {"meal": "Breakfast", "menu": "Bread + Peanut Butter + Banana", "calories": "350 kcal", "portion": "2 slices"},
          {"meal": "Lunch", "menu": "Veg Pasta", "calories": "550 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Fruit Smoothie", "calories": "200 kcal", "portion": "1 glass"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Sunday": [
          {"meal": "Breakfast", "menu": "Pancakes + Honey", "calories": "350 kcal", "portion": "2 pancakes"},
          {"meal": "Lunch", "menu": "Vegetable Khichdi", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts + Dates", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Paneer Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        // Add all 7 days here...
      },
      "Moderate": {
        "Monday": [
          {"meal": "Breakfast", "menu": "Oatmeal + Banana", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Rice + Dal + Veggies", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Peanut Chikki", "calories": "150 kcal", "portion": "2 pieces"},
          {"meal": "Dinner", "menu": "Roti + Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Tuesday": [
          {"meal": "Breakfast", "menu": "Poha + Green Tea", "calories": "250 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Chapati + Sabzi + Salad", "calories": "550 kcal", "portion": "2 chapati + 1 bowl sabzi"},
          {"meal": "Snack", "menu": "Fruit Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Vegetable Pulao + Raita", "calories": "450 kcal", "portion": "1 plate"},
        ],
        "Wednesday": [
          {"meal": "Breakfast", "menu": "Upma + Coconut Chutney", "calories": "300 kcal", "portion": "1 plate"},
          {"meal": "Lunch", "menu": "Veg Sandwich + Soup", "calories": "500 kcal", "portion": "1 sandwich + 1 bowl soup"},
          {"meal": "Snack", "menu": "Roasted Chickpeas", "calories": "200 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Paneer Curry + Roti", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Thursday": [
          {"meal": "Breakfast", "menu": "Dalia + Milk", "calories": "300 kcal", "portion": "1 bowl"},
          {"meal": "Lunch", "menu": "Veg Biryani + Raita", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts Mix", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "400 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Friday": [
          {"meal": "Breakfast", "menu": "Idli + Sambar", "calories": "300 kcal", "portion": "2 idlis + 1 bowl sambar"},
          {"meal": "Lunch", "menu": "Chole + Rice", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Sprouts Salad", "calories": "150 kcal", "portion": "1 bowl"},
          {"meal": "Dinner", "menu": "Roti + Bhindi Sabzi", "calories": "400 kcal", "portion": "2 rotis + 1 bowl bhindi"},
        ],
        "Saturday": [
          {"meal": "Breakfast", "menu": "Bread + Peanut Butter + Banana", "calories": "350 kcal", "portion": "2 slices"},
          {"meal": "Lunch", "menu": "Veg Pasta", "calories": "550 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Fruit Smoothie", "calories": "200 kcal", "portion": "1 glass"},
          {"meal": "Dinner", "menu": "Roti + Mixed Veg Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
        "Sunday": [
          {"meal": "Breakfast", "menu": "Pancakes + Honey", "calories": "350 kcal", "portion": "2 pancakes"},
          {"meal": "Lunch", "menu": "Vegetable Khichdi", "calories": "600 kcal", "portion": "1 plate"},
          {"meal": "Snack", "menu": "Nuts + Dates", "calories": "200 kcal", "portion": "1 small handful"},
          {"meal": "Dinner", "menu": "Roti + Paneer Curry", "calories": "450 kcal", "portion": "2 rotis + 1 bowl curry"},
        ],
      
      },
      "Rich": {
          // Add all 7 days here...
      },
    },
  };

  List<Map<String, String>> get currentMeals {
    return mealPlan[selectedDiet]?[selectedBudget]?[selectedDay] ?? [];
  }

  void _showMealDetails(Map<String, String> meal) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Colors.orangeAccent, Colors.orange],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(meal["meal"]!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 10),
              Text(meal["menu"]!, style: const TextStyle(fontSize: 18, color: Colors.white70)),
              const SizedBox(height: 10),
              Text("Calories: ${meal["calories"]}", style: const TextStyle(color: Colors.white70)),
              Text("Portion: ${meal["portion"]}", style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Nutrition AI"),
        backgroundColor: Colors.orange[700],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filters
            Row(
              children: [
                Expanded(
                  child: _buildDropdown("Day", selectedDay, days, (val) {
                    setState(() {
                      selectedDay = val!;
                    });
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown("Diet", selectedDiet, diets, (val) {
                    setState(() {
                      selectedDiet = val!;
                    });
                  }),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildDropdown("Budget", selectedBudget, budgets, (val) {
                    setState(() {
                      selectedBudget = val!;
                    });
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // AI Tip Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 3,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    colors: [Colors.orangeAccent, Colors.orange],
                  ),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "💡 AI Tip: Adjust portions based on your activity level today!",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: Lottie.asset(
                        "assets/lottie/water.json",
                        fit: BoxFit.contain,
                        repeat: true,
                        animate: true,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.local_drink, size: 50, color: Colors.white);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Meals List
            Expanded(
              child: ListView.builder(
                itemCount: currentMeals.length,
                itemBuilder: (context, index) {
                  final meal = currentMeals[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: CircleAvatar(
                        backgroundColor: Colors.orange[300],
                        child: Text(meal["meal"]![0]),
                      ),
                      title: Text(
                        meal["meal"]!,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${meal["menu"]} • ${meal["calories"]} • Portion: ${meal["portion"]}",
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () => _showMealDetails(meal),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String currentValue, List<String> options, ValueChanged<String?> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange),
      ),
      child: DropdownButton<String>(
        value: currentValue,
        underline: const SizedBox(),
        isExpanded: true,
        items: options.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }
}
