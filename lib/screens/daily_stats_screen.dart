import 'package:flutter/material.dart';
import '../services/stats_service.dart';

class DailyStatsScreen extends StatefulWidget {
  const DailyStatsScreen({super.key});
  @override
  State<DailyStatsScreen> createState() => _DailyStatsScreenState();
}

class _DailyStatsScreenState extends State<DailyStatsScreen> {
  final StatsService _svc = StatsService();
  int steps = 0;
  int calories = 0;
  int sleepMinutes = 0;
  int waterMl = 0;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final doc = await _svc.getDailyStats();
    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        steps = data['steps'] ?? 0;
        calories = data['calories'] ?? 0;
        sleepMinutes = data['sleepMinutes'] ?? 0;
        waterMl = data['waterMl'] ?? 0;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await _svc.setDailyStats({
      'steps': steps,
      'calories': calories,
      'sleepMinutes': sleepMinutes,
      'waterMl': waterMl,
    });
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Today\'s Stats')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          _numberTile('Steps', steps, (v) => setState(() => steps = v)),
          _numberTile('Calories', calories, (v) => setState(() => calories = v)),
          _numberTile('Sleep (min)', sleepMinutes, (v) => setState(() => sleepMinutes = v)),
          _numberTile('Water (ml)', waterMl, (v) => setState(() => waterMl = v)),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: _saving ? null : _save, child: _saving ? const CircularProgressIndicator() : const Text('Save'))
        ]),
      ),
    );
  }

  Widget _numberTile(String label, int value, void Function(int) onChanged) {
    return ListTile(
      title: Text(label),
      trailing: SizedBox(
        width: 150,
        child: Row(children: [
          IconButton(onPressed: () => onChanged((value - 1).clamp(0, 99999)), icon: const Icon(Icons.remove)),
          Expanded(child: Text(value.toString(), textAlign: TextAlign.center)),
          IconButton(onPressed: () => onChanged((value + 1).clamp(0, 99999)), icon: const Icon(Icons.add)),
        ]),
      ),
    );
  }
}
