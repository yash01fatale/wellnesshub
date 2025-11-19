import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AIPersonalPlanScreen extends StatefulWidget {
  const AIPersonalPlanScreen({super.key});

  @override
  State<AIPersonalPlanScreen> createState() => _AIPersonalPlanScreenState();
}

class _AIPersonalPlanScreenState extends State<AIPersonalPlanScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;

  // Mock AI plan data — replace with real model output later
  Map<String, dynamic> aiPlan = {
    "summary":
        "Your personalized wellness plan is optimized based on your sleep, nutrition, stress, and activity trends.",
    "goals": {
      "nutrition": 0.72,
      "fitness": 0.65,
      "sleep": 0.80,
      "mental": 0.58,
      "spiritual": 0.70,
    },
    "microHabits": [
      "Drink 300ml water after waking",
      "Sunlight for 10 minutes",
      "5 deep breaths every 3 hours",
      "Evening walk for 15 minutes",
    ]
  };

  @override
  void initState() {
    super.initState();

    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    _anim.forward();
  }

  void _regeneratePlan() {
    setState(() {
      // TODO: Call your ML API here
      aiPlan["summary"] =
          "Your plan was updated based on your latest activity and sleep patterns.";
      aiPlan["microHabits"].shuffle();
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text("Plan regenerated using AI.")));
  }

  Widget _goalRing(String label, double value, Color color) {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                color: color,
              ),
              Text("${(value * 100).round()}%",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16))
            ]),
          ),
          const SizedBox(height: 6),
          Text(label),
        ],
      ),
    );
  }

  Widget _timelineTile(String time, String task, IconData icon) {
    return Row(
      children: [
        Column(
          children: [
            const SizedBox(height: 4),
            Text(time, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
            child: ListTile(
              leading: Icon(icon, color: Colors.deepPurple),
              title: Text(task),
            ),
          ),
        )
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(title,
        style: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold));
  }

  Widget _miniCard(String title, String subtitle, IconData icon) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(children: [
          CircleAvatar(
              backgroundColor: Colors.deepPurple.shade50,
              child: Icon(icon, color: Colors.deepPurple)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(subtitle, style: const TextStyle(color: Colors.black54))
              ],
            ),
          )
        ]),
      ),
    );
  }

  Widget _weeklyGoalChart() {
    return SizedBox(
      height: 150,
      child: LineChart(LineChartData(
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(),
          topTitles: AxisTitles(),
          rightTitles: AxisTitles(),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
              return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(days[v.toInt()],
                      style: const TextStyle(fontSize: 11)));
            },
          )),
        ),
        gridData: FlGridData(show: false),
        minY: 0,
        maxY: 1,
        lineBarsData: [
          LineChartBarData(
              isCurved: true,
              color: Colors.deepPurple,
              belowBarData: BarAreaData(
                  show: true,
                  color: Colors.deepPurple.withOpacity(0.12)),
              spots: const [
                FlSpot(0, 0.60),
                FlSpot(1, 0.72),
                FlSpot(2, 0.69),
                FlSpot(3, 0.75),
                FlSpot(4, 0.78),
                FlSpot(5, 0.72),
                FlSpot(6, 0.80),
              ])
        ],
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
          backgroundColor: Colors.deepPurple,
          title: const Text("AI Personalized Plan")),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _regeneratePlan,
        backgroundColor: Colors.deepPurple,
        label: const Text("Regenerate Plan"),
        icon: const Icon(Icons.refresh),
      ),

      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Summary Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(aiPlan["summary"],
                    style: const TextStyle(fontSize: 15)),
              ),
            ),

            const SizedBox(height: 20),

            _sectionTitle("Your Goal Rings"),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _goalRing("Nutrition", aiPlan["goals"]["nutrition"],
                    Colors.orange),
                _goalRing("Fitness", aiPlan["goals"]["fitness"],
                    Colors.green),
                _goalRing("Sleep", aiPlan["goals"]["sleep"], Colors.indigo),
                _goalRing("Mental", aiPlan["goals"]["mental"],
                    Colors.blueGrey),
                _goalRing("Spiritual", aiPlan["goals"]["spiritual"],
                    Colors.purple),
              ],
            ),

            const SizedBox(height: 20),

            _sectionTitle("Your Daily Routine"),
            const SizedBox(height: 12),

            _timelineTile("6:30 AM", "Wake up + hydration + sunlight",
                Icons.light_mode),
            _timelineTile("8:00 AM", "Healthy breakfast + supplements",
                Icons.restaurant),
            _timelineTile("1:00 PM", "Balanced lunch + walk",
                Icons.lunch_dining),
            _timelineTile("6:00 PM", "Workout / yoga", Icons.fitness_center),
            _timelineTile("10:30 PM", "Sleep routine + digital detox",
                Icons.bedtime),

            const SizedBox(height: 20),

            _sectionTitle("Key Recommendations"),
            const SizedBox(height: 12),

            _miniCard("Nutrition",
                "High fiber • 80–100g protein • Avoid sugar", Icons.apple),
            _miniCard("Fitness",
                "10 min HIIT • 3× strength • 10k steps", Icons.fitness_center),
            _miniCard("Mental",
                "Daily journaling • 5 min breathing", Icons.psychology),
            _miniCard("Spiritual",
                "Affirmations • gratitude journaling", Icons.spa),
            _miniCard("Sleep", "8 hours • limit screens 30 min before",
                Icons.nightlight_round),

            const SizedBox(height: 20),

            _sectionTitle("Micro Habits"),
            const SizedBox(height: 10),

            ...aiPlan["microHabits"].map<Widget>((h) {
              return ListTile(
                  leading: const Icon(Icons.check_circle,
                      color: Colors.deepPurple),
                  title: Text(h));
            }).toList(),

            const SizedBox(height: 20),

            _sectionTitle("Weekly Goal Progress"),
            const SizedBox(height: 10),
            _weeklyGoalChart(),

            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}
