// lib/screens/addiction_recovery_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/services.dart'; // for clipboard
import 'focus_screen.dart';
import 'ai_chat_screen.dart';

class AddictionRecoveryScreen extends StatefulWidget {
  const AddictionRecoveryScreen({super.key});

  @override
  State<AddictionRecoveryScreen> createState() => _AddictionRecoveryScreenState();
}

class _AddictionRecoveryScreenState extends State<AddictionRecoveryScreen> {
  // Mock user values (replace with Firestore later)
  int streakDays = 3;
  double cravingLevel = 0.3; // 0 to 1
  String selectedHabit = "Smoking";

  final List<String> habits = ["Smoking", "Alcohol", "Junk Food", "Phone Addiction"];

  // tasks with simple completion flag (kept in-memory)
  final List<Map<String, dynamic>> _tasks = [
    {"title": "Drink 1 glass of water", "done": false},
    {"title": "Take 10 deep breaths", "done": false},
    {"title": "Go for a 5-min walk", "done": false},
    {"title": "Write how you feel", "done": false},
  ];

  // quick notes for the session (in-memory)
  final List<String> _notes = [];

  // Daily tips (static)
  final List<String> dailyTips = [
    "Delay the urge for 5 minutes — often the craving eases.",
    "Chew gum or sip water when you feel a craving.",
    "Replace the habit with a short walk or breathing exercise.",
    "Notify a friend or accountability partner when tempted."
  ];

  void _updateCraving() {
    setState(() {
      cravingLevel = (cravingLevel + 0.2).clamp(0.0, 1.0);
    });
    _showCravingFeedback();
  }

  void _reduceCraving() {
    setState(() {
      cravingLevel = (cravingLevel - 0.25).clamp(0.0, 1.0);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Breathing exercise started — breathe slowly for 1 minute.')),
    );
  }

  void _showCravingFeedback() {
    final pct = (cravingLevel * 100).round();
    if (cravingLevel >= 0.8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Craving high ($pct%). Try a short breathing or call support.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Craving recorded ($pct%). You can use a calming tool below.')),
      );
    }
  }

  void _toggleTask(int idx) {
    setState(() {
      _tasks[idx]['done'] = !(_tasks[idx]['done'] as bool);
    });
  }

