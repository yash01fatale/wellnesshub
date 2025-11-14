import 'package:flutter/material.dart';

class SpiritualityScreen extends StatelessWidget {
  const SpiritualityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.purple.shade50,
      appBar: AppBar(
        backgroundColor: Colors.purple,
        title: const Text('Spiritual Wellness'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.self_improvement, size: 100, color: Colors.purple),
            const SizedBox(height: 20),
            const Text(
              "Find your inner peace ✨",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Reflect, meditate, and grow.",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
