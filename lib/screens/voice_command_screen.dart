import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class VoiceCommandScreen extends StatefulWidget {
  const VoiceCommandScreen({super.key});

  @override
  State<VoiceCommandScreen> createState() => _VoiceCommandScreenState();
}

class _VoiceCommandScreenState extends State<VoiceCommandScreen> {
  bool isListening = false;
  bool showResult = false;
  String userSpeech = "";
  String aiResponse = "";
  Timer? _fakeListenTimer;

  final List<String> demoSuggestions = [
    "Start meditation",
    "Suggest a healthy breakfast",
    "Read affirmations",
    "Start a workout",
    "Help me relax",
    "Start focus mode",
    "How was my sleep?",
    "Reduce my stress"
  ];

  void _startListening() {
    setState(() {
      isListening = true;
      showResult = false;
      userSpeech = "";
      aiResponse = "";
    });

    // Simulate recognition
    _fakeListenTimer = Timer(const Duration(seconds: 3), () {
      setState(() {
        userSpeech = "Start meditation";
        aiResponse = _generateAIResponse(userSpeech);
        showResult = true;
        isListening = false;
      });
    });
  }

  void _stopListening() {
    setState(() => isListening = false);
    _fakeListenTimer?.cancel();
  }

  String _generateAIResponse(String command) {
    final c = command.toLowerCase();

    if (c.contains("meditation")) {
      return "Starting a 5-minute calming meditation for you. 🧘‍♂️";
    }
    if (c.contains("breakfast")) {
      return "Try oats, fruits, and 10g almonds for a high-energy breakfast.";
    }
    if (c.contains("affirm")) {
      return "Here are affirmations: 'I am calm, I am growing, I am capable.'";
    }
    if (c.contains("workout")) {
      return "Starting your personalized strength workout. 💪";
    }
    if (c.contains("sleep")) {
      return "You slept 7h 20m last night — better than yesterday!";
    }
    if (c.contains("focus")) {
      return "Activating Focus Mode. ✨";
    }
    if (c.contains("stress") || c.contains("relax")) {
      return "Take 5 deep breaths… inhale 4 sec, exhale 6 sec. Feel the calm.";
    }

    return "I'm here — ask me about food, workouts, meditation, stress or your goals.";
  }

  @override
  void dispose() {
    _fakeListenTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text("Voice Command Assistant"),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Talk to your AI Coach 🎤",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ask anything about your health, mood, diet, sleep or workouts.",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // LISTENING ANIMATION
            if (isListening) ...[
              Center(
                child: Lottie.asset(
                  "assets/voice_wave.json",
                  height: 200,
                ),
              ),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  "Listening...",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],

            // AI RESPONSE
            if (showResult) _buildResponseCard(),

            const SizedBox(height: 28),

            // MIC BUTTON
            Center(
              child: GestureDetector(
                onTap: () {
                  isListening ? _stopListening() : _startListening();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 90,
                  width: 90,
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                    boxShadow: isListening
                        ? [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.5),
                              blurRadius: 20,
                              spreadRadius: 4,
                            )
                          ]
                        : [],
                  ),
                  child: Icon(
                    isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 42,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),
            _buildSuggestions(),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("You said:", style: TextStyle(fontSize: 13, color: Colors.black54)),
            Text(
              userSpeech,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text("AI Response", style: TextStyle(fontSize: 13, color: Colors.black54)),
            Text(
              aiResponse,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.deepPurple),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Try saying:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: demoSuggestions.map((s) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(s, style: const TextStyle(color: Colors.deepPurple)),
            );
          }).toList(),
        )
      ],
    );
  }
}