  Future<void> _openBreathing() async {
    // Navigate to FocusScreen (pomodoro/breathing). If not present, show fallback dialog.
    try {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const FocusScreen()));
    } catch (_) {
      showDialog(
        context: context,
        builder: (_) => const AlertDialog(
          title: Text('Breathing'),
          content: Text('Start a 3-minute breathing exercise: Inhale 4s • Hold 7s • Exhale 8s.'),
        ),
      );
    }
  }

  void _openRelaxMusic() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SizedBox(
        height: 220,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(children: [
            const Text('Relax Music', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            const Text('This is a placeholder for ambient playlists. Integrate audio player or stream here.'),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Playing mock ambient music')));
              },
              child: const Text('Play (mock)'),
            )
          ]),
        ),
      ),
    );
  }

  void _openReadTips() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Recovery Tips'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemBuilder: (_, i) => Text('• ${dailyTips[i]}'),
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemCount: dailyTips.length,
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen()));
            },
            child: const Text('Ask AI Coach'),
          ),
        ],
      ),
    );
  }

  Future<void> _openSupport() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Support & Hotline'),
        content: const Text(
            'If you are in immediate danger or need urgent help contact local emergency services.\n\nFor peer support, call: +1-800-XXX-XXXX (mock sample).'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
          TextButton(
            onPressed: () {
              Clipboard.setData(const ClipboardData(text: '+1-800-XXX-XXXX'));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Support number copied to clipboard')));
            },
            child: const Text('Copy Number'),
          ),
        ],
      ),
    );
  }

  Future<void> _addNote() async {
    final controller = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Quick Journal'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Write how you feel...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isNotEmpty) {
                setState(() => _notes.insert(0, '${DateTime.now().toLocal().toString().split(".").first} — $text'));
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _lottieOrFallback(double height) {
    // Try to show Lottie asset; if it fails (asset missing) show a simple icon
    try {
      return Lottie.asset(
        'assets/heal.json',
        height: height,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          // fallback
          return Icon(Icons.volunteer_activism, size: height, color: Colors.deepPurple);
        },
      );
    } catch (_) {
      return Icon(Icons.volunteer_activism, size: height, color: Colors.deepPurple);
    }
  }

  @override
  Widget build(BuildContext context) {
    // adapt sizes
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 720;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Addiction Recovery'),
        backgroundColor: Colors.deepPurple,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // heading
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
            Text("You're not alone 💛", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Text("Small steps every day lead to big transformations.", style: TextStyle(fontSize: 14, color: Colors.black54)),
          ]),
          const SizedBox(height: 16),

          // selector
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("What are you healing from?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: habits.map((h) {
                    final selected = selectedHabit == h;
                    return ChoiceChip(
                      label: Text(h),
                      selected: selected,
                      selectedColor: Colors.deepPurple.shade50,
                      onSelected: (_) => setState(() => selectedHabit = h),
                    );
                  }).toList(),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // streak + lottie
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(children: [
                _lottieOrFallback(90),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text("Your Healing Streak", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text("$streakDays days", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    const Text("Stay consistent. You're doing great!", style: TextStyle(color: Colors.black54)),
                    const SizedBox(height: 8),
                    Row(children: [
                      OutlinedButton.icon(
                        onPressed: () => setState(() => streakDays++),
                        icon: const Icon(Icons.add),
                        label: const Text('Add Day'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => setState(() => streakDays = (streakDays - 1).clamp(0, 999)),
                        child: const Text('Undo'),
                      )
                    ])
                  ]),
                ),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // craving
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text("Craving Level", style: TextStyle(fontWeight: FontWeight.bold)),
                  const Text("Tap if you're craving", style: TextStyle(color: Colors.black54)),
                ]),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: cravingLevel,
                  minHeight: 12,
                  color: Colors.deepPurple,
                  backgroundColor: Colors.deepPurple.shade100,
                ),
                const SizedBox(height: 12),
                Row(children: [
                  ElevatedButton.icon(
                    onPressed: _updateCraving,
                    icon: const Icon(Icons.warning),
                    label: const Text("I'm Craving"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _reduceCraving,
                    icon: const Icon(Icons.spa),
                    label: const Text("Calm Me"),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton.icon(
                    onPressed: () => _openBreathing(),
                    icon: const Icon(Icons.bedtime),
                    label: const Text("Breath"),
                  ),
                ])
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // tasks
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Today's Recovery Tasks", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ..._tasks.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final t = entry.value;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Checkbox(
                      value: t["done"] as bool,
                      onChanged: (_) => _toggleTask(idx),
                    ),
                    title: Text(t["title"] as String,
                        style: TextStyle(decoration: (t["done"] as bool) ? TextDecoration.lineThrough : null)),
                  );
                }).toList(),
                const SizedBox(height: 8),
                Row(children: [
                  ElevatedButton.icon(
                      onPressed: () => setState(() => _tasks.add({"title": "New small task", "done": false})),
                      icon: const Icon(Icons.add),
                      label: const Text('Add')),
                  const SizedBox(width: 12),
                  TextButton(onPressed: _addNote, child: const Text('Quick Journal')),
                ])
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // quick help
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Instant Relief Tools", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(spacing: 12, runSpacing: 12, children: [
                  _quickHelpButton(Icons.self_improvement, "Breathing", _openBreathing),
                  _quickHelpButton(Icons.music_note, "Relax Music", _openRelaxMusic),
                  _quickHelpButton(Icons.book, "Read Tips", _openReadTips),
                  _quickHelpButton(Icons.call, "Support", _openSupport),
                ]),
              ]),
            ),
          ),

          const SizedBox(height: 16),

          // notes preview
          if (_notes.isNotEmpty)
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 1,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text("Recent Notes", style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ..._notes.take(5).map((n) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Text(n))),
                ]),
              ),
            ),

          const SizedBox(height: 16),

          // motivation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(color: Colors.deepPurple, borderRadius: BorderRadius.circular(14)),
            child: const Text(
              "\"Healing is not a straight line. Even tiny progress counts.\"",
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }

  Widget _quickHelpButton(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Colors.deepPurple.shade50, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [Icon(icon, color: Colors.deepPurple), const SizedBox(width: 8), Text(label)]),
      ),
    );
  }
}
