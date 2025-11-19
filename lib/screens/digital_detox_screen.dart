import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DigitalDetoxScreen extends StatefulWidget {
  const DigitalDetoxScreen({super.key});

  @override
  State<DigitalDetoxScreen> createState() => _DigitalDetoxScreenState();
}

class _DigitalDetoxScreenState extends State<DigitalDetoxScreen> {
  // Mock values (replace with real usage stats later)
  int screenMinutesToday = 214;
  int notificationsToday = 89;
  bool blockApps = false;
  bool blockNotifications = false;

  List<int> weeklyUsage = [120, 150, 180, 200, 140, 210, 170];

  List<String> detoxGoals = [
    "Avoid phone 30 min after waking up",
    "No social media during meals",
    "Put phone away 1 hour before bed",
    "Take a 10-minute digital break every 2 hours",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: const Text("Digital Detox"),
        backgroundColor: Colors.deepPurple,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _screenTimeCard(),
            const SizedBox(height: 16),
            _quickTimerSection(),
            const SizedBox(height: 16),
            _controlSwitches(),
            const SizedBox(height: 16),
            _weeklyChart(),
            const SizedBox(height: 16),
            _goalsCard(),
            const SizedBox(height: 16),
            _aiTipCard(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ------------------------- SCREEN TIME CARD -------------------------
  Widget _screenTimeCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 32,
              backgroundColor: Colors.deepPurple.shade50,
              child: const Icon(Icons.phone_iphone, color: Colors.deepPurple, size: 32),
            ),
            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Screen Time Today", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("${(screenMinutesToday ~/ 60)}h ${(screenMinutesToday % 60)}m",
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text("Notifications: $notificationsToday"),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  // ------------------------- QUICK TIMER -------------------------
  Widget _quickTimerSection() {
    List<int> times = [10, 20, 30];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Quick Focus Timers", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 14),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: times.map((t) {
              return ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("$t-minute focus timer started (mock)."))
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                child: Text("$t min"),
              );
            }).toList(),
          ),
        ]),
      ),
    );
  }

  // ------------------------- SWITCH CONTROLS -------------------------
  Widget _controlSwitches() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          SwitchListTile(
            value: blockApps,
            onChanged: (v) => setState(() => blockApps = v),
            title: const Text("Block distracting apps (mock)"),
            secondary: const Icon(Icons.block),
          ),
          SwitchListTile(
            value: blockNotifications,
            onChanged: (v) => setState(() => blockNotifications = v),
            title: const Text("Mute notifications (mock)"),
            secondary: const Icon(Icons.notifications_off),
          ),
        ]),
      ),
    );
  }

  // ------------------------- WEEKLY CHART -------------------------
  Widget _weeklyChart() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Weekly Screen Usage", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                barGroups: _buildBarGroups(),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(),
                  rightTitles: AxisTitles(),
                  topTitles: AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                        return Text(days[v.toInt()], style: const TextStyle(fontSize: 12));
                      },
                    ),
                  ),
                ),
              ),
            ),
          )
        ]),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(weeklyUsage.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyUsage[index].toDouble(),
            color: Colors.deepPurple,
            width: 14,
            borderRadius: BorderRadius.circular(6),
          )
        ],
      );
    });
  }

  // ------------------------- DAILY GOALS -------------------------
  Widget _goalsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Daily Detox Goals", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),

          ...detoxGoals.map((g) => ListTile(
            leading: const Icon(Icons.check_circle_outline, color: Colors.deepPurple),
            title: Text(g),
          )),
        ]),
      ),
    );
  }

  // ------------------------- AI TIP -------------------------
  Widget _aiTipCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
            colors: [Colors.deepPurple, Colors.purpleAccent]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: const Text(
        "\"Every moment offline is a moment for your mind to breathe. Create space for clarity.\"",
        style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
        textAlign: TextAlign.center,
      ),
    );
  }
}
