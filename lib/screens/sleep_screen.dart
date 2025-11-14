import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class SleepScreen extends StatefulWidget {
  const SleepScreen({super.key});

  @override
  State<SleepScreen> createState() => _SleepScreenState();
}

class _SleepScreenState extends State<SleepScreen> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  String currentSound = "";

  String selectedRoutine = "Bedtime Routine";

  final List<String> routines = [
    "Bedtime Routine",
    "Sleep Recovery",
    "Sleep Optimization",
  ];

  final Map<String, List<String>> aiTips = {
    "Bedtime Routine": [
      "Dim your lights 1 hour before bed to trigger melatonin.",
      "Avoid phone or TV 30 minutes before sleeping.",
      "Practice 5 minutes of slow breathing.",
      "Maintain consistent sleep time between 10–11 PM."
    ],
    "Sleep Recovery": [
      "Take a short nap if you feel fatigued during the day.",
      "Avoid heavy meals and caffeine after 7 PM.",
      "Hydrate well — lack of water impacts deep sleep.",
      "Try light stretching before going to bed."
    ],
    "Sleep Optimization": [
      "Keep your bedroom cool (18–20°C).",
      "Block noise and light distractions.",
      "Follow your natural sleep-wake rhythm daily.",
      "Avoid screens in bed; read a book instead."
    ],
  };

  final List<Map<String, dynamic>> cantSleepOptions = [
    {
      "icon": Icons.music_note_rounded,
      "title": "Listen to Calm Music",
      "description": "Play soothing nature or sleep sounds."
    },
    {
      "icon": Icons.menu_book_rounded,
      "title": "Read a Peaceful Book",
      "description": "Read something inspiring or light."
    },
    {
      "icon": Icons.self_improvement_rounded,
      "title": "Try Meditation",
      "description": "Focus on your breath for 5 minutes."
    },
    {
      "icon": Icons.note_alt_outlined,
      "title": "Write Down Thoughts",
      "description": "Journaling helps release mental stress."
    },
  ];

  Future<void> _toggleSound(String soundFile) async {
    if (isPlaying && currentSound == soundFile) {
      await _audioPlayer.stop();
      setState(() {
        isPlaying = false;
        currentSound = "";
      });
    } else {
      await _audioPlayer.play(AssetSource('sounds/$soundFile'));
      setState(() {
        isPlaying = true;
        currentSound = soundFile;
      });
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sleep AI Companion 😴"),
        backgroundColor: Colors.deepPurple,
        elevation: 4,
      ),
      backgroundColor: const Color(0xFFF6F5FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient Header
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C4DFF), Color(0xFF9575CD)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.shade200,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "💤 Smart Sleep Optimization",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Your AI companion for better rest and recovery.",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sleep Stats
            _buildStatsCard(),

            const SizedBox(height: 20),

            // AI Routine Section
            Text(
              "🧠 AI-Based Routine Guidance",
              style: TextStyle(
                  fontSize: 18,
                  color: Colors.deepPurple[800],
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            _buildDropdown(),

            const SizedBox(height: 12),

            ...aiTips[selectedRoutine]!
                .map(
                  (tip) => Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lightbulb_outline,
                            color: Colors.deepPurple),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                ,

            const SizedBox(height: 25),

            // Can't Sleep Section
            Text(
              "🌙 Can't Fall Asleep?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.indigo[900],
              ),
            ),
            const SizedBox(height: 10),
            ...cantSleepOptions.map((option) {
              return Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Icon(option["icon"], color: Colors.deepPurple),
                  title: Text(option["title"]),
                  subtitle: Text(option["description"]),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded,
                      size: 18, color: Colors.grey),
                  onTap: option["title"] == "Listen to Calm Music"
                      ? () => _openMusicBottomSheet()
                      : () {},
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Text(
              "Last Night's Sleep Summary",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStat("7h 40m", "Duration"),
                _buildStat("88%", "Quality"),
                _buildStat("10:45 PM", "Bedtime"),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
              fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
        ),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedRoutine,
          isExpanded: true,
          items: routines
              .map(
                (r) => DropdownMenuItem(
                  value: r,
                  child: Text(r),
                ),
              )
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedRoutine = value!;
            });
          },
        ),
      ),
    );
  }

  void _openMusicBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("🎵 Sleep Sounds",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple)),
            const SizedBox(height: 15),
            _buildMusicTile("Rain Sounds", "rain.mp3"),
            _buildMusicTile("Ocean Waves", "waves.mp3"),
            _buildMusicTile("Forest Night", "forest.mp3"),
            _buildMusicTile("Wind Chimes", "wind.mp3"),
          ],
        ),
      ),
    );
  }

  Widget _buildMusicTile(String title, String fileName) {
    bool isCurrent = currentSound == fileName && isPlaying;
    return ListTile(
      leading: Icon(
        isCurrent ? Icons.pause_circle_filled : Icons.play_circle_fill,
        color: Colors.deepPurple,
        size: 32,
      ),
      title: Text(title),
      onTap: () => _toggleSound(fileName),
    );
  }
}
