import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/habits_service.dart';

class HabitTrackerScreen extends StatefulWidget {
  const HabitTrackerScreen({super.key});
  @override
  State<HabitTrackerScreen> createState() => _HabitTrackerScreenState();
}

class _HabitTrackerScreenState extends State<HabitTrackerScreen> {
  final HabitsService _svc = HabitsService();
  final _newCtl = TextEditingController();

  @override
  void dispose() {
    _newCtl.dispose();
    super.dispose();
  }

  void _addHabit() async {
    final text = _newCtl.text.trim();
    if (text.isEmpty) return;
    await _svc.addHabit(text);
    _newCtl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Habit Tracker')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextField(controller: _newCtl, decoration: const InputDecoration(hintText: 'New habit'))),
            IconButton(icon: const Icon(Icons.add), onPressed: _addHabit)
          ]),
          const SizedBox(height: 12),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: _svc.streamHabits(),
              builder: (context, snap) {
                if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                final docs = snap.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No habits yet'));
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (ctx, i) {
                    final d = docs[i];
                    final id = d.id;
                    final data = d.data();
                    final completed = data['completedToday'] ?? false;
                    final streak = data['streak'] ?? 0;
                    return ListTile(
                      title: Text(data['title'] ?? ''),
                      subtitle: Text('Streak: $streak days'),
                      leading: CircleAvatar(child: completed ? const Icon(Icons.check) : null),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        ElevatedButton(
                          child: Text(completed ? 'Done' : 'Mark'),
                          onPressed: () => _svc.toggleCompleted(id, !completed),
                        ),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _svc.deleteHabit(id)),
                      ]),
                    );
                  },
                );
              },
            ),
          )
        ]),
      ),
    );
  }
}
