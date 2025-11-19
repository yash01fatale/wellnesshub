import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DiseaseRiskScreen extends StatefulWidget {
  const DiseaseRiskScreen({super.key});

  @override
  State<DiseaseRiskScreen> createState() => _DiseaseRiskScreenState();
}

class _DiseaseRiskScreenState extends State<DiseaseRiskScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;
  late Animation<double> _fade;

  // Mock risk values (0–1) — replace with ML output later
  double heartRisk = 0.42;
  double diabetesRisk = 0.27;
  double obesityRisk = 0.33;
  double stressRisk = 0.55;

  double bmi = 23.4;
  double sleepDebt = 1.2; // hours below ideal
  int steps = 6542;
  double nutritionScore = 0.71;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    _anim.forward();
  }

  Future<void> _runPrediction() async {
    setState(() {
      // TODO: Call your ML API or TFLite model
      // Replace mock values with actual predictions
      heartRisk = 0.38;
      diabetesRisk = 0.31;
      obesityRisk = 0.28;
      stressRisk = 0.62;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("AI prediction updated.")),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Widget _riskRing(String title, double value, Color color) {
    return SizedBox(
      width: 150,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: 8,
                    color: color,
                  ),
                ),
                Text("${(value * 100).round()}%",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))
              ],
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }

  Widget _lifestyleCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Lifestyle Indicators",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _smallTile("BMI", bmi.toStringAsFixed(1), Icons.monitor_weight),
              _smallTile("Sleep Debt", "${sleepDebt}h", Icons.bedtime),
              _smallTile("Daily Steps", "$steps", Icons.directions_walk),
              _smallTile("Nutrition", "${(nutritionScore * 100).round()}%",
                  Icons.restaurant),
            ],
          )
        ]),
      ),
    );
  }

  Widget _smallTile(String title, String value, IconData icon) {
    return Column(
      children: [
        CircleAvatar(
          backgroundColor: Colors.deepPurple.shade50,
          child: Icon(icon, color: Colors.deepPurple),
        ),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
      ],
    );
  }

  Widget _riskInsightCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: const [
              Icon(Icons.health_and_safety, color: Colors.deepPurple),
              SizedBox(width: 8),
              Text("AI Health Insights",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          const Text("• Your stress-related risk is slightly elevated today."),
          const Text("• Consider 10 min of breathing exercises."),
          const Text("• Sleep recovery is improving."),
          const Text("• Your nutrition score is above average."),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("View Personalized Plan"),
          )
        ]),
      ),
    );
  }

  Widget _chartCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("7-Day Risk Trend",
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          SizedBox(
            height: 160,
            child: LineChart(LineChartData(
              minY: 0,
              maxY: 1,
              gridData: FlGridData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(),
                topTitles: AxisTitles(),
                rightTitles: AxisTitles(),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = [
                          "Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"
                        ];
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(days[v.toInt()],
                              style: const TextStyle(fontSize: 11)),
                        );
                      }),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                    isCurved: true,
                    color: Colors.deepPurple,
                    belowBarData: BarAreaData(
                        show: true,
                        color: Colors.deepPurple.withOpacity(0.15)),
                    spots: const [
                      FlSpot(0, 0.30),
                      FlSpot(1, 0.35),
                      FlSpot(2, 0.33),
                      FlSpot(3, 0.38),
                      FlSpot(4, 0.41),
                      FlSpot(5, 0.39),
                      FlSpot(6, 0.42),
                    ])
              ],
            )),
          ),
        ]),
      ),
    );
  }

  Widget _preventCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Preventive Actions",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          const Text("• 20 min brisk walk\n• High-fiber breakfast\n• 8 glasses of water\n• 10 min meditation\n• Reduce sugar intake"),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
            child: const Text("Get Detailed AI Plan"),
          )
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Disease Risk"),
        backgroundColor: Colors.deepPurple,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _runPrediction,
        label: const Text("Run Prediction"),
        icon: const Icon(Icons.insights),
        backgroundColor: Colors.deepPurple,
      ),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                _riskRing("Heart Risk", heartRisk, Colors.red),
                _riskRing("Diabetes Risk", diabetesRisk, Colors.orange),
                _riskRing("Obesity Risk", obesityRisk, Colors.teal),
                _riskRing("Stress Risk", stressRisk, Colors.indigo),
              ],
            ),
            const SizedBox(height: 20),
            _lifestyleCard(),
            const SizedBox(height: 16),
            _riskInsightCard(),
            const SizedBox(height: 16),
            _chartCard(),
            const SizedBox(height: 16),
            _preventCard(),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }
}
