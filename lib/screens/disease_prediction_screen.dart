import 'package:flutter/material.dart';

class DiseasePredictionScreen extends StatelessWidget {
  const DiseasePredictionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("AI Health Prediction"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _headerCard(),
            const SizedBox(height: 20),

            _riskRings(),

            const SizedBox(height: 20),

            _questionnaireButton(context),

            const SizedBox(height: 20),

            _aiInsightCard(),

            const SizedBox(height: 20),

            _tipsCard(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _headerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            "Early Detection Matters 🧬",
            style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255), fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            "Your daily lifestyle + habits + metrics help predict risks early. "
            "AI constantly learns from your patterns.",
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _riskRings() {
    final risks = [
      {"name": "Heart Health", "value": 0.64, "color": Colors.red},
      {"name": "Diabetes", "value": 0.52, "color": Colors.orange},
      {"name": "Stress", "value": 0.70, "color": Colors.deepPurple},
      {"name": "Sleep Quality", "value": 0.58, "color": Colors.blue},
    ];

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Risk Overview", style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: risks
                  .map((r) => _ring(
                        r["name"] as String,
                        r["value"] as double,
                        r["color"] as Color,
                      ))
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget _ring(String label, double percent, Color color) {
    return SizedBox(
      width: 160,
      child: Column(
        children: [
          Stack(alignment: Alignment.center, children: [
            SizedBox(
              width: 90,
              height: 90,
              child: CircularProgressIndicator(
                value: percent,
                strokeWidth: 8,
                color: color,
              ),
            ),
            Text(
              "${(percent * 100).round()}%",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
          ]),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _questionnaireButton(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const _QuestionnaireScreen()),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: const Icon(Icons.health_and_safety),
      label: const Text("Complete Health Questionnaire"),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _aiInsightCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("AI Early Insights",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              "• Sleep recovery is slightly low this week.\n"
              "• Stress levels have increased based on your focus sessions.\n"
              "• You may be at mild risk for fatigue & burnout.\n"
              "• Consider adjusting bedtime + hydration.",
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _tipsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Recommended Improvements",
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Text(
              "• Drink 2.5–3L water daily\n"
              "• Reduce sugar intake\n"
              "• Sleep before 11 PM\n"
              "• 20 minutes daily walk\n"
              "• Practice gratitude journaling 5 min/day",
              style: TextStyle(color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//  QUESTIONNAIRE INPUT PAGE (For ML Intake)
// ---------------------------------------------------------------------------

class _QuestionnaireScreen extends StatefulWidget {
  const _QuestionnaireScreen();

  @override
  State<_QuestionnaireScreen> createState() => __QuestionnaireScreenState();
}

class __QuestionnaireScreenState extends State<_QuestionnaireScreen> {
  final ageController = TextEditingController();
  final weightController = TextEditingController();
  final heightController = TextEditingController();
  String gender = "Male";

  bool hasDiabetes = false;
  bool hasBP = false;
  bool smokes = false;
  bool drinks = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Health Questionnaire"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          _input("Age", ageController),
          _input("Weight (kg)", weightController),
          _input("Height (cm)", heightController),

          const SizedBox(height: 16),
          _genderSection(),
          const SizedBox(height: 16),
          _checkbox("Diabetes", (v) => setState(() => hasDiabetes = v)),
          _checkbox("High Blood Pressure", (v) => setState(() => hasBP = v)),
          _checkbox("Smoking", (v) => setState(() => smokes = v)),
          _checkbox("Alcohol Consumption", (v) => setState(() => drinks = v)),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Responses saved for AI prediction!")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 30),
            ),
            child: const Text("Save & Return"),
          ),
        ]),
      ),
    );
  }

  Widget _input(String label, TextEditingController controller) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Widget _genderSection() {
    return Row(
      children: [
        const Text("Gender:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(width: 20),
        DropdownButton(
          value: gender,
          items: const [
            DropdownMenuItem(value: "Male", child: Text("Male")),
            DropdownMenuItem(value: "Female", child: Text("Female")),
          ],
          onChanged: (v) => setState(() => gender = v.toString()),
        ),
      ],
    );
  }

  Widget _checkbox(String text, Function(bool) onChanged) {
    return CheckboxListTile(
      value: text == "Diabetes"
          ? hasDiabetes
          : text == "High Blood Pressure"
              ? hasBP
              : text == "Smoking"
                  ? smokes
                  : drinks,
      onChanged: (v) => onChanged(v!),
      title: Text(text),
    );
  }
}
