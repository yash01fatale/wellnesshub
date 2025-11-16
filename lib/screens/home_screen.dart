// lib/screens/home_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Import other screens used for navigation.
// Make sure these files exist in lib/screens/.
import 'dashboard_screen.dart';
import 'nutrition_screen.dart';
import 'fitness_screen.dart';
import 'sleep_screen.dart';
import 'mental_screen.dart';
import 'spirituality_screen.dart';
import 'habits_screen.dart';
import 'daily_stats_screen.dart';
import 'ai_chat_screen.dart';
import 'profile_screen.dart';
import 'focus_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String displayName = "User";
  bool loading = true;

  // Mock / default values - will be loaded from Firestore when available
  int steps = 6542;
  String heartRate = "78";
  int calories = 1850;
  String sleep = "7h 20m";
  String mood = "Calm";
  int habitStreak = 3;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => loading = false);
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          displayName = (data['name'] as String?) ?? displayName;
          steps = (data['today_steps'] as int?) ?? steps;
          heartRate = (data['heart_rate']?.toString()) ?? heartRate;
          calories = (data['calories'] as int?) ?? calories;
          sleep = (data['sleep'] as String?) ?? sleep;
          mood = (data['mood'] as String?) ?? mood;
          habitStreak = (data['habit_streak'] as int?) ?? habitStreak;
        });
      }
    } catch (e) {
      // ignore: print for debug
      // print('Failed to load profile: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    // After sign out, you probably have an AuthWrapper in main to redirect.
    // If not, push to LoginScreen using Navigator.
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Row(
          children: [
            CircleAvatar(backgroundColor: color.withOpacity(0.12), child: Icon(icon, color: color)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(fontSize: 12, color: Colors.black54)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ])
          ],
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label, Widget destination) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => destination)),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: SizedBox(
          width: 110,
          height: 110,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 34, color: Theme.of(context).primaryColor),
              const SizedBox(height: 12),
              Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13)),
            ]),
          ),
        ),
      ),
    );
  }

  // Small helper: build an elevated gradient header
  Widget _buildHeader(BuildContext ctx) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(children: [
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(
              _getGreeting() + ", $displayName",
              style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text("Here's your wellbeing snapshot", style: TextStyle(color: Colors.white.withOpacity(0.9))),
          ]),
        ),
  
       
      ]),
    );
  }

  Widget _aiAssistantCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("AI Wellness Assistant", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 6),
              const Text("Ask about sleep routines, diet tweaks, short meditations or focus tips."),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text("Chat with AI"),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    // Quick suggestion: open AI chat with sample prompt - for now go to AI screen
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen()));
                  },
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text("Suggestions"),
                ),
              ])
            ]),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [Colors.deepPurple.shade100, Colors.deepPurple.shade50]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.smart_toy, color: Colors.deepPurple, size: 40),
          )
        ]),
      ),
    );
  }

  Widget _personalInsightsCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: const [
            Icon(Icons.insights_outlined, color: Colors.deepPurple),
            SizedBox(width: 8),
            Text('Personalized Insights', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          const SizedBox(height: 10),
          const Text('• Sleep slightly below 8h average this week.\n• Short walk after lunch improves digestion.\n• Try evening wind-down routine before 11 PM.'),
          const SizedBox(height: 12),
          Row(children: [
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NutritionScreen())), child: const Text('Improve diet')),
            const Spacer(),
            TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SleepScreen())), child: const Text('Sleep tips')),
          ])
        ]),
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('WellnessHub'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Profile',
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: _logout,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: LayoutBuilder(builder: (context, constraints) {
                final width = constraints.maxWidth;
                final isWide = width > 800;
                // compute grid columns for quick actions
                final quickCols = isWide ? 4 : (width > 500 ? 3 : 2);

                return SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    _buildHeader(context),

                    const SizedBox(height: 16),

                    // Top vitals row (responsive)
                    isWide
                        ? Row(children: [
                            Expanded(child: _statCard('Heart Rate', '$heartRate bpm', Icons.favorite, Colors.redAccent)),
                            const SizedBox(width: 12),
                            Expanded(child: _statCard('Steps', steps.toString(), Icons.directions_walk, Colors.orange)),
                            const SizedBox(width: 12),
                            Expanded(child: _statCard('Calories', '$calories kcal', Icons.local_fire_department, Colors.teal)),
                            const SizedBox(width: 12),
                            Expanded(child: _statCard('Sleep', sleep, Icons.bedtime, Colors.indigo)),
                          ])
                        : Column(children: [
                            Row(children: [
                              Expanded(child: _statCard('Heart Rate', '$heartRate bpm', Icons.favorite, Colors.redAccent)),
                              const SizedBox(width: 12),
                              Expanded(child: _statCard('Steps', steps.toString(), Icons.directions_walk, Colors.orange)),
                            ]),
                            const SizedBox(height: 12),
                            Row(children: [
                              Expanded(child: _statCard('Calories', '$calories kcal', Icons.local_fire_department, Colors.teal)),
                              const SizedBox(width: 12),
                              Expanded(child: _statCard('Sleep', sleep, Icons.bedtime, Colors.indigo)),
                            ]),
                          ]),

                    const SizedBox(height: 14),

                    // Mood and streaks row
                    Row(children: [
                      Expanded(
                        flex: 2,
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(children: [
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  Text(mood, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 8),
                                  const Text('Quick tips: Hydrate • 10 min walk • 5 min breathing')
                                ]),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton(
                                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AIChatScreen())),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                                child: const Text('Ask AI'),
                              ),
                            ]),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(children: [
                              const Text('Habit Streak', style: TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(height: 8),
                              Text('$habitStreak', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 6),
                              Text('days', style: TextStyle(color: Colors.grey[600])),
                            ]),
                          ),
                        ),
                      )
                    ]),

                    const SizedBox(height: 16),

                    // AI Assistant
                    _aiAssistantCard(),

                    const SizedBox(height: 14),

                    // Quick actions grid (responsive)
                    const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _quickAction(Icons.restaurant, 'Nutrition', const NutritionScreen()),
                        _quickAction(Icons.fitness_center, 'Fitness', const FitnessScreen()),
                        _quickAction(Icons.bedtime, 'Sleep', const SleepScreen()),
                        _quickAction(Icons.psychology, 'Mental', const MentalScreen()),
                        _quickAction(Icons.spa, 'Spiritual', const SpiritualityScreen()),
                        _quickAction(Icons.track_changes, 'Habits', const HabitsScreen()),
                        _quickAction(Icons.bar_chart, 'Today', const DailyStatsScreen()),
                        _quickAction(Icons.dashboard_customize, 'Dashboard', const DashboardScreen()),
                        _quickAction(Icons.timelapse, 'Focus Mode', const FocusScreen()), // use Focus screen later
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Personalized insights / suggestions
                    _personalInsightsCard(),

                    const SizedBox(height: 20),

                    // Footer / motivational quote
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Text('Daily Motivation', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(
                            '“Small consistent steps are better than occasional big leaps.” — Keep going!',
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ]),
                );
              }),
            ),
    );
  }
}
