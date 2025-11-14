import 'package:flutter/material.dart';

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});
  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final _controller = TextEditingController();
  final _messages = <_Msg>[];

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.insert(0, _Msg(text, true));
      _messages.insert(0, _Msg(_replyTo(text), false));
      _controller.clear();
    });
  }

  String _replyTo(String q) {
    final ql = q.toLowerCase();
    if (ql.contains('sleep')) return 'Try a consistent bedtime; reduce screens 30 min before bed.';
    if (ql.contains('diet') || ql.contains('food') || ql.contains('calorie')) return 'Include protein and fiber — balance carbs and veggies.';
    if (ql.contains('workout') || ql.contains('train')) return 'Mix cardio and strength: 3x strength, 2x cardio weekly.';
    if (ql.contains('anxious') || ql.contains('sad')) return 'Try 5 deep breaths, then write one small step to feel better.';
    return 'I can help with sleep, diet, exercise, or mental wellness. Try asking about one of those.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Health Assistant')),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (ctx, i) {
              final m = _messages[i];
              return Align(
                alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: m.fromUser ? Colors.deepPurple[50] : Colors.deepPurple[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(m.text),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Row(children: [
            Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Ask the assistant...'))),
            IconButton(onPressed: _send, icon: const Icon(Icons.send)),
          ]),
        )
      ]),
    );
  }
}

class _Msg {
  final String text;
  final bool fromUser;
  _Msg(this.text, this.fromUser);
}
