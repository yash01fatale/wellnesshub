import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HabitsScreen extends StatelessWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Habits"),
        backgroundColor: Colors.deepPurple,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('habit_logs')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No habits yet. Add one!"));
          }

          final docs = snapshot.data!.docs;
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index].data() as Map<String, dynamic>;
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: Icon(
                    data['completed'] ? Icons.check_circle : Icons.circle_outlined,
                    color: data['completed'] ? Colors.green : Colors.grey,
                  ),
                  title: Text(
                    data['habit_name'] ?? "Unnamed Habit",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text("Streak: ${data['streak'] ?? 0}"),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.add),
        onPressed: () => _addHabit(context),
      ),
    );
  }

  void _addHabit(BuildContext context) {
    final habitController = TextEditingController();
    final userId = FirebaseAuth.instance.currentUser?.uid;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Habit"),
        content: TextField(
          controller: habitController,
          decoration: const InputDecoration(labelText: "Habit Name"),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final habit = habitController.text.trim();
              if (habit.isEmpty) return;

              await FirebaseFirestore.instance
                  .collection('users')
                  .doc(userId)
                  .collection('habit_logs')
                  .add({
                'habit_name': habit,
                'streak': 0,
                'completed': false,
                'timestamp': Timestamp.now(),
              });

              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
